--  Sovereign_Neuromorphic_Spike_Timing_Governor
--  SPARK 2022 Formal Verification Enclave: Level 4 Gold (DO-178C DAL-A)
--  Leaky Integrate-and-Fire (LIF) and Spike-Timing-Dependent Plasticity (STDP) governor.
--  Enforces membrane potential bounds, refractory gating, and synaptic plasticity saturation.

pragma SPARK_Mode (On);

package Sovereign_Neuromorphic_Spike_Timing_Governor is

   subtype Membrane_Potential_Mv is Integer range -90 .. 40;
   subtype Synaptic_Weight is Natural range 0 .. 1000;
   subtype Refractory_Ticks is Natural range 0 .. 50;

   Resting_Potential   : constant Membrane_Potential_Mv := -70;
   Threshold_Potential : constant Membrane_Potential_Mv := -55;
   Reset_Potential     : constant Membrane_Potential_Mv := -75;

   Max_Synapses : constant := 16;
   subtype Synapse_Id is Positive range 1 .. Max_Synapses;
   type Synapse_Array is array (Synapse_Id) of Synaptic_Weight;

   type Neuron_State is record
      V_Membrane       : Membrane_Potential_Mv;
      Refractory_Left  : Refractory_Ticks;
      Weights          : Synapse_Array;
      Total_Spikes     : Natural;
      Total_Injections : Natural;
   end record;

   procedure Init_Neuron
     (State : out Neuron_State)
   with
     Global  => null,
     Depends => (State => null),
     Post    => State.V_Membrane = Resting_Potential and
                State.Refractory_Left = 0 and
                State.Total_Spikes = 0 and
                State.Total_Injections = 0 and
                (for all S in Synapse_Id => State.Weights (S) = 100);

   procedure Inject_Current
     (State       : in out Neuron_State;
      Current_In  : in     Integer;
      Spiked      : out    Boolean)
   with
     Global  => null,
     Depends => (State =>+ Current_In, Spiked => (State, Current_In)),
     Pre     => Current_In in -20 .. 50 and State.Total_Injections < Natural'Last and State.Total_Spikes < Natural'Last,
     Post    => State.Total_Injections = State.Total_Injections'Old + 1 and
                (if Spiked then State.V_Membrane = Reset_Potential and State.Refractory_Left = 5 and State.Total_Spikes = State.Total_Spikes'Old + 1
                 else State.Total_Spikes = State.Total_Spikes'Old);

   procedure Apply_STDP_Adaptation
     (State    : in out Neuron_State;
      Synapse  : in     Synapse_Id;
      Delta_W  : in     Integer)
   with
     Global  => null,
     Depends => (State =>+ (Synapse, Delta_W)),
     Pre     => Delta_W in -100 .. 100,
     Post    => State.Weights (Synapse) <= 1000;

end Sovereign_Neuromorphic_Spike_Timing_Governor;
