class PaymentsController < ApplicationController
  CURRENCY = 'RUB'

  def create
    result = Service::GatewayProcessor.call(
      gateway: CloudPayment,
      current_user: current_user,
      amount: payment_params[:amount],
      currency: CURRENCY,
      product: @product,
      product_id: payment_params[:product_id]
    )

    if result.success?
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: 'Что-то пошло не так'
    end
  end

  private

  def payment_params
    params.permit(:amount, :product_id)
  end
end
