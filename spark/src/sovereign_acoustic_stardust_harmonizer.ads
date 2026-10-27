package Sovereign_Acoustic_Stardust_Harmonizer with
  SPARK_Mode => On
is
   subtype Tone_Frequency_Hz is Integer range 100 .. 2000;
   subtype Sound_Level_dBA is Integer range 0 .. 75;
   subtype Harmonic_Scale_ID is Integer range 1 .. 12;
   subtype Frame_Counter is Integer range 0 .. 100_000;

   type Stardust_Audio_State is record
      Active_Frequency  : Tone_Frequency_Hz;
      Current_Level_dBA : Sound_Level_dBA;
      Active_Scale      : Harmonic_Scale_ID;
      Emitted_Frames    : Frame_Counter;
      Is_Purged         : Boolean;
   end record;

   procedure Initialize_Synthesizer (State : out Stardust_Audio_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Active_Frequency = 432 and
             State.Current_Level_dBA = 0 and
             State.Active_Scale = 1 and
             State.Emitted_Frames = 0 and
             State.Is_Purged = False;

   procedure Synthesize_Silver_Chime
     (State   : in out Stardust_Audio_State;
      Freq    : in     Tone_Frequency_Hz;
      Level   : in     Sound_Level_dBA;
      Scale   : in     Harmonic_Scale_ID;
      Success : out    Boolean) with
     Global => null,
     Depends => (State   => (State, Freq, Level, Scale),
                 Success => Level),
     Pre => State.Emitted_Frames < Frame_Counter'Last,
     Post => (if Success then
                State.Active_Frequency = Freq and
                State.Current_Level_dBA = Level and
                State.Active_Scale = Scale and
                State.Emitted_Frames = State.Emitted_Frames'Old + 1 and
                State.Is_Purged = False
              else
                State = State'Old);

   procedure Purge_Synthesizer_Session (State : in out Stardust_Audio_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Current_Level_dBA = 0 and
             State.Is_Purged = True;

end Sovereign_Acoustic_Stardust_Harmonizer;
