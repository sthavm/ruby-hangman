wordfile_lines = File.readlines('5desk.txt')

File.open('dictionary.txt', 'w+') do |file|
  wordfile_lines.each do |word|
    if word.length >= 6 && word.length <= 13
      file.puts(word.downcase)
    end
  end
end
