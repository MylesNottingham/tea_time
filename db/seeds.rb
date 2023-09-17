# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Tea.destroy_all
Subscription.destroy_all
SubscriptionTea.destroy_all
CustomerSubscription.destroy_all
Customer.destroy_all

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
