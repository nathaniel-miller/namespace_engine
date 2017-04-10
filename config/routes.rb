Rails.application.routes.draw do
  mount MyNamespace::MyEngine::Engine => '/my_engine', as: 'my_engine' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
