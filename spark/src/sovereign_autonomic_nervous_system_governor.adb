--  Sovereign_Autonomic_Nervous_System_Governor Implementation
pragma SPARK_Mode (On);

package body Sovereign_Autonomic_Nervous_System_Governor is

   procedure Init_Autonomic_System
     (State : out Autonomic_Governor_State)
   is
   begin
      State := Autonomic_Governor_State'
        (Status            => Autonomic_Harmonious,
         Queue_Depth       => 0,
         Heartbeat_Count   => 0,
         Total_Dispatched  => 0,
         Errors_In_Window  => 0,
         Cognitive_Lockout => False);
   end Init_Autonomic_System;

   procedure Ingest_Synaptic_Event
     (State   : in out Autonomic_Governor_State;
      Ev_Type : in     Synaptic_Event_Type;
      Queued  : out    Boolean)
   is
   begin
      if State.Status in Autonomic_Circuit_Tripped | Autonomic_Airgap_Severed then
         Queued := False;
         return;
      end if;

      if Ev_Type = Heartbeat_Tick then
         if State.Heartbeat_Count < Natural'Last then
            State.Heartbeat_Count := State.Heartbeat_Count + 1;
         end if;
      end if;

      if State.Queue_Depth < Max_Reflex_Queue then
         State.Queue_Depth := State.Queue_Depth + 1;
         Queued := True;
         if State.Queue_Depth > 192 then
            State.Status := Autonomic_Elevated_Stress;
         end if;
      else
         Queued := False;
      end if;
   end Ingest_Synaptic_Event;

   procedure Dispatch_Next_Reflex
     (State      : in out Autonomic_Governor_State;
      Dispatched : out    Boolean)
   is
   begin
      if State.Status in Autonomic_Circuit_Tripped | Autonomic_Airgap_Severed or else State.Queue_Depth = 0 then
         Dispatched := False;
         return;
      end if;

      State.Queue_Depth := State.Queue_Depth - 1;
      if State.Total_Dispatched < Natural'Last then
         State.Total_Dispatched := State.Total_Dispatched + 1;
      end if;
      if State.Queue_Depth <= 64 and State.Status = Autonomic_Elevated_Stress then
         State.Status := Autonomic_Harmonious;
      end if;
      Dispatched := True;
   end Dispatch_Next_Reflex;

   procedure Register_Autonomic_Fault
     (State         : in out Autonomic_Governor_State;
      Circuit_Broke : out    Boolean)
   is
   begin
      State.Errors_In_Window := State.Errors_In_Window + 1;
      if State.Errors_In_Window >= 5 then
         State.Status := Autonomic_Circuit_Tripped;
         Circuit_Broke := True;
      else
         Circuit_Broke := False;
      end if;
   end Register_Autonomic_Fault;

   procedure Enforce_Cognitive_Airgap
     (State : in out Autonomic_Governor_State)
   is
   begin
      State.Status := Autonomic_Airgap_Severed;
      State.Queue_Depth := 0;
      State.Cognitive_Lockout := True;
   end Enforce_Cognitive_Airgap;

end Sovereign_Autonomic_Nervous_System_Governor;
