require "net/http"
require "json"

class BookCoverFetcher
  GB_API = "https://www.googleapis.com/books/v1/volumes"
  OL_URL = "https://covers.openlibrary.org/b/isbn"

  def self.call(book)
    isbn = book.isbn&.tr("-", "")
    try_google_by_isbn(book, isbn) || try_google_by_title(book) || try_open_library(book, isbn)
  end

  def self.try_google_by_isbn(book, isbn)
    return nil if isbn.blank?
    uri = URI("#{GB_API}?q=isbn:#{isbn}&fields=items(volumeInfo(imageLinks))")
    extract_cover(book, uri)
  end

  def self.try_google_by_title(book)
    query = +""
    query << "intitle:#{book.title}" if book.title.present?
    query << "+inauthor:#{book.author}" if book.author.present?
    return nil if query.blank?
    uri = URI("#{GB_API}?q=#{URI.encode_www_form_component(query)}&fields=items(volumeInfo(imageLinks))")
    extract_cover(book, uri)
  end

  def self.try_open_library(book, isbn)
    return nil if isbn.blank?
    book.update(cover_url: "#{OL_URL}/#{isbn}-M.jpg")
  end

  def self.extract_cover(book, uri)
    response = Net::HTTP.get_response(uri)
    return nil unless response.code.to_i == 200
    data = JSON.parse(response.body)
    link = data.dig("items", 0, "volumeInfo", "imageLinks", "thumbnail")
    return nil if link.blank?
    link = link.sub("http:", "https:") if link.start_with?("http:")
    book.update(cover_url: link)
  rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED
    nil
  end
end
