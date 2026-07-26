desc "Fetch cover URLs for all books with ISBN"
task fetch_book_covers: :environment do
  Book.where(cover_url: nil).find_each do |book|
    BookCoverFetcher.call(book)
    print "."
  end
  puts " done"
end
