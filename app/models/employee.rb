class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :employee_additional_values, dependent: :destroy
  has_many :dayinfos, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code
end
