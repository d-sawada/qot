Rails.application.routes.draw do
  devise_for :employees
  resources :employees
  mount RailsAdmin::Engine => '/system_admin', as: 'rails_admin'
  devise_for :sys_admins, skip: :all

  devise_scope :sys_admin do
    get    'sign_in'  => 'sys_admins/sessions#new',     as: 'new_sys_admin_session'
    post   'sign_in'  => 'sys_admins/sessions#create',  as: 'sys_admin_session'
    delete 'sign_out' => 'sys_admins/sessions#destroy', as: 'destroy_sys_admin_session'
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
