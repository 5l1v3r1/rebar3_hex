-module(rebar3_hex_search).

-behaviour(provider).

-export([init/1,
         do/1,
         format_error/1]).

-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("providers/include/providers.hrl").

-define(PROVIDER, search).
-define(DEPS, []).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
                                {name, ?PROVIDER},
                                {module, ?MODULE},
                                {namespace, hex},
                                {bare, false},
                                {deps, ?DEPS},
                                {example, "rebar3 hex search <term>"},
                                {short_desc, "."},
                                {desc, ""},
                                {opts, [{term, undefined, undefined, string, "Search term."}]}
                                ]),
    State1 = rebar_state:add_provider(State, Provider),
    {ok, State1}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    case rebar_packages:registry(State) of
        {ok, Registry} ->
            {Args, _} = rebar_state:command_parsed_args(State),
            Term = proplists:get_value(term, Args, undefined),
            ets:foldl(fun({Name, _}, ok) when is_binary(Name) ->
                              case string:str(binary_to_list(Name), Term) of
                                  0 ->
                                      ok;
                                  N when N >= 0 ->
                                      io:format("~s~n", [Name])
                              end;
                         (_, ok) ->
                              ok
                      end, ok, Registry),
            {ok, State};
        error ->
            ?PRV_ERROR(load_registry_fail)
    end.

-spec format_error(any()) -> iolist().
format_error(load_registry_fail) ->
    "Failed to load package regsitry. Try running 'rebar3 update' to fix".
