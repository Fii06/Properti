class Fasilitas
  include Mongoid::Document
  field :nama, type: String
  has_and_belongs_to_many :propertis, class_name: 'Propertis', inverse_of: :fasilitas
end
