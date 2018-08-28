class WorkPattern < ApplicationRecord
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers
  belongs_to :company
  validates :company_id, presence: true
  validates :name,  presence: true
  validates :start, presence: true
  validates :end,   presence: true
  validates :start_day, inclusion: { in: %w(前日 当日 翌日) }
  validates :end_day,   inclusion: { in: %w(前日 当日 翌日) }

  before_save :erase_rest_day

  def erase_rest_day
    self.rest_start_day = nil if self.rest_start.blank?
    self.rest_end_day = nil if self.rest_end.blank?
  end
  def to_table_row
    [
      self.name,
      self.start_day + " " + self.start.to_hm,
      self.end_day + " " + self.end.to_hm,
      self.rest_start_day.present? ? self.rest_start_day + " " + self.rest_start.to_hm : "",
      self.rest_end_day.present? ? self.rest_end_day + " " + self.rest_end.to_hm : "",
      content_tag(:a, "編集", href: self.id.nil? ? nil : "/admin/setting?pattern=#{self.id}#nav-label-pattern"),
      content_tag(:a, "削除", href: self.id.nil? ? nil : destroy_pattern_path(self), rel: "nofollow", data: { remote: true, method: :delete,
          title: "パターン[#{self.name}]を削除しますか？", confirm: "削除しても[#{self.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]
  end
end
