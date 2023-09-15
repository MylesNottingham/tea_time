class CustomerSubscription < ApplicationRecord
  belongs_to :customers
  belongs_to :subscriptions
end
