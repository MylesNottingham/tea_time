class CustomerSubscription < ApplicationRecord
  belongs_to :customer
  belongs_to :subscription

  enum status: [:active, :cancelled]
  enum frequency: [:monthly, :quarterly, :semiannually, :annually]

  after_initialize :set_defaults

  private

  def set_defaults
    self.status ||= 0
    self.frequency ||= 0
  end
end
