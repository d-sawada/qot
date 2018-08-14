Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/system_admin', as: 'rails_admin'
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :sys_admins, skip: :all
  devise_for :admins, skip: :all
  devise_for :employee, skip: :all

  devise_scope :sys_admin do
    get    'sign_in'  => 'sys_admins/sessions#new',     as: 'new_sys_admin_session'
    post   'sign_in'  => 'sys_admins/sessions#create',  as: 'sys_admin_session'
    delete 'sign_out' => 'sys_admins/sessions#destroy', as: 'destroy_sys_admin_session'
  end

  devise_scope :admin do
    get    ':company_code/admin/sign_in'  => 'admins/sessions#new',     as: 'new_admin_session'
    post   ':company_code/admin/sign_in'  => 'admins/sessions#create',  as: 'admin_session'
    delete ':company_code/admin/sign_out' => 'admins/sessions#destroy', as: 'destroy_admin_session'
    resource :passwords,     as: 'admin_password',     path: 'admin/password',     module: 'admins', except: [:index, :show]
    resource :confirmations, as: 'admin_confirmation', path: 'admin/confirmation', module: 'admins', only: [:new, :create, :show]
    resource :registrations, as: 'admin_registration', path: 'admin',              module: 'admins', except: [:index, :show], path_names: {new: 'sign_up'} do
      get :cancel, on: :collection
    end
  end

  scope :admin do
    get 'setting' => 'companies#setting', as: 'setting'
    resources :employee_additional_labels, only: [:create, :destroy]
    resources :admins, only: [:index]
    resources :employees, except: [:new, :create]
  end

  devise_scope :employee do
    get    ':company_code/employee/sign_in'  => 'employees/sessions#new',     as: 'new_employee_session'
    post   ':company_code/employee/sign_in'  => 'employees/sessions#create',  as: 'employee_session'
    delete ':company_code/employee/sign_out' => 'employees/sessions#destroy', as: 'destroy_employee_session'
    resource :passwords,     as: 'employee_password',     path: 'employee/password',     module: 'employees', except: [:index, :show]
    resource :confirmations, as: 'employee_confirmation', path: 'employee/confirmation', module: 'employees', only: [:new, :create, :show]
    resource :registrations, as: 'employee_registration', path: 'employee',              module: 'employees', except: [:index, :show], path_names: {new: 'sign_up'} do
      get :cancel, on: :collection
    end
  end

  get 'timecard' => 'dayinfos#new', as: 'timecard'
  put 'timecard' => 'dayinfos#put'
end
