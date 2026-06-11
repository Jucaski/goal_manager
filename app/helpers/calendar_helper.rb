module CalendarHelper
  def workout_icon_if_present(sessions)
    content_tag(:div, "🏋️", class: "text-green-600 text-xl") if sessions.present?
  end
end
