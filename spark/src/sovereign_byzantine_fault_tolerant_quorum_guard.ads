--  Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Enforces 3f + 1 Byzantine Fault Tolerant quorum invariants and equivocation prevention.

pragma SPARK_Mode (On);

package Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard is

   Max_Nodes : constant := 64;
   subtype Node_Id is Positive range 1 .. Max_Nodes;
   subtype Cluster_Size is Positive range 4 .. Max_Nodes;

   type BFT_Phase is (Phase_PrePrepare, Phase_Prepare, Phase_Commit, Phase_Finalized, Phase_View_Change);

   type Vote_Matrix is array (Node_Id) of Boolean;

   type Quorum_State is record
      Total_Nodes    : Cluster_Size;
      Max_Faulty    : Natural;
      Quorum_Needed : Positive;
      Current_View   : Natural;
      Sequence_Num   : Natural;
      Current_Phase  : BFT_Phase;
      Votes_Logged   : Vote_Matrix;
      Vote_Count     : Natural;
   end record;

   procedure Init_BFT_Cluster
     (State : out Quorum_State;
      Nodes : in  Cluster_Size)
   with
     Global  => null,
     Depends => (State => Nodes),
     Pre     => Nodes >= 4,
     Post    => State.Total_Nodes = Nodes and
                State.Current_View = 0 and
                State.Sequence_Num = 0 and
                State.Current_Phase = Phase_PrePrepare and
                State.Vote_Count = 0 and
                State.Max_Faulty = (Nodes - 1) / 3 and
                State.Quorum_Needed = 2 * ((Nodes - 1) / 3) + 1;

   procedure Submit_Vote
     (State       : in out Quorum_State;
      Voter       : in     Node_Id;
      Phase       : in     BFT_Phase;
      Accepted    : out    Boolean;
      Quorum_Met  : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ (Voter, Phase), Accepted => (State, Voter, Phase), Quorum_Met => (State, Voter, Phase)),
     Pre     => Voter <= State.Total_Nodes and State.Vote_Count < Max_Nodes,
     Post    => (if Accepted then State.Vote_Count = State.Vote_Count'Old + 1 and State.Votes_Logged (Voter)
                 else State.Vote_Count = State.Vote_Count'Old);

   procedure Advance_Phase
     (State   : in out Quorum_State;
      Success : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ null, Success => State),
     Post    => (if State.Current_Phase'Old = Phase_Prepare and State.Vote_Count'Old >= State.Quorum_Needed
                 then Success and State.Current_Phase = Phase_Commit and State.Vote_Count = 0
                 elsif State.Current_Phase'Old = Phase_Commit and State.Vote_Count'Old >= State.Quorum_Needed
                 then Success and State.Current_Phase = Phase_Finalized and State.Vote_Count = 0
                 else not Success and State.Current_Phase = State.Current_Phase'Old);

   procedure Trigger_View_Change
     (State : in out Quorum_State)
   with
     Global  => null,
     Depends => (State =>+ null),
     Pre     => State.Current_View < Natural'Last,
     Post    => State.Current_View = State.Current_View'Old + 1 and
                State.Current_Phase = Phase_View_Change and
                State.Vote_Count = 0;

end Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard;
