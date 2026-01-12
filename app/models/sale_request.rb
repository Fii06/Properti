class SaleRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :alamat, type: String
  field :luas_tanah, type: Integer
  field :luas_bangunan, type: Integer

  field :harga_tanah_input, type: Integer
  field :harga_bangunan_input, type: Integer

  field :rekomendasi_min, type: Integer
  field :rekomendasi_mid, type: Integer
  field :rekomendasi_max, type: Integer

  field :harga_final, type: Integer
  field :published, type: Boolean, default: false

  # 🔥 GRIDFS
  field :image_ids, type: Array, default: []

  validates :alamat, :luas_tanah, :luas_bangunan, presence: true
  validate :minimal_5_images

  private

  def minimal_5_images
    errors.add(:images, "minimal 5 gambar") if image_ids.size < 5
  end
end
