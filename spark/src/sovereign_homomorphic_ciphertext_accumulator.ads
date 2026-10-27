--  Sovereign_Homomorphic_Ciphertext_Accumulator
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Partially Homomorphic Encryption (PHE) Additive Ciphertext Accumulator.
--  Enforces bounded modular ciphertext multiplication, noise budget decay, and zero-egress tallying.

pragma SPARK_Mode (On);

package Sovereign_Homomorphic_Ciphertext_Accumulator is

   Mod_Ring : constant := 65537; -- Fermat prime ring
   type Ciphertext_Element is mod Mod_Ring;
   subtype Noise_Percentage is Natural range 0 .. 100;

   type Accumulator_State is record
      Cipher_Tally   : Ciphertext_Element;
      Additions_Done : Natural;
      Noise_Budget   : Noise_Percentage;
      Needs_Refresh  : Boolean;
   end record;

   procedure Init_Accumulator
     (State : out Accumulator_State)
   with
     Global  => null,
     Depends => (State => null),
     Post    => State.Cipher_Tally = 1 and
                State.Additions_Done = 0 and
                State.Noise_Budget = 100 and
                not State.Needs_Refresh;

   procedure Homomorphic_Add
     (State      : in out Accumulator_State;
      Cipher_In  : in     Ciphertext_Element;
      Success    : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ Cipher_In, Success => (State, Cipher_In)),
     Pre     => State.Additions_Done < Natural'Last,
     Post    => (if Success
                 then State.Additions_Done = State.Additions_Done'Old + 1 and
                      State.Noise_Budget <= State.Noise_Budget'Old
                 else State.Additions_Done = State.Additions_Done'Old);

   procedure Refresh_Noise_Budget
     (State : in out Accumulator_State)
   with
     Global  => null,
     Depends => (State =>+ null),
     Post    => State.Noise_Budget = 100 and not State.Needs_Refresh;

end Sovereign_Homomorphic_Ciphertext_Accumulator;
