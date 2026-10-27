package body Czech_Sign_Dactyl_Morphology_Guard with
  SPARK_Mode => On
is

   procedure Initialize_Dactyl_Guard (State : out Dactyl_Morphology_State) is
   begin
      State := (Active_Code      => 1,
                Current_Flexion  => 0,
                Current_Spread   => 0,
                Validated_Frames => 0,
                Is_Purged        => False);
   end Initialize_Dactyl_Guard;

   procedure Validate_Dactyl_Pose
     (State   : in out Dactyl_Morphology_State;
      Code    : in     Dactyl_Char_Code;
      Flexion : in     Finger_Bend_Angle;
      Spread  : in     Finger_Spread_Angle;
      Valid   : out    Boolean)
   is
   begin
      if Flexion <= 85 and Spread >= -25 and Spread <= 25 then
         State.Active_Code      := Code;
         State.Current_Flexion  := Flexion;
         State.Current_Spread   := Spread;
         State.Validated_Frames := State.Validated_Frames + 1;
         State.Is_Purged        := False;
         Valid                  := True;
      else
         Valid := False;
      end if;
   end Validate_Dactyl_Pose;

   procedure Purge_Dactyl_Session (State : in out Dactyl_Morphology_State) is
   begin
      State.Current_Flexion := 0;
      State.Current_Spread  := 0;
      State.Is_Purged       := True;
   end Purge_Dactyl_Session;

end Czech_Sign_Dactyl_Morphology_Guard;
