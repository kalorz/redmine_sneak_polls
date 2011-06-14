class CreateSneakPollVersions < ActiveRecord::Migration
  def self.up
    create_table :sneak_poll_versions do |t|
      t.integer :poll_id,    :null => false
      t.integer :version_id, :null => false

      t.timestamps :null => false
    end

    # add_index :sneak_poll_versions, :sneak_poll_id # Index added automatically by MySQL Foreign Key
    # add_index :sneak_poll_versions, :version_id    # Index added automatically by MySQL Foreign Key
    add_index :sneak_poll_versions, [:poll_id, :version_id], :unique => true

    SneakPollVersion.reset_column_information

    SneakPollVersion.connection.execute("ALTER TABLE #{SneakPollVersion.quoted_table_name} ADD FOREIGN KEY (poll_id) REFERENCES #{SneakPoll.quoted_table_name}(id);")
    SneakPollVersion.connection.execute("ALTER TABLE #{SneakPollVersion.quoted_table_name} ADD FOREIGN KEY (version_id) REFERENCES #{Version.quoted_table_name}(id);")
  end

  def self.down
    drop_table :sneak_poll_versions
  end
end
