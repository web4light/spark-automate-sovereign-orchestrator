--  Sovereign_Homomorphic_Ciphertext_Accumulator Implementation
pragma SPARK_Mode (On);

package body Sovereign_Homomorphic_Ciphertext_Accumulator is

   procedure Init_Accumulator
     (State : out Accumulator_State)
   is
   begin
      State := Accumulator_State'
        (Cipher_Tally   => 1,
         Additions_Done => 0,
         Noise_Budget   => 100,
         Needs_Refresh  => False);
   end Init_Accumulator;

   procedure Homomorphic_Add
     (State      : in out Accumulator_State;
      Cipher_In  : in     Ciphertext_Element;
      Success    : out    Boolean)
   is
   begin
      if State.Needs_Refresh or Cipher_In = 0 then
         Success := False;
         return;
      end if;

      State.Cipher_Tally   := State.Cipher_Tally * Cipher_In;
      State.Additions_Done := State.Additions_Done + 1;

      if State.Noise_Budget >= 2 then
         State.Noise_Budget := State.Noise_Budget - 2;
      else
         State.Noise_Budget := 0;
      end if;

      if State.Noise_Budget <= 10 then
         State.Needs_Refresh := True;
      end if;

      Success := True;
   end Homomorphic_Add;

   procedure Refresh_Noise_Budget
     (State : in out Accumulator_State)
   is
   begin
      State.Noise_Budget  := 100;
      State.Needs_Refresh := False;
   end Refresh_Noise_Budget;

end Sovereign_Homomorphic_Ciphertext_Accumulator;
