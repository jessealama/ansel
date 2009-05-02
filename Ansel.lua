--[[

Ansel: A World of Warcraft screenshot addon to rule them all.

--]]

Ansel_GameTime = {

  -----------------------------------------------------------
  -- function Ansel_GameTime:Get()
  --
  -- Return game time as (h,m,s) where s has 3 decimals of
  -- precision (though it's only likely to be precise down
  -- to ~20th of seconds since we're dependent on frame
  -- refreshrate).
  --
  -- During the first minute of play, the seconds will
  -- consistenly be "00", since we haven't observed any
  -- minute changes yet.
  --
  --

  Get = function(self)
  	if(self.LastMinuteTimer == nil) then
  		local h,m = GetGameTime();
  		return h,m,0;
  	end
  	local s = GetTime() - self.LastMinuteTimer;
  	if(s>59.999) then
  		s=59.999;
  	end
  	return self.LastGameHour, self.LastGameMinute, s;
  end,


  -----------------------------------------------------------
  -- function Ansel_GameTime:OnUpdate()
  --
  -- Called by: Private frame <OnUpdate> handler
  --
  -- Construct high precision server time by polling for
  -- server minute changes and remembering GetTime() when it
  -- last did
  --

  OnUpdate = function(self)
  	local h,m = GetGameTime();
  	if(self.LastGameMinute == nil) then
  		self.LastGameHour = h;
  		self.LastGameMinute = m;
  		return;
  	end
  	if(self.LastGameMinute == m) then
  		return;
  	end
  	self.LastGameHour = h;
  	self.LastGameMinute = m;
  	self.LastMinuteTimer = GetTime();
  end,

  -----------------------------------------------------------
  -- function Ansel_GameTime:Initialize()
  --
  -- Create frame to pulse OnUpdate() for us
  --

  Initialize = function(self)
  	self.Frame = CreateFrame("Frame");
  	self.Frame:SetScript("OnUpdate", function() self:OnUpdate(); end);
  end
}

Ansel_GameTime:Initialize();

-- For the keybindings
BINDING_HEADER_ANSEL = "Ansel"

-- Keep track of the hour, minute, and second just before a screenshot
-- is taken.  We store this information in the photo database, along
-- with the the hour, minute, and second immediately after a
-- screenshot is taken.  We use these data to figure out what file in
-- the Screenshots directory corresponds to the the screenshot we
-- took.
local current_hour, current_minute, current_second;

-- We keep track of whether the UI was hidden before we took the last
-- screenshot.
local uihidden = false;

-- Photo database
AnselPhotoDB = {};

function purpleAnselChatMessage (s)
   DEFAULT_CHAT_FRAME:AddMessage ("[Ansel] " .. s, 1.0, 0.0, 1.0);
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
      local h,m,s    = Ansel_GameTime:Get();
      local x,y      = GetPlayerMapPosition("player");
      if (uihidden) then
	 UIParent:Show ();
	 uihidden = false;
      end
      local record = { ["preshot hour"] = current_hour, 
		       ["preshot minute"] = current_minute, 
		       ["preshot second"] = current_second,
		       ["postshot hour"] = h,
		       ["postshot minute"] = m,
		       ["postshot second"] = s,
		       ["zone"] = zone,
		       ["subzone"] = subzone,
		       ["x"] = x,
		       ["y"] = y };
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
   purpleAnselChatMessage ("Taking a single screenshot instead.")
   Screenshot ();
end

function AnselSingleShot ()
   if (IsShiftKeyDown ()) then
      uihidden = true;
      CloseAllWindows();
      UIParent:Hide ();      
   end
   current_hour, current_minute, current_second = Ansel_GameTime:Get ();
   Screenshot();
end
