Rails.application.routes.draw do

  root "companies#top"
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

    post 'create_pattern' => 'companies#create_pattern', as: 'create_pattern'
    patch 'update_pattern/:id' => 'companies#update_pattern', as: 'update_pattern'
    delete 'destroy_pattern/:id' => 'companies#destroy_pattern', as: 'destroy_pattern'

    post 'create_template' => 'companies#create_template', as: 'create_template'
    patch 'update_template/:id' => 'companies#update_template', as: 'update_template'
    delete 'destroy_template/:id' => 'companies#destroy_template', as: 'destroy_template'
    
    post 'create_status' => 'companies#create_status', as: 'create_status'
    patch 'update_status/:id' => 'companies#update_status', as: 'update_status'
    delete 'destroy_status/:id' => 'companies#destroy_status', as: 'destroy_status'

    post 'create_admin' => 'companies#create_admin', as: 'create_admin'
    patch 'update_admin/:id' => 'companies#update_admin', as: 'update_admin'
    delete 'destroy_admin/:id' => 'companies#destroy_admin', as: 'destroy_admin'

    patch 'update_company_config' => 'companies#update_company_config', as: 'update_company_config'
    
    resources :admins, only: [:index]
    resources :employees do
      post :update_employees, as: 'update', on: :collection
    end
    get 'daily' => 'employees#daily_index', as: 'daily_index'
    get 'daily/:id'=> 'employees#daily_show', as: 'daily_show'
    get 'monthly'=> 'employees#monthly_index', as: 'monthly_index'
    get 'monthly:id'=> 'employees#monthly_show', as: 'monthly_show'
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

  scope :employee do
    get 'list' => 'employees#show', as: 'employee_list'
  end

  get 'top' => 'companies#top', as: 'top'
  post 'top' => 'companies#check_company', as: 'check_company'
  post 'create_company' => 'companies#create_company', as: 'create_company'
  get 'after_create_company' => 'companies#after_create_company', as: 'after_create_company'

  get 'timecard' => 'dayinfos#new', as: 'timecard'
  put 'timecard' => 'dayinfos#put'

  resources :requests, only: [:index, :new, :create, :show, :update]
end
