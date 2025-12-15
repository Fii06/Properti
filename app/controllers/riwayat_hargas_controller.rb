class RiwayatHargasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_properti

  def index
    @riwayat_hargas = @properti.riwayat_hargas.desc(:tanggal)
  end

  def new
    @riwayat = @properti.riwayat_hargas.build(tanggal: Date.today)
  end

  def create
    @riwayat = @properti.riwayat_hargas.build(riwayat_params)
    if @riwayat.save
      redirect_to properti_path(@properti), notice: "Riwayat harga ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @riwayat = @properti.riwayat_hargas.find(params[:id])
    @riwayat.destroy
    redirect_to properti_path(@properti), notice: "Riwayat harga dihapus."
  end

  private

  def set_properti
    @properti = Propertis.find(params[:properti_id])
  end

  def riwayat_params
    params.require(:riwayat_harga).permit(:harga, :tanggal)
  end
end
