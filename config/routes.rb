# frozen_string_literal: true

Rails.application.routes.draw do
  get 'admin', to: 'admin#index'

  resources :prompts do
    collection do
      get 'last'
      get 'story'
    end

    member do
      post 'report'
    end
  end

  resources :deli_counter do
    collection do
      post 'ticket'
      post 'now_serving'
      post 'heartbeat'
    end
  end

  root 'home#index'
end
