defmodule Markov do

  import Random
  import ExJSON

  def new(text) do
    HashDict.new
    |> add_text text
  end

  def new do
    HashDict.new
  end

  def add_text(markov_map, text) do
    # IO.puts "text to add was: #{text}"
    words = List.flatten [:start, String.split(text), :end]
    # IO.inspect words
    markov_map
    |> add_words(words)
  end

  def add_files(markov_map, [file|rest]) when length(rest) == 0 do
    IO.puts "adding file #{file}"
    add_file(markov_map, file)
  end

  def add_files(markov_map, [file|rest]) do
    markov_map = add_file(markov_map, file)
    add_files(markov_map, rest)
  end

  def add_file(markov_map, tweeter_file) do
    contents = File.read! tweeter_file
    # get rid of the first line
    [_,json_data] = Regex.run(~r/Grailbird.data.tweets_\d+_\d+ =(.*)/s,contents)
    tweets = ExJSON.parse(json_data, :to_map)
        # IO.puts "about to add tweets to markov_map"
        # Markov.dump(markov_map)
    parse_tweet(markov_map, tweets)
  end

  def generate(markov_map) do
    #TODO: i don't like the repition with the logic in the called module
    {:ok, nexts} = Dict.fetch(markov_map, :start)
    word = sample(nexts)
    generate(markov_map, word)
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

  defp generate(markov_map, word) do
    {:ok, nexts} = Dict.fetch(markov_map, word)
    # use the Random module
    next = sample(nexts)
    # IO.puts "the word is #{word} and its possible followers are:"
    # IO.inspect Dict.fetch(markov_map, next)
    "#{word} " <> generate(markov_map, next)
  end
    
  # #############################################################
  # tweet array processing
  # #############################################################
  defp parse_tweet(markov_map, tweets) when length(tweets) == 0 do
    markov_map
  end

  defp parse_tweet(markov_map, [tweet|rest]) do
    #IO.puts "tweet to parse is: #{tweet["text"]}"
    # markov_map 
    # |> add_text tweet["text"]
    # |> parse_tweet rest
    markov_map = add_text(markov_map, tweet["text"])
    parse_tweet(markov_map, rest)
  end

end # the Markov module declaration

mark = Markov.new
mark = Markov.add_files(mark, System.argv)
# mark = Markov.add_file(mark, "2012_12.js")
Markov.dump(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)
IO.puts Markov.generate(mark)


#text = "this is a long text of words that is not too full of words there are more"
#mark = Markov.new text
#text = "first fa1 first fa2 second sa1 first fa3"
#mark = Markov.add_text(mark, text)

#Markov.dump(mark)

#IO.puts Markov.generate(mark)

# {:ok, agent} = Agent.start_link fn -> [] end

# mark = Markov.new "foo bar baz"
