class Request < ApplicationRecord
  belongs_to :employee

  validates :employee_id, presence: true
  validates :state, presence: true, inclusion: { in: %w(申請中 棄却 承認済)}
  validates :employee_comment, length: { maximum: 255 }
  validates :admin_comment, length: { maximum: 255 }
end
