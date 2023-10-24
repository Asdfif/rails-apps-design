class PaymentsController < ApplicationController
  CURRENCY = 'RUB'

  before_action :find_product, only: %i[create]

  def create
    return head :not_found unless @product

    result = Service::GatewayProcessor.call(
      gateway: CloudPayment,
      current_user: current_user,
      amount: payment_params[:amount] * 100,
      currency: CURRENCY,
      product: @product
    )

    if result.success?
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: 'Что-то пошло не так'
    end
  end

  private

  def find_product
    @product = Product.find_by_id(params[:product_id])
  end

  def payment_params
    params.permit(:amount)
  end
end
