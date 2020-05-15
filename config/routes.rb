# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'

  resources :prompts do
    collection do
      get 'last'
    end

    member do
      post 'report'
    end
  end

  root 'home#index'
end
