# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'
    when /^the signup\s?page$/
      '/sign_up'
    when /^the login\s?page$/
      '/login'
    when /^the logout\s?page$/
      '/logout'
    when /^the graphs\s?page$/
      '/graphs'
    when /^the actions\s?page$/
      '/actions'
    when /^the change password\s?page$/
      '/account/change_password'
    when /^the "(.*)" graph$/
      "/graphs/#{Graph.find_by_name($1).id}"
    when /^the new graph$/
      "/graphs/new"
    when /^the edit page for the "(.*)" graph$/
      "/graphs/#{Graph.find_by_name($1).id}/edit"
    when /^the "(.*)" node$/
      "/nodes/#{Node.find_by_title($1).id}"
    when /^the new node$/
      "/nodes/new"
    when /^the edit page for the "(.*)" node$/
      "/nodes/#{Node.find_by_title($1).id}/edit"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
