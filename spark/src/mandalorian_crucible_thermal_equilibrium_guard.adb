package body Mandalorian_Crucible_Thermal_Equilibrium_Guard with
  SPARK_Mode => On
is

   procedure Initialize_Crucible (State : out Crucible_Thermal_State) is
   begin
      State := (Current_Temp   => 1200,
                Active_Flux    => 0,
                Forged_Batches => 0,
                Is_Equilibrium => True,
                Is_Purged      => False);
   end Initialize_Crucible;

   procedure Regulate_Equilibrium
     (State       : in out Crucible_Thermal_State;
      Target_Temp : in     Celsius_Degrees;
      Flux        : in     Thermal_Flux;
      Stable      : out    Boolean)
   is
   begin
      if Target_Temp >= 1200 and Target_Temp <= 1650 and Flux <= 80 then
         State.Current_Temp   := Target_Temp;
         State.Active_Flux    := Flux;
         State.Forged_Batches := State.Forged_Batches + 1;
         State.Is_Equilibrium := True;
         State.Is_Purged      := False;
         Stable               := True;
      else
         Stable := False;
      end if;
   end Regulate_Equilibrium;

   procedure Purge_Crucible_Thermal_Session (State : in out Crucible_Thermal_State) is
   begin
      State.Active_Flux    := 0;
      State.Is_Purged      := True;
      State.Is_Equilibrium := True;
   end Purge_Crucible_Thermal_Session;

end Mandalorian_Crucible_Thermal_Equilibrium_Guard;
