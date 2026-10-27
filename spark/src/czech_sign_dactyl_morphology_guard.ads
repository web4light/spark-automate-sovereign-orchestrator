package Czech_Sign_Dactyl_Morphology_Guard with
  SPARK_Mode => On
is
   subtype Dactyl_Char_Code is Integer range 1 .. 36;
   subtype Finger_Bend_Angle is Integer range 0 .. 90;
   subtype Finger_Spread_Angle is Integer range -30 .. 30;
   subtype Frame_Counter is Integer range 0 .. 100_000;

   type Dactyl_Morphology_State is record
      Active_Code       : Dactyl_Char_Code;
      Current_Flexion   : Finger_Bend_Angle;
      Current_Spread    : Finger_Spread_Angle;
      Validated_Frames  : Frame_Counter;
      Is_Purged         : Boolean;
   end record;

   procedure Initialize_Dactyl_Guard (State : out Dactyl_Morphology_State) with
     Global => null,
     Depends => (State => null),
     Post => State.Active_Code = 1 and
             State.Current_Flexion = 0 and
             State.Current_Spread = 0 and
             State.Validated_Frames = 0 and
             State.Is_Purged = False;

   procedure Validate_Dactyl_Pose
     (State   : in out Dactyl_Morphology_State;
      Code    : in     Dactyl_Char_Code;
      Flexion : in     Finger_Bend_Angle;
      Spread  : in     Finger_Spread_Angle;
      Valid   : out    Boolean) with
     Global => null,
     Depends => (State => (State, Code, Flexion, Spread),
                 Valid => (Flexion, Spread)),
     Pre => State.Validated_Frames < Frame_Counter'Last,
     Post => (if Valid then
                State.Active_Code = Code and
                State.Current_Flexion = Flexion and
                State.Current_Spread = Spread and
                State.Validated_Frames = State.Validated_Frames'Old + 1 and
                State.Is_Purged = False
              else
                State = State'Old);

   procedure Purge_Dactyl_Session (State : in out Dactyl_Morphology_State) with
     Global => null,
     Depends => (State =>+ null),
     Post => State.Current_Flexion = 0 and
             State.Current_Spread = 0 and
             State.Is_Purged = True;

end Czech_Sign_Dactyl_Morphology_Guard;
