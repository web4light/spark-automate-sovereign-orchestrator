package body Sovereign_IP_Perimeter_Guard with
  SPARK_Mode => On
is

   procedure Initialize_Guard (State : out Perimeter_State) is
   begin
      State := (Active_Level      => 5,
                Total_Redacted    => 0,
                Processed_Packets => 0,
                Is_Airgapped      => True,
                Is_Purged         => False);
   end Initialize_Guard;

   procedure Sanitize_Outbound_Packet
     (State     : in out Perimeter_State;
      In_Bytes  : in     Secret_Byte_Count;
      Level     : in     Redaction_Level;
      Out_Bytes : out    Secret_Byte_Count;
      Leaked    : out    Boolean)
   is
   begin
      Leaked                  := False;
      State.Is_Airgapped      := True;
      State.Processed_Packets := State.Processed_Packets + 1;
      State.Total_Redacted    := State.Total_Redacted + In_Bytes;
      State.Active_Level      := Level;

      if Level = 5 then
         Out_Bytes := 0;
      else
         Out_Bytes := In_Bytes / Level;
      end if;
   end Sanitize_Outbound_Packet;

   procedure Purge_Perimeter_Session (State : in out Perimeter_State) is
   begin
      State.Total_Redacted := 0;
      State.Is_Purged      := True;
      State.Is_Airgapped   := True;
   end Purge_Perimeter_Session;

end Sovereign_IP_Perimeter_Guard;
