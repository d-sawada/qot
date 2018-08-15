class Company < ApplicationRecord
  validates :code, length: { is: 6 }, uniqueness: true
  validates :name, length: { maximum: 255 }

  has_many :admins, primary_key: :code, foreign_key: :company_code, dependent: :destroy
  has_many :employees, primary_key: :code, foreign_key: :company_code, dependent: :destroy
  has_many :employee_additional_labels, primary_key: :code, foreign_key: :company_code, dependent: :destroy
  has_many :dayinfos, through: :employees, primary_key: :id, foreign_key: :employee_id

  rails_admin do
    edit do
      configure :admins do
        visible false
      end
      configure :employees do
        visible false
      end
    end
  end
end
