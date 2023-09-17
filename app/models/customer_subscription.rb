class CustomerSubscription < ApplicationRecord
  belongs_to :customer
  belongs_to :subscription

  enum status: [:active, :cancelled], _default: :active
  enum frequency: [:monthly, :quarterly, :semiannually, :annually], _default: :monthly

  validates_presence_of :customer_id
  validates_presence_of :subscription_id
  validates_presence_of :status
  validates_presence_of :frequency

  delegate :title, :price, to: :subscription
end
