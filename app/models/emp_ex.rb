class EmpEx < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  has_many :ex_vals, dependent: :destroy
  belongs_to :company

  def to_table_row
    [self.name, edit_link, delete_link]
  end

  private

  def edit_path
    self.id ? setting_path(emp_ex: self.id) + "#nav-label-emp-ex" : nil
  end

  def edit_link
    content_tag(:a, EDIT_LINK, href: edit_path)
  end

  def delete_path
    self.id ?  destroy_emp_ex_path(self) : nil
  end

  def delete_link
    content_tag(:a, DELETE_LINK, href: delete_path, rel: "nofollow",
      data: {
        remote: true, method: :delete,
        title: "追加情報[#{self.name}]を削除しますか？",
        cancel: CANCEL, commit: DELETE
      }
    )
  end
end
