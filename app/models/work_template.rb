class WorkTemplate < ApplicationRecord
  include ActionView::Helpers::TagHelper
  belongs_to :company
  has_one :emp_status

  def to_table_row(pattern_names)
    row = [self.name]
    [self.mon, self.tue, self.wed, self.thu, self.fri, self.sat, self.sun].each do |id|
      row << (id.present? ? pattern_names[id] : nil)
    end
    p row
    row << content_tag(:a, "編集", href: self.id.nil? ? nil : "/admin/setting?template=#{self.id}#nav-label-template") <<
      content_tag(:a, "削除", href: "/admin/destroy_template/#{self.id}", rel: "nofollow",
          data: { remote: true, method: :delete, title: "テンプレート[#{self.name}]を削除しますか？", confirm: "削除しても[#{self.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する" }
      )
  end
end
