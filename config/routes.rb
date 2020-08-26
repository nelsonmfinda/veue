# frozen_string_literal: true

Rails.application.routes.draw do
  resources :videos, only: %i[index show new] do
    collection do
      get "broadcast"
    end
  end

  resources :chat_messages, only: [:create] do
    get :grouped_message, as: :member
  end

  post "/mux/webhook", to: "mux_webhooks#index"

  devise_for :users

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "videos#index"
end
