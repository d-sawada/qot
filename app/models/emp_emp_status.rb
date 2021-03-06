class EmpEmpStatus < ApplicationRecord
  belongs_to :company
  belongs_to :employee
  belongs_to :emp_status
  
  rails_admin do
    edit do
      configure :holidays do
        visible false
      end
    end
  end

  after_save :create_emp_status_history

  def create_emp_status_history
    sd = Date.new(1970)
    nd = Date.current
    ed = Date.new(2200)
    name = EmpStatus.find(self.emp_status_id).name
    latest = self.employee.emp_status_historys.find_by_end(ed)
    if latest
      latest.update({end: nd})
      self.employee.emp_status_historys
        .create({start: nd, end: ed, emp_status_str: name})
    else
      self.employee.emp_status_historys
        .create({start: sd, end: ed, emp_status_str: name})
    end
  end
end
