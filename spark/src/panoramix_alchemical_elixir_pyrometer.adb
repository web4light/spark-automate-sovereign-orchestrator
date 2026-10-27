--  Panoramix_Alchemical_Elixir_Pyrometer Implementation
pragma SPARK_Mode (On);

package body Panoramix_Alchemical_Elixir_Pyrometer is

   procedure Ignite_Crucible
     (State : out Cauldron_Telemetry)
   is
   begin
      State := Cauldron_Telemetry'
        (Status       => Cauldron_Cold,
         Temperature  => 20,
         Pressure     => 1013,
         Purity       => 0,
         Quench_Count => 0,
         Total_Cycles => 0);
   end Ignite_Crucible;

   procedure Regulate_Brewing_Cycle
     (State          : in out Cauldron_Telemetry;
      Heat_Delta     : in     Integer;
      Pressure_Delta : in     Integer;
      Quench_Tripped : out    Boolean)
   is
      New_T : constant Integer := State.Temperature + Heat_Delta;
      New_P : constant Integer := State.Pressure + Pressure_Delta;
   begin
      State.Temperature := New_T;
      State.Pressure    := New_P;
      State.Total_Cycles := State.Total_Cycles + 1;

      if State.Temperature > Safe_Max_Temp or State.Pressure > Safe_Max_Press then
         State.Status := Cauldron_Safety_Quenched;
         if State.Quench_Count < Natural'Last then
            State.Quench_Count := State.Quench_Count + 1;
         end if;
         Quench_Tripped := True;
      else
         Quench_Tripped := False;
         if State.Temperature in Safe_Min_Temp .. Safe_Max_Temp and State.Pressure in 900 .. 2000 then
            State.Status := Cauldron_Optimal_Vapor;
            if State.Purity < 100 then
               State.Purity := State.Purity + 1;
            end if;
         else
            State.Status := Cauldron_Brewing;
         end if;
      end if;
   end Regulate_Brewing_Cycle;

   procedure Harvest_Elixir
     (State   : in out Cauldron_Telemetry;
      Success : out    Boolean)
   is
   begin
      if State.Status = Cauldron_Optimal_Vapor and State.Purity >= 90 then
         State.Purity := 0;
         State.Status := Cauldron_Cold;
         Success := True;
      else
         Success := False;
      end if;
   end Harvest_Elixir;

end Panoramix_Alchemical_Elixir_Pyrometer;
