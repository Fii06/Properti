class PropertisController < ApplicationController
  def preview
    tanah  = params[:propertis][:harga_tanah_input].to_i
    bangun = params[:propertis][:harga_bangunan_input].to_i
    dasar  = tanah + bangun

    @rekomendasi = {
      min: (dasar * 0.95).to_i,
      mid: dasar,
      max: (dasar * 1.10).to_i
    }

    # hanya field yang ADA di model
    @properti = Propertis.new(
      alamat: params[:propertis][:alamat],
      luas_tanah: params[:propertis][:luas_tanah],
      luas_bangunan: params[:propertis][:luas_bangunan]
    )

    @images = encode_images(params[:propertis][:images])

    render "pages/services"
  end

  def create
    @properti = Propertis.new(
      alamat: params[:propertis][:alamat],
      luas_tanah: params[:propertis][:luas_tanah],
      luas_bangunan: params[:propertis][:luas_bangunan],
      harga_pasar: params[:harga_final],
      images: encode_images(params[:propertis][:images])
    )

    if @properti.save
      redirect_to listings_path, notice: "Properti berhasil dipublikasikan"
    else
      render "pages/services"
    end
  end

  def show
    @properti = Propertis.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to listings_path, alert: "Properti tidak ditemukan"
  end

  private

  def property_params
    params.require(:propertis).permit(
    :alamat,
    :luas_tanah,
    :luas_bangunan,
    images: []
  )
  end

  def encode_images(files)
    return [] unless files

    files.map do |file|
      Base64.encode64(file.read)
    end
  end
end

