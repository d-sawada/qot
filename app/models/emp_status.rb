class EmpStatus < ApplicationRecord
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  has_many :emp_emp_statuses
  has_many :employees, through: :emp_emp_statuses
  has_many :holidays, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code
  belongs_to :work_template

  validates :name, presence: true

  def edit_path
    if self.id
      return setting_path(status: self.id) + "#nav-label-status"
    else
      nil
    end
  end

  def edit_link
    return content_tag(:a, EDIT_LINK, href: edit_path)
  end

  def delete_path
    if self.id
      return destroy_status_path(self.id)
    else
      nil
    end
  end

  def delete_link
    return content_tag(:a, DELETE_LINK, href: delete_path, rel: "nofollow",
      data: {
        remote: true, method: :destroy,
        title: "雇用区分[#{self.name}]を削除しますか？",
        confirm: "削除すると雇用区分[#{self.name}]が関連づけられた社員が全て削除されます"
        cancel: CANCEL, commit: DELETE
      }
    )
  end

  def to_table_row(template_names)
    [self.name, template_name[self.work_template_id], edit_link, delete_link]
  end
end
