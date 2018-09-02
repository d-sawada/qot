class Request < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers

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

  def detail_link
    content_tag(:a, DETAIL_LINK, href: request_path(self.id))
  end

  def to_table_row(emp_names = nil, admin_names = nil)
    applier = 
      case
      when self.admin_id.blank?
        "本人"
      when admin_names
        admin_names[self.admin_id]
      else
        Admin.find(self.admin_id).name
      end
    emp_name = emp_names ? emp_names[self.employee_id] : self.employee.name
    row = [
      self.state,
      applier,
      emp_name,
      self.date.tr('-', '/'),
      self.prev_start.to_hm,
      self.prev_end.to_hm,
      self.start.to_hm,
      self.end.to_hm
    ]
    row << detail_link if emp_names
    row
  end
end
