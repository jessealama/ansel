--[[

ansel-db: Manage Ansel databases

--]]

require "lfs";

local wow_directory = "/Applications/World of Warcraft";
local wow_screenshot_dir = wow_directory .. "/" .. "Screenshots";
local wow_accounts_dir = wow_directory .. "/WTF/Account";

function time_less_than (month1, day1, year1, hour1, minute1, second1,
			 month2, day2, year2, hour2, minute2, second2)
   return 
     (year1 < year2) or
     (year1 == year2 and month1 < month2) or
     (month1 == month2 and day1 < day2) or
     (day1 == day2 and hour1 < hour2) or
     (hour1 == hour2 and minute1 < minute2) or
     (minute1 == minute2 and second1 < second2);
end

function screenshot_info (screenshot)
   -- Screenshot names are "ScreenShot_MMDDYY_HHMMSS"
   local month  = string.sub (screenshot, 12, 13);
   local day    = string.sub (screenshot, 14, 15);
   local year   = string.sub (screenshot, 16, 17);
   local hour   = string.sub (screenshot, 19, 20);
   local minute  = string.sub (screenshot, 21, 22);
   local second   = string.sub (screenshot, 23, 24);
   return month, day, year, hour, minute, second
end

function db_entry_corresponds_to_screenshot (db_entry, screenshot)
   local ss_month, ss_day, ss_year, ss_hour, ss_minute, ss_second
      = screenshot_info (screenshot);
   local ansel_pre_ss_month = db_entry["preshot_month"];
   local ansel_pre_ss_day = db_entry["preshot day"];
   local ansel_pre_ss_year = db_entry["preshot year"];
   local ansel_pre_ss_hour = db_entry["preshot hour"];
   local ansel_pre_ss_minute = db_entry["preshot minute"];
   local ansel_pre_ss_second = db_entry["preshot second"];
   local ansel_post_ss_month = db_entry["postshot_month"];
   local ansel_post_ss_day = db_entry["postshot day"];
   local ansel_post_ss_year = db_entry["postshot year"];
   local ansel_post_ss_hour = db_entry["postshot hour"];
   local ansel_post_ss_minute = db_entry["postshot minute"];
   local ansel_post_ss_second = db_entry["postshot second"];
   return (time_less_than (ansel_pre_ss_month,
			   ansel_pre_ss_day,
			   ansel_pre_ss_year,
			   ansel_pre_ss_hour,
			   ansel_pre_ss_minute,
			   ansel_pre_ss_second,
			   ss_month,
			   ss_day,
			   ss_year,
			   ss_hour,
			   ss_minute,
			   ss_second)
	   and
	   time_less_than (ss_month,
			   ss_day,
			   ss_year,
			   ss_hour,
			   ss_minute,
			   ss_second,
			   ansel_post_ss_month,
			   ansel_post_ss_day,
			   ansel_post_ss_year,
			   ansel_post_ss_hour,
			   ansel_post_ss_minute,
			   ansel_post_ss_second));
end


-- Gather the available accounts, realms, and characters
local wow_accounts = {};
for account in lfs.dir (wow_accounts_dir) do
   if (account ~= "." and account ~= "..") then
      local account_realms = {};
      local account_dir = wow_accounts_dir .. "/" .. account;
      for realm in lfs.dir (account_dir) do
	 local realm_path = account_dir .. "/" .. realm;
	 if (realm ~= "SavedVariables" and 
	     realm ~= "." and realm ~= ".." and
	     lfs.attributes (realm_path, "mode") == "directory") then
	    local realm_dir = account_dir .. "/" .. realm;
	    local realm_characters = {};
	    for character in lfs.dir (realm_dir) do
	       local character_path = realm_dir .. "/" .. character;
	       if (character ~= "." and character ~= "..") then
		  local saved_variables_dir = character_path .. "/" .. "SavedVariables";
		  local ansel_saved_variables_path = saved_variables_dir .. "/" .. "Ansel.lua";
		  if (lfs.attributes (ansel_saved_variables_path) ~= nil) then
		     local f;
		     print ("about to load: " .. ansel_saved_variables_path);
		     f = loadfile (ansel_saved_variables_path);
		     f();
		     local character_db = AnselPhotoDB;
		     table.insert (realm_characters, { character, character_db });
		  else
		     table.insert (realm_characters, { character });
		  end
	       end
	    end
	    table.insert (account_realms, { realm, realm_characters });
	 end
      end
      table.insert (wow_accounts, { account, account_realms });
   end
end

-- Print all this out
for i = 1, #wow_accounts do
  local account = wow_accounts[i];
  local account_name = account[1];
  local account_dir = wow_accounts_dir .. "/" .. account_name;
  local account_realms = account[2];
  print ("account: " .. account_name);
  for j = 1, #account_realms do
    local realm = account_realms[j];
    local realm_name = realm[1];
    local realm_dir = account_dir .. "/" .. realm_name;
    local realm_characters = realm[2];
    print ("realm: " .. realm_name);
    for k = 1, #realm_characters do
      local character = realm_characters[k];
      local character_name = character[1];
      local character_db = character[2];
      print ("character: " .. character_name);
      if (character_db == nil) then
	 print ("No Ansel data available");
      else 
	 print ("Ansel data available");
      end
    end
 end
end

local wow_screenshots = {};

for file in lfs.dir (wow_screenshot_dir) do
   if (file ~= "." and file ~= "..") then
      table.insert (wow_screenshots, file);
   end
end

print (#wow_screenshots .. " screenshots found");

local month, day, year, hour, minute, second = 
	  screenshot_info ("ScreenShot_042709_134625.jpeg");

print ("month: " .. month);
print ("day: " .. day);
print ("year: " .. year);
print ("hour: " .. hour);
print ("minute: " .. minute);
print ("second: " .. second);
