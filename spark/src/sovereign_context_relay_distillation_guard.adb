package body Sovereign_Context_Relay_Distillation_Guard with
  SPARK_Mode => On
is
   procedure Initialize_Relay (State : out Relay_State) is
   begin
      State := (Current_Tokens  => 0,
                Total_Handovers => 0,
                Distilled_Bytes => 0,
                Is_Relay_Ready  => False,
                Is_Scrubbed     => False);
   end Initialize_Relay;

   procedure Trigger_Context_Distillation
     (State           : in out Relay_State;
      In_Tokens       : in     Context_Token_Count;
      Compression_Pct : in     Distillation_Ratio_Pct;
      Handover_Size   : out    Handover_Payload_Bytes;
      Relay_Accepted  : out    Boolean)
   is
   begin
      if In_Tokens >= 100_000 then
         declare
            Raw_Estimate : constant Integer := (In_Tokens / 1_000) * Compression_Pct;
         begin
            if Raw_Estimate > 65_536 then
               Handover_Size := 65_536;
            else
               Handover_Size := Raw_Estimate;
            end if;
         end;

         State.Current_Tokens  := 0;
         State.Total_Handovers := State.Total_Handovers + 1;
         State.Distilled_Bytes := Handover_Size;
         State.Is_Relay_Ready  := True;
         Relay_Accepted        := True;
      else
         Handover_Size         := 0;
         State.Current_Tokens  := In_Tokens;
         State.Is_Relay_Ready  := False;
         Relay_Accepted        := False;
      end if;
   end Trigger_Context_Distillation;

   procedure Purge_Relay_Epoch (State : in out Relay_State) is
   begin
      State.Distilled_Bytes := 0;
      State.Is_Relay_Ready  := False;
      State.Is_Scrubbed     := True;
   end Purge_Relay_Epoch;

end Sovereign_Context_Relay_Distillation_Guard;
