defmodule Markov do

  defstruct markov_map: HashDict.new()

  # TODO: should I use atoms here? Does it matter?
  # __START__
  # __END__

  def add_text(text) do
    add_words(["__START__"|String.split(text)])
  end # def add_text

  
  def add_words(words) when (length words) == 1 do
    [first|_] = words
    add_pair(first,"__END__")
  end

  def add_words(words) do
    [first|rest] = words
    [second|_] = rest
    add_pair(first,second)
    add_words rest
  end # def add_words

  def add_pair(first, second) do
    Dict.update(markov_map, first, [second], fn words -> [second|words] end )
  end # def add_pair

  def dump do
    IO.puts markov_map
  end

end # the Markov module declaration

mark = Markov.new()

Markov.add_text("this is a long text of words that is not too full of words there are more")
Markov.dump

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
