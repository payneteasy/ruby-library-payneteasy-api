require 'payment_data/data'
require 'payment_data/customer'
require 'payment_data/billing_address'
require 'payment_data/credit_card'
require 'payment_data/recurrent_card'
require 'payment_data/payment_transaction'

module PaynetEasy::PaynetEasyApi::PaymentData
  class Payment < Data
    # Payment is new, and not processing
    STATUS_NEW        = 'new'

    # Payment is under preauth, or preauth is finished
    STATUS_PREAUTH    = 'preauth'

    # Payment is under capture, or capture is finished
    STATUS_CAPTURE    = 'capture'

    # Payment is under return, or return is finished
    STATUS_RETURN     = 'return'

    # All allowed payment statuses
    @@allowed_statuses =
    [
      STATUS_PREAUTH,
      STATUS_CAPTURE,
      STATUS_RETURN
    ]

    # Unique identifier of payment assigned by merchant
    #
    # @var [String]
    attr_accessor :client_id

    # Unique identifier of payment assigned by PaynetEasy
    #
    # @var [String]
    attr_accessor :paynet_id

    # Brief payment description
    #
    # @var [String]
    attr_accessor :description

    # Destination to where the payment goes
    #
    # @var [String]
    attr_accessor :destination

    # Amount to be charged
    #
    # @var [Float]
    attr_accessor :amount

    # Currency the transaction is charged in (three-letter currency code)
    #
    # @var [String]
    attr_accessor :currency

    # A short comment for payment
    #
    # @var [String]
    attr_accessor :comment

    # Payment status
    #
    # @var [String]
    attr_accessor :status

    # Payment customer
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::Customer]
    attr_accessor :customer

    # Payment billing address
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::BillingAddress]
    attr_accessor :billing_address

    # Payment credit card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::CreditCard]
    attr_accessor :credit_card

    # Payment source recurrent card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard]
    attr_accessor :recurrent_card_from

    # Payment destination recurrent card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard]
    attr_accessor :recurrent_card_to

    # Payment transactions for payment
    #
    # @var  [Array]
    attr_accessor :payment_transactions

    def amount_in_cents
      (amount * 100).to_i if amount
    end

    def customer=(customer)
      @customer = customer
    end

    def customer
      @customer ||= Customer.new
    end

    def billing_address=(billing_address)
      @billing_address = billing_address
    end

    def billing_address
      @billing_address ||= BillingAddress.new
    end

    def credit_card=(credit_card)
      @credit_card = credit_card
    end

    def credit_card
      @credit_card ||= CreditCard.new
    end

    def recurrent_card_from=(recurrent_card)
      @recurrent_card_from = recurrent_card
    end

    def recurrent_card_from
      @recurrent_card_from ||= RecurrentCard.new
    end

    def recurrent_card_to=(recurrent_card)
      @recurrent_card_to = recurrent_card
    end

    def recurrent_card_to
      @recurrent_card_to ||= RecurrentCard.new
    end

    def payment_transactions
      @payment_transactions ||= []
    end

    def add_payment_transaction(payment_transaction)
      unless has_payment_transaction? payment_transaction
        @payment_transactions << payment_transaction
      end

      unless payment_transaction.payment === self
        payment_transaction.payment = self
      end
    end

    def has_payment_transaction?(payment_transaction)
      payment_transactions.include? payment_transaction
    end

    # True, if the payment has a transaction that is currently being processed
    def has_processing_transaction?
      payment_transactions.one? &:processing?
    end

    def status=(status)
      unless @@allowed_statuses.include? status
        raise ArgumentError, "Unknown payment status given: '#{status}'"
      end

      @status = status
    end

    # True, if payment is new
    def new?
      status == STATUS_NEW
    end

    # True, is payment is paid up
    def paid?
      [STATUS_PREAUTH, STATUS_CAPTURE].include? status
    end

    # True, if funds returned to customer
    def returned?
      status == STATUS_RETURN
    end
  end
end
