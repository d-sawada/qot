class EmployeeAdditionalValue < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_additional_label

  validates :employee_id, presence: true
  validates :employee_additional_label_id, presence: true
  validates :value, length: { maximum: 255 }

  def ex_key_id
    self.employee_additional_label_id
  end
end
