class CreateSneakPollVotes < ActiveRecord::Migration
  def self.up
    create_table :sneak_poll_votes do |t|
      t.integer :poll_id,  :null => false
      t.integer :voter_id, :null => false
      t.integer :user_id,  :null => false
      t.integer :timeliness
      t.string  :timeliness_notes
      t.integer :quality
      t.string  :quality_notes
      t.integer :commitment
      t.string  :commitment_notes
      t.integer :office_procedures
      t.string  :office_procedures_notes
      t.integer :grade1
      t.string  :grade1_notes
      t.integer :grade2
      t.string  :grade2_notes
      t.string  :notes

      t.timestamps :null => false
    end

    # add_index :sneak_poll_votes, :sneak_poll_id # Index added automatically by MySQL Foreign Key
    # add_index :sneak_poll_votes, :version_id    # Index added automatically by MySQL Foreign Key
    add_index :sneak_poll_votes, [:poll_id, :voter_id, :user_id], :unique => true

    SneakPollVote.reset_column_information

    SneakPollVote.connection.execute("ALTER TABLE #{SneakPollVote.quoted_table_name} ADD FOREIGN KEY (poll_id) REFERENCES #{SneakPoll.quoted_table_name}(id);")
    SneakPollVote.connection.execute("ALTER TABLE #{SneakPollVote.quoted_table_name} ADD FOREIGN KEY (voter_id) REFERENCES #{User.quoted_table_name}(id);")
    SneakPollVote.connection.execute("ALTER TABLE #{SneakPollVote.quoted_table_name} ADD FOREIGN KEY (user_id) REFERENCES #{User.quoted_table_name}(id);")
  end

  def self.down
    drop_table :sneak_poll_votes
  end
end
