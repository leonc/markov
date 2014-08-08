defmodule Markov do

  import Random
  import ExJSON

  def new(text) do
    HashDict.new
    |> add_text text
  end

  def add_text(markov_map, text) do
    words = List.flatten [:start, String.split(text), :end]
    markov_map
    |> add_words(words)
  end

  def generate(markov_map) do
    generate(markov_map, :start)
  end

  def dump(markov_map) do
    IO.inspect markov_map
  end

  # ##################################################################

  defp add_words(markov_map, [:start | [first_word|_]=rest]) do
    markov_map
    |> add_pair(:start, first_word)
    |> add_words(rest)
  end

  defp add_words(markov_map, [last_word, :end]) do
    markov_map
    |> add_pair(last_word, :end)
  end

  defp add_words(markov_map, [word | [word_after|_]=rest]) do
    markov_map
    |> add_pair(word, word_after)
    |> add_words(rest)
  end

  defp add_pair(markov_map, first, second) do
    markov_map
    |> Dict.update first, [second], fn words -> [second|words] end
  end

  # #############################################################
  # output
  # #############################################################

  defp generate(_, :end) do
    ""
  end

  defp generate(markov_map, previous) do
    {:ok, nexts} = Dict.fetch(markov_map, previous)
    # use the Random module
    word = sample(nexts)
    "#{word} " <> generate(markov_map, word)
  end
    
end # the Markov module declaration

text = "this is a long text of words that is not too full of words there are more"
mark = Markov.new text
text = "first fa1 first fa2 second sa1 first fa3"
mark = Markov.add_text(mark, text)

Markov.dump(mark)

IO.puts Markov.generate(mark)

{:ok, agent} = Agent.start_link fn -> [] end
