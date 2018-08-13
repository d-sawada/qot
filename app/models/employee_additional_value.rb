class EmployeeAdditionalValue < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_additional_label, primary_key: :name, foreign_key: :name

  validates :employee_id, presence: true
  validates :name, presence: true, length: { maximum: 8 }
  validates :value, length: { maximum: 255 }
end
