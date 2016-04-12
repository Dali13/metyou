if Rails.env.production?
  REDIS_PROVIDER = ENV["REDISCLOUD_URL"]
end