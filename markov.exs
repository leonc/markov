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

  def add_text(text) do
    # IO.puts "calling the agent's add_text"
    Agent.update(@name, &do_add_text(&1, text))
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
  # do_add_text impl
  # ###########################################################################

  def do_add_text(dict \\ HashDict.new, text) do

    # IO.puts "in the impl with #{text} and"
    # IO.inspect dict

    words = List.flatten [:start, String.split(text), :end]
    add_words(dict, words)

  end

  # TODO: could have these be 
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

    # IO.puts "generating a tweet from"
    # IO.inspect dict

    case Dict.fetch(dict, :start) do
      {:ok, nexts} -> Dict.fetch(dict, :start)
                      word = Random.sample(nexts)
                      next_word(dict, word)
      :error -> "the start tag wasn't in the dict"
    end
  end

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
    

  # ###########################################################################
  # local helpers, not in the agent
  # ###########################################################################

  # dealing with twitter data files
  def add_files([]) do
    # noop
  end

  def add_files([file|rest]) do
    add_file(file)
    add_files(rest)
  end

  def add_file(tweeter_file) do
    contents = File.read! tweeter_file
    # get rid of the first line, which isn't JSON
    # TODO could read this file line by line, using pattern matching to
    # find the _one_ line i want.
    [_,json_data] = Regex.run(~r/Grailbird.data.tweets_\d+_\d+ =(.*)/s,contents)
    tweets = ExJSON.parse(json_data, :to_map)
        # IO.puts "about to add tweets to dict"
        # Markov.dump(dict)
    parse_tweet(tweets)
  end

  # defp parse_tweet(dict, tweets) when length(tweets) == 0 do
  defp parse_tweet([]) do
  end

  defp parse_tweet([tweet|rest]) do
    #IO.puts "tweet to parse is: #{tweet["text"]}"
    add_text(tweet["text"])
    parse_tweet(rest)
  end

  # generating multiple tweets

  def generate_tweets(0) do
  end

  def generate_tweets(times) do
    IO.puts generate_tweet
    generate_tweets(times - 1)
  end

  # #############################################################
  # adding tweet text to the chain data 
  # #############################################################
end # the Markov module declaration

[times|files] = System.argv
{times,_} = Integer.parse(times)

Markov.start_link
# Markov.add_text("this is a possible tweet.")
Markov.add_files(files)
# IO.inspect Markov.dump
# IO.puts Markov.generate_tweet
Markov.generate_tweets(times)




