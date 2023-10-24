class CloudPayment
  VALID_STATUS = 'completed'

  class << self
    def proccess(user_uid:, amount_cents:, currency:)
      { status: VALID_STATUS }
    end
  end
end
