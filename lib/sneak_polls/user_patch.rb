module SneakPolls
  module UserPatch

    def self.included(base) # :nodoc:
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable

        belongs_to :master, :class_name => 'User', :inverse_of => :servants, :counter_cache => :servants_count
        has_many :servants, :foreign_key => 'master_id', :class_name => 'User', :inverse_of => :master, :dependent => :nullify
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end

  end
end