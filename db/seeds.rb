# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

SysAdmin.delete_all
Company.delete_all
Admin.delete_all
Employee.delete_all
EmployeeAdditionalLabel.delete_all
EmployeeAdditionalValue.delete_all
Dayinfo.delete_all

SysAdmin.create({email: "sys_admin@email.com", password: "password", password_confirmation: "password" })
ga = Company.create({code: "ga0001", name: "GAtechnologies" })
ga.admins.create({email: "admin1@email.com", password: "password", password_confirmation: "password" })

labels = %w(名前 所属 部署)

labels.each do |label|
  ga.employee_additional_labels.create({name: label})
end

infos = [
  {"名前" => "emp1", "所属" => "本社", "部署" => "開発"},
  {"名前" => "emp2", "所属" => "本社", "部署" => "営業"},
  {"名前" => "emp3", "所属" => "本社", "部署" => "事務"},
  {"名前" => "emp4", "所属" => "支社", "部署" => "開発"},
  {"名前" => "emp5", "所属" => "支社", "部署" => "営業"}
]

(1..5).each do |i|
  ga.employees.create({email: "emp#{i}@email.com", password: "password", password_confirmation: "password" })
end

(1..5).each do |i|
  employee = ga.employees.find_by_email("emp#{i}@email.com")
  labels.each do |label|
    employee.employee_additional_values.create({employee_additional_label_id: EmployeeAdditionalLabel.find_by_name(label).id, value: infos[i-1][label]})
  end
  
  (1..5).each do |i|
    #s = rand(24 * 60 - 1) 
    #e = rand(24 * 60 - s) + s + 1
    #ss = ("0" + (s / 60).to_s).slice(-2,2) + ":" + ("0" + (s % 60).to_s).slice(-2,2)
    #es = ("0" + (e / 60).to_s).slice(-2,2) + ":" + ("0" + (e % 60).to_s).slice(-2,2)
    ss = Time.current
    es = Time.current + 3600
    employee.dayinfos.create({date: "2018-08-1" + i.to_s, start: ss, end: es})
  end
end
