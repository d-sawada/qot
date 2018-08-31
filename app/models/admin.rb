class Admin < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :company, primary_key: :code, foreign_key: :company_code

  validates :name, presence: true

  def update_with_password(params, * options)
    if params[:password].blank?
      params.delete(:password)
      if params[:password_confirmation].blank?
        params.delete(:password_confirmation)
      end
    end
    update_attributes(params, * options)
  end

  def is_super_mark
    if self.is_super
      return "〇"
    else
      return ""
    end
  end

  def edit_path
    if self.id.present?
      return setting_path(admin: self.id) + "#nav-label-admins"
    else
      return nil
    end
  end

  def edit_link
    return content_tag(:a, EDIT_LINK, href: edit_path)
  end

  def delete_path
    if self.id.present?
      return destroy_admin_path(self)
    else
      return nil
    end
  end

  def delete_link(current_admin_id)
    return LOGED_IN if current_admin_id == self.id
    return content_tag(:a, DELETE_LINK, href: delete_path, rel: "nofollow",
      data: {
        remote: true, method: :delete,
        title: "管理者[#{self.name}]を削除しますか？",
        cancel: CANCEL,
        commit: DELETE
      }
    )
  end

  def to_table_row(current_admin_id = nil)
    [
      is_super_mark,
      self.name,
      self.email,
      edit_link,
      delete_link(current_admin_id)
    ]
  end
end
