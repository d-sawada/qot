Rails.application.routes.draw do
  devise_for :admins
  mount RailsAdmin::Engine => '/system_admin', as: 'rails_admin'
  devise_for :sys_admins, skip: :all
  devise_for :employee, skip: :all

  devise_scope :sys_admin do
    get    'sign_in'  => 'sys_admins/sessions#new',     as: 'new_sys_admin_session'
    post   'sign_in'  => 'sys_admins/sessions#create',  as: 'sys_admin_session'
    delete 'sign_out' => 'sys_admins/sessions#destroy', as: 'destroy_sys_admin_session'
  end

  scope ':company_code' do
    devise_scope :employee do
      get    'employee/sign_in'  => 'employees/sessions#new',     as: 'new_employee_session'
      post   'employee/sign_in'  => 'employees/sessions#create',  as: 'employee_session'
      delete 'employee/sign_out' => 'employees/sessions#destroy', as: 'destroy_employee_session'
      resource :passwords,     as: 'employee_password',     path: 'employee/password',     module: 'employees', except: [:index, :show]
      resource :confirmations, as: 'employee_confirmation', path: 'employee/confirmation', module: 'employees', only: [:new, :create, :show]
      resource :registrations, as: 'employee_registration', path: 'employee',              module: 'employees', except: [:index, :show], path_names: {new: 'sign_up'} do
        get :cancel, on: :collection
      end
    end

    resources :employees
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
