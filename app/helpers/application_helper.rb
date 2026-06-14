module ApplicationHelper
  def page_title(title = nil)
    [title.presence, "SPK Properti"].compact.join(" · ")
  end

  def active_nav_class(key)
    current_key = content_for?(:active_nav) ? content_for(:active_nav) : nil
    "active" if current_key == key
  end

  def rupiah(amount, precision: 0)
    number_to_currency(amount, unit: "Rp ", precision: precision)
  end

  def property_image_src(image)
    return if image.blank?

    value = image.to_s.sub(/\Adata:image\/jpg;base64,/, "data:image/jpeg;base64,")
    return value if value.start_with?("data:", "http://", "https://", "/")

    "data:image/jpeg;base64,#{value}"
  end

    def whatsapp_url(phone, properti)
    return "#" if phone.blank?

    number = phone.gsub(/\D/, "")

    if number.start_with?("08")
      number = "62#{number[1..]}"
    elsif number.start_with?("8")
      number = "62#{number}"
    end

    message = CGI.escape(
      "Halo, saya tertarik dengan properti di #{properti.alamat}. Apakah masih tersedia?"
    )

    "https://wa.me/#{number}?text=#{message}"
  end
end
