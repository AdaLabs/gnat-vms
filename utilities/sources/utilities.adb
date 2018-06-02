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
with Ada.Text_IO;

package body Utilities is

   procedure Log (M : String)
   is
   begin
      Ada.Text_IO.Put_Line (">>" & M);
   end Log;

end Utilities;
