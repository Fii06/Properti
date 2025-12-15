class PagesController < ApplicationController
  def home
    @propertis = Propertis.desc(:created_at).limit(6)
    @featured = Propertis.desc(:harga_pasar).limit(3)
  end
end
