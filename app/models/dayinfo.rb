class Dayinfo < ApplicationRecord
  belongs_to :employee

  validates :date, presence: true, length: { is: 8 }
  validates :start, length: { maximum: 4 }
  validates :end, length: { maximum: 4 }
  validates :pre_start, length: { maximum: 4 }
  validates :pre_end, length: { maximum: 4 }
  validates :employee_id, presence: true
end
