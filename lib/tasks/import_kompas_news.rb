# lib/tasks/import_kompas_news.rb
# Jalankan:
# rails runner lib/tasks/import_kompas_news.rb

require "open-uri"
require "nokogiri"

ARTICLES = [
  "https://www.kompas.com/properti/read/2025/12/29/132734621/proyek-genting-di-bogor-bikin-sentul-city-masuk-top-5-pengembang-ri",
  "https://www.kompas.com/properti/read/2025/12/26/120000521/ini-lokasi-lokasi-paling-seksi-yang-diincar-multinational-company",
  "https://www.kompas.com/properti/read/2025/12/24/124617921/tutup-kalender-2025-paramount-incar-rp-1-triliun-dari-ekspo-properti",
  "https://www.kompas.com/properti/read/2025/12/23/112417821/bukan-ayah-ibulah-yang-menentukan-pembelian-rumah",
  "https://www.kompas.com/properti/read/2025/12/20/182848421/summarecon-lima-dekade-membangun-kehidupan-berkelanjutan",
  "https://www.kompas.com/properti/read/2025/12/19/160000721/manuver-bersejarah-danantara-ambil-alih-novotel-mekkah",
  "https://www.kompas.com/properti/read/2025/12/15/200000721/penasaran-seberapa-luas-ukuran-rumah-subsidi-terbaru-cek-di-sini",
  "https://www.kompas.com/properti/read/2025/12/15/190000121/berapa-harga-rumah-subsidi-terbaru",
  "https://www.kompas.com/properti/read/2025/12/15/160000021/berapa-gaji-maksimal-yang-berhak-beli-rumah-subsidi",
  "https://www.kompas.com/properti/read/2025/12/14/074456721/tetangga-bikin-polisi-tidur-di-perumahan-bisa-dipidana"
  
]

puts "📥 Importing Kompas Properti news..."

ARTICLES.each do |url|
  if News.where(url: url).exists?
    puts "⏭️  Skip (already exists): #{url}"
    next
  end

  begin
    html = URI.open(url).read
    doc  = Nokogiri::HTML(html)

    # TITLE
    title = doc.at_css("h1")&.text&.strip || "Berita Properti Kompas"

    # IMAGE (INI BAGIAN PENTING)
    image =
      doc.at_css("meta[property='og:image']")&.[]("content") ||
      doc.at_css("img")&.[]("src")

    # EXCERPT
    excerpt =
      doc.at_css("meta[name='description']")&.[]("content") ||
      "Baca berita selengkapnya di Kompas Properti."

    News.create!(
      title: title,
      url: url,
      image: image,
      excerpt: excerpt,
      content: nil,
      source: "Kompas Properti",
      posted_at: Time.now.strftime("%Y-%m-%d")
    )

    puts "✅ Imported: #{title}"
    puts "🖼️  Image: #{image}"

  rescue => e
    puts "❌ Failed to import #{url}"
    puts e.message
  end
end

puts "🎉 Done. Total news in DB: #{News.count}"
