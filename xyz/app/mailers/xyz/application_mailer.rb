module Xyz
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
