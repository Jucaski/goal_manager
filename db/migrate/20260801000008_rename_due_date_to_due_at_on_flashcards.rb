class RenameDueDateToDueAtOnFlashcards < ActiveRecord::Migration[8.1]
  def up
    rename_column :flashcards, :due_date, :due_at
    change_column :flashcards, :due_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
  end

  def down
    change_column :flashcards, :due_at, :date, default: -> { "CURRENT_DATE" }
    rename_column :flashcards, :due_at, :due_date
  end
end
