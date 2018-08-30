SysAdmin.delete_all
SysAdmin.create({email: "sys_admin@email.com", password: "password", password_confirmation: "password" })

Company.delete_all
CompanyConfig.delete_all
EmpEx.delete_all
ga = Company.create({code: "ga0001", name: "GAtechnologies" })
busyo = ga.emp_exes.create({name: "部署"})
syozoku = ga.emp_exes.create({name: "所属"})

Admin.delete_all
ga.admins.create({name: "管理者1", email: "admin1@email.com", password: "password", password_confirmation: "password", is_super: true })

WorkPattern.delete_all
hei = ga.work_patterns.create({name: "平日",      start_day: "当日", start: "10:00", end_day: "当日", end: "19:00", rest_start_day: "当日", rest_start: "13:00", rest_end_day: "当日", rest_end: "14:00"})
asa = ga.work_patterns.create({name: "平日(朝会)", start_day: "当日", start: "9:00", end_day: "当日", end: "18:00", rest_start_day: "当日", rest_start: "13:00", rest_end_day: "当日", rest_end: "14:00"})

WorkTemplate.delete_all
normal = ga.work_templates.create({name: "通常", mon: asa.id, tue: hei.id, wed: hei.id, thu: hei.id, fri: hei.id})
asanashi = ga.work_templates.create({name: "朝会無し", mon: hei.id, tue: hei.id, wed: hei.id, thu: hei.id, fri: hei.id})
ga.work_templates.create({name: "土曜勤務", mon: hei.id, wed: hei.id, thu: hei.id, fri: hei.id, sat: hei.id})

EmpStatus.delete_all
regular = ga.emp_statuses.create({name: "正社員", work_template_id: normal.id })
ga.emp_statuses.create({name: "アルバイト", work_template_id: asanashi.id})

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
ExVal.delete_all
(1..100).each do |i|
  if emp = ga.employees.create({no: "000#{i}".slice(-4,4), name: "従業員 #{i}", email: "emp#{i}@email.com", password: "password", password_confirmation: "password"})
    EmpEmpStatus.create({employee_id: emp.id, emp_status_id: regular.id + (i <= 50 ? 0 : 1), company_id: ga.id})
    emp.ex_vals.create({emp_ex_id: busyo.id, value: "SDD"})
    emp.ex_vals.create({emp_ex_id: syozoku.id, value: "本社"})
  end
end

Dayinfo.delete_all
ga.employees.each do |emp|  
  (1..31).each do |i|
    wd = DateTime.new(2018,8,i).wday
    if wd != 6 && wd != 0
      sr = rand(21) - 10
      er = rand(21) - 10
      if wd == 1
        s = DateTime.new(2018,8,i,8,45+sr,0,0.375)
        e = DateTime.new(2018,8,i,18,15+er,0,0.375)
      elsif
        s = DateTime.new(2018,8,i,9,45+sr,0,0.375)
        e = DateTime.new(2018,8,i,19,15+er,0,0.375)
      end
      emp.dayinfos.create({date: "2018-08-" + i.to_s, start: s, end: e})
    end
  end
end

Request.delete_all
