class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :dayinfos, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_one :emp_emp_status, dependent: :destroy
  has_one :emp_status, through: :emp_emp_status, primary_key: :emp_status_id, foreign_key: :id
  has_many :holidays, through: :emp_status, primary_key: :id, foreign_key: :emp_status_id
  has_many :emp_status_historys, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code
  has_one :work_template, through: :emp_status, primary_key: :work_template_id, foreign_key: :id
  accepts_nested_attributes_for :emp_emp_status

  validates :no, presence: true
  validates :no, length: { is: 4 }, if: ->(u) { u.no.present? }
  validates :name, presence: true
  validate :no_uniqu_in_company?

  def no_uniqu_in_company?
    if self.company.employees.find_by_no(self.no).present?
      errors.add(:no, "#{self.no}はすでに使われている社員番号です")
    end
  end
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
