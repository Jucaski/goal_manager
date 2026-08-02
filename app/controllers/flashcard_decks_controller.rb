class FlashcardDecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck, only: [ :show, :update, :destroy, :generate_cards, :study, :study_writing, :summary ]

  def index
    @decks = current_user.flashcard_decks.order(:created_at)
    @deck = current_user.flashcard_decks.build
  end

  def show
    @cards = @deck.flashcards.includes(:chinese_word).order(:id)
    @due_count = @deck.due_cards.count
  end

  def create
    @deck = current_user.flashcard_decks.build(deck_params)

    if @deck.save
      redirect_to @deck, notice: "Deck created."
    else
      @decks = current_user.flashcard_decks.order(:created_at)
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Deck updated."
    else
      render :show, status: :unprocessable_content
    end
  end

  def destroy
    @deck.destroy!
    redirect_to flashcard_decks_path, notice: "Deck deleted."
  end

  def generate_cards
    created = @deck.generate_cards!
    redirect_to @deck, notice: "Generated #{created} cards."
  end

  def study
    @card = @deck.next_card
    redirect_to @deck, notice: no_cards_message if @card.nil?
  end

  def study_writing
    @card = @deck.next_card
    redirect_to @deck, notice: no_cards_message if @card.nil?

    return unless @card

    @characters = @card.chinese_word.word.each_char.to_a
    @hanzi_data = @characters.to_h { |character| [ character, Hanzi.find_by(character: character) ] }
  end

  def summary
    @studied_count = @deck.studied_count
    @words_by_level = @deck.words_by_level
    @phase_counts = @deck.phase_counts
    @review_counts_by_day = @deck.review_counts_by_day
  end

  private

  def set_deck
    @deck = current_user.flashcard_decks.find(params[:id])
  end

  def no_cards_message
    if @deck.flashcards.any?
      if @deck.words_studied_today >= @deck.daily_review_goal.to_i
        "You reached your daily limit of #{@deck.daily_review_goal} words. Come back tomorrow!"
      elsif @deck.new_cards_today >= @deck.daily_goal.to_i
        "You finished today's #{@deck.daily_goal} new words — the rest of your reviews are ready. Keep going!"
      else
        "No cards are due right now. Learning cards become available again shortly."
      end
    else
      "No cards to study yet. Generate cards first."
    end
  end

  def deck_params
    params.require(:flashcard_deck).permit(
      :name, :kind, :daily_goal, :daily_review_goal, :tts_front, :tts_back,
      front_fields: [], back_fields: [], levels: []
    )
  end
end
