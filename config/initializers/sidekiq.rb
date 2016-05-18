if Rails.env.production?
  
  require 'sidekiq_calculations'

Sidekiq.configure_client do |config|
  sidekiq_calculations = SidekiqCalculations.new
  sidekiq_calculations.raise_error_for_env!

  config.redis = {
    url: ENV['REDISCLOUD_URL'],
    size: sidekiq_calculations.client_redis_size
  }
end

Sidekiq.configure_server do |config|
  sidekiq_calculations = SidekiqCalculations.new
  sidekiq_calculations.raise_error_for_env!

  config.options[:concurrency] = sidekiq_calculations.server_concurrency_size
  config.redis = {
    url: ENV['REDISCLOUD_URL']
  }
end

else
  
  Sidekiq.configure_client do |config|
    config.redis = { :namespace => 'Rsidekiq', :url => 'redis://127.0.0.1:6379/1' }
  end

  Sidekiq.configure_server do |config|
    config.redis = { :namespace => 'Rsidekiq', :url => 'redis://127.0.0.1:6379/1' }
  end

end

Sidekiq.configure_server do |config|  
  schedule_file = "config/sidekiq_schedule.yml"

  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end  