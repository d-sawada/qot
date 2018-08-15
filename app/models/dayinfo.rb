class Dayinfo < ApplicationRecord
  belongs_to :employee

  validates :date, presence: true
  validates :employee_id, presence: true
end
