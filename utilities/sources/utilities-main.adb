------------------------------------------------------------------------------
--                                                                          --
--                         UTILITIES                                        --
--                                                                          --
--          Copyright (C) 2015, AdaLabs Ltd & PIA-SOFER                     --
--                                                                          --
-- This is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with GNAT; see file COPYING3.  If not, go to --
-- http://www.gnu.org/licenses for a complete copy of the license.          --
--                                                                          --
-- Author: AdaLabs Ltd                                                      --
--                                                                          --
------------------------------------------------------------------------------
with Ada.Calendar.Formatting,
     Ada.Calendar.Time_Zones,
     Ada.Command_Line,
     Ada.Directories,
     Ada.Exceptions;

use Ada.Directories;

with GNAT.OS_Lib;

with Utilities.Versions;

procedure Utilities.Main
is
   Source      : constant String  := GNAT.OS_Lib.Normalize_Pathname (Ada.Command_Line.Argument (1));
   Destination : constant String  := GNAT.OS_Lib.Normalize_Pathname (Ada.Command_Line.Argument (2));
   Success     :          Boolean := True;
   For_Reel    : constant Boolean := Boolean'Value (Ada.Command_Line.Argument (3));
   Clock_Image : constant String  := Ada.Calendar.Formatting.Image (Date                  => Ada.Calendar.Clock,
                                                                    Time_Zone             => Ada.Calendar.Time_Zones.UTC_Time_Offset);
   Stamp       : constant String := Clock_Image (Clock_Image'First     .. Clock_Image'First + 3) &
                   Clock_Image (Clock_Image'First + 5 .. Clock_Image'First + 6) &
                   Clock_Image (Clock_Image'First + 8 .. Clock_Image'First + 9) &
                   Clock_Image (Clock_Image'First + 11 .. Clock_Image'First + 12) &
                   Clock_Image (Clock_Image'First + 14 .. Clock_Image'First + 15) &
                   Clock_Image (Clock_Image'First + 17 .. Clock_Image'First +  18);

   function From_Source (E          : String;
                         Add_Origin : Boolean := False) return String;
   function From_Destination (E          : String;
                              Add_Origin : Boolean := False) return String;


   function From_Source (E          : String;
                         Add_Origin : Boolean := False) return String
   is
   begin
      if Add_Origin then
         declare
            R       : constant String := "[src]" & E (E'First + Source'Length .. E'Last);
            Padding : constant String (1 .. Integer'Max (60 - R'Length, 1)) := (others => ' ');
         begin
            return R & Padding;
         end;
      else
         return E (E'First + Source'Length .. E'Last);
      end if;
   end From_Source;

   function From_Destination (E          : String;
                              Add_Origin : Boolean := False) return String
   is
   begin
      if Add_Origin then
         return "[dst]" & E (E'First + Destination'Length .. E'Last);
      else
         return E (E'First + Destination'Length .. E'Last);
      end if;
   end From_Destination;

   procedure Do_Search (Search_Point : String);

   procedure Do_Search (Search_Point : String)
   is
      Search          : Ada.Directories.Search_Type;
      Directory_Entry : Ada.Directories.Directory_Entry_Type;
      Filter          : Ada.Directories.Filter_Type := (Directory     => True,
                                                        Ordinary_File => True,
                                                        Special_File  => True);
   begin
      Ada.Directories.Start_Search (Search    => Search,
                                    Directory => Search_Point,
                                    Pattern   => "*",
                                    Filter    => Filter);

      while Ada.Directories.More_Entries (Search) loop
         Ada.Directories.Get_Next_Entry (Search,
                                         Directory_Entry);
         case Kind (Directory_Entry) is
            when Ordinary_File
               | Special_File =>

               if Ada.Directories.Exists (Destination & From_Source (Full_Name (Directory_Entry), Add_Origin => False)) then
                  Log (From_Source (Full_Name (Directory_Entry), Add_Origin => True) &
                       (From_Destination (Destination & From_Source (Full_Name (Directory_Entry), Add_Origin => False),
                          Add_Origin => True) & " patched"));

                  if For_Reel then
                     Ada.Directories.Rename (Old_Name => Destination & From_Source (Full_Name (Directory_Entry)),
                                             New_Name => Destination & From_Source (Full_Name (Directory_Entry)) &
                                               ".patched." & Stamp);

                     Ada.Directories.Copy_File
                       (Source_Name => Full_Name (Directory_Entry),
                        Target_Name => Destination & From_Source (Full_Name (Directory_Entry)));
                  end if;

               else
                  Log (From_Source (Full_Name (Directory_Entry), Add_Origin => True) &  "skipped");
               end if;


            when Directory =>
               if Simple_Name (Directory_Entry) not in  "." | ".." then
                  Do_Search (Full_Name (Directory_Entry));
               end if;
         end case;
      end loop;

      Ada.Directories.End_Search (Search);
   end Do_Search;

begin
   Log (Ada.Command_Line.Command_Name & " " & Utilities.Versions.Label);


   if not Ada.Directories.Exists (Source) then
      Log ("invalid source " & Source);
      Success := False;
   end if;

   if not Ada.Directories.Exists (Destination) then
      Log ("invalid destination " & Destination);
      Success := False;
   end if;
   Log ("src => " & Source);
   Log ("dst => " & Destination);

   Do_Search (Source);

   if Success then
      Ada.Command_Line.Set_Exit_Status (0);
   else
      Ada.Command_Line.Set_Exit_Status (2);
   end if;

exception
   when E : others =>
      Log ("fatal error " & Ada.Exceptions.Exception_Information (E));
      Ada.Command_Line.Set_Exit_Status (1);

end Utilities.Main;
