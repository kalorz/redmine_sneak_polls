module SneakPolls
  class ViewHooks < Redmine::Hook::ViewListener

    render_on :view_users_form, :partial => 'hooks/sneak_polls/view_users_form'

  end
end
