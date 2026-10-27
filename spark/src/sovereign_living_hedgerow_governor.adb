package body Sovereign_Living_Hedgerow_Governor with
  SPARK_Mode => On
is
   procedure Initialize_Hedgerow (State : out Hedgerow_State) is
   begin
      State := (Active_Nodes       => 0,
                Biodiversity_Score => 100,
                Max_Dominance      => 0,
                Is_Monoculture     => False,
                Is_Scrubbed        => False,
                Cycles             => 0);
   end Initialize_Hedgerow;

   procedure Register_Sovereign_Node
     (State          : in out Hedgerow_State;
      Node_Weight    : in     Node_Dominance_Pct;
      Corridor_Hops  : in     Corridor_Hop_Count;
      Accepted       : out    Boolean;
      New_Score      : out    Biodiversity_Index)
   is
   begin
      if Node_Weight <= 15 and Corridor_Hops in 1 .. 10 then
         State.Active_Nodes := State.Active_Nodes + 1;
         State.Cycles := State.Cycles + 1;
         if Node_Weight > State.Max_Dominance then
            State.Max_Dominance := Node_Weight;
         end if;
         State.Biodiversity_Score := 100 - State.Max_Dominance;
         State.Is_Monoculture := False;
         Accepted := True;
         New_Score := State.Biodiversity_Score;
      else
         Accepted := False;
         New_Score := State.Biodiversity_Score;
      end if;
   end Register_Sovereign_Node;

   procedure Purge_Volatile_Hedgerow_Cache (State : in out Hedgerow_State) is
   begin
      State.Biodiversity_Score := 100;
      State.Max_Dominance      := 0;
      State.Is_Monoculture     := False;
      State.Is_Scrubbed        := True;
   end Purge_Volatile_Hedgerow_Cache;

end Sovereign_Living_Hedgerow_Governor;
