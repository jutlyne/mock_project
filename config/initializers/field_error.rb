ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  is_input_tag = %w[input select textarea].include?(html_tag[/\w+/].to_s)
  
  if is_input_tag
    class_attribute = html_tag.match(/class=['"](.+?)['"]/)
    modified_html = if class_attribute
      html_tag.sub(/class=['"](.+?)['"]/, "class=\"#{class_attribute[1]} is-invalid\"")
    else
      html_tag.sub(/>/, " class='is-invalid'>")
    end
    modified_html.html_safe 
  else
    html_tag.html_safe
  end
end