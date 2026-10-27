--  Quantum_Resistant_Lattice_KEM_Guard Implementation
pragma SPARK_Mode (On);

package body Quantum_Resistant_Lattice_KEM_Guard is

   procedure Init_Enclave
     (State     : out KEM_Enclave_State;
      Sec_Level : in  Lattice_Security_Level)
   is
   begin
      State := KEM_Enclave_State'
        (Status            => KEM_Idle,
         Sec_Level         => Sec_Level,
         Entropy_Bits      => 0,
         Total_Encaps      => 0,
         Total_Rejections  => 0,
         Last_Noise_L2_Sq  => 0,
         Poly_Accumulator  => 0);
   end Init_Enclave;

   procedure Inject_Entropy
     (State        : in out KEM_Enclave_State;
      Entropy_Bits : in     Positive)
   is
   begin
      State.Entropy_Bits := State.Entropy_Bits + Entropy_Bits;
      if State.Entropy_Bits >= 256 and State.Status = KEM_Idle then
         State.Status := KEM_KeyGen_Ready;
      end if;
   end Inject_Entropy;

   procedure Verify_And_Accumulate_Polynomial
     (State    : in out KEM_Enclave_State;
      Poly     : in     Polynomial_Coefficients;
      Success  : out    Boolean)
   is
      Sum : Natural := 0;
   begin
      for I in Poly_Index loop
         pragma Loop_Invariant (Sum <= Natural (I) * (Kyber_Q - 1));
         Sum := (Sum + Natural (Poly (I))) mod Kyber_Q;
      end loop;

      State.Poly_Accumulator := Mod_Q_Value (Sum);
      Success := True;
   end Verify_And_Accumulate_Polynomial;

   procedure Validate_Noise_Vector
     (State    : in out KEM_Enclave_State;
      Noise    : in     Noise_Vector;
      Accepted : out    Boolean)
   is
      L2_Sq : Natural := 0;
      Max_Threshold : constant Natural := Poly_N * (Max_Eta * Max_Eta);
   begin
      for I in Poly_Index loop
         pragma Loop_Invariant (L2_Sq <= Natural (I) * (Max_Eta * Max_Eta));
         declare
            Val : constant Integer := Integer (Noise (I));
            Sq  : constant Natural := Natural (Val * Val);
         begin
            L2_Sq := L2_Sq + Sq;
         end;
      end loop;

      if L2_Sq <= Max_Threshold then
         State.Last_Noise_L2_Sq := L2_Sq;
         Accepted := True;
      else
         if State.Total_Rejections < Natural'Last then
            State.Total_Rejections := State.Total_Rejections + 1;
         end if;
         Accepted := False;
      end if;
   end Validate_Noise_Vector;

   procedure Finalize_Encapsulation
     (State   : in out KEM_Enclave_State;
      Success : out    Boolean)
   is
   begin
      if State.Status = KEM_KeyGen_Ready and State.Entropy_Bits >= 256 then
         State.Status := KEM_Encapsulated;
         State.Total_Encaps := State.Total_Encaps + 1;
         Success := True;
      else
         Success := False;
      end if;
   end Finalize_Encapsulation;

end Quantum_Resistant_Lattice_KEM_Guard;
