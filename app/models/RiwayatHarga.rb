class RiwayatHarga
  include Mongoid::Document
  field :harga, type: BigDecimal
  field :tanggal, type: Date

  belongs_to :propertis, class_name: 'Properti', inverse_of: :riwayat_hargas
end
