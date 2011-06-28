class AddBossColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :boss, :boolean, :null => false, :default => false
    add_column :users, :master_id, :integer
    add_column :users, :servants_count, :integer, :null => false, :default => 0

    add_index :users, :boss
    # add_index :users, :master_id # Index added automatically by MySQL Foreign Key

    execute("ALTER TABLE #{User.quoted_table_name} ADD FOREIGN KEY (master_id) REFERENCES #{User.quoted_table_name}(id);")
  end

  def self.down
    remove_column :users, :boss
    remove_column :users, :master_id
    remove_column :users, :servants_count
  end
end
