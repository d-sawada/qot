class Dayinfo < ApplicationRecord
  include ApplicationHelper
  belongs_to :employee
  belongs_to :work_pattern, required: false
  validates :date, presence: true
  validates :employee_id, presence: true
  before_create :times_trunc_sec, :apply_template, :aggregate
  before_update :times_trunc_sec, :apply_template, :aggregate
  scope :monthly, -> (date) {
    where(date: (date.beginning_of_month)..(date.end_of_month) )
      .select(<<-SELECT).group(:employee_id)
        employee_id,
        sum(pre_workdays)      as sum_pre_workdays,
        sum(pre_worktimes)     as sum_pre_worktimes,
        sum(workdays)          as sum_workdays,
        sum(worktimes)         as sum_worktimes,
        sum(holiday_workdays)  as sum_holiday_workdays,
        sum(holiday_worktimes) as sum_holiday_worktimes
      SELECT
  }

  def times_trunc_sec
    self.start = Time.at(self.start.to_i / 60 * 60) if self.start.present?
    self.end = Time.at(self.end.to_i / 60 * 60 + 1) if self.end.present?
  end
  def apply_template
    if self.work_pattern_id.present?
      pattern = self.work_pattern
    else
      pattern = WorkPattern.find_by_id(self.employee.emp_status.work_template[[:sun, :mon, :tue, :wed, :thu, :fri, :sat][self.date.wday]])
    end
    if pattern.present?
      self.pre_start = pattern.start.change(year: self.date.year, month: self.date.month, day: self.date.day) if pattern.start.present?
      self.pre_end = pattern.end.change(year: self.date.year, month: self.date.month, day: self.date.day) if pattern.end.present?
      self.rest_start = pattern.rest_start.change(year: self.date.year, month: self.date.month, day: self.date.day) if pattern.rest_start.present?
      self.rest_end = pattern.rest_end.change(year: self.date.year, month: self.date.month, day: self.date.day) if pattern.rest_start.present?
      self.pre_start = self.pre_start.yesterday if pattern.start_day == "前日"
      self.pre_start = self.pre_start.tommorrow if pattern.start_day == "翌日"
      self.pre_end = self.pre_end.yesterday if pattern.end_day == "前日"
      self.pre_end = self.pre_end.tommorrow if pattern.end_day == "翌日"
      self.rest_start = self.rest_start.yesterday if pattern.rest_start_day == "前日"
      self.rest_start = self.rest_start.tommorrow if pattern.rest_start_day == "翌日"
      self.rest_end = self.rest_end.yesterday if pattern.rest_end_day == "前日"
      self.rest_end = self.rest_end.tommorrow if pattern.rest_end_day == "翌日"
    end
  end
  def aggregate
    self.pre_workdays,  self.workdays,  self.holiday_workdays  = 0, 0, 0
    self.pre_worktimes, self.worktimes, self.holiday_worktimes = 0, 0, 0

    if self.start.present? && self.end.present?
      self.workdays = 1
      if self.pre_start.present? && self.pre_end.present?
        self.worktimes = (([self.end, self.pre_end].min - [self.start, self.pre_start].max).to_i / 60).apply_rest
      else
        self.worktimes = ((self.end - self.start).to_i / 60).apply_rest
      end
    end
    if self.pre_start.present? && self.pre_end.present?
      self.pre_workdays = 1
      self.pre_worktimes = ((self.pre_end - self.pre_start).to_i / 60).apply_rest
    else #if self.employee.holidays.find_by_date(self.date).present?
      self.holiday_workdays,  self.workdays  = self.workdays,  0
      self.holiday_worktimes, self.worktimes = self.worktimes, 0
    end
  end

  def daily_index_row
    [
      self.start.to_hm,
      self.end.to_hm
    ]
  end
  def monthly_index_row
    [
      self.try(:sum_pre_workdays),
      self.try(:sum_pre_worktimes).min_to_times,
      self.try(:sum_workdays),
      self.try(:sum_worktimes).min_to_times,
      self.try(:sum_holiday_workdays),
      self.try(:sum_holiday_worktimes).min_to_times
    ]
  end

  #不要
  def daily_data
    daily_index_row
  end
  def monthly_data
    monthly_index_row
  end
end
