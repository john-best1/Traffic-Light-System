with HWIF; use HWIF;
with HWIF_Types; use HWIF_Types;
with Ada.Calendar; use Ada.Calendar;
procedure Controller is
   State : Integer;
   PhaseStart : Time;
   Phase1LastTime : Time;
   Phase2LastTime : Time;
   PedestrianLastTime: Time := Ada.Calendar.Clock;
   AmberQuickPedCycle: boolean := False;
   procedure RedToRedAmber (Dir1, Dir2 : Direction) is
   begin
      Traffic_Light ( Dir1 ) := 6;
      Traffic_Light ( Dir2 ) := 6;
   end RedToRedAmber;
   procedure RedAmberToGreen (Dir1, Dir2 : Direction) is
   begin
      Traffic_Light ( Dir1 ) := 1;
      Traffic_Light ( Dir2 ) := 1;
   end RedAmberToGreen;
   procedure GreenToAmber (Dir1, Dir2 : Direction) is
   begin
      Traffic_Light ( Dir1 ) := 2;
      Traffic_Light ( Dir2 ) := 2;
   end GreenToAmber;
   procedure AmberToRed (Dir1, Dir2 : Direction) is
   begin
      Traffic_Light ( Dir1 ) := 4;
      Traffic_Light ( Dir2 ) := 4;
   end AmberToRed;
   procedure PedRedToGreen is
   begin
      Pedestrian_Wait(North) := 0;
      Pedestrian_Wait(South) := 0;
      Pedestrian_Wait(East) := 0;
      Pedestrian_Wait(West) := 0;
      Pedestrian_Light ( North ) := 1;
      Pedestrian_Light ( South ) := 1;
      Pedestrian_Light ( East ) := 1;
      Pedestrian_Light ( West ) := 1;
   end PedRedToGreen;
   procedure PedGreenToRed  is
   begin
      Pedestrian_Light ( North ) := 2;
      Pedestrian_Light ( South ) := 2;
      Pedestrian_Light ( East ) := 2;
      Pedestrian_Light ( West ) := 2;
   end PedGreenToRed;
   procedure WaitLights is
   begin
      if Pedestrian_Button (North) = 1 and Pedestrian_Wait (North) = 0 and Pedestrian_Light (North) = 2 then
         Pedestrian_Wait (North) := 1; end if;
      if Pedestrian_Button (South) = 1 and Pedestrian_Wait (South) = 0 and Pedestrian_Light (South) = 2 then
         Pedestrian_Wait (South) := 1; end if;
      if Pedestrian_Button (East) = 1 and Pedestrian_Wait (East) = 0 and Pedestrian_Light (East) = 2 then
         Pedestrian_Wait (East) := 1; end if;
      if Pedestrian_Button (West) = 1 and Pedestrian_Wait (West) = 0 and Pedestrian_Light (West) = 2 then
         Pedestrian_Wait (West) := 1; end if;
   end WaitLights;
   procedure WaitLightsCheck is
   begin
      if Pedestrian_Button (North) = 1 or Pedestrian_Button (South) = 1 or Pedestrian_Button (East) = 1 or Pedestrian_Button (West) = 1 then
         WaitLights; end if;
   end WaitLightsCheck;
   procedure LightLoop(Time: Duration) is
   begin
      PhaseStart := Ada.Calendar.Clock;
      loop
          exit when Ada.Calendar.Clock - PhaseStart > Time;
          WaitLightsCheck;
          delay(0.197);
      end loop;
   end LightLoop;
   Procedure PedestrianLightsCycle is
   begin
      AmberQuickPedCycle := False;
      PedRedToGreen;
      LightLoop(6.05);
      PedGreenToRed;
      PedestrianLastTime := Ada.Calendar.Clock;
      WaitLightsCheck;
   end PedestrianLightsCycle;
   procedure TenSecondLoop(Dir1, Dir2: Direction) is
   begin
      PhaseStart := Ada.Calendar.Clock;
      loop
         exit when Ada.Calendar.Clock - PhaseStart > 10.05 or
           Emergency_Vehicle_Sensor(Dir1) = 1 or Emergency_Vehicle_Sensor(Dir2) = 1;
          WaitLightsCheck;
          delay(0.197);
      end loop;
   end TenSecondLoop;
   procedure EmergencyLoop(Dir1, Dir2: Direction) is
   begin
      loop
          exit when Emergency_Vehicle_Sensor(Dir1) = 0 and Emergency_Vehicle_Sensor(Dir2) = 0;
          WaitLightsCheck;
          delay(0.197);
      end loop;
      TenSecondLoop(Dir1, Dir2);
   end EmergencyLoop;
   procedure GreenLightLoop(Dir1, Dir2: Direction) is
   begin
      PhaseStart := Ada.Calendar.Clock;
      loop
          exit when Ada.Calendar.Clock - PhaseStart > 5.05;
          WaitLightsCheck;
          delay(0.197);
      end loop;
      if Emergency_Vehicle_Sensor(Dir1) = 1 or Emergency_Vehicle_Sensor(Dir2) = 1 then
      loop
          exit when Emergency_Vehicle_Sensor(Dir1) = 0 and Emergency_Vehicle_Sensor(Dir2) = 0;
          EmergencyLoop(Dir1, Dir2);
      end loop;end if;
   end GreenLightLoop;
   procedure QuickPedAmberCheck is
   begin
      if (Emergency_Vehicle_Sensor(North) = 1 or Emergency_Vehicle_Sensor(South) = 1
          or Emergency_Vehicle_Sensor(East) = 1 or Emergency_Vehicle_Sensor(West) = 1)
        and Ada.Calendar.Clock - Phase1LastTime < 53.8 and Ada.Calendar.Clock - Phase2LastTime < 53.8 then
         AmberQuickPedCycle := True; end if;
   end QuickPedAmberCheck;
   procedure AmberLightLoop is
   begin
      PhaseStart := Ada.Calendar.Clock;
      loop
          exit when Ada.Calendar.Clock - PhaseStart > 3.05;
          WaitLightsCheck;
          QuickPedAmberCheck;
          delay(0.197);
      end loop;
      QuickPedAmberCheck;
   end AmberLightLoop;
   procedure ModifyState is
   begin
      if Ada.Calendar.Clock - PedestrianLastTime > 51.8
        and (Pedestrian_Wait(North) = 1 or Pedestrian_Wait(South) = 1 or Pedestrian_Wait(East) = 1 or Pedestrian_Wait(West) = 1) then
         PedestrianLightsCycle;
      end if;
      if Ada.Calendar.Clock - Phase1LastTime > 53.8 then  State := 1;
      elsif Ada.Calendar.Clock - Phase2LastTime > 53.8 then State := 2;
      elsif Emergency_Vehicle_Sensor(North) = 1 or Emergency_Vehicle_Sensor(South) = 1 then
         if AmberQuickPedCycle then PedestrianLightsCycle; end if;
         State := 1;
      elsif Emergency_Vehicle_Sensor(East) = 1 or Emergency_Vehicle_Sensor(West) = 1 then
          if AmberQuickPedCycle then PedestrianLightsCycle; end if;
         State := 2;
      else
         if Ada.Calendar.Clock - PedestrianLastTime > 30.0 then PedestrianLightsCycle; end if;
         State := (State mod 2) + 1;
      end if;
   end ModifyState;
