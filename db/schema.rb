# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_26_141204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "company_code", default: "", null: false
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_super", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_companies_on_code", unique: true
  end

  create_table "company_configs", force: :cascade do |t|
    t.integer "company_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dayinfos", force: :cascade do |t|
    t.integer "employee_id"
    t.date "date"
    t.datetime "pre_start"
    t.datetime "pre_end"
    t.datetime "start"
    t.datetime "end"
    t.datetime "rest_start"
    t.datetime "rest_end"
    t.integer "pre_workdays"
    t.integer "pre_worktimes"
    t.integer "workdays"
    t.integer "worktimes"
    t.integer "holiday_workdays"
    t.integer "holiday_worktimes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emp_emp_statuses", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "emp_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emp_status_histories", force: :cascade do |t|
    t.date "start"
    t.date "end"
    t.string "emp_status_str"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emp_statuses", force: :cascade do |t|
    t.string "company_code", null: false
    t.string "name", null: false
    t.integer "work_template_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "company_code", null: false
    t.string "no", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true
  end

  create_table "holidays", force: :cascade do |t|
    t.integer "emp_status_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "admin_id"
    t.string "state", null: false
    t.string "date", null: false
    t.datetime "prev_start"
    t.datetime "prev_end"
    t.datetime "start"
    t.datetime "end"
    t.text "employee_comment"
    t.text "admin_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sys_admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_sys_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sys_admins_on_reset_password_token", unique: true
  end

  create_table "work_patterns", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.datetime "start", null: false
    t.datetime "end", null: false
    t.datetime "rest_start"
    t.datetime "rest_end"
    t.string "start_day", null: false
    t.string "end_day", null: false
    t.string "rest_start_day"
    t.string "rest_end_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_templates", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.integer "mon"
    t.integer "tue"
    t.integer "wed"
    t.integer "thu"
    t.integer "fri"
    t.integer "sat"
    t.integer "sun"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
