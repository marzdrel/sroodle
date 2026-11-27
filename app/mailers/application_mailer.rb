class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM") { "Sroodle <no-reply@#{default_url_options.fetch(:host, "localhost")}>" } }
  layout "mailer"
end
