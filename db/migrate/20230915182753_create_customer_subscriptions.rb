class CreateCustomerSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_subscriptions do |t|
      t.references :customers, null: false, foreign_key: true
      t.references :subscriptions, null: false, foreign_key: true

      t.timestamps
    end
  end
end
