class AnalisisHarga
  include Mongoid::Document
  include Mongoid::Timestamps
  field :harga_rekomendasi, type: BigDecimal
  field :metode, type: String
  belongs_to :properti, class_name: 'Propertis', inverse_of: :analisis_hargas
end
