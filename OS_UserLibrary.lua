require("user.secrets")

-- S is the private package, exposed as 'sprinkler' library
local S = {}
sprinkler = S

------------------------------
     -- User Settings --
------------------------------

-- NAC User Param application
local CBUS_USERPARAM_NAME_WL = "Water Level"
local CBUS_USERPARAM_NAME_DEBUGLOGGING = "Debug Logging"
local CBUS_USERPARAM_NAME_Z1_STATUS = "Irrigation Zone 1"
local CBUS_USERPARAM_NAME_Z2_STATUS = "Irrigation Zone 2"
local CBUS_USERPARAM_NAME_Z3_STATUS = "Irrigation Zone 3"

-- NAC Irrigation Zone Mappings
--local CBUS_ZONE_GROUPS = { 160, 161, 162 }

-- The IP address of the OpenSprinkler Device
local OS_IP = "192.168.1.119"

-- Password
local os_pw = secrets.opensprinklerpw

------------------------------
       -- Utilities --
------------------------------

-- Debugging Functions

local function isDebuggingEnabled()
  return toboolean( GetUserParam(0, CBUS_USERPARAM_NAME_DEBUGLOGGING) )
end

local function debuglog(str)
  if ( isDebuggingEnabled() ) then
    log(str)
  end
end

-- Utility Function to check if variable is empty
function isempty(s)
  return s == nil or s == ''
end

------------------------------
      -- OS Functions --
------------------------------

local http = require("socket.http")
local json = require("json")

-- Get data from the specified API endpoint
function S.Get(endpoint)
	local result,content,header = http.request('http://' .. OS_IP .. '/' .. endpoint .. '?pw=' .. os_pw)
  return result
end

-- Get Options

function S.GetSystemOptions() 
  local result = {}
  local httpresult = S.Get("jo")
  debuglog(httpresult)
  local httptable = json.decode(httpresult)
  result["waterlevel"] = ( httptable["wl"] )
  return result
end

-- Get Station Status
function S.GetStationStatus() 
  local result = {}
  local httpresult = S.Get("js")
  local httptable = json.decode(httpresult)
  result["status"] = ( httptable["sn"] )
  debuglog(httptable)
  return result
end

------------------------------
    -- Resident Script --
------------------------------

function S.Resident_Poll()
	-- Get Water Level for the day
	spr = sprinkler.GetSystemOptions()
	SetUserParam(0, CBUS_USERPARAM_NAME_WL, tostring(spr["waterlevel"])) 
	
	-- Get station status
	stn = sprinkler.GetStationStatus()
	SetUserParam(0, CBUS_USERPARAM_NAME_Z1_STATUS, stn["status"][1]) 
	SetUserParam(0, CBUS_USERPARAM_NAME_Z2_STATUS, stn["status"][2]) 
	SetUserParam(0, CBUS_USERPARAM_NAME_Z3_STATUS, stn["status"][3]) 	
	
end