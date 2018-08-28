class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :company, primary_key: :code, foreign_key: :company_code

  validates :name, presence: true

  def to_table_row
    [
      (self.is_super ? "〇" : ""), self.name, self.email,
      content_tag(:a, "編集", href: self.id.nil? ? nil : "/admin/setting?admin=#{self.id}#nav-label-admins"),
      content_tag(:a, "削除", href: (self.id.nil? ? nil : destroy_admin_path(self)), rel: "nofollow", data: { remote: true, method: :delete,
          title: "管理者[#{self.name}]を削除しますか？", cancel: "やめる", commit: "削除する"})
    ]
  end
end