begin
   State := 1;
   LightLoop(2.00);
   Phase2LastTime := Ada.Calendar.Clock;
   PedestrianLastTime := Ada.Calendar.Clock;
   loop
      case State is
         when 1 =>
            RedToRedAmber(North, South);
            LightLoop(0.05);
            RedAmberToGreen(North, South);
            if Emergency_Vehicle_Sensor(North) = 1 or Emergency_Vehicle_Sensor(South) = 1 then
               loop
                  exit when Emergency_Vehicle_Sensor(North) = 0 and Emergency_Vehicle_Sensor(South) = 0;
                  EmergencyLoop(North, South);
               end loop;
            else GreenLightLoop(North, South); end if;
            Phase1LastTime := Ada.Calendar.Clock;
            GreenToAmber(North, South);
            if Emergency_Vehicle_Sensor(North) = 0 and Emergency_Vehicle_Sensor(South) = 0
                 and Emergency_Vehicle_Sensor(East) = 0 and Emergency_Vehicle_Sensor(West) = 0 then AmberLightLoop;
            else LightLoop(3.05); end if;
            AmberToRed(North, South);
         when 2 =>
            RedToRedAmber(East, West);
            LightLoop(0.05);
            RedAmberToGreen(East, West);
            if Emergency_Vehicle_Sensor(East) = 1 or Emergency_Vehicle_Sensor(West) = 1 then
               loop
                  exit when Emergency_Vehicle_Sensor(East) = 0 and Emergency_Vehicle_Sensor(West) = 0;
                  EmergencyLoop(East, West);
               end loop;
            else GreenLightLoop(East, West); end if;
            Phase2LastTime := Ada.Calendar.Clock;
            GreenToAmber(East, West);
            if Emergency_Vehicle_Sensor(North) = 0 and Emergency_Vehicle_Sensor(South) = 0
                 and Emergency_Vehicle_Sensor(East) = 0 and Emergency_Vehicle_Sensor(West) = 0 then AmberLightLoop;
            else LightLoop(3.05); end if;
            AmberToRed(East, West);
            if Ada.Calendar.Clock - Phase1LastTime < 53.8
              and Emergency_Vehicle_Sensor(North) = 0 and Emergency_Vehicle_Sensor(South) = 0 and
              (Pedestrian_Wait(North) = 1 or Pedestrian_Wait(South) = 1 or Pedestrian_Wait(East) = 1 or Pedestrian_Wait(West) = 1) then
               PedestrianLightsCycle; end if;
         when others => null;
      end case;
      ModifyState;
      delay(0.03);
   end loop;
end Controller;
