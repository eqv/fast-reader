
sleep_time = 60/700.0

def hl_index(word)
  return case word.length
    when 1      then    0
    when 2..5   then    1
    when 6..9   then    2
    when 10..13 then    3
    else 4
  end
end

def clear_screen()
  print("\033[2J\033[1;1H")
end

def print_word(word)
  clear_screen()
  i = hl_index(word)
  str = ("\n"*10) + " "*(10-i)
  str += word[0...i]
  str += "\033[31m#{word[i].chr}\033[0m"
  str += word[i+1..-1]
  str+="\n"
  print str
  STDOUT.flush
end

def time_factor(word, sentence_length)
  mult = 1
  mult *= 1.6 if word.length > 13
  mult *= 1.3 if word.length > 7 && word.length <=13
  mult *= 1.3 if word.length < 4
  mult *= 1.3 unless word =~ /^[a-z]+$/i
  mult *= 1.1 if word =~ /^[A-Z]/
  if word =~/[,;:."?]/
    mult *= 3.3 if sentence_length > 22
    mult *= 2.2 if sentence_length > 11 && sentence_length <= 22
  end

  return mult
end

clear_screen
print_word("get ready")

sleep 1
sentence_length = 0
while line = gets
  line.split(/\s+/).each do |word|
    next unless word.length > 0
    print_word(word)
    sleep sleep_time*time_factor(word, sentence_length)
    if word =~ /\./
      sentence_length = 0
    else
      sentence_length += 1
    end
  end
end
