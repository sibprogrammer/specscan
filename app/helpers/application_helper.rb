module ApplicationHelper

  def context_help?(help)
    help || ('' != t(get_locale_section_for_context + ".help", :default => ''))
  end

  def context_help(help)
    help || t(get_locale_section_for_context + ".help")
  end

  def form_field(form, field, type, options = {})
    haml_tag '.clearfix' do
      haml_concat form.label field, t('.field.' + field.to_s)
      haml_tag '.input' do
        haml_concat form.send(type, field, options)
      end
    end
  end

  private

    def get_locale_section_for_context
      "#{params[:controller].sub('/', '.')}.#{params[:action]}"
    end

end
