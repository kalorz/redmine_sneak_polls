module SneakPollsHelper

  def abbr(text)
    t(text.is_a?(Symbol) ? :"#{text}_abbr" : nil, :default => (text.is_a?(Symbol) ? t(text) : text).to_s.gsub(/^field_/, '').humanize.gsub(/[\(\[].*[\)\]]/, '').split(/\s+/).map{|name| name.first}.join.upcase)
  end

  def abbr_tag(text)
    content_tag(:abbr, h(abbr(text)), :title => h(text.is_a?(Symbol) ? t(text) : text))
  end

  def can_manage?
    @can_manage ||= !!@project && !!User.current.allowed_to?(:manage_sneak_polls, @project)
  end

  def can_vote?
    @can_vote ||= !!@project && !!User.current.allowed_to?(:vote_sneak_polls, @project)
  end

  def format_grade(grade)
    grade ? number_with_precision(grade, :precision => 2) : t(:label_sneak_poll_not_applicable_abbr)
  end

end
