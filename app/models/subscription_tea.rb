class SubscriptionTea < ApplicationRecord
  belongs_to :subscription
  belongs_to :tea

  validates_presence_of :subscription_id
  validates_presence_of :tea_id
end
