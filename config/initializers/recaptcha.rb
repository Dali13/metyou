# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.public_key  = '6LdVPhUTAAAAAGbjtUD44AuMWC2lX_67ccKHfu4x'
  config.private_key = '6LdVPhUTAAAAAP36MOq6gQooRDjkOCYCBPUs3tmI'
  config.use_ssl_by_default = true
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end