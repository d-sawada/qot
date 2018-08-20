class Holiday < ApplicationRecord
  belongs_to :emp_status, dependent: :destroy
end
