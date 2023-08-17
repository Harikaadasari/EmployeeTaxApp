Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :employees, only: [:create, :index, :update, :destroy]
      get '/employees/tax_deduction', to: 'employees#tax_deduction'
    end
  end
end
