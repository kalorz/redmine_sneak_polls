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
    grade ? number_with_precision(grade, :precision => 2) : t(:label_sneak_poll_not_applicable_symbol)
  end

  def radio_select(form, field, collection, options = {})
    ''.tap do |html|
      html << form.label("#{field}_notes", "#{l("field_#{field}")}:", options.merge(:class => form.object.errors.on("#{field}_notes") ? 'invalid' : nil))
      if blank = options.delete(:include_blank)
        html << content_tag(:span, :class => 'radio') do
          form.radio_button(field, '', options) +
              form.label(field, blank, options.merge(:value => '', :class => 'inline grade-nan')) unless blank.is_a?(TrueClass)
        end
      end
      collection.each do |element|
        html << content_tag(:span, :class => 'radio') do
          form.radio_button(field, element, options.merge(:id => "#{form.object_name}_#{field}_#{element}")) +#TODO: Remove :id after migration to Rails 3
              form.label(field, element, options.merge(:for => "#{form.object_name}_#{field}_#{element}", :class => "inline#{SneakPoll.grade_css_classes(element)}")) #TODO: Remove :id after migration to Rails 3
        end
      end
    end
  end

  def grade_field(form, field, options = {})
    content_tag(:p, :class => form.object.errors.on("#{field}_notes") ? 'invalid' : nil) do
      radio_select(form, field, SneakPollVote::GRADES_RANGE.to_a, :include_blank => t(:label_sneak_poll_not_applicable_abbr), :disabled => !can_vote?, :readonly => !can_vote?) +
          tag(:br) +
          form.text_area("#{field}_notes", :rows => 2, :disabled => !can_vote?, :readonly => !can_vote?) +
          (form.object.errors.on("#{field}_notes") ? tag(:br) + form.object.errors.on("#{field}_notes") : '')
    end
  end

end
