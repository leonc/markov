defmodule Markov do

  def new(text) do
    HashDict.new
    |> add_text text
  end

  def add_text(markov_map, text) do
    words = List.flatten [:start, String.split(text), :end]
    markov_map
    |> add_words(words)
  end

  def add_words(markov_map, [:start | [first_word|_]=rest]) do
    markov_map
    |> add_pair(:start, first_word)
    |> add_words(rest)
  end

  def add_words(markov_map, [last_word, :end]) do
    markov_map
    |> add_pair(last_word, :end)
  end

  def add_words(markov_map, [word | [word_after|_]=rest]) do
    markov_map
    |> add_pair(word, word_after)
    |> add_words(rest)
  end

  def add_pair(markov_map, first, second) do
    markov_map
    |> Dict.update first, [second], fn words -> [second|words] end
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

{:ok, agent} = Agent.start_link fn -> [] end
