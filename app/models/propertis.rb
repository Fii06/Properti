class Propertis
  include Mongoid::Document
  include Mongoid::Timestamps

  field :alamat, type: String
  field :latitude, type: Float
  field :longitude, type: Float

  field :luas_tanah, type: Integer
  field :luas_bangunan, type: Integer
  field :tahun_pembangunan, type: Integer
  field :status_kepemilikan, type: String

  field :njop, type: BigDecimal
  field :harga_pasar, type: BigDecimal

  # GAMBAR (Base64)
  field :images, type: Array, default: []

  # REKOMENDASI HARGA SPK
  field :harga_rekomendasi_min, type: BigDecimal
  field :harga_rekomendasi_mid, type: BigDecimal
  field :harga_rekomendasi_max, type: BigDecimal

  belongs_to :user, optional: true

  validates :alamat, :luas_tanah, :luas_bangunan, :njop, presence: true
  validate :minimal_5_images

  def minimal_5_images
    errors.add(:images, "minimal 5 gambar") if images.size < 5
  end
end
