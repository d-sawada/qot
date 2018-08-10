json.extract! employee, :id, :email, :password, :password_confirmation, :created_at, :updated_at
json.url employee_url(employee, format: :json)
