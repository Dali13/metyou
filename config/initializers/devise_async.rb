# config/initializers/devise_async.rb
Devise::Async.backend = :sidekiq
Devise::Async.queue = :default