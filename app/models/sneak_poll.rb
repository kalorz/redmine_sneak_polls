class SneakPoll < ActiveRecord::Base
  unloadable

  alias_attribute :created_on, :created_at # Compatibility with standard Redmine models
  alias_attribute :updated_on, :updated_at # Compatibility with standard Redmine models

  belongs_to :project
  has_many   :sneak_poll_versions, :foreign_key => :poll_id, :dependent => :delete_all
  has_many   :versions, :through => :sneak_poll_versions
  has_many   :votes, :class_name => 'SneakPollVote', :foreign_key => :poll_id, :dependent => :delete_all

  attr_accessible :title, :version_ids

  after_create :send_mail_notification

  validates_presence_of :project
  validates_length_of   :title, :in => 3..255, :allow_blank => false
  validate_on_create    :versions_must_belong_to_poll_project
  validate              :versions_must_not_be_blank

  named_scope :order, lambda {|*order| {:order => order.first || 'created_at DESC, title ASC'}}

  # Normalized average grade: 0..5
  def self.grade_css_classes(grade)
    grade = grade.to_d if grade.respond_to?(:to_d)
    grade.is_a?(Numeric) ? " normalized-grade-#{10 * (grade - SneakPollVote::GRADES_RANGE.first).round.to_i / (SneakPollVote::GRADES_RANGE.last - SneakPollVote::GRADES_RANGE.first) / 2} " : ' grade-nan '
  end

  # Returns the mail adresses of users that should be notified
  def recipients
    # project.users.select{|u| u.active? && u.notify_about?(self)}.uniq.map(&:mail)
    project.users.select(&:active?).map(&:mail).compact.uniq
  end

  def average_timeliness
    @average_timeliness ||= votes.average(:timeliness)
  end

  def average_quality
    @average_quality ||= votes.average(:quality)
  end

  def average_commitment
    @average_commitment ||= votes.average(:commitment)
  end

  def average_office_procedures
    @average_office_procedures ||= votes.average(:office_procedures)
  end

  def average_grade
    @average_grade ||= begin
      grades = [average_timeliness, average_quality, average_commitment, average_office_procedures].compact
      grades.blank? ? nil : grades.sum / grades.size
    end
  end

  private ##############################################################################################################

  def versions_must_belong_to_poll_project
    errors.add_to_base(:invalid_versions) if versions && versions.detect{|version| version.project_id != project_id}
  end

  def versions_must_not_be_blank
    errors.add_to_base(:blank_versions) if versions.blank?
  end

  def send_mail_notification
    Mailer.deliver_sneak_poll_add(self) # if Setting.notified_events.include?('issue_added')
  end

end
