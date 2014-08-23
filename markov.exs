defmodule Markov do

  @name MarkovAgent

  # import Random
  # import ExJSON

  def start_link do
    Agent.start_link(&HashDict.new/0, name: @name)
  end

  # API for a remote agent. not going to pass files in the API as the caller
  # and callee might be on different machines.
  # also leaving the parsing of the tweet file on the client. the server is
  # just where you add the tweets.

  def add_tweet(text) do
    # IO.puts "calling the agent's add_tweet"
    Agent.update(@name, &do_add_tweet(&1, text))
  end

  def generate_tweet do
    Agent.get(@name, &do_generate_tweet(&1))
  end

  def dump() do
    Agent.get(@name, &do_dump(&1))
  end

  # ###########################################################################
  # end api
  # ###########################################################################

  def do_dump(dict) do
    dict
  end


  # ###########################################################################
  # do_add_tweet impl
  # ###########################################################################

  def do_add_tweet(dict \\ HashDict.new, text) do

    words = List.flatten [:start, String.split(text), :end]
    add_words(dict, words)

  end

  # could have these be 
  # map, [:start, first_word | rest] do
  # map, [last_word, :end] do
  # map, [word, word_after|rest] do, calling next: add_pair([word_after|rest]

  defp add_words(dict, [:start | [first_word|_]=rest]) do
    dict
    |> add_pair(:start, first_word)
    |> add_words(rest)
  end

  defp add_words(dict, [last_word, :end]) do
    add_pair(dict, last_word, :end)
  end

  defp add_words(dict, [word | [word_after|_]=rest]) do
    dict
    |> add_pair(word, word_after)
    |> add_words(rest)
  end

  defp add_pair(dict, first, second) do
    Dict.update dict, first, [second], fn words -> [second|words] end
  end

  # ###########################################################################
  # do_generate_tweet impl
  # ###########################################################################
  def do_generate_tweet(dict) do

    #TODO: i don't like the repition with the logic in the called module
    {:ok, nexts} = Dict.fetch(dict, :start)
    word = Random.sample(nexts)
    next_word(dict, word)

  end

  defp next_word(_, :end) do
    ""
  end

  defp next_word(dict, word) do
    {:ok, nexts} = Dict.fetch(dict, word)
    next = Random.sample(nexts)
    "#{word} " <> next_word(dict, next)
  end
    

  # ###########################################################################
  # local helpers, not in the agent
  # ###########################################################################

  # dealing with twitter data files
  def add_files([]) do
    # noop
  end

  def add_files([file|rest]) do
    # add_file(file)
    add_file_by_line(file)
    add_files(rest)
  end

  def add_file(tweeter_file) do
    contents = File.read! tweeter_file
    # get rid of the first line, which isn't JSON
    [_,json_data] = Regex.run(~r/Grailbird.data.tweets_\d+_\d+ =(.*)/s,contents)
    tweets = ExJSON.parse(json_data, :to_map)
        # IO.puts "about to add tweets to dict"
        # Markov.dump(dict)
    parse_tweet(tweets)
  end

  def add_file_by_line(twitter_file) do
    File.stream!(twitter_file)
      |> Stream.map( fn line -> 
           Regex.run(~r/\s+"text"\s+:\s+"(.*)",/s,line) 
         end)
      |> Stream.filter( fn x -> is_list x end) 
      |> Stream.map( fn [_,tweet_text] -> tweet_text end)
      |> Enum.to_list 
      |> parse_tweet2
  end

  defp parse_tweet([]) do
  end

  defp parse_tweet([tweet|rest]) do
    add_tweet(tweet["text"])
    parse_tweet(rest)
  end

  defp parse_tweet2([]) do
  end

  defp parse_tweet2([tweet|rest]) do
    add_tweet(tweet)
    parse_tweet2(rest)
  end

  # generating multiple tweets

  def generate_tweets(0) do
  end

  def generate_tweets(times) do
    IO.puts generate_tweet
    generate_tweets(times - 1)
  end

end # the Markov module declaration

[times|files] = System.argv
{times,_} = Integer.parse(times)

Markov.start_link
Markov.add_files(files)
Markov.generate_tweets(times)




