class AnalisisHarga
  include Mongoid::Document
  include Mongoid::Timestamps

  field :harga_rekomendasi, type: BigDecimal
  field :harga_rekomendasi_min, type: BigDecimal
  field :harga_rekomendasi_mid, type: BigDecimal
  field :harga_rekomendasi_max, type: BigDecimal
  field :baseline_njop, type: BigDecimal
  field :metode, type: String
  field :breakdown, type: Hash, default: {}
  field :input_snapshot, type: Hash, default: {}

  belongs_to :propertis, class_name: "Propertis", inverse_of: :analisis_hargas

  validates :metode, presence: true
end
