class PropertisController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_properti, only: [:show, :edit, :update, :destroy]

  def index
    @propertis = Propertis.desc(:created_at).page(params[:page]).per(12)
  end

  def show
    @riwayat_hargas = @properti.riwayat_hargas.order_by(tanggal: :desc)
    @analisis_hargas = @properti.analisis_hargas.order_by(created_at: :desc)
  end

  def new
    @properti = current_user.propertis.build
    @all_fasilitas = Fasilitas.all
  end

  def create
    @properti = current_user.propertis.build(properti_params)
    if @properti.save
      redirect_to @properti, notice: "Properti berhasil dibuat."
    else
      @all_fasilitas = Fasilitas.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @all_fasilitas = Fasilitas.all
  end

  def update
    if @properti.update(properti_params)
      redirect_to @properti, notice: "Properti berhasil diperbarui."
    else
      @all_fasilitas = Fasilitas.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @properti.destroy
    redirect_to propertis_path, notice: "Properti berhasil dihapus."
  end

  private

  def set_properti
    @properti = Propertis.find(params[:id])
  end

  def properti_params
    params.require(:propertis).permit(:alamat, :latitude, :longitude,
      :luas_tanah, :luas_bangunan, :tahun_pembangunan, :status_kepemilikan,
      :njop, :harga_pasar, :image_url, :deskripsi, fasilitas_ids: [])
  end
end
