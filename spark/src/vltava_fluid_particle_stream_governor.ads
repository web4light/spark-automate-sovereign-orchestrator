package Vltava_Fluid_Particle_Stream_Governor with
  SPARK_Mode => On
is
   subtype Flow_Velocity_Mps is Integer range 0 .. 50;
   subtype Turbulence_Index is Integer range 0 .. 100;
   subtype Particle_Budget is Integer range 0 .. 100_000;
   subtype Damping_Level_dB is Integer range 0 .. 60;
   subtype Stream_Cycle_Count is Integer range 0 .. 1_000_000;

   type Stream_State is record
      Current_Velocity   : Flow_Velocity_Mps;
      Current_Turbulence : Turbulence_Index;
      Active_Particles   : Particle_Budget;
      Acoustic_Damping   : Damping_Level_dB;
      Is_Laminar         : Boolean;
      Cycle_Count        : Stream_Cycle_Count;
   end record;

   procedure Initialize_Stream (State : out Stream_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Current_Velocity = 0 and
             State.Current_Turbulence = 0 and
             State.Active_Particles = 0 and
             State.Acoustic_Damping = 0 and
             State.Is_Laminar = True and
             State.Cycle_Count = 0;

   procedure Step_Stream_Simulation
     (State           : in out Stream_State;
      Inflow_Velocity : in     Flow_Velocity_Mps;
      Turbulence_Delta: in     Integer;
      Out_Particles   : out    Particle_Budget;
      Damping_Applied : out    Damping_Level_dB;
      Stable          : out    Boolean) with
     Global => null,
     Depends => (State           => (State, Inflow_Velocity, Turbulence_Delta),
                 Out_Particles   => (State, Inflow_Velocity, Turbulence_Delta),
                 Damping_Applied => (State, Inflow_Velocity, Turbulence_Delta),
                 Stable          => (State, Turbulence_Delta)),
     Pre => State.Cycle_Count < Stream_Cycle_Count'Last and
            Turbulence_Delta in -50 .. 50,
     Post => (if Stable then
                State.Current_Velocity = Inflow_Velocity and
                State.Cycle_Count = State.Cycle_Count'Old + 1 and
                Out_Particles = State.Active_Particles and
                Damping_Applied = State.Acoustic_Damping
              else
                State = State'Old and Out_Particles = 0 and Damping_Applied = 0);

   procedure Reset_To_Laminar (State : in out Stream_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Current_Turbulence = 0 and
             State.Acoustic_Damping = 0 and
             State.Is_Laminar = True;

end Vltava_Fluid_Particle_Stream_Governor;
