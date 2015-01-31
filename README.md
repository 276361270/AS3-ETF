Class help to communicate ActionScript and Erlang, using Erlang External Term Format.

Data Format

Erlang        | ActionScript    | Erlang
:------------:|:---------------:|:-----------------------:
atom		  |	"atom"          | <<"atom">>
<<"binary">>  | "binary"        | <<"binary>>
1             | 1               | 1
\#{}          | Object          | \#{}
\[\]          | \[\]            | \[\]
"string"      | [131,107,0,...] | \<\<131,107,0,6,115,116,114,105,110,103>>

Usage: 

    From AS to Erlang
    
        ActionScript
            var byte_array:ByteArray = Etf.encode(Data);
            socket.writeBytes(byte_array);
            
        Erlang 
            {ok, Packet} = gen_tcp:recv(Socket, 0),
            Data = binary_to_term(Packet).
            
    From Erlang to AS
    
        Erlang
            Packet = term_to_binary(Data), 
            gen_tcp:send(Socket, Packet).
            
        ActionScript
            var byte_array:ByteArray = new ByteArray();
            socket.readBytes(byte_array, 0, socket.bytesAvailable);
            var data:Object = Etf.decode(byte_array);
    
