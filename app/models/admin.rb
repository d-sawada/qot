class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :company, primary_key: :code, foreign_key: :company_code

  validates :is_super, presence: true
  validates :name, presence: true
  validates :email, presence: true
  validates :email, length: { maximum: 255 }
  validates :password, presence: true
end
