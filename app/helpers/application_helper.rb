module ApplicationHelper

  def context_help?(help)
    help || ('' != t(get_locale_section_for_context + ".help", :default => ''))
  end

  def context_help(help)
    help || t(get_locale_section_for_context + ".help")
  end

  private

    def get_locale_section_for_context
      "#{params[:controller].sub('/', '.')}.#{params[:action]}"
    end

end
