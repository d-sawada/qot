class WorkPattern < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  has_one :dayinfo
  belongs_to :company

  validates :company_id, presence: true
  validates :name,  presence: true
  validates :start, presence: true
  validates :end,   presence: true
  validates :start_day, inclusion: { in: %w(前日 当日 翌日) }
  validates :end_day,   inclusion: { in: %w(前日 当日 翌日) }

  before_save :format_rest_day

  def format_rest_day
    if self.rest_start && self.rest_end
      self.rest_start_day ||= "当日"
      self.rest_end_day ||= "当日"
    else
      self.rest_start_day = nil
      self.rest_start = nil
      self.rest_end_day = nil
      self.rest_end = nil
    end
  end

  def daily_index_row
    [
      self.name,
      self.start.to_hm,
      self.end.to_hm,
      self.rest_start.to_hm || "",
      self.rest_end.to_hm || ""
    ]
  end

  def edit_path
    self.id ? setting_path(pattern: self.id) + "#nav-label-pattern" : nil
  end

  def edit_link
    content_tag(:a, EDIT_LINK, href: edit_path)
  end
  
  def delete_path
    self.id ? destroy_pattern_path(self) : nil
  end

  def delete_link
    content_tag(
      :a, DELETE_LINK, href: delete_path, rel: "nofollow",
      data: {
        remote: true, method: :delete,
        title: "パターン[#{self.name}]を削除しますか？",
        confirm: "削除しても[#{self.name}]が適用されたスケジュールは変更されません",
        cancel: CANCEL, commit: DELETE
      }
    )
  end

  def day_prefixed_time(day, time)
    day ? day + "" + time.to_hm : ""
  end

  def to_table_row
    [
      self.name,
      self.start_day + " " + self.start.to_hm,
      self.end_day + " " + self.end.to_hm,
      day_prefixed_time(self.rest_start_day, self.rest_start),
      day_prefixed_time(self.rest_end_day, self.rest_end),
      edit_link,
      delete_link
    ]
  end
end
