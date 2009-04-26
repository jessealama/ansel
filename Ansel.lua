--[

Ansel: A World of Warcraft screenshot addon to rule them all.

--]

function purpleChatMessage (s)
   DEFAULT_CHAT_FRAME:AddMessage(s, 1.0, 0.0, 1.0);

function AnselRapidFireScreenshot ()
   purpleChatMessage ("Rapid-fire screenshots not yet enabled;");
   purpleChatMessage ("Taking a single screenshot instead.")
   ScreenShot ();
end

function AnselSingleShot ()
   Screenshot();
end
