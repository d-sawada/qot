class Dayinfo < ApplicationRecord
  include ApplicationHelper

  belongs_to :employee
  belongs_to :work_pattern, required: false

  validates :date, presence: true
  validates :employee_id, presence: true

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

  def self.new_with_pattern(employee, date)
    d = self.new(employee_id: employee.id, date: date)
          .apply_template.aggregate
  end

  before_create :times_trunc_sec, :apply_template, :aggregate
  before_update :times_trunc_sec, :apply_template, :aggregate

  def times_trunc_sec
    self.start -= self.start.sec if self.start
    self.end -= self.end.sec if self.end
  end

  def apply_template
    if (pattern = self.work_pattern || pattern_at_template)
      y = self.date.year
      m = self.date.month
      d = self.date.day
      self.pre_start = pattern.start.change(year: y, month: m, day: d)
      self.pre_end = pattern.end.change(year: y, month: m, day: d)
      if pattern.rest_start
        self.rest_start = pattern.rest_start.change(year: y, month: m, day: d)
      end
      if pattern.rest_end
        self.rest_end = pattern.rest_end.change(year: y, month: m, day: d)
      end
      self.pre_start.yesterday!  if pattern.start_day == "前日"
      self.pre_start.tommorrow!  if pattern.start_day == "翌日"
      self.pre_end.yesterday!    if pattern.end_day == "前日"
      self.pre_end.tommorrow!    if pattern.end_day == "翌日"
      self.rest_start.yesterday! if pattern.rest_start_day == "前日"
      self.rest_start.tommorrow! if pattern.rest_start_day == "翌日"
      self.rest_end.yesterday!   if pattern.rest_end_day == "前日"
      self.rest_end.tommorrow!   if pattern.rest_end_day == "翌日"
    end
    self
  end

  def aggregate
    self.pre_workdays = 0
    self.workdays = 0
    self.holiday_workdays  = 0
    self.pre_worktimes = 0
    self.worktimes = 0
    self.holiday_worktimes = 0

    if self.start && self.end
      self.workdays = 1
      if self.pre_start && self.pre_end
        s = [self.start, self.pre_start].max
        e = [self.end, self.pre_end].min
        self.worktimes = calc_worktime_minute(s, e)
      else
        self.worktimes = calc_worktime_minute(self.start, self.end)
      end
    end
    if self.pre_start && self.pre_end
      self.pre_workdays = 1
      self.pre_worktimes = calc_worktime_minute(self.pre_start, self.pre_end)
    else
      self.holiday_workdays = self.workdays
      self.workdays = 0
      self.holiday_worktimes = self.worktimes
      self.worktimes = 0
    end
    self
  end

  def pattern_at_template
    id = self.employee.emp_status.work_template.pattern_id_of(self.date)
    WorkPattern.find_by_id(id)
  end

  def daily_index_row
    [self.start.to_hm, self.end.to_hm]
  end

  alias_method :daily_show_row, :daily_index_row
  
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

  alias_method :monthly_show_row, :monthly_index_row

  private

  def calc_worktime_minute(s, e)
    ((e - s).to_i / 60).apply_rest
  end
end
