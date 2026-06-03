require "fileutils"

class PropertisController < ApplicationController
  def preview
    @properti = Propertis.new(property_attributes)
    @riwayat_hargas = normalized_history_params
    @preview_token = SecureRandom.uuid
    @encoded_images = normalized_images

    @properti.images = @encoded_images
    persist_preview_images!

    if validate_service_form
      @analysis_result = PriceEstimatorService.new(@properti, riwayat_hargas: @riwayat_hargas).estimate
      apply_recommendation_to_properti(@analysis_result)
      @rekomendasi = {
        min: @analysis_result[:min],
        mid: @analysis_result[:mid],
        max: @analysis_result[:max]
      }
    else
      @analysis_result = nil
      @rekomendasi = nil
    end

    render "pages/services", status: (@rekomendasi.present? ? :ok : :unprocessable_entity)
  end

  def create
    @properti = Propertis.new(property_attributes)
    @riwayat_hargas = normalized_history_params
    @preview_token = params[:preview_token].presence
    @encoded_images = preview_images_from_token.presence || normalized_images
    @properti.images = @encoded_images

    @analysis_result = PriceEstimatorService.new(@properti, riwayat_hargas: @riwayat_hargas).estimate
    apply_recommendation_to_properti(@analysis_result)
    @rekomendasi = {
      min: @analysis_result[:min],
      mid: @analysis_result[:mid],
      max: @analysis_result[:max]
    }

    chosen_price = params[:harga_final].to_i

    if validate_service_form && chosen_price.positive?
      @properti.harga_pasar = chosen_price

      if @properti.save
        persist_history!
        persist_analysis!
        cleanup_preview_images!
        redirect_to listings_path, notice: "Properti berhasil dipublikasikan"
      else
        render "pages/services", status: :unprocessable_entity
      end
    else
      @properti.errors.add(:harga_pasar, "pilih salah satu harga rekomendasi") unless chosen_price.positive?
      render "pages/services", status: :unprocessable_entity
    end
  end

  def show
    @properti = Propertis.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to listings_path, alert: "Properti tidak ditemukan"
  end

  private

  def property_params
    params.fetch(:propertis, {}).permit(
      :alamat,
      :daerah,
      :kecamatan,
      :kelurahan,
      :latitude,
      :longitude,
      :luas_tanah,
      :luas_bangunan,
      :tahun_pembangunan,
      :status_kepemilikan,
      :njop,
      images: [],
      riwayat_hargas: [:tanggal, :harga]
    )
  end

  def property_attributes
    property_params.to_h.except("images", "riwayat_hargas")
  end

  def normalized_images
    raw_images = Array(property_params[:images]).reject(&:blank?)

    raw_images.map do |image|
      if image.respond_to?(:read)
        encoded_image = Base64.strict_encode64(image.read)
        content_type = normalized_image_content_type(image)

        "data:#{content_type};base64,#{encoded_image}"
      else
        image.to_s
      end
    end
  end

  def persist_preview_images!
    return if @preview_token.blank? || @encoded_images.blank?

    FileUtils.mkdir_p(preview_images_directory)
    File.write(preview_images_path(@preview_token), @encoded_images.join("\n"))
  end

  def preview_images_from_token
    return [] if @preview_token.blank?
    return [] unless File.exist?(preview_images_path(@preview_token))

    File.read(preview_images_path(@preview_token)).split("\n").reject(&:blank?)
  end

  def cleanup_preview_images!
    return if @preview_token.blank?

    File.delete(preview_images_path(@preview_token))
  rescue Errno::ENOENT
    nil
  end

  def preview_images_directory
    Rails.root.join("tmp", "preview_uploads")
  end

  def preview_images_path(token)
    preview_images_directory.join("#{token}.txt")
  end

  def normalized_image_content_type(image)
    content_type = image.content_type.to_s.presence
    extension = File.extname(image.original_filename.to_s).downcase

    return "image/jpeg" if content_type == "image/jpg" || extension == ".jpg"

    content_type || "image/jpeg"
  end

  def normalized_history_params
    raw_items = params.dig(:propertis, :riwayat_hargas)
    items = case raw_items
            when ActionController::Parameters
              raw_items.to_unsafe_h.values
            when Array
              raw_items
            else
              []
            end

    items.filter_map do |item|
      attrs = item.is_a?(ActionController::Parameters) ? item.to_unsafe_h : item
      next if attrs.blank?

      tanggal = attrs["tanggal"] || attrs[:tanggal]
      harga = attrs["harga"] || attrs[:harga]
      next if tanggal.blank? && harga.blank?

      { tanggal: tanggal, harga: harga }
    end
  end

  def validate_service_form
    @properti.valid?
    validate_history_params
    @properti.errors.empty?
  end

  def validate_history_params
    if @riwayat_hargas.empty?
      @properti.errors.add(:base, "isi minimal satu riwayat harga properti")
      return
    end

    @riwayat_hargas.each_with_index do |entry, index|
      @properti.errors.add(:base, "riwayat harga ##{index + 1} harus berisi tanggal") if entry[:tanggal].blank?
      @properti.errors.add(:base, "riwayat harga ##{index + 1} harus berisi harga") if entry[:harga].blank?
      validate_history_date(entry, index)
    end
  end

  def validate_history_date(entry, index)
    return if entry[:tanggal].blank?

    Date.parse(entry[:tanggal].to_s)
  rescue Date::Error
    @properti.errors.add(:base, "riwayat harga ##{index + 1} memiliki tanggal tidak valid")
  end

  def apply_recommendation_to_properti(result)
    @properti.njop = result[:baseline_njop] if @properti.njop.blank? && result[:baseline_njop].to_f.positive?
    @properti.harga_rekomendasi_min = result[:min]
    @properti.harga_rekomendasi_mid = result[:mid]
    @properti.harga_rekomendasi_max = result[:max]
  end

  def persist_history!
    @riwayat_hargas.each do |entry|
      @properti.riwayat_hargas.create!(
        tanggal: Date.parse(entry[:tanggal].to_s),
        harga: entry[:harga]
      )
    end
  end

  def persist_analysis!
    @properti.analisis_hargas.create!(
      harga_rekomendasi: @analysis_result[:mid],
      harga_rekomendasi_min: @analysis_result[:min],
      harga_rekomendasi_mid: @analysis_result[:mid],
      harga_rekomendasi_max: @analysis_result[:max],
      baseline_njop: @analysis_result[:baseline_njop],
      metode: @analysis_result[:method],
      breakdown: @analysis_result[:adjustments].merge(
        "explanation" => @analysis_result[:explanation]
      ),
      input_snapshot: {
        alamat: @properti.alamat,
        daerah: @properti.daerah,
        kecamatan: @properti.kecamatan,
        kelurahan: @properti.kelurahan,
        luas_tanah: @properti.luas_tanah,
        luas_bangunan: @properti.luas_bangunan,
        tahun_pembangunan: @properti.tahun_pembangunan,
        status_kepemilikan: @properti.status_kepemilikan,
        riwayat_hargas: @riwayat_hargas
      }
    )
  end
end
