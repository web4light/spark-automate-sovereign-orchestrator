--  Quantum_Resistant_Lattice_KEM_Guard
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Enforces post-quantum lattice polynomial ring invariants (Kyber / ML-KEM parameters: q=3329, n=256)
--  Zero heap, zero dynamic allocation, provable arithmetic bounds.

pragma SPARK_Mode (On);

package Quantum_Resistant_Lattice_KEM_Guard is

   Kyber_Q : constant := 3329;
   Poly_N  : constant := 256;
   Max_Eta : constant := 3;

   type Poly_Index is range 0 .. Poly_N - 1;
   type Mod_Q_Value is range 0 .. Kyber_Q - 1;
   type Centered_Noise is range -Max_Eta .. Max_Eta;

   type Polynomial_Coefficients is array (Poly_Index) of Mod_Q_Value;
   type Noise_Vector is array (Poly_Index) of Centered_Noise;

   type KEM_Status is (KEM_Idle, KEM_KeyGen_Ready, KEM_Encapsulated, KEM_Decapsulated, KEM_Reject_Invalid_Ciphertext);

   type Lattice_Security_Level is (Level_512, Level_768, Level_1024);

   type KEM_Enclave_State is record
      Status            : KEM_Status;
      Sec_Level         : Lattice_Security_Level;
      Entropy_Bits      : Natural;
      Total_Encaps      : Natural;
      Total_Rejections  : Natural;
      Last_Noise_L2_Sq  : Natural;
      Poly_Accumulator  : Mod_Q_Value;
   end record;

   procedure Init_Enclave
     (State     : out KEM_Enclave_State;
      Sec_Level : in  Lattice_Security_Level)
   with
     Global  => null,
     Depends => (State => Sec_Level),
     Post    => State.Status = KEM_Idle and
                State.Sec_Level = Sec_Level and
                State.Entropy_Bits = 0 and
                State.Total_Encaps = 0 and
                State.Total_Rejections = 0 and
                State.Last_Noise_L2_Sq = 0 and
                State.Poly_Accumulator = 0;

   procedure Inject_Entropy
     (State        : in out KEM_Enclave_State;
      Entropy_Bits : in     Positive)
   with
     Global  => null,
     Depends => (State =>+ Entropy_Bits),
     Pre     => State.Entropy_Bits <= Natural'Last - Entropy_Bits,
     Post    => State.Entropy_Bits = State.Entropy_Bits'Old + Entropy_Bits and
                (if State.Entropy_Bits >= 256 and State.Status'Old = KEM_Idle
                 then State.Status = KEM_KeyGen_Ready
                 else State.Status = State.Status'Old);

   procedure Verify_And_Accumulate_Polynomial
     (State    : in out KEM_Enclave_State;
      Poly     : in     Polynomial_Coefficients;
      Success  : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ Poly, Success => null),
     Pre     => State.Status in KEM_KeyGen_Ready | KEM_Encapsulated,
     Post    => (if Success then State.Poly_Accumulator < Kyber_Q);

   procedure Validate_Noise_Vector
     (State    : in out KEM_Enclave_State;
      Noise    : in     Noise_Vector;
      Accepted : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ Noise, Accepted => Noise),
     Post    => (if Accepted then State.Last_Noise_L2_Sq <= Poly_N * (Max_Eta * Max_Eta)
                 else State.Total_Rejections = State.Total_Rejections'Old + 1);

   procedure Finalize_Encapsulation
     (State   : in out KEM_Enclave_State;
      Success : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ null, Success => State),
     Pre     => State.Total_Encaps < Natural'Last,
     Post    => (if State.Status'Old = KEM_KeyGen_Ready and State.Entropy_Bits >= 256
                 then Success and State.Status = KEM_Encapsulated and State.Total_Encaps = State.Total_Encaps'Old + 1
                 else not Success and State.Status = State.Status'Old);

end Quantum_Resistant_Lattice_KEM_Guard;
