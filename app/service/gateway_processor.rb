module Service
  class GatewayProcessor < Trailblazer::Operation
    step :gateway_process
    step :validate_payment
    step :create_product_access
    step :send_order_mail

    def gateway_process(ctx, params)
      ctx[:payment_result] = params[:gateway].proccess(
        user_uid: params[:current_user].cloud_payments_uid,
        amount_cents: params[:amount],
        currency: params[:currency]
      )
    end

    def validate_payment(ctx, params)
      ctx[:payment_result][:status] == 'completed'
    end

    def create_product_access(ctx, params)
      ctx[:product_access] = ProductAccess.create(
        user: params[:current_user],
        product: params[:product]
      )
    end

    def send_order_mail(ctx, params)
      OrderMailer.product_access_email(ctx[:product_access]).deliver_later
    end
  end
end
