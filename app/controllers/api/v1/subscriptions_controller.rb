class Api::V1::SubscriptionsController < ApplicationController
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
    subscription = CustomerSubscription.find(params[:id])

    if subscription.update(status: params[:status].to_i)
      render json: SubscriptionSerializer.new(subscription)
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    subscriptions = CustomerSubscription.where(customer_id: params[:customer_id])

    render json: SubscriptionSerializer.new(subscriptions)
  end
end
