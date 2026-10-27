--  Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard Implementation
pragma SPARK_Mode (On);

package body Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard is

   procedure Init_BFT_Cluster
     (State : out Quorum_State;
      Nodes : in  Cluster_Size)
   is
      F : constant Natural := (Nodes - 1) / 3;
   begin
      State := Quorum_State'
        (Total_Nodes    => Nodes,
         Max_Faulty    => F,
         Quorum_Needed => 2 * F + 1,
         Current_View   => 0,
         Sequence_Num   => 0,
         Current_Phase  => Phase_PrePrepare,
         Votes_Logged   => (others => False),
         Vote_Count     => 0);
   end Init_BFT_Cluster;

   procedure Submit_Vote
     (State       : in out Quorum_State;
      Voter       : in     Node_Id;
      Phase       : in     BFT_Phase;
      Accepted    : out    Boolean;
      Quorum_Met  : out    Boolean)
   is
   begin
      if Phase = State.Current_Phase and not State.Votes_Logged (Voter) then
         State.Votes_Logged (Voter) := True;
         State.Vote_Count := State.Vote_Count + 1;
         Accepted := True;
      else
         Accepted := False;
      end if;

      Quorum_Met := (State.Vote_Count >= State.Quorum_Needed);
   end Submit_Vote;

   procedure Advance_Phase
     (State   : in out Quorum_State;
      Success : out    Boolean)
   is
   begin
      if State.Current_Phase = Phase_Prepare and State.Vote_Count >= State.Quorum_Needed then
         State.Current_Phase := Phase_Commit;
         State.Vote_Count := 0;
         State.Votes_Logged := (others => False);
         Success := True;
      elsif State.Current_Phase = Phase_Commit and State.Vote_Count >= State.Quorum_Needed then
         State.Current_Phase := Phase_Finalized;
         State.Vote_Count := 0;
         State.Votes_Logged := (others => False);
         Success := True;
      else
         Success := False;
      end if;
   end Advance_Phase;

   procedure Trigger_View_Change
     (State : in out Quorum_State)
   is
   begin
      State.Current_View := State.Current_View + 1;
      State.Current_Phase := Phase_View_Change;
      State.Vote_Count := 0;
      State.Votes_Logged := (others => False);
   end Trigger_View_Change;

end Sovereign_Byzantine_Fault_Tolerant_Quorum_Guard;
