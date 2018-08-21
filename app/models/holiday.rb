class Holiday < ApplicationRecord
  belongs_to :emp_status
  belongs_to :emp_emp_status, primary_key: :emp_status_id, foreign_key: :emp_status_id
end
