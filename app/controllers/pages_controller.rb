class PagesController < ApplicationController
  before_action :load_propertis, only: [:home, :listings]
  before_action :prepare_services_form, only: :services

  def home
    @propertis = @propertis.recent_first
  end

  def listings
    @propertis = @propertis.recent_first
                           .matching_query(params[:q])
                           .within_price(params[:harga_pasar])
  end

  def agents
  end

  def about
  end

  def services
  end

  def blog
    @news = News.desc(:created_at).limit(10)
  end

  def contact
  end

  def faq
  end

  def privacy
  end

  def terms
  end

  def neighborhoods
    Fasilitas.seed_bojongsoang_defaults!

    @selected_category = params[:category].presence
    @available_categories = Fasilitas::KATEGORI
    @fasilitas_scope = Fasilitas.in_bojongsoang_area.ordered
    @fasilitas_scope = @fasilitas_scope.where(kategori: @selected_category) if @selected_category.present?

    @fasilitas_by_category = @fasilitas_scope.group_by(&:kategori)
    @total_fasilitas = @fasilitas_scope.count
    @listing_bojongsoang_count = Propertis.any_of(
      { daerah: /bojongsoang/i },
      { kecamatan: /bojongsoang/i },
      { kelurahan: /bojongsoang/i },
      { alamat: /bojongsoang/i }
    ).count
  end

  private

  def load_propertis
    @propertis = Propertis.all
  end

  def prepare_services_form
    @properti ||= Propertis.new
    @riwayat_hargas ||= [{}]
    @rekomendasi ||= nil
    @analysis_result ||= nil
    @encoded_images ||= []
  end
end
