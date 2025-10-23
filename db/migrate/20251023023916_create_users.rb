class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.numeric :team_id
      t.string :avatar
      t.string :password_digest

      t.timestamps
    end
  end
end
