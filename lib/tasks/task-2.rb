class PrepareDelivery
  class DeliveryError < StandardError; end

  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze
  REQUIRED_ADDRESS_PARAMS = %w[house city street].freeze

  ERROR_STATUS = "error".freeze

  attr_reader :order, :user

  def initialize(order, user)
    @order = order
    @user = user
    @result = {
      truck: nil,
      weight: nil,
      order_number: order.id,
      address: destination_address,
      status: :ok
    }
  end

  def perform(destination_address, delivery_date)
    validate_delivery_date!(delivery_date)
    validate_destination_address!(destination_address)
    check_weight!

   rescue DeliveryError
    result[:satus] = ERROR_STATUS
   ensure
    result
  end

  private

  attr_reader :result

  def validate_delivery_date!(delivery_date)
    raise DeliveryError.new("Дата доставки уже прошла") if delivery_date < Time.current
  end

  def validate_destination_address!(destination_address)
    REQUIRED_ADDRESS_PARAMS.each do |addr|
      raise DeliveryError.new("Invalid #{addr}") if destination_address.try(addr).blank?
    end
  end

  def check_weight!
    raise DeliveryError.new("Нет машин грузоподъемностью более #{weight}") unless set_available_truck
  end

  def set_available_truck
    result[:truck] = available_truck
  end

  def available_truck
    TRUCKS.find { |_, v| v > weight }&.first
  end

  def weight
    @weight ||= order.products.sum(&:weight)
  end
end

class Order
  def id
    'id'
  end

  def products
    [OpenStruct.new(weight: 20), OpenStruct.new(weight: 40)]
  end
end

class Address
  def city
    "Ростов-на-Дону"
  end

  def street
    "ул. Маршала Конюхова"
  end

  def house
    "д. 5"
  end
end

PrepareDelivery.new(Order.new, OpenStruct.new).perform(Address.new, Date.tomorrow)
