class Action < ActiveRecord::Base
  attr_accessible :action, :controller, :user_id, :target_id
  belongs_to :user
  #belongs_to :graph, :class_name => @controller, :foreign_key => "target_id", :conditions => { :controller == "graph" }
  
  def date
    created_at
  end
  
  def target
    controller.constantize.find(target_id) if target_id
  end
  
  def to_s
    case controller
    when "Session"
      case action
      when "create"
        "#{user} logged in"
      when "destroy"
        "#{user} logged out"
      end
    when "User"
      case action
      when "create"
        "#{user} signed up"
      end
    when "Graph", "Node"
      case action
      when "index"
        "#{user} viewed the index page for all #{controller.pluralize}"
      when "new"
        "#{user} viewed the new #{controller} page"
      when "create"
        "#{user} created a new #{controller}"
      when "show"
        "#{user} viewed #{target}"
      when "destroy"
        "#{user} deleted #{target}"
      when "edit"
        "#{user} viewed the edit page for #{target}"
      when "update"
        "#{user} edited #{target}"
      end
    end
  end
  
  def action_str
    " #{action} "
  end
end
