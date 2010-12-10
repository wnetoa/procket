%% Copyright (c) 2010, Michael Santos <michael.santos@gmail.com>
%% All rights reserved.
%% 
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions
%% are met:
%% 
%% Redistributions of source code must retain the above copyright
%% notice, this list of conditions and the following disclaimer.
%% 
%% Redistributions in binary form must reproduce the above copyright
%% notice, this list of conditions and the following disclaimer in the
%% documentation and/or other materials provided with the distribution.
%% 
%% Neither the name of the author nor the names of its contributors
%% may be used to endorse or promote products derived from this software
%% without specific prior written permission.
%% 
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
%% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
%% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
%% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
%% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
%% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.

%% Atomically create a temporary file.
%%
%% This module just creates a directory, put whatever temp files
%% you %% need inside the directory.
%%
%% Maybe this is better to do in C, inside an NIF.
%%
%% Problems:
%% * On some platforms, Unix sockets will be created with
%%   modes 777.
%% * The module does not test if the directory exists before
%%   creation
%% * If the directory creation fails, the module will just
%%   return an error.

-module(mktmp).

-export([dirname/0,dirname/1,make_dir/1,close/1]).

-include_lib("kernel/include/file.hrl").

-define(TEMPLATELEN, 6).
-define(TEMPNAME, "erlang.").

-define(S_IRWXU, 8#00400 bor 8#00200 bor 8#00100).

dirname() ->
    TMP = case os:getenv("TMPDIR") of
        false -> "/tmp";
        Dir -> Dir
    end,
    dirname(TMP).

dirname(TMP) ->
    crypto:start(),
    TmpDir = lists:flatten(
        [ io_lib:format("~.16B", [N]) || N <- binary_to_list(crypto:rand_bytes(?TEMPLATELEN)) ]
    ),
    TMP ++ "/" ++ ?TEMPNAME ++ TmpDir.

make_dir(Path) ->
    case file:make_dir(Path) of
        ok ->
            file:write_file_info(Path, #file_info{mode = ?S_IRWXU});
        Error ->
            Error
    end.

close(Path) ->
    file:del_dir(Path).


