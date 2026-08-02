class AddDailyGoalToFlashcardDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :flashcard_decks, :daily_goal, :integer, null: false, default: 20
    add_column :flashcards, :first_review_date, :date
  end
end
