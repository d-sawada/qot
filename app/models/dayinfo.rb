class Dayinfo < ApplicationRecord
  has_one :emp_emp_statuses, primary_key: :employee_id, foreign_key: :employee_id
  belongs_to :employee

  validates :date, presence: true
  validates :employee_id, presence: true

  before_create :times_trunc_sec
  before_update :times_trunc_sec

  def times_trunc_sec
    [:pre_start, :pre_end, :start, :end].each do |sym|
      self[sym] = Time.at(self[sym].to_i / 60 * 60) if self[sym].present?
    end
  end
  def is_workday
    self.pre_start.present? && self.pre_end.present? ? 1 : 0
  end
  def pre_work_sec
    self.pre_start.present? && self.pre_end.present? ? self.pre_end - self.pre_start : 0
  end
  def is_attendedday
    self.start.present? && self.end.present? ? 1 : 0
  end
  def actual_work_sec
    self.start.present? && self.end.present? ? self.end - self.start : 0
  end
  def totalization
    [self.is_workday, self.pre_work_sec, self.is_attendedday, self.actual_work_sec]
  end
end
