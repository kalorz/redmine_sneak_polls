module SneakPolls
  module MailerPatch

    def self.included(base) # :nodoc:
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def sneak_poll_add(sneak_poll)
        @author = User.anonymous
        redmine_headers 'Project'       => sneak_poll.project.identifier,
                        'Sneak-Poll-Id' => sneak_poll.id
        message_id sneak_poll
        recipients sneak_poll.recipients
        cc sneak_poll.project.recipients - [*@recipients]
        subject "[#{sneak_poll.project.name} - Nowa ankieta \"#{sneak_poll.title}\""
        body :sneak_poll     => sneak_poll,
             :sneak_poll_url => url_for(:controller => 'sneak_polls', :action => 'show', :project_id => sneak_poll.project, :id => sneak_poll),
             :project        => sneak_poll.project,
             :project_url    => url_for(:controller => 'projects', :action => 'show', :id => sneak_poll.project)
        render_multipart('sneak_poll_add', body)
      end

    end

  end
end
