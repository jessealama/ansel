--[[

Ansel: A World of Warcraft screenshot addon to rule them all.

--]]

-- For the keybindings
BINDING_HEADER_ANSEL = "Ansel"

function purpleChatMessage (s)
   DEFAULT_CHAT_FRAME:AddMessage (s, 1.0, 0.0, 1.0);
end

function Ansel_OnLoad ()
   purpleChatMessage("Ansel now loaded -- take screenshots like a pro!");
end

function Ansel_OnEvent (event)
end

function AnselRapidFireScreenshot ()
   purpleChatMessage ("Rapid-fire screenshots not yet enabled;");
   purpleChatMessage ("Taking a single screenshot instead.")
   Screenshot ();
end

function AnselSingleShot ()
   local zone    = GetRealZoneText();
   local subzone = GetSubZoneText();
   local time    = GetGameTime();
   local x, y    = GetPlayerMapPosition("player");
   -- now ignore these data
   Screenshot();
   -- purpleChatMessage ("Screenshot taken in subzone " .. subzone .. " of " .. zone " at gametime " .. time .. "in location \(" x .. "," .. y .."\)");
end
