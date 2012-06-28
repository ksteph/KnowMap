module SearchHelper
  def highlight_matches(string, term)
    string.gsub(/(#{term})/i) { "<span class=\"search-match\">#{$1}</span>" }.html_safe
  end
end
