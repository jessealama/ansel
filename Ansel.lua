--[

Ansel: A World of Warcraft screenshot addon to rule them all.

--]

function purpleChatMessage (s)
   DEFAULT_CHAT_FRAME:AddMessage(s, 1.0, 0.0, 1.0, 1.0);
end

function Ansel_OnLoad ()
   purpleChatMessage("Ansel: Take screenshots like a pro!");
end

function Ansel_OnEvent (event)
   -- I don't know what to do here
end

function AnselRapidFireScreenshot ()
   purpleChatMessage ("Rapid-fire screenshots not yet enabled;");
   purpleChatMessage ("Taking a single screenshot instead.")
   ScreenShot ();
end

function AnselSingleShot ()
   local zone    = GetRealZoneText();
   local subzone = GetSubZoneText();
   local time    = GetGameTime();
   local x, y    = GetPlayerMapPosition("player");
   -- now ignore these data
   Screenshot();
end
