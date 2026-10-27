package body Sovereign_Acoustic_Stardust_Harmonizer with
  SPARK_Mode => On
is

   procedure Initialize_Synthesizer (State : out Stardust_Audio_State) is
   begin
      State := (Active_Frequency  => 432,
                Current_Level_dBA => 0,
                Active_Scale      => 1,
                Emitted_Frames    => 0,
                Is_Purged         => False);
   end Initialize_Synthesizer;

   procedure Synthesize_Silver_Chime
     (State   : in out Stardust_Audio_State;
      Freq    : in     Tone_Frequency_Hz;
      Level   : in     Sound_Level_dBA;
      Scale   : in     Harmonic_Scale_ID;
      Success : out    Boolean)
   is
   begin
      if Level > 0 then
         State.Active_Frequency  := Freq;
         State.Current_Level_dBA := Level;
         State.Active_Scale      := Scale;
         State.Emitted_Frames    := State.Emitted_Frames + 1;
         State.Is_Purged         := False;
         Success                 := True;
      else
         Success := False;
      end if;
   end Synthesize_Silver_Chime;

   procedure Purge_Synthesizer_Session (State : in out Stardust_Audio_State) is
   begin
      State.Current_Level_dBA := 0;
      State.Is_Purged         := True;
   end Purge_Synthesizer_Session;

end Sovereign_Acoustic_Stardust_Harmonizer;
