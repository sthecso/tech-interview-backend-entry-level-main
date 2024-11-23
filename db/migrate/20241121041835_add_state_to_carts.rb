class AddStateToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :state, :string, default: "active", null: false
  end
end
