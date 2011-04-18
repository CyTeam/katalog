class AddUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string

    User.all.each do |user|
      user.username = user.email.split('@').first
      user.save
    end
  end

  def self.down
    remove_column :users, :username
  end
end
