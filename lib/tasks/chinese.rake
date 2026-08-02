namespace :chinese do
  desc "Import Chinese words from the HSK CSV (shared by all users)"
  task :import_words, [ :path ] => :environment do |_t, args|
    path = args[:path] || ENV["HSK_CSV_PATH"] || Rails.root.join("hsk.csv")

    result = ChineseWordImporter.import!(path: path)
    puts "Imported #{result[:imported]} new words, updated #{result[:updated]}"
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
