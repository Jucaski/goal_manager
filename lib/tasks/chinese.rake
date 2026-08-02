namespace :chinese do
  desc "Import Chinese words from the HSK CSV (all users unless an email is given)"
  task :import_words, [ :path, :email ] => :environment do |_t, args|
    path = args[:path] || ENV["HSK_CSV_PATH"] || Rails.root.join("hsk.csv")
    email = args[:email] || ENV["IMPORT_EMAIL"]

    users = email ? [ User.find_by!(email: email) ] : User.all
    users.each do |user|
      result = ChineseWordImporter.import!(user: user, path: path)
      puts "#{user.email}: imported #{result[:imported]}, updated #{result[:updated]}"
    end
  end

  desc "Import hanzi stroke data from makemeahanzi graphics.txt"
  task :import_hanzi, [ :path ] => :environment do |_t, args|
    path = args[:path] || ENV["MAKEMEAHANZI_PATH"]
    path ||= Rails.root.join("graphics.txt") if Rails.root.join("graphics.txt").exist?
    path ||= "/Users/pez/ExperimentalProjects/makemeahanzi/graphics.txt" if File.exist?("/Users/pez/ExperimentalProjects/makemeahanzi/graphics.txt")

    raise "graphics.txt not found. Pass a path: bin/rails chinese:import_hanzi[path/to/graphics.txt]" if path.nil?

    count = HanziImporter.import!(path: path)
    puts "Imported #{count} hanzi characters"
  end
end
