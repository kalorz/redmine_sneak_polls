class CreateSneakPolls < ActiveRecord::Migration
  def self.up
    create_table :sneak_polls do |t|
      t.integer :project_id,     :null => false
      t.string  :title,          :null => false
      t.integer :versions_count, :null => false, :default => 0
      t.integer :votes_count,    :null => false, :default => 0

      t.timestamps :null => false
    end

    # add_index :sneak_polls, :project_id # Index added automatically by MySQL Foreign Key

    SneakPoll.reset_column_information

    SneakPoll.connection.execute("ALTER TABLE #{SneakPoll.quoted_table_name} ADD FOREIGN KEY (project_id) REFERENCES #{Project.quoted_table_name}(id);")
  end

  def self.down
    drop_table :sneak_polls
  end
end
