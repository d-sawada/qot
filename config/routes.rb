Rails.application.routes.draw do
  devise_for :sys_admins
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
