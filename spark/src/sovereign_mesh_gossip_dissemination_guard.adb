package body Sovereign_Mesh_Gossip_Dissemination_Guard with
  SPARK_Mode => On
is
   procedure Initialize_Gossip_Engine (State : out Gossip_State) is
   begin
      State := (Known_Peers   => 0,
                Active_Fanout => 3,
                Current_Rate  => 0,
                Total_Rounds  => 0,
                Last_Digest   => 0,
                Is_Quenched   => False,
                Is_Scrubbed   => False);
   end Initialize_Gossip_Engine;

   procedure Register_Peer
     (State      : in out Gossip_State;
      Peer_Id    : in     Peer_Id_Range;
      Registered : out    Boolean)
   is
      pragma Unreferenced (Peer_Id);
   begin
      if State.Known_Peers < 64 then
         State.Known_Peers  := State.Known_Peers + 1;
         State.Total_Rounds := State.Total_Rounds + 1;
         Registered         := True;
      else
         Registered         := False;
      end if;
   end Register_Peer;

   procedure Disseminate_Rumor
     (State         : in out Gossip_State;
      In_Digest     : in     Hash_Digest;
      Payload_Bytes : in     Packet_Payload_Size;
      Target_Fanout : in     Hop_Budget;
      Out_Packets   : out    Disseminated_Packet_Count;
      Success       : out    Boolean)
   is
   begin
      if Payload_Bytes in 1 .. 4096
         and then In_Digest /= State.Last_Digest
         and then State.Current_Rate <= 90
      then
         declare
            Effective_Peers : constant Integer := (if State.Known_Peers < 8 then State.Known_Peers else 8);
         begin
            Out_Packets := Target_Fanout * Effective_Peers;
         end;

         State.Total_Rounds  := State.Total_Rounds + 1;
         State.Current_Rate  := State.Current_Rate + 1;
         State.Last_Digest   := In_Digest;
         State.Active_Fanout := Target_Fanout;
         State.Is_Quenched   := False;
         Success             := True;
      else
         Out_Packets       := 0;
         State.Is_Quenched := True;
         Success           := False;
      end if;
   end Disseminate_Rumor;

   procedure Quench_Rumor_Flood (State : in out Gossip_State) is
   begin
      State.Current_Rate := 0;
      State.Is_Quenched  := True;
   end Quench_Rumor_Flood;

   procedure Purge_Gossip_Cache (State : in out Gossip_State) is
   begin
      State.Last_Digest := 0;
      State.Current_Rate := 0;
      State.Is_Quenched := False;
      State.Is_Scrubbed := True;
   end Purge_Gossip_Cache;

end Sovereign_Mesh_Gossip_Dissemination_Guard;
