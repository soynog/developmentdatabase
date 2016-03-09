class Neighborhood < Place
  belongs_to :municipality, foreign_key: :place_id, class_name: 'Place'
end
