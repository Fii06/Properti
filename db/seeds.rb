require "base64"
require "digest"

Fasilitas.seed_bojongsoang_defaults!

demo_user = User.find_or_initialize_by(email: "owner@properti.local")
demo_user.password = "password123" if demo_user.new_record?
demo_user.password_confirmation = "password123" if demo_user.new_record?
demo_user.save!

PROPERTY_SEEDS = [
  {
    alamat: "Jl. Raya Bojongsoang No. 121, Bojongsoang, Kec. Bojongsoang, Kabupaten Bandung 40288",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Bojongsoang",
    latitude: -6.9891,
    longitude: 107.6429,
    luas_tanah: 128,
    luas_bangunan: 102,
    tahun_pembangunan: 2017,
    status_kepemilikan: "SHM",
    riwayat_hargas: [
      { tanggal: "2024-03-18", harga: 835_000_000 },
      { tanggal: "2025-02-10", harga: 885_000_000 },
      { tanggal: "2026-02-21", harga: 925_000_000 }
    ]
  },
  {
    alamat: "Jl. Bojongsoang Asri No. 14, Bojongsoang, Kec. Bojongsoang, Kabupaten Bandung 40288",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Bojongsoang",
    latitude: -6.9878,
    longitude: 107.6408,
    luas_tanah: 96,
    luas_bangunan: 84,
    tahun_pembangunan: 2020,
    status_kepemilikan: "HGB",
    riwayat_hargas: [
      { tanggal: "2024-05-02", harga: 715_000_000 },
      { tanggal: "2025-04-16", harga: 760_000_000 },
      { tanggal: "2026-03-08", harga: 805_000_000 }
    ]
  },
  {
    alamat: "Jl. Sukabirus Selatan No. 21, Lengkong, Kec. Bojongsoang, Kabupaten Bandung 40287",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Lengkong",
    latitude: -6.9807,
    longitude: 107.6481,
    luas_tanah: 110,
    luas_bangunan: 94,
    tahun_pembangunan: 2019,
    status_kepemilikan: "SHM",
    riwayat_hargas: [
      { tanggal: "2024-01-22", harga: 810_000_000 },
      { tanggal: "2025-01-29", harga: 855_000_000 },
      { tanggal: "2026-01-30", harga: 905_000_000 }
    ]
  },
  {
    alamat: "Jl. Cikoneng No. 9, Citeureup, Kec. Bojongsoang, Kabupaten Bandung 40288",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Citeureup",
    latitude: -6.9864,
    longitude: 107.6372,
    luas_tanah: 142,
    luas_bangunan: 98,
    tahun_pembangunan: 2014,
    status_kepemilikan: "AJB",
    riwayat_hargas: [
      { tanggal: "2024-02-14", harga: 760_000_000 },
      { tanggal: "2025-02-18", harga: 805_000_000 },
      { tanggal: "2026-02-26", harga: 845_000_000 }
    ]
  },
  {
    alamat: "Jl. Raya Sapan No. 57, Tegalluar, Kec. Bojongsoang, Kabupaten Bandung 40287",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Tegalluar",
    latitude: -6.9829,
    longitude: 107.6964,
    luas_tanah: 180,
    luas_bangunan: 130,
    tahun_pembangunan: 2016,
    status_kepemilikan: "SHM",
    riwayat_hargas: [
      { tanggal: "2024-04-11", harga: 930_000_000 },
      { tanggal: "2025-05-09", harga: 995_000_000 },
      { tanggal: "2026-03-17", harga: 1_040_000_000 }
    ]
  },
  {
    alamat: "Jl. Tegalluar Baru Barat No. 12, Tegalluar Baru, Kec. Bojongsoang, Kabupaten Bandung 40287",
    daerah: "Bojongsoang",
    kecamatan: "Bojongsoang",
    kelurahan: "Tegalluar Baru",
    latitude: -6.9805,
    longitude: 107.6878,
    luas_tanah: 162,
    luas_bangunan: 118,
    tahun_pembangunan: 2021,
    status_kepemilikan: "HGB",
    riwayat_hargas: [
      { tanggal: "2024-06-06", harga: 1_010_000_000 },
      { tanggal: "2025-06-18", harga: 1_085_000_000 },
      { tanggal: "2026-04-02", harga: 1_145_000_000 }
    ]
  }
].freeze

SEED_IMAGE_PATHS = Dir.glob(Rails.root.join("db/images/*.{jpg,jpeg,png,webp}"))
  .sort
  .freeze

def seed_images
  @seed_images ||= SEED_IMAGE_PATHS.map do |path|
    encoded = Base64.strict_encode64(File.binread(path))
    "data:image/jpeg;base64,#{encoded}"
  end
end

def property_images(seed_key, position)
  randomized = seed_images.shuffle(random: Random.new(Digest::MD5.hexdigest(seed_key.to_s).to_i(16)))
  cover_index = position % randomized.length
  chosen_cover = seed_images[cover_index]
  remaining = randomized.reject { |image| image == chosen_cover }
  remaining = remaining.reverse if position.odd?
  [chosen_cover, *remaining]
end

def matching_facilities(kelurahan)
  scoped = Fasilitas.any_of(
    { area_kelurahan: /#{Regexp.escape(kelurahan.to_s)}/i },
    { area_kelurahan: /bojongsoang/i },
    { area_kelurahan: /akses bojongsoang/i }
  ).ordered.to_a

  return scoped.first(4) if scoped.any?

  Fasilitas.ordered.limit(4).to_a
end

PROPERTY_SEEDS.each_with_index do |attributes, index|
  history_entries = attributes[:riwayat_hargas]
  listing = Propertis.find_or_initialize_by(alamat: attributes[:alamat])

  listing.assign_attributes(
    attributes.except(:riwayat_hargas).merge(
      user: demo_user,
      images: property_images(attributes[:alamat], index)
    )
  )

  estimation = PriceEstimatorService.new(listing, riwayat_hargas: history_entries).estimate
  listing.njop = estimation[:baseline_njop] if listing.njop.blank? && estimation[:baseline_njop].to_f.positive?
  listing.harga_rekomendasi_min = estimation[:min]
  listing.harga_rekomendasi_mid = estimation[:mid]
  listing.harga_rekomendasi_max = estimation[:max]
  listing.harga_pasar = estimation[:mid]
  listing.fasilitas = matching_facilities(attributes[:kelurahan])
  listing.save!

  listing.riwayat_hargas.delete_all
  history_entries.each do |entry|
    listing.riwayat_hargas.create!(
      tanggal: Date.parse(entry[:tanggal]),
      harga: entry[:harga]
    )
  end

  listing.analisis_hargas.delete_all
  listing.analisis_hargas.create!(
    harga_rekomendasi: estimation[:mid],
    harga_rekomendasi_min: estimation[:min],
    harga_rekomendasi_mid: estimation[:mid],
    harga_rekomendasi_max: estimation[:max],
    baseline_njop: listing.njop,
    metode: estimation[:method],
    breakdown: estimation[:adjustments],
    input_snapshot: attributes.except(:riwayat_hargas).merge(riwayat_hargas: history_entries)
  )
end

puts "Seeded #{Fasilitas.count} fasilitas and #{PROPERTY_SEEDS.length} demo properties."
