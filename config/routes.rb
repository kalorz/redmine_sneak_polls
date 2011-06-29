ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'sneak_polls' do |sneak_polls_routes|
    sneak_polls_routes.with_options :conditions => {:method => :get} do |sneak_polls_views|
      sneak_polls_views.connect 'projects/:project_id/sneak_polls', :action => 'index'
      sneak_polls_views.connect 'projects/:project_id/sneak_polls/new', :action => 'new'
      sneak_polls_views.connect 'projects/:project_id/sneak_polls/:id', :action => 'show'
      sneak_polls_views.connect 'projects/:project_id/sneak_polls/:id.:format', :action => 'show'
      sneak_polls_views.connect 'projects/:project_id/sneak_polls/:id/edit', :action => 'edit'
      sneak_polls_views.connect 'projects/:project_id/sneak_polls/:id/stats', :action => 'stats'
    end
    sneak_polls_routes.with_options :conditions => {:method => :post} do |sneak_polls_actions|
      sneak_polls_actions.connect 'projects/:project_id/sneak_polls', :action => 'new'
      sneak_polls_actions.connect 'projects/:project_id/sneak_polls/:id/:action', :action => /vote|edit|destroy/
    end
  end
end
