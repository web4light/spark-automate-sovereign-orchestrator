package Sovereign_IP_Perimeter_Guard with
  SPARK_Mode => On
is
   subtype Secret_Byte_Count is Integer range 0 .. 4096;
   subtype Redaction_Level is Integer range 1 .. 5;
   subtype Packet_Counter is Integer range 0 .. 100_000;

   type Perimeter_State is record
      Active_Level      : Redaction_Level;
      Total_Redacted    : Secret_Byte_Count;
      Processed_Packets : Packet_Counter;
      Is_Airgapped      : Boolean;
      Is_Purged         : Boolean;
   end record;

   procedure Initialize_Guard (State : out Perimeter_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Active_Level = 5 and
             State.Total_Redacted = 0 and
             State.Processed_Packets = 0 and
             State.Is_Airgapped = True and
             State.Is_Purged = False;

   procedure Sanitize_Outbound_Packet
     (State     : in out Perimeter_State;
      In_Bytes  : in     Secret_Byte_Count;
      Level     : in     Redaction_Level;
      Out_Bytes : out    Secret_Byte_Count;
      Leaked    : out    Boolean) with
     Global => null,
     Depends => (State     => (State, Level, In_Bytes),
                 Out_Bytes => (In_Bytes, Level),
                 Leaked    => null),
     Pre => State.Processed_Packets < Packet_Counter'Last and
            State.Total_Redacted <= Secret_Byte_Count'Last - In_Bytes,
     Post => Leaked = False and
             State.Is_Airgapped = True and
             State.Processed_Packets = State.Processed_Packets'Old + 1 and
             State.Total_Redacted = State.Total_Redacted'Old + In_Bytes and
             State.Active_Level = Level and
             (if Level = 5 then Out_Bytes = 0 else Out_Bytes <= In_Bytes);

   procedure Purge_Perimeter_Session (State : in out Perimeter_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Total_Redacted = 0 and
             State.Is_Purged = True and
             State.Is_Airgapped = True;

end Sovereign_IP_Perimeter_Guard;
