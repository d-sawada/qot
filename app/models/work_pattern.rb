class WorkPattern < ApplicationRecord
  belongs_to :company

  validates :company_id, presence: true
  validates :name,  presence: true
  validates :start, presence: true
  validates :end,   presence: true
  validates :start_day, inclusion: { in: %w(前日 当日 翌日) }
  validates :end_day,   inclusion: { in: %w(前日 当日 翌日) }

  before_save :erase_rest_day, apply_day_offset

  def erase_rest_day
    self.rest_start_day = "" if self.rest_start.nil?
    self.rest_end_day = "" if self.rest_end.nil?
  end
  def apply_day_offset
    self.start = self.start.yesterday if self.start_day == "前日"
    self.start = self.start.tommorrow if self.start_day == "翌日"
    self.end = self.end.yesterday if self.end_day == "前日"
    self.end = self.end.tommorrow if self.end_day == "翌日"
    self.rest_start = self.rest_start.yesterday if self.rest_start_day == "前日"
    self.rest_start = self.rest_start.tommorrow if self.rest_start_day == "翌日"
    self.rest_end = self.rest_end.yesterday if self.rest_end_day == "前日"
    self.rest_end = self.rest_end.tommorrow if self.rest_end_day == "翌日"
  end
end
