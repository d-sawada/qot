class EmpEx < ApplicationRecord
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  has_many :ex_vals, dependent: :destroy
  belongs_to :company

  def edit_path
    if self.id
      return setting_path(emp_ex: self.id) + "#nav-label-emp-ex"
    else
      return nil
    end
  end

  def edit_link
    return content_tag(:a, EDIT_LINK, href: edit_path)
  end

  def delete_path
    if self.id
      return destroy_emp_ex_path(self)
    else
      nil
    end
  end

  def delete_link
    return content_tag(:a, DELETE_LINK, href: delete_path, rel: "nofollow",
      data: {
        remote: true, method: :delete,
        title: "追加情報[#{self.name}]を削除しますか？",
        cancel: CANCEL, commit: DELETE
      }
    )
  end

  def to_table_row
    [self.name, edit_link, delete_link]
  end
end
