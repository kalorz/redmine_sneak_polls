module SneakPolls
  class ViewHooks < Redmine::Hook::ViewListener

    render_on :view_users_form, :partial => 'hooks/sneak_polls/view_users_form'

    def view_layouts_base_html_head(context)
      stylesheet_link_tag 'sneak_polls', :plugin => 'redmine_sneak_polls'
    end

    def view_account_right_bottom(context = {})
      stats = SneakPollVote.by_user(context[:user]).select_split_poll_stats.all(:include => {:poll => :project})
      stats_by_principals = SneakPollVote.by_user(context[:user]).select_stats.all(
          :joins      => SneakPollVote::JOIN_FOR_SPLIT_STATS,
          :conditions => SneakPollVote::CONDITION_FOR_SPLIT_STATS,
          :group      => 'user_id, voter_id, poll_id',
          :select     => "poll_id, user_id, voter_id, #{SneakPollVote::GRADE_COLUMNS.join(',')}",
          :include    => :voter
      ).group_by(&:poll_id)
      quarterly_stats = SneakPollVote.by_user(context[:user]).select_split_quarterly_stats.all

      context[:controller].send(:render_to_string, {
          :partial => 'hooks/sneak_polls/view_account_right_bottom',
          :locals  => context.merge({:stats => stats, :stats_by_principals => stats_by_principals, :quarterly_stats => quarterly_stats})
      })
    end

  end
end
