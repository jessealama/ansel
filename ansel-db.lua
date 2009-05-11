--[[

ansel-db: Manage Ansel databases

--]]

require "lfs";

local wow_directory = "/Applications/World of Warcraft";
local wow_screenshot_dir = wow_directory .. "/" .. "Screenshots";
local wow_accounts_dir = wow_directory .. "/WTF/Account";

function time_less_than_eq (month1, day1, year1, hour1, minute1, second1,
			    month2, day2, year2, hour2, minute2, second2)
   return 
   (
      (year1 < year2) or
      (year1 == year2 and month1 < month2) or
      (year1 == year2 and month1 == month2 and day1 < day2) or
      (year1 == year2 and month1 == month2 and day1 == day2 and hour1 < hour2) or
      (year1 == year2 and month1 == month2 and day1 == day2 and hour1 == hour2 and minute1 < minute2) or
      (year1 == year2 and month1 == month2 and day1 == day2 and hour1 == hour2 and minute1 == minute2 and second1 < second2) or
      (year1 == year2 and month1 == month2 and day1 == day2 and hour1 == hour2 and minute1 == minute2 and second1 == second2)
  )
end

function screenshot_info (screenshot)
   -- Screenshot names are "ScreenShot_MMDDYY_HHMMSS"
   local month  = tonumber (string.sub (screenshot, 12, 13));
   local day    = tonumber (string.sub (screenshot, 14, 15));
   local year   = tonumber (string.sub (screenshot, 16, 17));
   local hour   = tonumber (string.sub (screenshot, 19, 20));
   local minute = tonumber (string.sub (screenshot, 21, 22));
   local second = tonumber (string.sub (screenshot, 23, 24));
   return month, day, year, hour, minute, second;
end

function scan_screenshots ()
   local screenshots = {};
   for screenshot in lfs.dir (wow_screenshot_dir) do
      local screenshot_path = wow_accounts_dir .. "/" .. screenshot;
      if (screenshot ~= "." and 
	  screenshot ~= ".." and
	  lfs.attributes (screenshot_path, "mode") ~= "directory") then
	 local ss_month, ss_day, ss_year, ss_hour, ss_minute, ss_second
	    = screenshot_info (screenshot);
	 table.insert (screenshots, { screenshot, ss_year, ss_month, ss_day, ss_hour, ss_minute, ss_second });
      end
   end
   return screenshots;
end

function db_entry_corresponds_to_screenshot (db_entry, screenshot)
   local ss_month, ss_day, ss_year, ss_hour, ss_minute, ss_second
      = screenshot_info (screenshot);
   local pre_ss_month = db_entry["preshot month"];
   local pre_ss_day = db_entry["preshot day"];
   local pre_ss_year = db_entry["preshot year"];
   local pre_ss_hour = db_entry["preshot hour"];
   local pre_ss_minute = db_entry["preshot minute"];
   local pre_ss_second = db_entry["preshot second"];
   local post_ss_month = db_entry["postshot month"];
   local post_ss_day = db_entry["postshot day"];
   local post_ss_year = db_entry["postshot year"];
   local post_ss_hour = db_entry["postshot hour"];
   local post_ss_minute = db_entry["postshot minute"];
   local post_ss_second = db_entry["postshot second"];
   return (time_less_than_eq (pre_ss_month, pre_ss_day, pre_ss_year,
			      pre_ss_hour, pre_ss_minute, pre_ss_second,
			      ss_month, ss_day, ss_year,
			      ss_hour, ss_minute, ss_second)
	   and
	   time_less_than_eq (ss_month, ss_day, ss_year,
			      ss_hour, ss_minute, ss_second,
			      post_ss_month, post_ss_day, post_ss_year,
			      post_ss_hour, post_ss_minute, post_ss_second));
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
		     lfs.chdir (saved_variables_dir);
		     require 'Ansel';
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

local screenshots = scan_screenshots ();

function build_screenshot_db_correspondences ()
   local num_screenshots = #screenshots;
   local correspondences = {};
   local num_accounts = #wow_accounts;
   for j = 1, num_screenshots do
      local ss_record = screenshots[j];
      local screenshot = ss_record[1];
      for k = 1, num_accounts do
	 local account = wow_accounts[k];
	 local account_name = account[1];
	 local account_dir = wow_accounts_dir .. "/" .. account_name;
	 local account_realms = account[2];
	 local num_account_realms = #account_realms;
	 for l = 1, num_account_realms do
	    local realm = account_realms[l];
	    local realm_name = realm[1];
	    local realm_dir = account_dir .. "/" .. realm_name;
	    local realm_characters = realm[2];
	    local num_realm_characters = #realm_characters;
	    for m = 1, num_realm_characters do
	       local character = realm_characters[m];
	       local character_name = character[1];
	       local character_db = character[2];
	       if (character_db ~= nil) then
		  local num_db_entries = #character_db;
		  for n = 1, num_db_entries do
		     local db_entry = character_db[n];
		     if (db_entry_corresponds_to_screenshot (db_entry, screenshot)) then
			table.insert (correspondences, { screenshot, db_entry });
		     end
		  end
	       end
	    end
	 end      
      end
   end
   return correspondences;
end

function coherent_zones (db_entry) 
   return (db_entry["preshot zone"] == db_entry["postshot zone"]);
end

local correspondences = build_screenshot_db_correspondences ();

function print_correspondences ()
   local num_correspondences = #correspondences;
   for i = 1, num_correspondences do
      local correspondence = correspondences[i];
      local screenshot = correspondence[1];
      local db_entry = correspondence[2];
      if (coherent_zones (db_entry)) then
	 print ("found a coherent match for " .. screenshot);
      else
	 print ("found an incoherent match for " .. screenshot);
      end
   end
end

print_correspondences ();


