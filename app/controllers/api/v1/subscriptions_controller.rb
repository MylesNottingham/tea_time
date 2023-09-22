class Api::V1::SubscriptionsController < ApplicationController
  def index
    subscriptions = CustomerSubscription.where(customer_id: params[:customer_id])

    if Customer.exists?(params[:customer_id])
      render json: SubscriptionSerializer.new(subscriptions)
    else
    render json: { errors: "Customer not found" }, status: :not_found
    end
  end

  def create
    subscription = CustomerSubscription.new(
      customer_id: params[:customer_id],
      subscription_id: params[:subscription_id],
      frequency: params[:frequency].to_i || 0
    )

    if subscription.save
      render json: SubscriptionSerializer.new(subscription), status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    begin
      subscription = CustomerSubscription.find(params[:id])
      subscription.update!(status: params[:status].to_i)
      render json: SubscriptionSerializer.new(subscription)
    rescue ArgumentError
      render json: { errors: "Invalid status" }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Subscription not found" }, status: :not_found
    end
  end
end
