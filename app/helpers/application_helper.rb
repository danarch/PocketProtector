module ApplicationHelper
  def flash_class name
    # Translate rails conventions to bootstrap conventions
    case name.to_sym
    when :success
      "green"
    when :alert
      "red"
    when :notice
      "blue"
    else
      name
    end
  end
end
