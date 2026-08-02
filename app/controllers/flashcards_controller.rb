class FlashcardsController < ApplicationController
  before_action :authenticate_user!

  def review
    @card = current_user.flashcards.find(params[:id])
    @card.review!(params[:rating].to_i)
    redirect_to redirect_path(@card.flashcard_deck), notice: "Reviewed."
  end

  private

  def redirect_path(deck)
    if deck.writing?
      study_writing_flashcard_deck_path(deck)
    else
      study_flashcard_deck_path(deck)
    end
  end
end
