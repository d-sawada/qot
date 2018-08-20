class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :dayinfos, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_one :emp_emp_status, dependent: :destroy
  has_many :holidays, through: :emp_emp_status, primary_key: :emp_status_id, foreign_key: :emp_status_id
  belongs_to :company, primary_key: :code, foreign_key: :company_code
end
