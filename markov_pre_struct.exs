defmodule Markov do

  # TODO: should I use atoms here? Does it matter?
  # __START__
  # __END__

  def add_text(m,text) do
    add_words(m,["__START__"|String.split(text)])
  end # def add_text
  
  def add_words(m,words) when (length words) == 1 do
    IO.puts "got here!"
    [first|_] = words
    add_pair(m,first,"__END__")
  end

  def add_words(m,words) do
    [first|rest] = words
    [second|_] = rest
    m = add_pair(m,first,second)
    add_words(m,rest)
  end # def add_words

  def add_pair(m,first, second) do
    Dict.update(m, first, [second], fn words -> [second|words] end )
  end # def add_pair

end # the Markov module declaration

m = HashDict.new()
m = Markov.add_text(m,"this is a long text of words that is not too full of words there are more")

# call the program with a file name.
# use the file as the source.
# TODO: customize for tweets?
# take each line
#  split into words
#  store word one : word two
#  if a word is the next of the sentence or tweet, note that word : XX_END_XX
# after all of that
#
# x:y
# x:y
# x:z
# x:a
# x:y
# x:XX_END_XX

# randomly pick a starting word, print it.
# TODO: do you track starting words?
# randomly generate a number, find the next word, print it, use its
# possibilities to find the next.
# keep going into you get to an end word.
