class Dayinfo < ApplicationRecord
  include ApplicationHelper
  belongs_to :employee

  validates :date, presence: true
  validates :employee_id, presence: true

  before_create :times_trunc_sec, :apply_template, :aggregate
  before_update :times_trunc_sec, :apply_template, :aggregate

  def times_trunc_sec
    [:pre_start, :pre_end, :start, :end].each do |sym|
      self[sym] = Time.at(self[sym].to_i / 60 * 60) if self[sym].present?
    end
  end
  def calc_days_and_times(start_sym, end_sym, days_sym, times_sym)
    if self[start_sym].present? && self[end_sym].present?
      self[days_sym] = 1
      self[times_sym] = (self[end_sym] - self[start_sym]).to_i / 60
      apply_rest(tymes_sym)
    end
  end
  def apply_template
    pattern = WorkPattern.find(self.employee.emp_status.work_template[[:sun, :mon, :tue, :wed, :thu, :fri, :sat][self.date.wday]])
    if pattern.present?
      self.pre_start = pattern.start
      self.pre_end = pattern.end
      self.rest_start = pattern.rest_start
      self.rest_end = pattern.rest_end
    end
  end
  def aggregate
    self.pre_workdays,  self.workdays,  self.holiday_workdays  = 0, 0, 0
    self.pre_worktimes, self.worktimes, self.holiday_worktimes = 0, 0, 0

    if self.pre_start.present? && self.pre_end.present?
      self.pre_workdays = 1
      self.pre_worktimes = ((self.pre_end - self.pre_start).to_i / 60).apply_rest
    end
    if self.start.present? && self.end.present?
      self.workdays = 1
      if self.pre_start.present? && self.pre_end.present?
        self.worktimes = (([self.end, self.pre_end].min - [self.start, self.pre_start].max).to_i / 60).apply_rest
        p self.worktimes
        p self.pre_end
        p self.pre_start
      else
        self.worktimes = ((self.end - self.start).to_i / 60).apply_rest
      end
    end
    if self.employee.holidays.find_by_date(self.date).present?
      self.holiday_workdays,  self.workdays  = self.workdays,  0
      self.holiday_worktimes, self.worktimes = self.worktimes, 0
    end
  end

  def daily_data
    [
      self.pre_start.to_hm,
      self.pre_end.to_hm,
      self.start.to_hm,
      self.end.to_hm,
      self.rest_start.to_hm,
      self.rest_end.to_hm
    ]
  end
  def monthly_data
    [
      self.try(:sum_pre_workdays),
      self.try(:sum_pre_worktimes).min_to_times,
      self.try(:sum_workdays),
      self.try(:sum_worktimes).min_to_times,
      self.try(:sum_holiday_workdays),
      self.try(:sum_holiday_worktimes).min_to_times
    ]
  end
end
