module SneakPolls
  class ViewHooks < Redmine::Hook::ViewListener

    render_on :view_users_form, :partial => 'hooks/sneak_polls/view_users_form'

    def view_layouts_base_html_head(context)
      stylesheet_link_tag 'sneak_polls', :plugin => 'redmine_sneak_polls'
    end

    def view_account_right_bottom(context = {})
      principal_stats = SneakPollVote.by_user(context[:user]).by_principals.select_poll_stats.all(:include => {:poll => :project}).group_by(&:poll)
      coworker_stats  = SneakPollVote.by_user(context[:user]).exclude_principals.select_poll_stats.all(:include => {:poll => :project}).group_by(&:poll)
      poll_stats      = (principal_stats.keys + coworker_stats.keys).uniq.sort_by(&:created_at).reverse

      context[:controller].send(:render_to_string, {
          :partial => 'hooks/sneak_polls/view_account_right_bottom',
          :locals  => context.merge({:poll_stats => poll_stats, :principal_stats => principal_stats, :coworker_stats => coworker_stats})
      })
    end

  end
end
