%% @authors Priti Gumaste and Archana Dabbeghatta Nanjegowda
%% This file contains the Client implementation


-module(miningClient).
-compile(export_all).
-import(miningServer, [random_generator/2]).


%Client process 
 client(Leading_Zeros,Server_PID) when Leading_Zeros > 0 -> 
    {server, Server_PID} ! {create, Leading_Zeros},
    io:format("<CLIENT>Server requested for Leading_Zeros ~p \n", [Leading_Zeros]);
 

 client(Leading_Zeros, _) when Leading_Zeros  == 0 -> 
    random_generator(1, 0),
    io:format("<CLIENT>Server requested for Leading_Zeros~n").  


% Start the client using this function.
% Value is the number of prefixed zeroes we want in our hash value.
start_client(Server_Node) ->
	{ok, K} = io:read(" "),
    spawn(miningClient, client, [K, Server_Node]).
 
