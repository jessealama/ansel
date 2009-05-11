--[[

Ansel: A World of Warcraft screenshot addon to rule them all.

--]]

-- For the keybindings
BINDING_HEADER_ANSEL = "Ansel"

-- Keep track of the hour, minute, and second just before a screenshot
-- is taken.  We store this information in the photo database, along
-- with the the hour, minute, and second immediately after a
-- screenshot is taken.  We use these data to figure out what file in
-- the Screenshots directory corresponds to the the screenshot we
-- took.
local current_weekday;
local current_year, current_month, current_day;
local current_hour, current_minute, current_second;
local current_x, current_y;
local current_zone, current_subzone;

-- We keep track of whether the UI was hidden before we took the last
-- screenshot.
local uihidden = false;

-- Photo database
AnselPhotoDB = {};

function purpleAnselChatMessage (s)
   DEFAULT_CHAT_FRAME:AddMessage ("[Ansel] " .. s, 1.0, 0.0, 1.0);
end

function Ansel_midpoint (x1, y1, x2, y2)
   return (x1 + x2)/2, (y1 + y2)/2;
end

function Ansel_getTime ()
   local month = tonumber (date ("%m"));
   local day = tonumber (date ("%d"));
   local year = tonumber (date ("%y"));
   local hour = tonumber (date ("%H"));
   local minute = tonumber (date ("%M"));
   local second = tonumber (date ("%S"));
   return month, day, year, hour, minute, second;
end
   
function Ansel_OnLoad ()
   this:RegisterEvent ("SCREENSHOT_SUCCEEDED");
   this:RegisterEvent ("SCREENSHOT_FAILED");
   this:RegisterEvent ("VARIABLES_LOADED");
   purpleAnselChatMessage("Take screenshots like a pro!");
end

function Ansel_OnEvent (event)
   if (event == "SCREENSHOT_SUCCEEDED") then
      local zone     = GetRealZoneText();
      local subzone  = GetSubZoneText();
      local month, day, year, h, m, s    = Ansel_getTime();
      local x,y      = GetPlayerMapPosition("player");
      if (uihidden) then
	 UIParent:Show ();
	 uihidden = false;
      end
      local record = { 
	 ["preshot year"] = current_year,
	 ["preshot month"] = current_month,
	 ["preshot day"] = current_day,
	 ["preshot hour"] = current_hour, 
	 ["preshot minute"] = current_minute, 
	 ["preshot second"] = current_second,
	 ["postshot year"] = year,
	 ["postshot month"] = month,
	 ["postshot day"] = day,
	 ["postshot hour"] = h,
	 ["postshot minute"] = m,
	 ["postshot second"] = s,
	 ["preshot zone"] = current_zone,
	 ["preshot subzone"] = current_subzone,
	 ["postshot zone"] = zone,
	 ["postshot subzone"] = subzone,
	 ["preshot x"] = current_x,
	 ["preshot y"] = current_y;
	 ["postshot x"] = x,
	 ["postshot y"] = y 
      };
      table.insert(AnselPhotoDB,record);
      purpleAnselChatMessage ("Screenshot taken in subzone " .. subzone .. " of " .. zone .. " at gametime " .. h .. ":" .. m .. ":" .. s .. " in location (" .. x .. "," .. y ..")");
   elseif (event == "SCREENSHOT_FAILED") then
      purpleAnselChatMessage ("Screenshot failed -- sorry!");
   elseif (event == "VARIABLES_LOADED") then
      purpleAnselChatMessage ("Screenshot database loaded");
   else
      -- do nothing
   end
end

function AnselRapidFireScreenshot ()
   purpleAnselChatMessage ("Rapid-fire screenshots not yet enabled;");
   purpleAnselChatMessage ("taking a single screenshot instead.")
   Screenshot ();
end

function AnselSingleShot ()
   if (IsShiftKeyDown ()) then
      uihidden = true;
      CloseAllWindows();
      UIParent:Hide ();      
   end
   current_month, current_day, current_year, current_hour, current_minute, current_second = Ansel_getTime ();
   current_x, current_y = GetPlayerMapPosition ("player");
   current_zone     = GetRealZoneText();
   current_subzone  = GetSubZoneText();
   Screenshot();
end
