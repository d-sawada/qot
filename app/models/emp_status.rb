class EmpStatus < ApplicationRecord
  has_one :work_template
  has_many :emp_emp_statuses, dependent: :destroy
  has_many :holidays, dependent: :destroy
  belongs_to :company, primary_key: :code, foreign_key: :company_code
end
