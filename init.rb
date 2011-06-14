require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'project'
  require_dependency 'mailer'

  Project.send :include, SneakPolls::ProjectPatch
  Mailer.send  :include, SneakPolls::MailerPatch
end

Redmine::Plugin.register :redmine_sneak_polls do
  name        'Sneak Polls'
  author      'Activeweb'
  description 'Plugin for informing on colleagues'
  version     '0.0.3'
  url         'http://svn.activeweb.pl/redmine_sneak_polls/'
  author_url  'http://www.activeweb.pl/'

  project_module :sneak_polls do
    permission :view_sneak_polls,   {:sneak_polls => [:show, :index]}, :public => true, :require => :loggedin
    permission :manage_sneak_polls, {:sneak_polls => [:new, :edit, :destroy]}
    permission :vote_sneak_polls,   {:sneak_polls => [:vote]}, :require => :member
  end
  
  menu :project_menu, :sneak_polls, {:controller => 'sneak_polls', :action => 'index'}, :caption => :label_sneak_polls_title, :after => :overview, :param => :project_id
end
