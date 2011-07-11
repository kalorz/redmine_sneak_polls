module ApplicationHelper

  def abbr(text)
    t(text.is_a?(Symbol) ? :"#{text}_abbr" : nil, :default => (text.is_a?(Symbol) ? t(text) : text).to_s.gsub(/^field_/, '').humanize.gsub(/[\(\[].*[\)\]]/, '').split(/\s+/).map { |name| name.first }.join.upcase)
  end

  def abbr_tag(text)
    content_tag(:abbr, h(abbr(text)), :title => h(text.is_a?(Symbol) ? t(text) : text))
  end

  def format_grade(grade)
    grade ? number_with_precision(grade, :precision => 2) : t(:label_sneak_poll_not_applicable_symbol)
  end

  def sneak_poll_headers
    SneakPollVote::GRADE_COLUMNS.map do |column|
      content_tag(:th, abbr_tag(:"field_#{column}"), :colspan => 2)
    end.join
  end

  def sneak_poll_columns(stat)
    SneakPollVote::GRADE_COLUMNS.map do |column|
      principal_grade = stat["average_#{column}_by_principals"]
      coworker_grade  = stat["average_#{column}_by_coworkers"]

      content_tag(:td, :class => 'float grade_by_principals') do
        content_tag(:span, format_grade(principal_grade), :class => SneakPoll.grade_css_classes(principal_grade)) + ' / '
      end +
          content_tag(:td, :class => 'float grade_by_coworkers left') do
            content_tag(:span, format_grade(coworker_grade), :class => SneakPoll.grade_css_classes(coworker_grade))
          end
    end.join
  end

end
