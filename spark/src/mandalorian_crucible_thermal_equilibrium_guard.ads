package Mandalorian_Crucible_Thermal_Equilibrium_Guard with
  SPARK_Mode => On
is
   subtype Celsius_Degrees is Integer range 1000 .. 1800;
   subtype Thermal_Flux is Integer range 0 .. 100;
   subtype Batch_Counter is Integer range 0 .. 100_000;

   type Crucible_Thermal_State is record
      Current_Temp    : Celsius_Degrees;
      Active_Flux     : Thermal_Flux;
      Forged_Batches  : Batch_Counter;
      Is_Equilibrium  : Boolean;
      Is_Purged       : Boolean;
   end record;

   procedure Initialize_Crucible (State : out Crucible_Thermal_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Current_Temp = 1200 and
             State.Active_Flux = 0 and
             State.Forged_Batches = 0 and
             State.Is_Equilibrium = True and
             State.Is_Purged = False;

   procedure Regulate_Equilibrium
     (State       : in out Crucible_Thermal_State;
      Target_Temp : in     Celsius_Degrees;
      Flux        : in     Thermal_Flux;
      Stable      : out    Boolean) with
     Global => null,
     Depends => (State  => (State, Target_Temp, Flux),
                 Stable => (Target_Temp, Flux)),
     Pre => State.Forged_Batches < Batch_Counter'Last,
     Post => (if Stable then
                State.Current_Temp = Target_Temp and
                State.Active_Flux = Flux and
                State.Forged_Batches = State.Forged_Batches'Old + 1 and
                State.Is_Equilibrium = True and
                State.Is_Purged = False
              else
                State = State'Old);

   procedure Purge_Crucible_Thermal_Session (State : in out Crucible_Thermal_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Active_Flux = 0 and
             State.Is_Purged = True and
             State.Is_Equilibrium = True;

end Mandalorian_Crucible_Thermal_Equilibrium_Guard;
