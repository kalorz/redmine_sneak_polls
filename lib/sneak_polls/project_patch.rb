module SneakPolls
  module ProjectPatch

    def self.included(base) # :nodoc:
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable

        has_many :sneak_polls, :dependent => :destroy
        has_many :sneak_poll_votes, :through => :sneak_polls, :source => :votes
      end
    end

    module ClassMethods

      def average_average(ary)
        grades = ary.compact
        grades.blank? ? nil : grades.sum / grades.size
      end

    end

    module InstanceMethods

      def average_timeliness
        @average_timeliness ||= sneak_poll_votes.average(:timeliness)
      end

      def average_average_timeliness
        @average_average_timeliness ||= self.class.average_average(sneak_polls.map(&:average_timeliness))
      end

      def average_quality
        @average_quality ||= sneak_poll_votes.average(:quality)
      end

      def average_average_quality
        @average_average_quality ||= self.class.average_average(sneak_polls.map(&:average_quality))
      end

      def average_commitment
        @average_commitment ||= sneak_poll_votes.average(:commitment)
      end

      def average_average_commitment
        @average_average_commitment ||= self.class.average_average(sneak_polls.map(&:average_commitment))
      end

      def average_office_procedures
        @average_office_procedures ||= sneak_poll_votes.average(:office_procedures)
      end

      def average_average_office_procedures
        @average_average_office_procedures ||= self.class.average_average(sneak_polls.map(&:average_office_procedures))
      end

      def average_grade
        @average_grade ||= self.class.average_average([average_timeliness, average_quality, average_commitment, average_office_procedures])
      end

      def average_average_grade
        @average_average_grade ||= self.class.average_average(sneak_polls.map(&:average_grade))
      end

    end

  end
end
