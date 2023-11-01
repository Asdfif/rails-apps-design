module Service
  class GatewayProcessor < Trailblazer::Operation
    step :find_product
    step :gateway_process
    step :check_payment_status
    step :create_product_access
    step :send_order_mail
    step :setup_delivery

    def find_product(ctx, product_id:, **)
      ctx[:product] = Product.find_by_id(product_id)
    end

    def gateway_process(ctx, gateway:, current_user:, amount:, currency:, **)
      gateway.proccess(
        user_uid: current_user.cloud_payments_uid,
        amount_cents: amount * 100,
        currency: currency
      )
    end

    def check_payment_status(ctx, gateway:, **)
      gateway.success?
    end

    def create_product_access(ctx, current_user:, product:, **)
      ctx[:product_access] = ProductAccess.create(
        user: current_user,
        product: product
      )
    end

    def send_order_mail(ctx, product_access:, **)
      OrderMailer.product_access_email(product_access).deliver_later
    end

    def setup_delivery(ctx, current_user:, product:, **)
      Sdek.setup_delivery(address: current_user, person:, weight:)
    end
  end
end
