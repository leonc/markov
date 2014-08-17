#!/bin/sh
elixir -pa ../elixir-random/_build/dev/lib/random/ebin -pa ../exjson/_build/dev/lib/exjson/ebin markov.exs 10 ~/Downloads/tweets/data/js/tweets/*

