class EmpStatus < ApplicationRecord
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers
  has_many :emp_emp_statuses, dependent: :destroy
  has_many :holidays, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code
  belongs_to :work_template

  validates :name, presence: true

  def to_table_row(template_names)
    [
      self.name, template_names[self.work_template_id],
      content_tag(:a, "編集", href: self.id.nil? ? nil : "/admin/setting?status=#{self.id}#nav-label-status"),
      content_tag(:a, "削除", href: self.id.nil? ? nil : destroy_status_path(self), rel: "nofollow", data: { remote: true, method: :delete,
          title: "雇用区分[#{self.name}]を削除しますか？", confirm: "削除しても[#{self.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]
  end
end
