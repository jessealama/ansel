--[[

ansel-db: Manage Ansel databases

--]]

require "lfs";

local wow_directory = "/Applications/World of Warcraft";
local wow_accounts_dir = wow_directory .. "/WTF/Account";

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
		  table.insert (realm_characters, character);
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
      print ("character: " .. character);
      local character_dir = realm_dir .. "/" character;
      local saved_variables_dir = character_dir .. "/" .. "SavedVariables";
      local ansel_saved_variables_path = saved_variables_dir .. "/" .. "Ansel.lua";
      if (lfs.attributes (ansel_saved_variables_path) == nil) then
	 print ("No Ansel data available");
      else 
	 print ("Ansel data available");
      end
    end
 end
end
