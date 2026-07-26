class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:edit, :update, :destroy]

  def index
    @books = current_user.books.order(:title)
  end

  def new
    @book = current_user.books.build
  end

  def create
    @book = current_user.books.build(book_params)
    if @book.save
      BookCoverFetcher.call(@book)
      redirect_to request.referer.presence || book_planner_path, notice: "Book added."
    else
      redirect_to book_planner_path, alert: @book.errors.full_messages.join(", ")
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      BookCoverFetcher.call(@book)
      redirect_to book_planner_path, notice: "Book updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to book_planner_path, notice: "Book removed."
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :total_pages, :genre, :isbn)
  end
end
