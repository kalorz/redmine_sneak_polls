module SneakPolls
  module UserPatch

    def self.included(base) # :nodoc:
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable

        belongs_to :master, :class_name => 'User', :inverse_of => :servants, :counter_cache => :servants_count
        has_many :servants, :class_name => 'User', :foreign_key => :master_id, :inverse_of => :master, :dependent => :nullify
        has_many :sneak_poll_votes, :class_name => 'SneakPollVote', :foreign_key => :user_id, :dependent => :destroy # "How people voted on me?"
        has_many :sneak_poll_votings, :class_name => 'SneakPollVote', :foreign_key => :voter_id, :dependent => :destroy # "How I voted on people?"
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end

  end
end