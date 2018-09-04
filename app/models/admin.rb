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
      params.delete(:password_confirmation) if params[:password_confirmation]
    end
    update_attributes(params, * options)
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

  private

  def is_super_mark
    self.is_super ? "〇" : ""
  end

  def edit_path
    self.id ? setting_path(admin: self.id) + "#nav-label-admins" : nil
  end

  def edit_link
    content_tag(:a, EDIT_LINK, href: edit_path, rel: "nofllow")
  end

  def delete_path
    self.id ? destroy_admin_path(self) : nil
  end

  def delete_link(current_admin_id)
    if current_admin_id == self.id
      LOGED_IN
    else
      content_tag(
        :a, DELETE_LINK, href: delete_path, rel: "nofollow",
        data: {
          remote: true, method: :delete,
          title: "管理者[#{self.name}]を削除しますか？",
          confirm: " ",
          cancel: CANCEL, commit: DELETE
        }
      )
    end
  end
end
