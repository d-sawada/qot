class Request < ApplicationRecord
  belongs_to :employee

  validates :employee_id, presence: true
  validates :state, presence: true, inclusion: { in: %w(申請中 棄却 承認済)}
  validates :employee_comment, length: { maximum: 255 }
  validates :admin_comment, length: { maximum: 255 }

  before_save :change_date
  
  def change_date
    date = Date.parse(self.date)
    y = date.year
    m = date.month
    d = date.day
    self.start = self.start.change(year: y, month: m, day: d)
    self.end = self.end.change(year: y, month: m, day: d)
  end
end
