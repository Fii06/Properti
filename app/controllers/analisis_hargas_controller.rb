class AnalisisHargasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_properti

  def index
    @analisis_hargas = @properti.analisis_hargas.desc(:created_at)
  end

  def new
    @analisis = @properti.analisis_hargas.build
  end

  def create
    @analisis = @properti.analisis_hargas.build(analisis_params)
    if @analisis.save
      redirect_to properti_path(@properti), notice: "Analisis harga ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @analisis = @properti.analisis_hargas.find(params[:id])
    @analisis.destroy
    redirect_to properti_path(@properti), notice: "Analisis harga dihapus."
  end

  private

  def set_properti
    @properti = Propertis.find(params[:properti_id])
  end

  def analisis_params
    params.require(:analisis_harga).permit(:harga_rekomendasi, :metode)
  end
end
