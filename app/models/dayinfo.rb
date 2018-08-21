class Dayinfo < ApplicationRecord
  belongs_to :employee

  validates :date, presence: true
  validates :employee_id, presence: true

  before_create :times_trunc_sec, :aggregate
  before_update :times_trunc_sec, :aggregate

  def calc_days_and_times(start_sym, end_sym, days_sym, times_sym)
    if self[start_sym].present? && self[end_sym].present?
      self[days_sym] = 1
      self[times_sym] = (self[end_sym] - self[start_sym]).to_i / 60
      if self[times_sym] >= 480
        self[times_sym] -= 60
      elsif self[times_sym] >= 360
        self[times_sym] -= 45
      end
    end
  end
  def aggregate
    self.pre_workdays = 0
    self.pre_worktimes = 0
    self.workdays = 0
    self.worktimes = 0
    self.holiday_workdays = 0
    self.holiday_worktimes = 0
    calc_days_and_times(:pre_start, :pre_end, :pre_workdays, :pre_worktimes)
    calc_days_and_times(:start, :end, :workdays, :worktimes)
    if self.employee.holidays.find_by_date(self.date).present?
      self.holiday_workdays = self.workdays
      self.workdays = 0
      self.holiday_worktimes = self.worktimes
      self.worktimes = 0
    end
  end

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
