Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/system_admin', as: 'rails_admin'
  devise_for :sys_admins
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
