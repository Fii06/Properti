class PriceEstimatorService
  def initialize(properti)
    @properti = properti
  end

  # contoh sederhana: rekomendasi = (njop * factor) + (harga_pasar * factor2) + koreksi by luas
  def estimate
    njop = @properti.njop.to_f || 0.0
    pasar = @properti.harga_pasar.to_f || 0.0
    luas = (@properti.luas_tanah.to_f + @properti.luas_bangunan.to_f)/2.0
    # bobot contoh
    rekom = (0.5 * pasar) + (0.3 * njop) + (0.2 * (luas * 1000000))
    rekom.round(2)
  end
end
