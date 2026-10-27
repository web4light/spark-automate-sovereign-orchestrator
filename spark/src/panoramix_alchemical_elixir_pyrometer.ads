--  Panoramix_Alchemical_Elixir_Pyrometer
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Regulates thermodynamic brewing bounds and vapor pressure in the Druidic crucible cauldron.
--  Prevents alchemical detonation and guarantees 100% pure elixir potency.

pragma SPARK_Mode (On);

package Panoramix_Alchemical_Elixir_Pyrometer is

   subtype Temperature_Celsius is Integer range -20 .. 500;
   subtype Pressure_Mbar is Positive range 100 .. 5000;
   subtype Purity_Percentage is Natural range 0 .. 100;

   Safe_Min_Temp : constant := 85;
   Safe_Max_Temp : constant := 300;
   Safe_Max_Press : constant := 2200;

   type Pyrometer_State is (Cauldron_Cold, Cauldron_Brewing, Cauldron_Optimal_Vapor, Cauldron_Safety_Quenched);

   type Cauldron_Telemetry is record
      Status       : Pyrometer_State;
      Temperature  : Temperature_Celsius;
      Pressure     : Pressure_Mbar;
      Purity       : Purity_Percentage;
      Quench_Count : Natural;
      Total_Cycles : Natural;
   end record;

   procedure Ignite_Crucible
     (State : out Cauldron_Telemetry)
   with
     Global  => null,
     Depends => (State => null),
     Post    => State.Status = Cauldron_Cold and
                State.Temperature = 20 and
                State.Pressure = 1013 and
                State.Purity = 0 and
                State.Quench_Count = 0 and
                State.Total_Cycles = 0;

   procedure Regulate_Brewing_Cycle
     (State          : in out Cauldron_Telemetry;
      Heat_Delta     : in     Integer;
      Pressure_Delta : in     Integer;
      Quench_Tripped : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ (Heat_Delta, Pressure_Delta), Quench_Tripped => (State, Heat_Delta, Pressure_Delta)),
     Pre     => Heat_Delta in -50 .. 50 and then
                Pressure_Delta in -200 .. 200 and then
                State.Total_Cycles < Natural'Last and then
                State.Temperature in -20 - Heat_Delta .. 500 - Heat_Delta and then
                State.Pressure in 100 - Pressure_Delta .. 5000 - Pressure_Delta,
     Post    => State.Total_Cycles = State.Total_Cycles'Old + 1 and
                (if State.Temperature > Safe_Max_Temp or State.Pressure > Safe_Max_Press
                 then Quench_Tripped and State.Status = Cauldron_Safety_Quenched
                 else not Quench_Tripped);

   procedure Harvest_Elixir
     (State   : in out Cauldron_Telemetry;
      Success : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ null, Success => State),
     Post    => (if State.Status'Old = Cauldron_Optimal_Vapor and State.Purity'Old >= 90
                 then Success and State.Purity = 0 and State.Status = Cauldron_Cold
                 else not Success and State.Status = State.Status'Old);

end Panoramix_Alchemical_Elixir_Pyrometer;
