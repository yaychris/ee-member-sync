class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :ee_id
      t.integer :ee_group_id
      t.string  :ee_group_name
      t.string  :ee_username
      t.string  :ee_screen_name
      t.string  :ee_email

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
