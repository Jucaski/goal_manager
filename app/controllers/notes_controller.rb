class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  def index
    @notes = current_user.notes.ordered
    @notes = @notes.search(params[:q]) if params[:q].present?
    @notes = @notes.with_tag(params[:tag]) if params[:tag].present?
    @notes = @notes.where(note_type: params[:type]) if params[:type].present?

    @tags = current_user.notes
                     .pluck(:tags)
                     .flatten
                     .compact
                     .reject(&:blank?)
                     .tally
                     .sort_by { |_tag, count| -count }
  end

  def new
    @note = current_user.notes.build
    @note.note_type = params[:type] || "typed"
  end

  def create
    @note = current_user.notes.build(note_params)

    if @note.save
      redirect_to @note, notice: "Note created."
    else
      @tags = current_user.notes.pluck(:tags).flatten.compact.tally
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to @note, notice: "Note updated."
    else
      @tags = current_user.notes.pluck(:tags).flatten.compact.tally
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @note.destroy!
    redirect_to notes_path, notice: "Note deleted."
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :note_type, :content, :tags_string, :drawing_data, :ocr_text)
  end
end
