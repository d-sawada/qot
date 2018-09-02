class WorkTemplate < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  has_one :emp_status
  belongs_to :company

  validates :name, presence: true
  validate :least_have_one_pattern

  def least_have_one_pattern
    week_syms.each{ |sym| return if self[sym].present? }
    errors.add(:name, "にパターンを１つ以上設定してください")
  end

  def edit_path
    self.id ? setting_path(template: self.id) + "#nav-label-template" : nil
  end

  def edit_link
    content_tag(:a, EDIT_LINK, href: edit_path)
  end

  def delete_path
    destroy_template_path(self)
  end

  def delete_link
    content_tag(:a, DELETE_LINK, href: delete_path, rel: "nofollow",
      date: {
        remote: true, method: :delete,
        title: "テンプレート[#{self.name}]を削除しますか？",
        confirm: "削除しても[#{self.name}]が適用されたスケジュールは変更されません",
        cancel: CANCEL, commit: DELETE
      }
    )
  end
  
  def to_table_row(pattern_names)
    row = [self.name]
    week_syms_mon.each do |sym|
      id = self[sym]
      row << (id ? pattern_names[id] : nil)
    end
    row << edit_link << delete_link
  end
  
  def pattern_id_of(date)
    self[week_syms[date.wday]]
  end
end
