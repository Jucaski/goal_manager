# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_01_000011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.string "genre"
    t.string "isbn"
    t.string "title", null: false
    t.integer "total_pages"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "chinese_words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "decomposition"
    t.text "etymology"
    t.string "example_en1"
    t.string "example_en2"
    t.string "example_en3"
    t.string "example_zh1"
    t.string "example_zh2"
    t.string "example_zh3"
    t.text "grammar_note"
    t.integer "level"
    t.string "part_of_speech"
    t.string "pinyin"
    t.string "radical"
    t.string "translation"
    t.datetime "updated_at", null: false
    t.string "word", null: false
    t.index ["word"], name: "index_chinese_words_on_word", unique: true
  end

  create_table "counters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "descending", null: false
    t.string "duration_unit"
    t.integer "duration_value"
    t.date "end_date", null: false
    t.string "mode", default: "duration", null: false
    t.date "start_date", null: false
    t.string "tag"
    t.string "title", null: false
    t.string "units", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "tag"], name: "index_counters_on_user_id_and_tag"
    t.index ["user_id"], name: "index_counters_on_user_id"
  end

  create_table "day_habits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "habit_id", null: false
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["habit_id"], name: "index_day_habits_on_habit_id"
    t.index ["user_id"], name: "index_day_habits_on_user_id"
  end

  create_table "financial_entries", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.date "date"
    t.string "description"
    t.string "entry_type"
    t.string "source_or_category"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_financial_entries_on_user_id"
  end

  create_table "flashcard_decks", force: :cascade do |t|
    t.jsonb "back_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.integer "daily_goal", default: 20, null: false
    t.integer "daily_review_goal", default: 50, null: false
    t.jsonb "front_fields", default: [], null: false
    t.string "kind", default: "configurable", null: false
    t.jsonb "levels", default: [], null: false
    t.string "name", null: false
    t.boolean "tts_back", default: false, null: false
    t.boolean "tts_front", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_flashcard_decks_on_user_id"
  end

  create_table "flashcards", force: :cascade do |t|
    t.bigint "chinese_word_id", null: false
    t.datetime "created_at", null: false
    t.float "difficulty", default: 0.0, null: false
    t.datetime "due_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "elapsed_days", default: 0, null: false
    t.date "first_review_date"
    t.bigint "flashcard_deck_id", null: false
    t.integer "lapses", default: 0, null: false
    t.date "last_review_date"
    t.integer "reps", default: 0, null: false
    t.integer "scheduled_days", default: 0, null: false
    t.float "stability", default: 0.0, null: false
    t.integer "state", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chinese_word_id"], name: "index_flashcards_on_chinese_word_id"
    t.index ["flashcard_deck_id", "chinese_word_id"], name: "index_flashcards_on_flashcard_deck_id_and_chinese_word_id", unique: true
    t.index ["flashcard_deck_id"], name: "index_flashcards_on_flashcard_deck_id"
    t.index ["user_id", "due_at"], name: "index_flashcards_on_user_id_and_due_at"
    t.index ["user_id"], name: "index_flashcards_on_user_id"
  end

  create_table "habits", force: :cascade do |t|
    t.date "completed_date"
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "position"], name: "index_habits_on_user_id_and_position"
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "hanzi", primary_key: "character", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "medians", default: [], null: false
    t.jsonb "strokes", default: [], null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "month", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "year", null: false
    t.index ["user_id", "year", "month"], name: "index_monthly_plans_on_user_id_and_year_and_month", unique: true
    t.index ["user_id"], name: "index_monthly_plans_on_user_id"
  end

  create_table "planned_books", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "monthly_plan_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_planned_books_on_book_id"
    t.index ["monthly_plan_id", "book_id"], name: "index_planned_books_on_monthly_plan_id_and_book_id", unique: true
    t.index ["monthly_plan_id"], name: "index_planned_books_on_monthly_plan_id"
    t.index ["user_id"], name: "index_planned_books_on_user_id"
  end

  create_table "reading_logs", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.date "finish_date"
    t.text "notes"
    t.integer "rating"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_reading_logs_on_book_id"
    t.index ["user_id", "book_id"], name: "index_reading_logs_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_reading_logs_on_user_id"
  end

  create_table "review_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "flashcard_id", null: false
    t.integer "rating", null: false
    t.date "review_date", null: false
    t.integer "state_after", null: false
    t.integer "state_before", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["flashcard_id", "review_date"], name: "index_review_logs_on_flashcard_id_and_review_date"
    t.index ["flashcard_id"], name: "index_review_logs_on_flashcard_id"
    t.index ["user_id"], name: "index_review_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weight_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weight"
    t.index ["user_id"], name: "index_weight_entries_on_user_id"
  end

  create_table "workout_sessions", force: :cascade do |t|
    t.integer "calories"
    t.datetime "created_at", null: false
    t.date "date"
    t.float "distance"
    t.boolean "is_running"
    t.float "max_pace"
    t.text "note"
    t.integer "rest_duration"
    t.integer "sets"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "work_duration"
    t.bigint "workout_template_id"
    t.index ["user_id"], name: "index_workout_sessions_on_user_id"
    t.index ["workout_template_id"], name: "index_workout_sessions_on_workout_template_id"
  end

  create_table "workout_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_running"
    t.string "name"
    t.integer "rest_duration"
    t.integer "sets"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "work_duration"
    t.index ["user_id"], name: "index_workout_templates_on_user_id"
  end

  create_table "yearly_goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "target_books", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "year", null: false
    t.index ["user_id", "year"], name: "index_yearly_goals_on_user_id_and_year", unique: true
    t.index ["user_id"], name: "index_yearly_goals_on_user_id"
  end

  add_foreign_key "books", "users"
  add_foreign_key "counters", "users"
  add_foreign_key "day_habits", "habits"
  add_foreign_key "day_habits", "users"
  add_foreign_key "financial_entries", "users"
  add_foreign_key "flashcard_decks", "users"
  add_foreign_key "flashcards", "chinese_words"
  add_foreign_key "flashcards", "flashcard_decks"
  add_foreign_key "flashcards", "users"
  add_foreign_key "habits", "users"
  add_foreign_key "monthly_plans", "users"
  add_foreign_key "planned_books", "books"
  add_foreign_key "planned_books", "monthly_plans"
  add_foreign_key "planned_books", "users"
  add_foreign_key "reading_logs", "books"
  add_foreign_key "reading_logs", "users"
  add_foreign_key "review_logs", "flashcards"
  add_foreign_key "review_logs", "users"
  add_foreign_key "weight_entries", "users"
  add_foreign_key "workout_sessions", "users"
  add_foreign_key "workout_sessions", "workout_templates"
  add_foreign_key "workout_templates", "users"
  add_foreign_key "yearly_goals", "users"
end
