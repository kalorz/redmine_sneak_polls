class SneakPollVote < ActiveRecord::Base
  unloadable

  GRADES_RANGE = -2..2
  
  belongs_to :poll, :class_name => 'SneakPoll', :counter_cache => :votes_count
  belongs_to :voter, :class_name => 'User'
  belongs_to :user

  attr_accessible :timeliness, :quality, :commitment, :office_procedures, :comment

  validates_presence_of   :poll, :voter, :user
  validates_inclusion_of  :timeliness,        :in => GRADES_RANGE, :allow_nil => true
  validates_inclusion_of  :quality,           :in => GRADES_RANGE, :allow_nil => true
  validates_inclusion_of  :commitment,        :in => GRADES_RANGE, :allow_nil => true
  validates_inclusion_of  :office_procedures, :in => GRADES_RANGE, :allow_nil => true
  validates_length_of     :comment, :in => 1..255, :allow_blank => true
  validates_uniqueness_of :poll_id, :scope => [:voter_id, :user_id]
  validate                :voter_must_not_be_user

  named_scope :by_project,    lambda {|project| {:joins => :poll, :conditions => {:sneak_polls => {:project_id => project}}}}
  named_scope :by_voter,      lambda {|user|    {:conditions => {:voter_id => user}}}
  named_scope :by_user,       lambda {|voter|   {:conditions => {:user_id  => voter}}}
  named_scope :exclude_voter, lambda {|voter|   {:conditions => ["#{quoted_table_name}.voter_id <> ?", voter]}}
  named_scope :exclude_user,  lambda {|user|    {:conditions => ["#{quoted_table_name}.user_id <> ?",  user]}}
  named_scope :blank,         :conditions => ["#{quoted_table_name}.timeliness IS NULL AND #{quoted_table_name}.quality IS NULL AND #{quoted_table_name}.commitment IS NULL AND #{quoted_table_name}.office_procedures IS NULL AND (#{quoted_table_name}.comment IS NULL OR #{quoted_table_name}.comment = '')"]
  named_scope :unblank,       :conditions => ["#{quoted_table_name}.timeliness IS NOT NULL OR #{quoted_table_name}.quality IS NOT NULL OR #{quoted_table_name}.commitment IS NOT NULL OR #{quoted_table_name}.office_procedures IS NOT NULL OR (#{quoted_table_name}.comment IS NOT NULL AND #{quoted_table_name}.comment <> '')"]

  def self.unique(sneak_poll, voter, attributes_or_user)
    if attributes_or_user.is_a?(Hash)
      user, attributes = attributes_or_user.delete('user_id') || attributes_or_user.delete(:user_id), attributes_or_user
    else
      user, attributes = attributes_or_user, {}
    end

    sneak_poll = sneak_poll.id if sneak_poll.is_a?(ActiveRecord::Base)
    voter      = voter.id      if voter.is_a?(ActiveRecord::Base)
    user       = user.id       if user.is_a?(ActiveRecord::Base)

    find_or_initialize_by_poll_id_and_voter_id_and_user_id(sneak_poll, voter, user).tap{|vote| vote.attributes = attributes}
  end

  def self.all_unique_from_params(sneak_poll, voter, params)
    if params.is_a?(Hash)
      params.map{|key, attributes| SneakPollVote.unique(sneak_poll, voter, attributes)}
    elsif params.is_a?(Array)
      params.map{|attributes| SneakPollVote.unique(sneak_poll, voter, attributes)}
    else
      [SneakPollVote.unique(sneak_poll, voter, params)]
    end
  end

  def grades_blank?
    timeliness.blank? && quality.blank? && commitment.blank? && office_procedures.blank?
  end

  def blank?
    grades_blank? && comment.blank?
  end

  def css_classes
    classes = []
    classes << (blank? ? 'blank' : 'voted')
    classes << (grades_blank? ? 'grades-blank' : 'grades-voted')
    classes << (comment.blank? ? 'comment-blank' : 'comment-voted')
    " #{classes.join(' ')} "
  end

  private ##############################################################################################################

  def voter_must_not_be_user
    errors.add(:voter, :invalid) if voter && user && voter == user
  end

end
