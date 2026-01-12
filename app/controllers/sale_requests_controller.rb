class SaleRequestsController < ApplicationController
  def create
    @sale = SaleRequest.new(sale_params.except(:images))

    hitung_rekomendasi(@sale)

    if params[:sale_request][:images].present?
      image_ids = []

      params[:sale_request][:images].each do |img|
        grid_file = Mongoid::GridFs.put(
          img.tempfile,
          filename: img.original_filename,
          content_type: img.content_type
        )
        image_ids << grid_file.id
      end

      @sale.image_ids = image_ids
    end

    if @sale.save
      redirect_to services_path, notice: "Properti berhasil dianalisis"
    else
      render "pages/services", status: :unprocessable_entity
    end
  end

  def confirm
    sale = SaleRequest.find(params[:id])

    sale.update(
      harga_final: params[:harga_final].to_i,
      published: true
    )

    redirect_to listings_path, notice: "Properti berhasil dipublikasikan"
  end

  private

  def sale_params
    params.require(:sale_request).permit(
      :alamat, :luas_tanah, :luas_bangunan,
      :harga_tanah_input, :harga_bangunan_input,
      images: []
    )
  end

  def hitung_rekomendasi(sale)
    dasar = sale.harga_tanah_input.to_i + sale.harga_bangunan_input.to_i
    sale.rekomendasi_min = (dasar * 0.95).to_i
    sale.rekomendasi_mid = dasar
    sale.rekomendasi_max = (dasar * 1.10).to_i
  end
end
