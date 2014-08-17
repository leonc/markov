defmodule Markov do

  # import Random
  # import ExJSON

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

  # used to have a version that was [head|tail] when (length tail) == 0
  def add_files(markov_map, []) do
    # have to return the dict
    markov_map
  end

  def add_files(markov_map, [file|rest]) do
    markov_map
      |> add_file(file)
      |> add_files(rest)
  end

  # if think this would work if we had this function here:
  # def add_files(markov_map, [file]) do
    # add_file(markov_map, file)
  # end

  def add_file(markov_map, tweeter_file) do
    contents = File.read! tweeter_file
    # get rid of the first line, which isn't JSON
    # TODO could read this file line by line, using pattern matching to
    # find the _one_ line i want.
    [_,json_data] = Regex.run(~r/Grailbird.data.tweets_\d+_\d+ =(.*)/s,contents)
    tweets = ExJSON.parse(json_data, :to_map)
        # IO.puts "about to add tweets to markov_map"
        # Markov.dump(markov_map)
    parse_tweet(markov_map, tweets)
  end

  # produce a single tweet
  def generate_tweet(markov_map) do
    #TODO: i don't like the repition with the logic in the called module
    {:ok, nexts} = Dict.fetch(markov_map, :start)
    word = Random.sample(nexts)
    next_word(markov_map, word)
  end

  # NOTE: this used to have a when times == 0
  def generate_tweets(_, 0) do
  end

  def generate_tweets(markov_map, times) do
    IO.puts generate_tweet(markov_map)
    generate_tweets(markov_map, times - 1)
  end

  def dump(markov_map) do
    IO.inspect markov_map
  end

  # ##################################################################

  # TODO: could have these be 
  # map, [:start, first_word | rest] do
  # map, [last_word, :end] do
  # map, [word, word_after|rest] do, here calling with add_pair([word_after|rest]

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

  defp next_word(_, :end) do
    ""
  end

  defp next_word(markov_map, word) do
    {:ok, nexts} = Dict.fetch(markov_map, word)
    next = Random.sample(nexts)
    # IO.puts "the word is #{word} and its possible followers are:"
    # IO.inspect Dict.fetch(markov_map, next)
    "#{word} " <> next_word(markov_map, next)
  end
    
  # #############################################################
  # tweet array processing
  # #############################################################
  defp parse_tweet(markov_map, tweets) when length(tweets) == 0 do
    markov_map
  end

  defp parse_tweet(markov_map, [tweet|rest]) do
    #IO.puts "tweet to parse is: #{tweet["text"]}"
    markov_map 
      |> add_text(tweet["text"])
      |> parse_tweet(rest)
  end

end # the Markov module declaration

[times|files] = System.argv
{times,_} = Integer.parse(times)

mark = Markov.new
mark = Markov.add_files(mark, files)

Markov.generate_tweets(mark, times)

# {:ok, agent} = Agent.start_link fn -> [] end

