package Sovereign_Mesh_Gossip_Dissemination_Guard with
  SPARK_Mode => On
is
   subtype Peer_Id_Range is Integer range 1 .. 64;
   subtype Peer_Count is Integer range 0 .. 64;
   subtype Hop_Budget is Integer range 1 .. 8;
   subtype Packet_Payload_Size is Integer range 1 .. 4096;
   subtype Gossip_Rate_Pps is Integer range 0 .. 100;
   subtype Disseminated_Packet_Count is Integer range 0 .. 512;
   type Hash_Digest is mod 2**32;
   subtype Round_Counter is Integer range 0 .. 1_000_000;

   type Gossip_State is record
      Known_Peers   : Peer_Count;
      Active_Fanout : Hop_Budget;
      Current_Rate  : Gossip_Rate_Pps;
      Total_Rounds  : Round_Counter;
      Last_Digest   : Hash_Digest;
      Is_Quenched   : Boolean;
      Is_Scrubbed   : Boolean;
   end record;

   procedure Initialize_Gossip_Engine (State : out Gossip_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Known_Peers = 0 and
             State.Active_Fanout = 3 and
             State.Current_Rate = 0 and
             State.Total_Rounds = 0 and
             State.Last_Digest = 0 and
             State.Is_Quenched = False and
             State.Is_Scrubbed = False;

   procedure Register_Peer
     (State      : in out Gossip_State;
      Peer_Id    : in     Peer_Id_Range;
      Registered : out    Boolean) with
     Global => null,
     Depends => (State      => State,
                 Registered => State,
                 null       => Peer_Id),
     Pre => State.Total_Rounds < Round_Counter'Last,
     Post => (if Registered then
                State.Known_Peers = State.Known_Peers'Old + 1 and
                State.Total_Rounds = State.Total_Rounds'Old + 1 and
                State.Known_Peers'Old < 64
              else
                State = State'Old and State.Known_Peers = 64);

   procedure Disseminate_Rumor
     (State         : in out Gossip_State;
      In_Digest     : in     Hash_Digest;
      Payload_Bytes : in     Packet_Payload_Size;
      Target_Fanout : in     Hop_Budget;
      Out_Packets   : out    Disseminated_Packet_Count;
      Success       : out    Boolean) with
     Global => null,
     Depends => (State       => (State, In_Digest, Payload_Bytes, Target_Fanout),
                 Out_Packets => (State, In_Digest, Payload_Bytes, Target_Fanout),
                 Success     => (State, In_Digest, Payload_Bytes)),
     Pre => State.Total_Rounds < Round_Counter'Last and
            State.Current_Rate < Gossip_Rate_Pps'Last,
     Post => (if Success then
                State.Total_Rounds = State.Total_Rounds'Old + 1 and
                State.Current_Rate = State.Current_Rate'Old + 1 and
                State.Last_Digest = In_Digest and
                State.Active_Fanout = Target_Fanout and
                not State.Is_Quenched and
                Out_Packets <= 512
              else
                State.Total_Rounds = State.Total_Rounds'Old and
                State.Current_Rate = State.Current_Rate'Old and
                State.Is_Quenched and
                Out_Packets = 0);

   procedure Quench_Rumor_Flood (State : in out Gossip_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Current_Rate = 0 and
             State.Is_Quenched = True;

   procedure Purge_Gossip_Cache (State : in out Gossip_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Last_Digest = 0 and
             State.Current_Rate = 0 and
             State.Is_Quenched = False and
             State.Is_Scrubbed = True;

end Sovereign_Mesh_Gossip_Dissemination_Guard;
