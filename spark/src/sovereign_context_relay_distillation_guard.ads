package Sovereign_Context_Relay_Distillation_Guard with
  SPARK_Mode => On
is
   subtype Context_Token_Count is Integer range 0 .. 2_000_000;
   subtype Distillation_Ratio_Pct is Integer range 1 .. 100;
   subtype Handover_Payload_Bytes is Integer range 0 .. 65_536;
   subtype Relay_Epoch_Count is Integer range 0 .. 100_000;

   type Relay_State is record
      Current_Tokens   : Context_Token_Count;
      Total_Handovers  : Relay_Epoch_Count;
      Distilled_Bytes  : Handover_Payload_Bytes;
      Is_Relay_Ready   : Boolean;
      Is_Scrubbed      : Boolean;
   end record;

   procedure Initialize_Relay (State : out Relay_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Current_Tokens = 0 and
             State.Total_Handovers = 0 and
             State.Distilled_Bytes = 0 and
             State.Is_Relay_Ready = False and
             State.Is_Scrubbed = False;

   procedure Trigger_Context_Distillation
     (State           : in out Relay_State;
      In_Tokens       : in     Context_Token_Count;
      Compression_Pct : in     Distillation_Ratio_Pct;
      Handover_Size   : out    Handover_Payload_Bytes;
      Relay_Accepted  : out    Boolean) with
     Global => null,
     Depends => (State          => (State, In_Tokens, Compression_Pct),
                 Handover_Size  => (In_Tokens, Compression_Pct),
                 Relay_Accepted => In_Tokens),
     Pre => State.Total_Handovers < Relay_Epoch_Count'Last,
     Post => (if Relay_Accepted then
                State.Total_Handovers = State.Total_Handovers'Old + 1 and
                State.Current_Tokens = 0 and
                State.Distilled_Bytes = Handover_Size and
                State.Is_Relay_Ready and
                In_Tokens >= 100_000
              else
                State.Total_Handovers = State.Total_Handovers'Old and
                State.Current_Tokens = In_Tokens and
                Handover_Size = 0 and
                not State.Is_Relay_Ready and
                In_Tokens < 100_000);

   procedure Purge_Relay_Epoch (State : in out Relay_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Distilled_Bytes = 0 and
             State.Is_Relay_Ready = False and
             State.Is_Scrubbed = True;

end Sovereign_Context_Relay_Distillation_Guard;
