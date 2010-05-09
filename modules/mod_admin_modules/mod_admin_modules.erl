%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2009 Marc Worrell
%% @date 2009-06-03
%% @doc Add a module management screen to the admin.

%% Copyright 2009 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(mod_admin_modules).
-author("Marc Worrell <marc@worrell.nl>").
-behaviour(gen_server).

-mod_title("Admin module support").
-mod_description("Manages modules. Adds an admin interface to activate and deactivate modules.").
-mod_prio(700).

%% gen_server exports
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/1]).

%% interface functions
-export([
    all/1
]).

-include("zotonic.hrl").


%% @spec all(context()) -> ModuleDescriptions
%% @doc Fetch a list of all modules available, including their description as a propertylist. The module list is sorted
%% on the name of the module.
all(Context) ->
    Active  = z_module_sup:active(Context),
    Modules = z_module_sup:scan(Context),
    Descrs  = [ add_sort_key({z_module_sup:prio(M), M, [{active, lists:member(M, Active)}, {path, Path} | descr(M)]}) || {M, Path} <- Modules ],
    lists:sort(Descrs).


    add_sort_key({Prio, M, Props}) ->
        SortKey = case atom_to_list(M) of
                    "mod_" ++ _ -> {2, z_string:to_name(proplists:get_value(mod_title, Props))};
                    _ -> {1, proplists:get_value(mod_title, Props)}
                  end,
        {SortKey, Prio, M, Props}.
        

%% @spec descr(ModuleName) -> proplist()
%% @doc Return a property list with the title and other attributes of the module.
descr(Module) ->
    Descr = case z_module_sup:module_exists(Module) of
        true ->
            try
                erlang:get_module_info(Module, attributes)
            catch 
                _M:E -> [{error, E}]
            end;
        false ->
            [{error, enoent}]
    end,
    case proplists:get_value(title, Descr) of
        undefined ->
            Title = case atom_to_list(Module) of
                        "mod_" ++ T -> 
                            string:join(string:tokens(T, "_"), " ");
                        T ->
                            string:join(string:tokens(T, "_"), " ")
                    end,
            [{title, Title} | Descr];
        _Title ->
            Descr
    end.



%%====================================================================
%% API
%%====================================================================
%% @spec start_link(Args) -> {ok,Pid} | ignore | {error,Error}
%% @doc Starts the server
start_link(Args) when is_list(Args) ->
    gen_server:start_link(?MODULE, Args, []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore               |
%%                     {stop, Reason}
%% @doc Initiates the server.
init(_Args) ->
    {ok, []}.

%% @spec handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%% @doc Trap unknown calls
handle_call(Message, _From, State) ->
    {stop, {unknown_call, Message}, State}.


%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @doc Trap unknown casts
handle_cast(Message, State) ->
    {stop, {unknown_cast, Message}, State}.



%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% @doc Handling all non call/cast messages
handle_info(_Info, State) ->
    {noreply, State}.

%% @spec terminate(Reason, State) -> void()
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
terminate(_Reason, _State) ->
    ok.

%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @doc Convert process state when code is changed

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%====================================================================
%% support functions
%%====================================================================

