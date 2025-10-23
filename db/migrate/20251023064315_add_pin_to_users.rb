class AddPinToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_reset_pin, :integer
    add_column :users, :password_reset_sent_at, :datetime
  end
end
