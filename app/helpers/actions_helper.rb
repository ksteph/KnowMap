module ActionsHelper
  def action_to_html(action)
    case action.controller
    when "Session"
      case action.action
      when "create"
        "#{link_to action.user, action.user, :remote => remote? } logged in".html_safe
      when "destroy"
        "#{link_to action.user, action.user, :remote => remote? } logged out".html_safe
      end
    when "User"
      case action.action
      when "index"
        "#{link_to action.user, action.user, :remote => remote? } viewed the index page for all #{action.controller.pluralize}".html_safe
      when "create"
        "#{link_to action.user, action.user, :remote => remote? } signed up".html_safe
      when "show"
        "#{link_to action.user, action.user, :remote => remote? } viewed #{link_to action.target, action.target, :remote => remote? }'s profile".html_safe
      when "destroy"
        "#{link_to action.user, action.user, :remote => remote? } deleted #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "edit"
        "#{link_to action.user, action.user, :remote => remote? } viewed the edit page for #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "update"
        "#{link_to action.user, action.user, :remote => remote? } edited #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "profile"
        "#{link_to action.user, action.user, :remote => remote? } their profile".html_safe
      end
    when "Graph", "Node"
      case action.action
      when "index"
        "#{link_to action.user, action.user, :remote => remote? } viewed the index page for all #{action.controller.downcase.pluralize}".html_safe
      when "new"
        "#{link_to action.user, action.user, :remote => remote? } viewed the new #{action.controller.downcase} page".html_safe
      when "create"
        "#{link_to action.user, action.user, :remote => remote? } created a new #{action.controller.downcase}".html_safe
      when "show"
        "#{link_to action.user, action.user, :remote => remote? } viewed #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "destroy"
        "#{link_to action.user, action.user, :remote => remote? } deleted #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "edit"
        "#{link_to action.user, action.user, :remote => remote? } viewed the edit page for #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "update"
        "#{link_to action.user, action.user, :remote => remote? } edited #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "highlight"
        "#{link_to action.user, action.user, :remote => remote? } highlighted the group #{link_to action.target, action.target, :remote => remote? }".html_safe
      when "unhighlight"
        "#{link_to action.user, action.user, :remote => remote? } unhighlighted the group #{link_to action.target, action.target, :remote => remote? }".html_safe
      end
    end
  end
end
