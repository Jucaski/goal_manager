namespace :chinese do
  desc "Import Chinese words from the HSK CSV"
  task :import_words, [ :path, :email ] => :environment do |_t, args|
    path = args[:path] || ENV["HSK_CSV_PATH"] || Rails.root.join("hsk.csv")
    email = args[:email] || ENV["IMPORT_EMAIL"]
    user = email ? User.find_by!(email: email) : User.order(:id).first

    result = ChineseWordImporter.import!(user: user, path: path)
    puts "Imported #{result[:imported]} new words, updated #{result[:updated]}"
  end

  desc "Import hanzi stroke data from makemeahanzi graphics.txt"
  task :import_hanzi, [ :path ] => :environment do |_t, args|
    path = args[:path] || ENV["MAKEMEAHANZI_PATH"] || "/Users/pez/ExperimentalProjects/makemeahanzi/graphics.txt"

    count = HanziImporter.import!(path: path)
    puts "Imported #{count} hanzi characters"
  end
end
