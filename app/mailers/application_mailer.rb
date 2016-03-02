class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@sendgrid.com"
  layout 'mailer'
end
