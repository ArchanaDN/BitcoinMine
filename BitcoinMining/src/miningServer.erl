%% @authors Priti Gumaste and Archana Dabbeghatta Nanjegowda
%% This file contains the Server implementation


-module(miningServer).
-compile(export_all).
-import(string,[concat/2]).

%Server process
server() -> 
    receive
      {create, Leading_Zeros} -> 
            io:format("<SERVER> Server requested for Leading_Zeros ~p \n", [Leading_Zeros]),
            %Number 4 here is the number of actors that will be spawned in total. 
			Sup_PID = spawn(miningServer, supervisor, [4,Leading_Zeros]),
			%4 below is hardcoded value which is the number of coins we want to print
            Sup_PID ! {create,100},
            server()
    end.


%random_generator function performs the hashing and prints the hashed value of a random string
random_generator(Coins, K) when Coins > 0 ->
    Str2 = lists:concat(lists:duplicate(K, 0)),
    RB = base64:encode_to_string(crypto:strong_rand_bytes(8)),
    StrFinal = concat("priti4953-5219" , RB),
    String = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,StrFinal))]),
    Value2= string:slice(String, 0, K),
    Bool = string:equal([Str2], [Value2]),
 
    if 
       Bool == true -> 
          io:fwrite("\n"),
		  io:fwrite("~s : ~s", [StrFinal, String]),
          random_generator(Coins - 1, K);
       true ->
          random_generator(Coins, K)
    end;


random_generator(Coins, _) when Coins =< 0 ->
    {_,Time12} = statistics(runtime),
    {_,Time22} = statistics(wall_clock),
    io:format("\n The work took ~p CPU milliseconds and ~p Wall Clock milliseconds\n", [Time12, Time22]),
    io:format("\n Ratio of CPU/Real Time is: ~p ", [(Time12 /Time22)]).   

 
%This is the master to create the mining processors. 
 supervisor(Actors, Leading_Zeros) when Actors > 0 ->
   {_,Time1} = statistics(runtime),
    {_,Time2} = statistics(wall_clock),
    receive
      {create, NoOfCoins} -> 
            Coins_Per_Actor = NoOfCoins/Actors,
            %Spawn process to get the coins
            spawn(miningServer, random_generator, [NoOfCoins rem Actors, Leading_Zeros]),
            if Coins_Per_Actor > 0 ->
                createActors(Coins_Per_Actor, Actors, Leading_Zeros);
            true ->
                io:fwrite("Coin creation is done")
            end
    end.


%Function to create processes which will mine the coins
createActors(Coins, NoOfActors, Leading_Zeros) ->
    Pid = spawn(miningServer, random_generator, [Coins, Leading_Zeros]),
    io:format("~p~n \n", [Pid]),
    if NoOfActors - 1 > 0 ->
        createActors(Coins, NoOfActors - 1, Leading_Zeros);
    true ->
       io:fwrite("Actor creation is done")
    end.


%Start function for the server
start_server() ->
    register(server, spawn(miningServer, server, [])).