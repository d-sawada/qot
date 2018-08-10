class Company < ApplicationRecord
  validates :code, length: { is: 6 }, uniqueness: true
  validates :name, length: { maximum: 255 }

  has_many :admins, primary_key: :code, foreign_key: :company_code, dependent: :destroy

  rails_admin do
    edit do
      configure :admins do
        visible false
      end
    end
  end
end
