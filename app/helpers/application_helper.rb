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
end
