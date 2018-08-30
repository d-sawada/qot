class EmpEx < ApplicationRecord
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers
  has_many :ex_vals, dependent: :destroy
  belongs_to :company

  def to_table_row
    [
      self.name,
      content_tag(:a, "編集", href: self.id.nil? ? nil : "/admin/setting?emp_ex=#{self.id}#nav-label-emp-ex"),
      content_tag(:a, "削除", href: self.id.nil? ? nil : destroy_emp_ex_path(self), rel: "nofollow", data: { remote: true, method: :delete,
          title: "追加情報[#{self.name}]を削除しますか？", cancel: "やめる", commit: "削除する"})
    ]
  end
end
