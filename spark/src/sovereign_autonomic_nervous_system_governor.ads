--  Sovereign_Autonomic_Nervous_System_Governor
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Formalizes the "One Agent, n8n as Autonomic Nervous System" architectural boundary.
--  Controls synaptic reflex queues, involuntary vitals, fail-safe circuit breaker, and airgap isolation.

pragma SPARK_Mode (On);

package Sovereign_Autonomic_Nervous_System_Governor is

   Max_Reflex_Queue : constant := 256;
   subtype Reflex_Queue_Index is Natural range 0 .. Max_Reflex_Queue;

   type Nervous_System_State is (Autonomic_Harmonious, Autonomic_Elevated_Stress, Autonomic_Circuit_Tripped, Autonomic_Airgap_Severed);

   type Synaptic_Event_Type is (Heartbeat_Tick, Webhook_Reflex, State_Sync, Background_Harvest, Circuit_Reset);

   type Autonomic_Governor_State is record
      Status            : Nervous_System_State;
      Queue_Depth       : Reflex_Queue_Index;
      Heartbeat_Count   : Natural;
      Total_Dispatched  : Natural;
      Errors_In_Window  : Natural;
      Cognitive_Lockout : Boolean;
   end record;

   procedure Init_Autonomic_System
     (State : out Autonomic_Governor_State)
   with
     Global  => null,
     Depends => (State => null),
     Post    => State.Status = Autonomic_Harmonious and
                State.Queue_Depth = 0 and
                State.Heartbeat_Count = 0 and
                State.Total_Dispatched = 0 and
                State.Errors_In_Window = 0 and
                not State.Cognitive_Lockout;

   procedure Ingest_Synaptic_Event
     (State   : in out Autonomic_Governor_State;
      Ev_Type : in     Synaptic_Event_Type;
      Queued  : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ Ev_Type, Queued => State),
     Post    => (if Queued then State.Queue_Depth = State.Queue_Depth'Old + 1
                 else State.Queue_Depth = State.Queue_Depth'Old);

   procedure Dispatch_Next_Reflex
     (State      : in out Autonomic_Governor_State;
      Dispatched : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ null, Dispatched => State),
     Pre     => State.Total_Dispatched < Natural'Last,
     Post    => (if Dispatched then State.Queue_Depth = State.Queue_Depth'Old - 1 and
                                    State.Total_Dispatched = State.Total_Dispatched'Old + 1
                 else State.Queue_Depth = State.Queue_Depth'Old);

   procedure Register_Autonomic_Fault
     (State         : in out Autonomic_Governor_State;
      Circuit_Broke : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ null, Circuit_Broke => State),
     Pre     => State.Errors_In_Window < Natural'Last,
     Post    => State.Errors_In_Window = State.Errors_In_Window'Old + 1 and
                (if State.Errors_In_Window >= 5
                 then Circuit_Broke and State.Status in Autonomic_Circuit_Tripped | Autonomic_Airgap_Severed
                 else not Circuit_Broke);

   procedure Enforce_Cognitive_Airgap
     (State : in out Autonomic_Governor_State)
   with
     Global  => null,
     Depends => (State =>+ null),
     Post    => State.Status = Autonomic_Airgap_Severed and
                State.Queue_Depth = 0 and
                State.Cognitive_Lockout;

end Sovereign_Autonomic_Nervous_System_Governor;
