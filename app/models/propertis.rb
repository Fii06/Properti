class Propertis
  include Mongoid::Document
  include Mongoid::Timestamps

  field :alamat, type: String
  field :daerah, type: String
  field :kecamatan, type: String
  field :kelurahan, type: String
  field :latitude, type: Float
  field :longitude, type: Float
  field :contact_penjual, type: String

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
  has_many :riwayat_hargas, class_name: "RiwayatHarga", inverse_of: :propertis, dependent: :destroy
  has_many :analisis_hargas, class_name: "AnalisisHarga", inverse_of: :propertis, dependent: :destroy
  has_and_belongs_to_many :fasilitas, class_name: "Fasilitas", inverse_of: :propertis

  STATUS_KEPEMILIKAN = ["SHM", "HGB", "AJB", "Girik", "Lainnya"].freeze

  scope :recent_first, -> { order_by(created_at: :desc) }
  scope :matching_query, lambda { |query|
    return all if query.blank?

    keyword = /#{Regexp.escape(query)}/i
    any_of({ alamat: keyword }, { daerah: keyword }, { kecamatan: keyword }, { kelurahan: keyword })
  }
  scope :within_price, lambda { |price|
    return all if price.blank?

    where(:harga_pasar.lte => price.to_i)
  }

  validates :alamat, :daerah, :kecamatan, :kelurahan, :latitude, :longitude,
            :luas_tanah, :luas_bangunan, :tahun_pembangunan, :status_kepemilikan,
            presence: true
  validates :status_kepemilikan, inclusion: { in: STATUS_KEPEMILIKAN }
  validate :njop_or_area_baseline_present
  validate :minimal_5_images
  validate :harga_dimensions_positive

  def minimal_5_images
    errors.add(:images, "minimal 5 gambar") if images.size < 5
  end

  private

  def njop_or_area_baseline_present
    return if njop.present?
    return if daerah.present? && kecamatan.present? && kelurahan.present?

    errors.add(:njop, "harus diisi atau area harus lengkap untuk lookup baseline")
  end

  def harga_dimensions_positive
    if luas_tanah.present? && luas_tanah <= 0
      errors.add(:luas_tanah, "harus lebih besar dari 0")
    end

    if luas_bangunan.present? && luas_bangunan <= 0
      errors.add(:luas_bangunan, "harus lebih besar dari 0")
    end
  end
end
