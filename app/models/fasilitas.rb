class Fasilitas
  include Mongoid::Document
  include Mongoid::Timestamps

  field :nama, type: String
  field :kategori, type: String
  field :alamat, type: String
  field :deskripsi_singkat, type: String
  field :latitude, type: Float
  field :longitude, type: Float
  field :area_kelurahan, type: String

  KATEGORI = [
    "taman",
    "tempat makan",
    "tempat nongkrong",
    "pendidikan",
    "kesehatan",
    "ibadah",
    "transportasi",
    "belanja/kebutuhan harian"
  ].freeze

  BOJONGSOANG_DEFAULTS = [
    {
      nama: "Taman Kota Bojongsoang",
      kategori: "taman",
      alamat: "Jl. Bojongsoang Raya, Bojongsoang",
      deskripsi_singkat: "Ruang terbuka untuk olahraga ringan dan aktivitas keluarga.",
      latitude: -6.9794,
      longitude: 107.6294,
      area_kelurahan: "Bojongsoang"
    },
    {
      nama: "Warung Nasi Ampera Bojongsoang",
      kategori: "tempat makan",
      alamat: "Jl. Raya Bojongsoang, Bojongsoang",
      deskripsi_singkat: "Pilihan makan harian yang mudah dijangkau dari koridor utama Bojongsoang.",
      latitude: -6.9815,
      longitude: 107.6308,
      area_kelurahan: "Bojongsoang"
    },
    {
      nama: "Kopi Soe Bojongsoang",
      kategori: "tempat nongkrong",
      alamat: "Jl. Bojongsoang Raya, Bojongsoang",
      deskripsi_singkat: "Tempat santai dan meeting informal dengan akses mudah dari area kampus.",
      latitude: -6.9831,
      longitude: 107.6324,
      area_kelurahan: "Bojongsoang"
    },
    {
      nama: "Telkom University",
      kategori: "pendidikan",
      alamat: "Jl. Telekomunikasi No. 1, Terusan Buahbatu",
      deskripsi_singkat: "Kampus utama yang menjadi salah satu pusat aktivitas pendidikan di sekitar Bojongsoang.",
      latitude: -6.973,
      longitude: 107.6301,
      area_kelurahan: "Sukapura"
    },
    {
      nama: "RS Al Islam Bandung",
      kategori: "kesehatan",
      alamat: "Jl. Soekarno-Hatta No. 644, Manjahlega",
      deskripsi_singkat: "Rumah sakit rujukan yang masih terjangkau dari kawasan Bojongsoang.",
      latitude: -6.9389,
      longitude: 107.6567,
      area_kelurahan: "Akses Bojongsoang"
    },
    {
      nama: "Masjid Besar Bojongsoang",
      kategori: "ibadah",
      alamat: "Jl. Raya Bojongsoang, Bojongsoang",
      deskripsi_singkat: "Pusat kegiatan ibadah dan komunitas warga di area Bojongsoang.",
      latitude: -6.9802,
      longitude: 107.6299,
      area_kelurahan: "Bojongsoang"
    },
    {
      nama: "Terminal Bojongsoang",
      kategori: "transportasi",
      alamat: "Jl. Raya Bojongsoang, Bojongsoang",
      deskripsi_singkat: "Simpul angkutan yang memudahkan mobilitas ke Bandung dan sekitarnya.",
      latitude: -6.981,
      longitude: 107.6286,
      area_kelurahan: "Bojongsoang"
    },
    {
      nama: "Borma Bojongsoang",
      kategori: "belanja/kebutuhan harian",
      alamat: "Jl. Bojongsoang Raya, Bojongsoang",
      deskripsi_singkat: "Pusat belanja kebutuhan harian yang sering jadi rujukan warga sekitar.",
      latitude: -6.9824,
      longitude: 107.6315,
      area_kelurahan: "Bojongsoang"
    }
  ].freeze

  has_and_belongs_to_many :propertis, class_name: "Propertis", inverse_of: :fasilitas

  validates :nama, :kategori, :alamat, :deskripsi_singkat, :area_kelurahan, presence: true
  validates :kategori, inclusion: { in: KATEGORI }

  scope :ordered, -> { order_by(kategori: :asc, nama: :asc) }
  scope :in_bojongsoang_area, -> { any_of({ area_kelurahan: /bojongsoang/i }, { alamat: /bojongsoang/i }) }

  def self.seed_bojongsoang_defaults!
    BOJONGSOANG_DEFAULTS.each do |attributes|
      fasilitas = find_or_initialize_by(nama: attributes[:nama])
      fasilitas.assign_attributes(attributes)
      fasilitas.save! if fasilitas.changed?
    end
  end
end
