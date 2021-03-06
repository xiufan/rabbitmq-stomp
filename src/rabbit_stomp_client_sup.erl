%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2007-2012 VMware, Inc.  All rights reserved.
%%

-module(rabbit_stomp_client_sup).
-behaviour(supervisor2).

-define(MAX_WAIT, 16#ffffffff).
-export([start_link/1, start_processor/2, init/1]).

start_link(Configuration) ->
    {ok, SupPid} = supervisor2:start_link(?MODULE, []),
    {ok, ReaderPid} =
        supervisor2:start_child(SupPid,
                               {rabbit_stomp_reader,
                                {rabbit_stomp_reader,
                                 start_link, [SupPid, Configuration]},
                                intrinsic, ?MAX_WAIT, worker,
                                [rabbit_stomp_reader]}),
    {ok, SupPid, ReaderPid}.

start_processor(SupPid, Args) ->
    supervisor2:start_child(SupPid,
                            {rabbit_stomp_processor,
                             {rabbit_stomp_processor, start_link, [Args]},
                             intrinsic, ?MAX_WAIT, worker,
                             [rabbit_stomp_processor]}).

init([]) ->
    {ok, {{one_for_all, 0, 1}, []}}.

