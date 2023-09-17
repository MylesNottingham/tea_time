require "rails_helper"

RSpec.describe CustomerSubscription, type: :model do
  describe "relationships" do
    it { should belong_to(:customer) }
    it { should belong_to(:subscription) }
  end

  describe "validations" do
    it { should validate_presence_of :customer_id }
    it { should validate_presence_of :subscription_id }
    it { should validate_presence_of :status }
    it { should validate_presence_of :frequency }

    it { should define_enum_for(:status).with_values([:active, :cancelled]) }
    it { should define_enum_for(:frequency).with_values([:monthly, :quarterly, :semiannually, :annually]) }
  end

  describe "delegate" do
    it { should delegate_method(:title).to(:subscription) }
    it { should delegate_method(:price).to(:subscription) }
  end
end
