require "rails_helper"

RSpec.describe "Api::V1::Subscriptions", type: :request do
  before :each do
    # Creates 9 teas
    9.times do
      Tea.create!(
        title: Faker::Tea.variety,
        description: Faker::Coffee.notes,
        temperature: Faker::Number.between(from: 100, to: 200),
        brew_time: Faker::Number.between(from: 1, to: 10)
      )
    end

    # Creates 3 subscriptions
    3.times do
      Subscription.create!(
        title: Faker::Tea.type,
        price: Faker::Number.between(from: 5, to: 10)
      )
    end

    # Creates 9 SubscriptionTeas from the 3 subscriptions and 9 teas
    tea_ids = Tea.all.pluck(:id)

    Subscription.all.each_with_index do |subscription, index|
      3.times do |i|
        SubscriptionTea.create!(
          subscription_id: subscription.id,
          tea_id: tea_ids[i + (index * 3)]
        )
      end
      index += 1
    end

    # Creates 3 Customers
    3.times do
      Customer.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        address: Faker::Address.street_address
      )
    end

    # Creates 3 CustomerSubscriptions
    subscription_ids = Subscription.all.pluck(:id)
    # Default customer subscription
    CustomerSubscription.create!(
      customer_id: Customer.first.id,
      subscription_id: subscription_ids[0]
    )

    # Customer subscription with status 1 and frequency 1
    CustomerSubscription.create!(
      customer_id: Customer.first.id,
      subscription_id: subscription_ids[1],
      status: 1,
      frequency: 1
    )

    # Customer subscription with status 1 and frequency 2
    CustomerSubscription.create!(
      customer_id: Customer.first.id,
      subscription_id: subscription_ids[2],
      status: 1,
      frequency: 2
    )
  end

  describe "GET /index" do
    context "happy path" do
      it "returns all subcriptions for a customer in the correct json format" do
        get api_v1_subscriptions_path, params: { customer_id: Customer.first.id }

        expect(response).to have_http_status(:ok)

        subscriptions = JSON.parse(response.body, symbolize_names: true)

        expect(subscriptions).to have_key(:data)
        expect(subscriptions[:data]).to be_an(Array)
        expect(subscriptions[:data].count).to eq(3)

        subscriptions[:data].each do |subscription|
          expect(subscription).to have_key(:id)
          expect(subscription[:id]).to be_a(String)

          expect(subscription).to have_key(:type)
          expect(subscription[:type]).to eq("subscription")

          expect(subscription).to have_key(:attributes)
          expect(subscription[:attributes]).to be_a(Hash)

          expect(subscription[:attributes]).to have_key(:title)
          expect(subscription[:attributes][:title]).to be_a(String)

          expect(subscription[:attributes]).to have_key(:price)
          expect(subscription[:attributes][:price]).to be_an(Integer)

          expect(subscription[:attributes]).to have_key(:status)
          expect(subscription[:attributes][:status]).to(satisfy { |status| ["active", "cancelled"].include?(status) })

          expect(subscription[:attributes]).to have_key(:frequency)
          expect(subscription[:attributes][:frequency]).to(
            satisfy { |frequency| ["monthly", "quarterly", "semiannually", "annually"].include?(frequency) }
          )
        end
      end

      it "returns an empty array if the user has no subscriptions" do
        get api_v1_subscriptions_path, params: { customer_id: Customer.second.id }

        expect(response).to have_http_status(:ok)

        subscriptions = JSON.parse(response.body, symbolize_names: true)

        expect(subscriptions).to have_key(:data)
        expect(subscriptions[:data]).to be_a(Array)
        expect(subscriptions[:data].count).to eq(0)
      end
    end

    context "sad path" do
      it "returns an error if no customer id is given" do
        get api_v1_subscriptions_path, params: { customer_id: nil }

        expect(response).to have_http_status(:not_found)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_a(String)
        expect(error[:errors]).to eq("Customer not found")
      end

      it "returns an error if the customer id is invalid" do
        get api_v1_subscriptions_path, params: { customer_id: 0 }

        expect(response).to have_http_status(:not_found)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_a(String)
        expect(error[:errors]).to eq("Customer not found")
      end
    end
  end

  describe "POST /create" do
    context "happy path" do
      it "creates a new subscription for a customer and sets default frequency to monthly" do
        customer_id = Customer.second.id
        subscription_id = Subscription.first.id

        expect(Customer.find(customer_id).subscriptions.count).to eq(0)

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id,
          subscription_id: subscription_id
        }

        expect(response).to have_http_status(:created)

        subscription = JSON.parse(response.body, symbolize_names: true)

        expect(subscription).to have_key(:data)
        expect(subscription[:data]).to be_a(Hash)

        expect(subscription[:data]).to have_key(:id)
        expect(subscription[:data][:id]).to be_a(String)

        expect(subscription[:data]).to have_key(:type)
        expect(subscription[:data][:type]).to eq("subscription")

        expect(subscription[:data]).to have_key(:attributes)
        expect(subscription[:data][:attributes]).to be_a(Hash)

        expect(subscription[:data][:attributes]).to have_key(:title)
        expect(subscription[:data][:attributes][:title]).to be_a(String)

        expect(subscription[:data][:attributes]).to have_key(:price)
        expect(subscription[:data][:attributes][:price]).to be_an(Integer)

        expect(subscription[:data][:attributes]).to have_key(:status)
        expect(subscription[:data][:attributes][:status]).to eq("active")

        expect(subscription[:data][:attributes]).to have_key(:frequency)
        expect(subscription[:data][:attributes][:frequency]).to eq("monthly")

        expect(Customer.find(customer_id).subscriptions.count).to eq(1)
      end

      it "creates a new subscription for a customer and sets frequency to quarterly when passed 1" do
        customer_id = Customer.second.id
        subscription_id = Subscription.first.id
        frequency = 1

        expect(Customer.find(customer_id).subscriptions.count).to eq(0)

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id,
          subscription_id: subscription_id,
          frequency: frequency
        }

        expect(response).to have_http_status(:created)

        subscription = JSON.parse(response.body, symbolize_names: true)

        expect(subscription[:data][:attributes]).to have_key(:frequency)
        expect(subscription[:data][:attributes][:frequency]).to eq("quarterly")

        expect(Customer.find(customer_id).subscriptions.count).to eq(1)
      end

      it "creates a new subscription for a customer and sets frequency to semiannually when passed 2" do
        customer_id = Customer.second.id
        subscription_id = Subscription.first.id
        frequency = 2

        expect(Customer.find(customer_id).subscriptions.count).to eq(0)

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id,
          subscription_id: subscription_id,
          frequency: frequency
        }

        expect(response).to have_http_status(:created)

        subscription = JSON.parse(response.body, symbolize_names: true)

        expect(subscription[:data][:attributes]).to have_key(:frequency)
        expect(subscription[:data][:attributes][:frequency]).to eq("semiannually")

        expect(Customer.find(customer_id).subscriptions.count).to eq(1)
      end

      it "creates a new subscription for a customer and sets frequency to annually when passed 3" do
        customer_id = Customer.second.id
        subscription_id = Subscription.first.id
        frequency = 3

        expect(Customer.find(customer_id).subscriptions.count).to eq(0)

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id,
          subscription_id: subscription_id,
          frequency: frequency
        }

        expect(response).to have_http_status(:created)

        subscription = JSON.parse(response.body, symbolize_names: true)

        expect(subscription[:data][:attributes]).to have_key(:frequency)
        expect(subscription[:data][:attributes][:frequency]).to eq("annually")

        expect(Customer.find(customer_id).subscriptions.count).to eq(1)
      end
    end

    context "sad path" do
      it "returns an error if no customer id is given" do
        subscription_id = Subscription.first.id

        post api_v1_subscriptions_path, params: {
          subscription_id: subscription_id
        }

        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_an(Array)
        expect(error[:errors].first).to eq("Customer must exist")
      end

      it "returns an error if the customer id is invalid" do
        subscription_id = Subscription.first.id

        post api_v1_subscriptions_path, params: {
          customer_id: 0,
          subscription_id: subscription_id
        }

        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_an(Array)
        expect(error[:errors].first).to eq("Customer must exist")
      end

      it "returns an error if no subscription id is given" do
        customer_id = Customer.second.id

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id
        }

        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_an(Array)
        expect(error[:errors].first).to eq("Subscription must exist")
      end

      it "returns an error if the subscription id is invalid" do
        customer_id = Customer.second.id

        post api_v1_subscriptions_path, params: {
          customer_id: customer_id,
          subscription_id: 0
        }

        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_an(Array)
        expect(error[:errors].first).to eq("Subscription must exist")
      end
    end
  end

  describe "PATCH /update" do
    context "happy path" do
      it "updates the status of a subscription" do
        subscription_id = CustomerSubscription.first.id
        status = 1

        expect(CustomerSubscription.find(subscription_id).status).to eq("active")

        patch api_v1_subscription_path(subscription_id), params: {
          status: status
        }

        expect(response).to have_http_status(:ok)

        subscription = JSON.parse(response.body, symbolize_names: true)

        expect(subscription).to have_key(:data)
        expect(subscription[:data]).to be_a(Hash)

        expect(subscription[:data]).to have_key(:id)
        expect(subscription[:data][:id]).to be_a(String)

        expect(subscription[:data]).to have_key(:type)
        expect(subscription[:data][:type]).to eq("subscription")

        expect(subscription[:data]).to have_key(:attributes)
        expect(subscription[:data][:attributes]).to be_a(Hash)

        expect(subscription[:data][:attributes]).to have_key(:title)
        expect(subscription[:data][:attributes][:title]).to be_a(String)

        expect(subscription[:data][:attributes]).to have_key(:price)
        expect(subscription[:data][:attributes][:price]).to be_an(Integer)

        expect(subscription[:data][:attributes]).to have_key(:status)
        expect(subscription[:data][:attributes][:status]).to eq("cancelled")

        expect(subscription[:data][:attributes]).to have_key(:frequency)
        expect(subscription[:data][:attributes][:frequency]).to eq("monthly")
      end
    end

    context "sad path" do
      it "returns an error if the subscription id is invalid" do
        status = 1

        patch api_v1_subscription_path(0), params: {
          status: status
        }

        expect(response).to have_http_status(:not_found)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_a(String)
        expect(error[:errors]).to eq("Subscription not found")
      end

      it "returns an error if the status is invalid" do
        subscription_id = CustomerSubscription.first.id
        status = 2

        patch api_v1_subscription_path(subscription_id), params: {
          status: status
        }

        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error).to have_key(:errors)
        expect(error[:errors]).to be_a(String)
        expect(error[:errors]).to eq("Invalid status")
      end
    end
  end
end
