class OrderMailer < ApplicationMailer
  def product_access_email(product_access)
    mail to: 'test', subject: 'test'
  end
end
