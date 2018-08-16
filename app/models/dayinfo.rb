class Dayinfo < ApplicationRecord
  belongs_to :employee

  validates :date, presence: true
  validates :employee_id, presence: true

  before_save :times_trunc_sec
  before_create :times_trunc_sec
  before_update :times_trunc_sec

  def times_trunc_sec
    self.pre_start = self.pre_start.trunc_sec
    self.pre_end = self.pre_end.trunc_sec
    self.start = self.start.trunc_sec
    self.end = self.end.trunc_sec
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
