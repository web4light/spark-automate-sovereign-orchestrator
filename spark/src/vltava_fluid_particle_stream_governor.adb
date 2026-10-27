package body Vltava_Fluid_Particle_Stream_Governor with
  SPARK_Mode => On
is
   procedure Initialize_Stream (State : out Stream_State) is
   begin
      State := (Current_Velocity   => 0,
                Current_Turbulence => 0,
                Active_Particles   => 0,
                Acoustic_Damping   => 0,
                Is_Laminar         => True,
                Cycle_Count        => 0);
   end Initialize_Stream;

   procedure Step_Stream_Simulation
     (State           : in out Stream_State;
      Inflow_Velocity : in     Flow_Velocity_Mps;
      Turbulence_Delta: in     Integer;
      Out_Particles   : out    Particle_Budget;
      Damping_Applied : out    Damping_Level_dB;
      Stable          : out    Boolean)
   is
      Candidate_Turbulence : constant Integer := State.Current_Turbulence + Turbulence_Delta;
   begin
      if Candidate_Turbulence >= 0 and Candidate_Turbulence <= 100 then
         State.Current_Velocity := Inflow_Velocity;
         State.Current_Turbulence := Candidate_Turbulence;
         State.Cycle_Count := State.Cycle_Count + 1;

         if State.Current_Turbulence <= 25 and State.Current_Velocity <= 20 then
            State.Is_Laminar := True;
            State.Acoustic_Damping := 0;
         else
            State.Is_Laminar := False;
            State.Acoustic_Damping := State.Current_Turbulence / 2;
         end if;

         State.Active_Particles := State.Current_Velocity * 1000 + State.Current_Turbulence * 100;
         Out_Particles := State.Active_Particles;
         Damping_Applied := State.Acoustic_Damping;
         Stable := True;
      else
         Out_Particles := 0;
         Damping_Applied := 0;
         Stable := False;
      end if;
   end Step_Stream_Simulation;

   procedure Reset_To_Laminar (State : in out Stream_State) is
   begin
      State.Current_Turbulence := 0;
      State.Acoustic_Damping   := 0;
      State.Is_Laminar         := True;
   end Reset_To_Laminar;

end Vltava_Fluid_Particle_Stream_Governor;
