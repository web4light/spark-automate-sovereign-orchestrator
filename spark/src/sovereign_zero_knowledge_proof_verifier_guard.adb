--  Sovereign_Zero_Knowledge_Proof_Verifier_Guard Implementation
pragma SPARK_Mode (On);

package body Sovereign_Zero_Knowledge_Proof_Verifier_Guard is

   procedure Init_Verifier
     (State : out ZK_Verifier_State)
   is
   begin
      State := ZK_Verifier_State'
        (Verdict          => Proof_Unverified,
         Inputs_Count     => 0,
         Challenge_Digest => 0,
         Scalar_Sum       => 0,
         Total_Verified   => 0,
         Total_Rejected   => 0);
   end Init_Verifier;

   procedure Load_Public_Inputs
     (State   : in out ZK_Verifier_State;
      Inputs  : in     Public_Inputs_Array;
      Count   : in     Input_Count;
      Success : out    Boolean)
   is
      Sum : Prime_Scalar := 0;
   begin
      if Count = 0 then
         Success := False;
         return;
      end if;

      for I in 1 .. Count loop
         Sum := Sum + Inputs (I);
      end loop;

      State.Scalar_Sum   := Sum;
      State.Inputs_Count := Count;
      State.Verdict      := Proof_Unverified;
      Success := True;
   end Load_Public_Inputs;

   procedure Compute_Fiat_Shamir_Challenge
     (State : in out ZK_Verifier_State;
      Seed  : in     Prime_Scalar)
   is
   begin
      State.Challenge_Digest := State.Challenge_Digest + Seed;
   end Compute_Fiat_Shamir_Challenge;

   procedure Verify_Pairing_Commitment
     (State     : in out ZK_Verifier_State;
      Evaluator : in     Prime_Scalar;
      Accepted  : out    Boolean)
   is
   begin
      if State.Inputs_Count = 0 or Evaluator = 0 then
         State.Verdict := Proof_Rejected_Invalid_Scalar;
         State.Total_Rejected := State.Total_Rejected + 1;
         Accepted := False;
         return;
      end if;

      if (State.Challenge_Digest xor Evaluator) mod 2 = 0 then
         State.Verdict := Proof_Valid;
         State.Total_Verified := State.Total_Verified + 1;
         Accepted := True;
      else
         State.Verdict := Proof_Rejected_Pairing_Failure;
         State.Total_Rejected := State.Total_Rejected + 1;
         Accepted := False;
      end if;
   end Verify_Pairing_Commitment;

end Sovereign_Zero_Knowledge_Proof_Verifier_Guard;
