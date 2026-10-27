package Sovereign_Living_Hedgerow_Governor with
  SPARK_Mode => On
is
   subtype Biodiversity_Index is Integer range 0 .. 100;
   subtype Node_Dominance_Pct is Integer range 0 .. 100;
   subtype Hedgerow_Node_Count is Integer range 0 .. 50_000;
   subtype Corridor_Hop_Count is Integer range 1 .. 10;
   subtype Cycle_Counter is Integer range 0 .. 1_000_000;

   type Hedgerow_State is record
      Active_Nodes       : Hedgerow_Node_Count;
      Biodiversity_Score : Biodiversity_Index;
      Max_Dominance      : Node_Dominance_Pct;
      Is_Monoculture     : Boolean;
      Is_Scrubbed        : Boolean;
      Cycles             : Cycle_Counter;
   end record;

   procedure Initialize_Hedgerow (State : out Hedgerow_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Active_Nodes = 0 and
             State.Biodiversity_Score = 100 and
             State.Max_Dominance = 0 and
             State.Is_Monoculture = False and
             State.Is_Scrubbed = False and
             State.Cycles = 0;

   procedure Register_Sovereign_Node
     (State          : in out Hedgerow_State;
      Node_Weight    : in     Node_Dominance_Pct;
      Corridor_Hops  : in     Corridor_Hop_Count;
      Accepted       : out    Boolean;
      New_Score      : out    Biodiversity_Index) with
     Global => null,
     Depends => (State     => (State, Node_Weight, Corridor_Hops),
                 Accepted  => (Node_Weight, Corridor_Hops),
                 New_Score => (State, Node_Weight, Corridor_Hops)),
     Pre => State.Cycles < Cycle_Counter'Last and
            State.Active_Nodes < Hedgerow_Node_Count'Last and
            State.Max_Dominance <= 15,
     Post => (if Accepted then
                State.Active_Nodes = State.Active_Nodes'Old + 1 and
                State.Cycles = State.Cycles'Old + 1 and
                State.Max_Dominance <= 15 and
                State.Is_Monoculture = False and
                New_Score = State.Biodiversity_Score
              else
                State = State'Old and New_Score = State.Biodiversity_Score);

   procedure Purge_Volatile_Hedgerow_Cache (State : in out Hedgerow_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Biodiversity_Score = 100 and
             State.Max_Dominance = 0 and
             State.Is_Monoculture = False and
             State.Is_Scrubbed = True;

end Sovereign_Living_Hedgerow_Governor;
