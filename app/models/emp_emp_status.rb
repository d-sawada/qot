class EmpEmpStatus < ApplicationRecord
  has_many :holidays, primary_key: :emp_status_id, foreign_key: :emp_status_id, dependent: :destroy
  belongs_to :company
  belongs_to :emp_status
  belongs_to :employee
end
