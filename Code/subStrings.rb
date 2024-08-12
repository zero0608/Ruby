def substrings(word, dictionary)
  cleaned_word = word.downcase.gsub(/[^a-z0-9]/, '')
  result = Hash.new(0)

  dictionary.each do |substring|
    cleaned_substring = substring.downcase
    count = cleaned_word.scan(/(?=#{Regexp.escape(cleaned_substring)})/).size
    result[cleaned_substring] += count if count > 0
  end

  result
end

dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
result = substrings("Howdy partner, sit down! How's it going?", dictionary)
puts result