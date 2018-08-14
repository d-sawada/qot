class EmployeeAdditionalLabel < ApplicationRecord
  belongs_to :company, primary_key: :code, foreign_key: :company_code

  validates :company_code, presence: true, length: { is: 6 }
  validates :name,         presence: true, length: { maximum: 8 }

  has_many :employee_additional_values, dependent: :destroy
end
