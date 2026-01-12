require 'httparty'
require 'nokogiri'

class PagesController < ApplicationController
  before_action :load_propertis, only: [:home, :listings]
  before_action :load_properti, only: [:listing_detail]

  def home
    @propertis = Propertis.order_by(created_at: :desc)
  end

  def listings
    @propertis = Propertis.all

    # SEARCH
    if params[:q].present?
      keyword = /#{Regexp.escape(params[:q])}/i
      @propertis = @propertis.where(
        "$or" => [
          { alamat: keyword },
          { daerah: keyword }
        ]
      )
    end

    # FILTER HARGA MAKS
    if params[:harga_pasar].present?
      @propertis = @propertis.where(:harga_pasar.lte => params[:harga_pasar].to_id)
      # @propertis = SaleRequest.where(published: true).order(created_at: :desc)
    end
    
  end

  def listing_detail
    @propertis = Propertis.find(params[:id])
  end

  def agents
  end

  def about
  end

  def services
    @properti = Propertis.new
  end

  def blog
    @news = News.desc(:created_at).limit(10)
  end

  # def blog
  #   scrape_kompas_properti_articles
  #   @news = News.desc(:created_at).limit(10)
  # end

  # private

  # def scrape_kompas_properti_articles
  #   # kita selalu scrape list URL dulu
  #   listing_url = "https://properti.kompas.com/listing-properti"

  #   response = HTTParty.get(listing_url, headers: { "User-Agent" => "Mozilla/5.0" })
  #   doc = Nokogiri::HTML(response.body)

  #   article_links = doc.css("div.article__list h3 a").map { |a| a["href"] }.uniq.first(10)

  #   article_links.each do |article_url|
  #     next if News.where(url: article_url).exists?

  #     article_resp = HTTParty.get(article_url, headers: { "User-Agent" => "Mozilla/5.0" })
  #     article_doc  = Nokogiri::HTML(article_resp.body)

  #     title = article_doc.at_css("h1.read__title")&.text&.strip
  #     date  = article_doc.at_css("div.read__time")&.text&.strip

  #     image_el = article_doc.at_css("div.read__content img")
  #     image = image_el ? image_el["src"] : nil

  #     content_paragraphs = article_doc.css("div.read__content p").map(&:text)
  #     content_text = content_paragraphs.join("\n\n")

  #     News.create!(
  #       title: title.presence || "No Title",
  #       url: article_url,
  #       image: image,
  #       excerpt: content_text.truncate(200),
  #       content: content_text,
  #       posted_at: date,
  #       source: "Kompas Properti"
  #     )
  #   rescue StandardError => e
  #     Rails.logger.error "Error scraping article: #{article_url} - #{e.message}"
  #   end
  # end

  def contact
  end

  def faq
  end

  def privacy
  end

  def terms
  end

  def neighborhoods
  end

  private

  def load_propertis
    @propertis = Propertis.all
  end

  def load_properti
    @properti = Propertis.find(params[:id])
  end
end
