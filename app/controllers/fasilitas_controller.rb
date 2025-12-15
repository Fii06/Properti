class FasilitasController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @fasilitas = Fasilitas.all
  end

  def new
    @fasilitas = Fasilitas.new
  end

  def create
    @fasilitas = Fasilitas.new(fasilitas_params)
    if @fasilitas.save
      redirect_to fasilitas_index_path, notice: "Fasilitas ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @fasilitas = Fasilitas.find(params[:id])
  end

  def update
    @fasilitas = Fasilitas.find(params[:id])
    if @fasilitas.update(fasilitas_params)
      redirect_to fasilitas_index_path, notice: "Fasilitas diperbarui."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fasilitas = Fasilitas.find(params[:id])
    @fasilitas.destroy
    redirect_to fasilitas_index_path, notice: "Fasilitas dihapus."
  end

  private

  def fasilitas_params
    params.require(:fasilitas).permit(:nama)
  end
end
