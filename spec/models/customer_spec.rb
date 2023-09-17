require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "relationships" do
    it { should have_many(:customer_subscriptions) }
    it { should have_many(:subscriptions).through(:customer_subscriptions) }
    it { should have_many(:subscription_teas).through(:subscriptions) }
    it { should have_many(:teas).through(:subscription_teas) }
  end

  describe "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :address }
  end
end
