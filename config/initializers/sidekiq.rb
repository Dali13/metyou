if Rails.env.production?
  REDIS_PROVIDER = REDISCLOUD_URL
end