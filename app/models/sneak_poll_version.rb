class SneakPollVersion < ActiveRecord::Base
  unloadable

  belongs_to :poll, :class_name => 'SneakPoll', :counter_cache => :versions_count
  belongs_to :version

  validates_presence_of   :poll, :version
  validates_uniqueness_of :version_id, :scope => :poll_id
end
