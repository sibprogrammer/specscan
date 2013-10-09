module ApplicationHelper

  def context_help?(help)
    help || ('' != t(get_locale_section_for_context + ".help", :default => ''))
  end

  def context_help(help)
    help || t(get_locale_section_for_context + ".help")
  end

  def form_field(form, field, type, options = {})
    haml_tag '.control-group' do
      haml_concat form.label(field, t('.field.' + field.to_s), :class => 'control-label')
      haml_tag '.controls' do
        haml_concat form.send(type, field, options)
      end
    end
  end

  def readonly_field(title, value)
    haml_tag '.control-group' do
      haml_tag 'label.control-label' do
        haml_concat title
      end
      haml_tag '.controls' do
        haml_tag 'span.uneditable-input' do
          haml_concat value
        end
      end
    end
  end

  def sortable_column(name, title, sort_state)
    sort_dir = 'desc' == sort_state[:dir] ? 'asc' : 'desc'
    sort_link = link_to(title, url_for(:page => params[:page], :sort_dir => sort_dir, :sort_field => name))
    sort_css_class = (sort_state[:field] == name) ? ('asc' == sort_dir ? 'sorting_desc' : 'sorting_asc') : 'sorting'

    haml_tag "th.#{sort_css_class}" do
      haml_concat sort_link
    end
  end

  def beta_version?
    'development' == Rails.env
  end

  def billing_period_title(plan)
    return t('admin.plans.form.field.bill_per_month') if 1 == plan.billing_period
    t('admin.plans.form.field.bill_per_year')
  end

  private

    def get_locale_section_for_context
      "#{params[:controller].sub('/', '.')}.#{params[:action]}"
    end

end
