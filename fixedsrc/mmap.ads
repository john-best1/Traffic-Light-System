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

with System;

package MMap is
   
   function Get_MMAP_RW return System.Address;
   
   procedure Close_MMAP;
   
end MMap;

