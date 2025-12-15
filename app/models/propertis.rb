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
#  mount_uploader :foto, PhotoUploader 

  field :fasilitas_ids, type: Array, default: []
  belongs_to :user, optional: true
  has_many :riwayat_hargas
  has_many :analisis_hargas
  has_and_belongs_to_many :fasilitas, class_name: 'Fasilitas'
end
