defmodule Markov do

  def new(text) do
    m = HashDict.new
    add_text m, text
  end

  def add_text(markov_map, text) do
    words = List.flatten [:start, String.split(text), :end]
    add_words markov_map, words
  end

  def add_words(markov_map, [:start | [first_word|_]=rest]) do
    m = add_pair markov_map, :start, first_word
    add_words m, rest
  end

  def add_words(markov_map, [last_word, :end]) do
    add_pair markov_map, last_word, :end
  end

  def add_words(markov_map, [word | [word_after|_]=rest]) do
    m = add_pair markov_map, word, word_after
    add_words m, rest
  end

  def add_pair(markov_map, first, second) do
    Dict.update markov_map, first, [second], fn words -> [second|words] end
  end

  def dump(markov_map) do
    IO.inspect markov_map
  end

end # the Markov module declaration

text = "this is a long text of words that is not too full of words there are more"
IO.puts "\nCreating new Markov with '#{text}'"
mark = Markov.new text
Markov.dump(mark)

text = "first fa1 first fa2 second sa1 first fa3"
IO.puts "\n\nCreating new Markov with '#{text}'"
mark = Markov.new text
Markov.dump(mark)

text = "first faa1"
IO.puts "\nAdding to existing Markov with '#{text}'"
mark = Markov.add_text(mark, text)
Markov.dump(mark)
