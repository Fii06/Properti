class RiwayatHarga
  include Mongoid::Document
  include Mongoid::Timestamps

  field :harga, type: BigDecimal
  field :tanggal, type: Date

  belongs_to :propertis, class_name: "Propertis", inverse_of: :riwayat_hargas

  validates :harga, :tanggal, presence: true
end
