class Holiday < ApplicationRecord
  belongs_to :emp_status, dependent: :destroy
  belongs_to :emp_emp_status, primary_key: :emp_status_id, foreign_key: :emp_status_id
end
