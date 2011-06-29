class SneakPollVote < ActiveRecord::Base
  unloadable

  GRADES_RANGE      = -2..2
  GRADE_COLUMNS     = [:timeliness, :quality, :commitment, :office_procedures, :grade1, :grade2]
  COLUMNS_FOR_STATS = GRADE_COLUMNS.map{ |column| "AVG(#{column}) AS average_#{column}" }.join(', ')

  belongs_to :poll, :class_name => 'SneakPoll', :counter_cache => :votes_count
  belongs_to :voter, :class_name => 'User', :inverse_of => :sneak_poll_votings
  belongs_to :user, :inverse_of => :sneak_poll_votes

  attr_accessible :timeliness, :timeliness_notes, :quality, :quality_notes,
                  :commitment, :commitment_notes, :office_procedures, :office_procedures_notes,
                  :grade1, :grade1_notes, :grade2, :grade2_notes,
                  :notes

  validates_presence_of   :poll_id, :voter_id, :user_id
  validates_length_of     :notes, :in => 1..255, :allow_blank => true
  validates_uniqueness_of :poll_id, :scope => [:voter_id, :user_id]
  validate                :voter_must_not_be_user

  GRADE_COLUMNS.each do |column|
    validates_inclusion_of column, :in => GRADES_RANGE, :allow_nil => true
    validates_length_of    "#{column}_notes", :in => 1..255, :allow_blank => true
    validates_presence_of  "#{column}_notes", :allow_blank => false, :if => Proc.new{ |vote| vote[column] == GRADES_RANGE.first || vote[column] == GRADES_RANGE.last }
  end

  named_scope :by_poll,       lambda{ |poll|    {:conditions => {:poll_id => poll}} }
  named_scope :by_project,    lambda{ |project| {:joins => :poll, :conditions => {:sneak_polls => {:project_id => project}}} }
  named_scope :by_voter,      lambda{ |user|    {:conditions => {:voter_id => user}} }
  named_scope :by_user,       lambda{ |voter|   {:conditions => {:user_id  => voter}} }
  named_scope :exclude_voter, lambda{ |voter|   {:conditions => ['voter_id NOT IN (?)', voter]} unless voter.blank? }
  named_scope :exclude_user,  lambda{ |user|    {:conditions => ['user_id NOT IN (?)', user]} unless user.blank? }
  named_scope :blank,
              :conditions => GRADE_COLUMNS.map{ |column| "#{column} IS NULL AND (#{column}_notes IS NULL OR #{column}_notes = '')" }.join(' AND ') +
                  " AND (notes IS NULL OR notes = '')"
  named_scope :unblank,
              :conditions => GRADE_COLUMNS.map{ |column| "#{column} IS NOT NULL OR (#{column}_notes IS NOT NULL AND #{column}_notes <> '')" }.join(' OR ') +
                  " OR (notes IS NOT NULL AND notes <> '')"
  named_scope :select_stats,  :select => "user_id, #{COLUMNS_FOR_STATS}", :group => :user_id
  named_scope :by_principals, Project.supports_fixed_manager ? {
      :joins => [:user, :voter, {:poll => :project}],
      :conditions => '(voter_id = COALESCE(users.master_id, -1)) OR (voters_sneak_poll_votes.boss) OR (voter_id = COALESCE(projects.fixed_manager_id, -1))'
  } : {
      :joins => [:user, :voter],
      :conditions => '(voter_id = COALESCE(users.master_id, -1)) OR (voters_sneak_poll_votes.boss)'
  }
  named_scope :exclude_principals, Project.supports_fixed_manager ? {
      :joins => [:user, :voter, {:poll => :project}],
      :conditions => '(voter_id <> COALESCE(users.master_id, -1)) AND (NOT voters_sneak_poll_votes.boss) AND (voter_id <> COALESCE(projects.fixed_manager_id, -1))'
  } : {
      :joins => [:user, :voter],
      :conditions => '(voter_id <> COALESCE(users.master_id, -1)) AND (NOT voters_sneak_poll_votes.boss)'
  }

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
      params.map{ |key, attributes| SneakPollVote.unique(sneak_poll, voter, attributes) }
    elsif params.is_a?(Array)
      params.map{ |attributes| SneakPollVote.unique(sneak_poll, voter, attributes) }
    else
      [SneakPollVote.unique(sneak_poll, voter, params)]
    end
  end

  def grades_blank?
    !GRADE_COLUMNS.detect{ |column| !self[column].blank? }
  end

  def notes_blank?
    notes.blank? && !GRADE_COLUMNS.detect{ |column| !self["#{column}_notes"].blank? }
  end

  def blank?
    grades_blank? && notes_blank?
  end

  def css_classes
    classes = []
    classes << (blank? ? 'blank' : 'voted')
    classes << (grades_blank? ? 'grades-blank' : 'grades-voted')
    classes << (notes_blank? ? 'notes-blank' : 'notes-voted')
    classes << (valid? ? 'valid' : 'invalid')
    " #{classes.join(' ')} "
  end

  private ##############################################################################################################

  def voter_must_not_be_user
    errors.add(:voter, :invalid) if voter && user && voter == user
  end

end
