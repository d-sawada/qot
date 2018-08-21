class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :dayinfos, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_one :emp_emp_status, dependent: :destroy
  has_one :emp_status, through: :emp_emp_status, primary_key: :emp_status_id, foreign_key: :id
  has_many :holidays, through: :emp_emp_status, primary_key: :emp_status_id, foreign_key: :emp_status_id
  has_many :emp_status_historys, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code

  validates :no, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :emp_emp_status

  
  def email_reqired?
    false
  end
  def email_changed?
    false
  end
  def data_array
    [self.no, self.emp_emp_status.emp_status.name, self.name]
  end
end
