class AddDailyReviewGoalToFlashcardDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :flashcard_decks, :daily_review_goal, :integer, null: false, default: 50
  end
end
