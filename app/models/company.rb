class Company < ApplicationRecord
  validates :code, length: { is: 6 }, unique: true
  validates :name, length: { maximum: 255 }
end
