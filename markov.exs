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

  def add_text(dict \\ HashDict.new, text) do
    words = List.flatten [:start, String.split(text), :end]
    add_words(dict, words)
  end

  def add_files(dict \\ HashDict.new, [file|rest]) do
    dict
      |> add_file(file)
      |> add_files(rest)
  end

  # used to have a version that was [head|tail] when (length tail) == 0
  def add_files(dict, []) do
    # have to return the dict
    dict
  end

  def add_file(dict \\ HashDict.new, tweeter_file) do
    contents = File.read! tweeter_file
    # get rid of the first line, which isn't JSON
    # TODO could read this file line by line, using pattern matching to
    # find the _one_ line i want.
    [_,json_data] = Regex.run(~r/Grailbird.data.tweets_\d+_\d+ =(.*)/s,contents)
    tweets = ExJSON.parse(json_data, :to_map)
        # IO.puts "about to add tweets to dict"
        # Markov.dump(dict)
    parse_tweet(dict, tweets)
  end

  # produce a single tweet
  def generate_tweet(dict) do
    #TODO: i don't like the repition with the logic in the called module
    {:ok, nexts} = Dict.fetch(dict, :start)
    word = Random.sample(nexts)
    next_word(dict, word)
  end

  def generate_tweets(_, 0) do
  end

  def generate_tweets(dict, times) do
    IO.puts generate_tweet(dict)
    generate_tweets(dict, times - 1)
  end

  def dump(dict) do
    IO.inspect dict
  end

  # ##################################################################

  # TODO: could have these be 
  # map, [:start, first_word | rest] do
  # map, [last_word, :end] do
  # map, [word, word_after|rest] do, here calling with add_pair([word_after|rest]

  defp add_words(dict, [:start | [first_word|_]=rest]) do
    dict
    |> add_pair(:start, first_word)
    |> add_words(rest)
  end

  defp add_words(dict, [last_word, :end]) do
    dict
    |> add_pair(last_word, :end)
  end

  defp add_words(dict, [word | [word_after|_]=rest]) do
    dict
    |> add_pair(word, word_after)
    |> add_words(rest)
  end

  defp add_pair(dict, first, second) do
    dict
    |> Dict.update first, [second], fn words -> [second|words] end
  end

  # #############################################################
  # output
  # #############################################################

  defp next_word(_, :end) do
    ""
  end

  defp next_word(dict, word) do
    {:ok, nexts} = Dict.fetch(dict, word)
    next = Random.sample(nexts)
    # IO.puts "the word is #{word} and its possible followers are:"
    # IO.inspect Dict.fetch(dict, next)
    "#{word} " <> next_word(dict, next)
  end
    
  # #############################################################
  # adding tweet text to the chain data 
  # #############################################################
  defp parse_tweet(dict, tweets) when length(tweets) == 0 do
    dict
  end

  defp parse_tweet(dict, [tweet|rest]) do
    #IO.puts "tweet to parse is: #{tweet["text"]}"
    dict 
      |> add_text(tweet["text"])
      |> parse_tweet(rest)
  end

end # the Markov module declaration

[times|files] = System.argv
{times,_} = Integer.parse(times)

# mark = Markov.new
mark = Markov.add_files(files)

Markov.generate_tweets(mark, times)

# {:ok, agent} = Agent.start_link fn -> [] end

