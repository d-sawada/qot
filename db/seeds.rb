SysAdmin.delete_all
SysAdmin.create({email: "sys_admin@email.com", password: "password", password_confirmation: "password" })

Company.delete_all
ga = Company.create({code: "ga0001", name: "GAtechnologies" })

Admin.delete_all
ga.admins.create({name: "管理者1", email: "admin1@email.com", password: "password", password_confirmation: "password" })

EmpStatus.delete_all
regular = ga.emp_statuses.create({name: "正社員"})
ga.emp_statuses.create({name: "アルバイト"})

Holiday.delete_all
(1..12).each do |m|
  (1..Date.new(2018, m).end_of_month.day).each do |d|
    ga.emp_statuses.each do |emp_status|
      dt = Date.new(2018, m, d)
      if dt.wday == 6 || dt.wday == 0
        emp_status.holidays.create({date: dt})
      end
    end
  end
end

Employee.delete_all
EmpEmpStatus.delete_all
EmpStatusHistory.delete_all
(1..100).each do |i|
  if emp = ga.employees.create({no: "000#{i}".slice(-4,4), name: "従業員 #{i}", email: "emp#{i}@email.com", password: "password", password_confirmation: "password"})
    EmpEmpStatus.create({employee_id: emp.id, emp_status_id: regular.id + (i <= 50 ? 0 : 1), company_id: ga.id})
  end
end

Dayinfo.delete_all
ga.employees.each do |emp|  
  (1..31).each do |i|
    wd = DateTime.new(2018,8,i).wday
    if wd != 6 && wd != 0
      if wd == 1
        s = DateTime.new(2018,8,i,8,45,0,0.375)
        e = DateTime.new(2018,8,i,18,15,0,0.375)
        ps = DateTime.new(2018,8,i,9,0,0,0.375)
        pe = DateTime.new(2018,8,i,18,0,0,0.375)
      elsif
        s = DateTime.new(2018,8,i,9,45,0,0.375)
        e = DateTime.new(2018,8,i,19,15,0,0.375)
        ps = DateTime.new(2018,8,i,10,0,0,0.375)
        pe = DateTime.new(2018,8,i,19,0,0,0.375)
      end
      rs = DateTime.new(2018,8,i,13,0,0,0.375)
      re = DateTime.new(2018,8,i,14,0,0,0.375)
      emp.dayinfos.create({date: "2018-08-" + i.to_s, start: s, end: e, pre_start: ps, pre_end: pe, rest_start: rs, rest_end: re})
    end
  end
end

Request.delete_all
