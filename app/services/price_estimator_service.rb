class PriceEstimatorService
  DATA_PATH = Rails.root.join("config", "njop_bojongsoang.yml")
  DEFAULT_METHOD = "heuristic_fallback".freeze

  def initialize(properti, riwayat_hargas: [])
    @properti = properti
    @riwayat_hargas = Array(riwayat_hargas).reject { |item| blank_history?(item) }
  end

  def estimate
    baseline_njop = baseline_njop_per_meter
    effective_njop = @properti.njop.present? ? @properti.njop.to_f : baseline_njop
    land_value = effective_njop * @properti.luas_tanah.to_f
    building_value = @properti.luas_bangunan.to_f * building_rate_per_meter
    history_anchor = historical_average
    age_adjustment = building_age_adjustment
    ownership_factor = ownership_adjustment
    history_adjustment = history_anchor.positive? ? history_anchor * 0.15 : 0.0

    mid = (land_value + building_value + history_adjustment) * age_adjustment * ownership_factor
    min = mid * 0.93
    max = mid * 1.08

    {
      min: min.round,
      mid: mid.round,
      max: max.round,
      baseline_njop: baseline_njop.round,
      effective_njop: effective_njop.round,
      njop_source: @properti.njop.present? ? "manual_reference" : "area_baseline",
      adjustments: {
        land_value: land_value.round,
        building_value: building_value.round,
        history_anchor: history_anchor.round,
        age_adjustment: age_adjustment.round(4),
        ownership_adjustment: ownership_factor.round(4)
      },
      method: lstm_available? ? "lstm_ready_fallback" : DEFAULT_METHOD,
      explanation: explanation_text(baseline_njop, history_anchor, age_adjustment, ownership_factor)
    }
  end

  private

  def baseline_njop_per_meter
    return @properti.njop.to_f if @properti.njop.present?

    dataset.dig(normalize_key(@properti.daerah), normalize_key(@properti.kecamatan), normalize_key(@properti.kelurahan)).to_f
  end

  def building_rate_per_meter
    rate = baseline_njop_per_meter * 0.65
    rate.positive? ? rate : 2_500_000.0
  end

  def historical_average
    values = @riwayat_hargas.filter_map do |item|
      price = item[:harga] || item["harga"]
      price.to_f if price.present?
    end

    return 0.0 if values.empty?

    values.sum / values.length
  end

  def building_age_adjustment
    year = @properti.tahun_pembangunan.to_i
    age = year.positive? ? Time.zone.now.year - year : 0

    case age
    when 0..5 then 1.08
    when 6..15 then 1.0
    when 16..25 then 0.94
    else 0.88
    end
  end

  def ownership_adjustment
    case @properti.status_kepemilikan.to_s.upcase
    when "SHM" then 1.05
    when "HGB" then 1.0
    when "AJB" then 0.97
    when "GIRIK" then 0.93
    else 0.95
    end
  end

  def explanation_text(baseline_njop, history_anchor, age_adjustment, ownership_adjustment)
    parts = []
    if @properti.njop.present?
      parts << "NJOP manual sebesar Rp #{@properti.njop.to_f.round.to_fs(:delimited)} per m2 dipakai dari referensi input user."
    elsif baseline_njop.positive?
      parts << "Baseline NJOP area Bojongsoang dipakai sebesar Rp #{baseline_njop.round.to_fs(:delimited)} per m2."
    end
    parts << "Riwayat harga memberi anchor rata-rata Rp #{history_anchor.round.to_fs(:delimited)}." if history_anchor.positive?
    parts << "Faktor usia bangunan #{age_adjustment.round(2)}x dan status kepemilikan #{ownership_adjustment.round(2)}x diterapkan ke estimasi."
    parts.join(" ")
  end

  def dataset
    @dataset ||= YAML.load_file(DATA_PATH).fetch(Rails.env, YAML.load_file(DATA_PATH)["default"])
  end

  def normalize_key(value)
    value.to_s.strip.downcase.gsub(/\s+/, "_")
  end

  def lstm_available?
    false
  end

  def blank_history?(item)
    tanggal = item[:tanggal] || item["tanggal"]
    harga = item[:harga] || item["harga"]

    tanggal.blank? && harga.blank?
  end
end
