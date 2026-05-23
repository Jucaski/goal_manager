json.extract! habit, :id, :title, :user_id, :completed_date, :created_at, :updated_at
json.url habit_url(habit, format: :json)
