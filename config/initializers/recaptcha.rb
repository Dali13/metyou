# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.public_key  = ENV['CAPTCHA_PUBLIC_KEY']
  config.private_key = ENV['CAPTCHA_PRIVATE_KEY']
  config.use_ssl_by_default = true
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end