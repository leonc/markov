defmodule Play do

  def tokenize(text) do
    String.split(text)
  end # def tokenize

end # defmodule

IO.puts Enum.join(Play.tokenize("this is a sentance. it has serveral parts,
all of which are important."), ":")

markov_map = HashDict.new()
Dict.put(markov_map,"one","first")
IO.puts Enum.join(markov_map)

case Dict.fetch(markov_map, "one") do
  :error -> rez = "it was an error"
  {:ok, following_words} -> rez = "it was ok"
end

IO.puts rez

