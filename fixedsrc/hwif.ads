-- Ada simulation/test harness of embedded system providing cross-roads ATS
-- Copyright (C) 2014-2018 Phil Brooke
-- 
-- This code may NOT be distributed beyond staff and students
-- teaching/studying the embedded systems module at Teesside University.
-- It may NOT be used for any other purpose other than teaching/studying
-- that module.  Copies must NOT be retained beyond necessary for
-- teaching/studying that module.  No licence headers or licence output
-- may be removed.
-- 
-- This code is distributed WITHOUT ANY WARRANTY; without even the
-- implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.

with HWIF_Types;               use HWIF_Types;
with MMap;
with System.Storage_Elements;
with System;

pragma Elaborate(MMap);

package HWIF is
   
   Addr : constant System.Address := MMap.Get_MMAP_RW;
   
   function "+" (A : in System.Address;
                 B : in System.Storage_Elements.Storage_Offset)
                return System.Address 
     renames System.Storage_Elements."+";
   
   type Direction is (North, South, East, West);
   type Direction_Octet is array (Direction) of Octet;
   
   -- Vehicle traffic lights are a single octet.
   -- 1 => green, 2 => amber, 4 => red.

   Traffic_Light : Direction_Octet with Address => Addr;
   pragma Volatile (Traffic_Light);
   
   -- Pedestrian lights are also a single octet.
   -- 1 => green, 2 => red.
   
   Pedestrian_Light : Direction_Octet with Address => Addr+10;
   pragma Volatile (Pedestrian_Light);
   
   -- Pedestrian wait lights.
   -- 1 => on.
   
   Pedestrian_Wait : Direction_Octet with Address => Addr+20;
   pragma Volatile (Pedestrian_Wait);
   
   -- Pedestrian button.
   -- 1 => currently pressed.
   
   Pedestrian_Button : Direction_Octet with Address => Addr+30;
   pragma Volatile (Pedestrian_Button);
   
   -- Priority sensor for emergency vehicles.
   -- 1 => signal currently being received.
   
   Emergency_Vehicle_Sensor : Direction_Octet with Address => Addr+40;
   pragma Volatile (Emergency_Vehicle_Sensor);
   
end HWIF;
