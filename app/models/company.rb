class Company < ApplicationRecord
  validates :code, length: { is: 6 }, uniqueness: true
  validates :name, length: { maximum: 255 }
end
