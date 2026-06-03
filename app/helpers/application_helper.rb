module ApplicationHelper
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
