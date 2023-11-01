class CloudPayment
  SUCCESS_STATUS = 'completed'

  class << self
    def proccess(user_uid:, amount_cents:, currency:)
      @result = { status: SUCCESS_STATUS }
    end

    def success?
      return if result.nil?

      result[:status] == SUCCESS_STATUS
    end

    private

    attr_reader :result
  end
end
