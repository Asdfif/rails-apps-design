class PrepareDelivery
  class DeliveryError < StandardError; end
  class DeliveryDateError < DeliveryError; end
  class DeliveryAddressError < DeliveryError; end
  class DeliveryTruckError < DeliveryError; end

  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze
  ERROR_STATUS = "error".freeze

  attr_reader :order, :user

  def initialize(order, user)
    @order = order
    @user = user
  end

  def perform(destination_address, delivery_date)
    init_result
    validate_delivery_date!(delivery_date)
    validate_destination_address!(destination_address)
    check_truck!

   rescue DeliveryError
    result[:satus] = ERROR_STATUS
   ensure
    result
  end

  private

  attr_reader :result

  def init_result
    @result = { truck: nil, weight: nil, order_number: order.id, address: destination_address, status: :ok }
  end

  def validate_delivery_date!(delivery_date)
    raise DeliveryDateError.new("Дата доставки уже прошла") if delivery_date < Time.current
  end

  def validate_destination_address!(destination_address)
    raise DeliveryAddressError.new("Нет адреса") if destination_address.city.empty? || destination_address.street.empty? || destination_address.house.empty?
  end

  def check_truck!
    raise DeliveryTruckError.new("Нет машин") unless set_available_truck
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
