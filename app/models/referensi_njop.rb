class ReferensiNjop
  include Mongoid::Document
  include Mongoid::Timestamps

  SEGMENT_LENGTHS = {
    kd_propinsi: 2,
    kd_dati2: 2,
    kd_kecamatan: 3,
    kd_kelurahan: 3,
    kd_blok: 3,
    no_urut: 4,
    kd_jns_op: 1
  }.freeze

  store_in collection: "referensi_njops"

  field :nomor_njop, type: String
  field :kd_propinsi, type: String
  field :kd_dati2, type: String
  field :kd_kecamatan, type: String
  field :kd_kelurahan, type: String
  field :kd_blok, type: String
  field :no_urut, type: String
  field :kd_jns_op, type: String
  field :harga_per_m2, type: BigDecimal
  field :alamat, type: String

  index({ nomor_njop: 1 }, unique: true, background: true)

  validates :nomor_njop, :alamat, presence: true
  validates :harga_per_m2, presence: true, numericality: { greater_than: 0 }
  validate :segments_are_numeric_and_exact_length

  before_validation :normalize_segments!
  before_validation :assign_nomor_njop

  class << self
    def normalize_segments(attributes)
      SEGMENT_LENGTHS.each_with_object({}) do |(key, length), result|
        value = attributes[key] || attributes[key.to_s]
        result[key] = value.to_s.gsub(/\D/, "")
      end
    end

    def build_nomor_njop(attributes)
      normalized = normalize_segments(attributes)
      return if normalized.values.any?(&:blank?)

      normalized.values.join(".")
    end

    def upsert_from_input!(attributes)
      nomor_njop = build_nomor_njop(attributes)
      record = where(nomor_njop: nomor_njop).first || new

      record.assign_attributes(
        normalize_segments(attributes).merge(
          nomor_njop: nomor_njop,
          harga_per_m2: attributes[:harga_per_m2] || attributes["harga_per_m2"],
          alamat: attributes[:alamat] || attributes["alamat"]
        )
      )
      record.save!
      record
    end
  end

  private

  def normalize_segments!
    self.class.normalize_segments(attributes).each do |key, value|
      self[key] = value
    end
  end

  def assign_nomor_njop
    self.nomor_njop = self.class.build_nomor_njop(attributes)
  end

  def segments_are_numeric_and_exact_length
    SEGMENT_LENGTHS.each do |key, length|
      value = self[key].to_s

      if value.blank?
        errors.add(key, "harus diisi")
      elsif value.length != length
        errors.add(key, "harus terdiri dari #{length} digit")
      elsif value.match?(/\D/)
        errors.add(key, "harus berupa angka")
      end
    end
  end
end
