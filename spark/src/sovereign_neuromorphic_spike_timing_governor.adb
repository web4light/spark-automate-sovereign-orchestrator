--  Sovereign_Neuromorphic_Spike_Timing_Governor Implementation
pragma SPARK_Mode (On);

package body Sovereign_Neuromorphic_Spike_Timing_Governor is

   procedure Init_Neuron
     (State : out Neuron_State)
   is
   begin
      State := Neuron_State'
        (V_Membrane       => Resting_Potential,
         Refractory_Left  => 0,
         Weights          => (others => 100),
         Total_Spikes     => 0,
         Total_Injections => 0);
   end Init_Neuron;

   procedure Inject_Current
     (State       : in out Neuron_State;
      Current_In  : in     Integer;
      Spiked      : out    Boolean)
   is
   begin
      State.Total_Injections := State.Total_Injections + 1;

      if State.Refractory_Left > 0 then
         State.Refractory_Left := State.Refractory_Left - 1;
         Spiked := False;
         return;
      end if;

      declare
         Next_V : Integer := State.V_Membrane + Current_In;
      begin
         if Next_V > 40 then
            Next_V := 40;
         elsif Next_V < -90 then
            Next_V := -90;
         end if;

         if Next_V >= Threshold_Potential then
            State.V_Membrane := Reset_Potential;
            State.Refractory_Left := 5;
            State.Total_Spikes := State.Total_Spikes + 1;
            Spiked := True;
         else
            State.V_Membrane := Membrane_Potential_Mv (Next_V);
            Spiked := False;
         end if;
      end;
   end Inject_Current;

   procedure Apply_STDP_Adaptation
     (State    : in out Neuron_State;
      Synapse  : in     Synapse_Id;
      Delta_W  : in     Integer)
   is
      New_W : Integer := Integer (State.Weights (Synapse)) + Delta_W;
   begin
      if New_W > 1000 then
         New_W := 1000;
      elsif New_W < 0 then
         New_W := 0;
      end if;
      State.Weights (Synapse) := Synaptic_Weight (New_W);
   end Apply_STDP_Adaptation;

end Sovereign_Neuromorphic_Spike_Timing_Governor;
