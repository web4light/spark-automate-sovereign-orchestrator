--  Sovereign_Hyperdimensional_Vector_Memory_Index Implementation
pragma SPARK_Mode (On);

package body Sovereign_Hyperdimensional_Vector_Memory_Index is

   procedure Init_HDC_Index
     (State : out HDC_Index_State)
   is
   begin
      State := HDC_Index_State'
        (Bank          => (others => (others => 0)),
         Occupied      => (others => False),
         Stored_Count  => 0,
         Total_Queries => 0);
   end Init_HDC_Index;

   procedure Store_Vector
     (State   : in out HDC_Index_State;
      Slot    : in     Slot_Index;
      Vec     : in     Hypervector;
      Success : out    Boolean)
   is
   begin
      if not State.Occupied (Slot) then
         State.Bank (Slot) := Vec;
         State.Occupied (Slot) := True;
         if State.Stored_Count < Natural'Last then
            State.Stored_Count := State.Stored_Count + 1;
         end if;
         Success := True;
      else
         Success := False;
      end if;
   end Store_Vector;

   function Popcount_32 (W : Hypervector_Word) return Natural is
      Count : Natural := 0;
      Val   : Hypervector_Word := W;
   begin
      for I in 1 .. 32 loop
         pragma Loop_Invariant (Count <= I - 1);
         if (Val and 1) /= 0 then
            Count := Count + 1;
         end if;
         Val := Val / 2;
      end loop;
      return Count;
   end Popcount_32;

   procedure Compute_Hamming_Distance
     (A        : in  Hypervector;
      B        : in  Hypervector;
      Distance : out Natural)
   is
      Total : Natural := 0;
   begin
      for I in Word_Index loop
         pragma Loop_Invariant (Total <= Natural (I - 1) * 32);
         declare
            Diff : constant Hypervector_Word := A (I) xor B (I);
            Bits : constant Natural := Popcount_32 (Diff);
         begin
            Total := Total + Bits;
         end;
      end loop;
      Distance := Total;
   end Compute_Hamming_Distance;

end Sovereign_Hyperdimensional_Vector_Memory_Index;
