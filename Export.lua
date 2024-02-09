local PrevLuaExportStart = LuaExportStart
local PrevLuaExportBeforeNextFrame = LuaExportBeforeNextFrame
local PrevLuaExportAfterNextFrame = LuaExportAfterNextFrame
local PrevLuaExportStop = LuaExportStop

package.path  = package.path..";.\\LuaSocket\\?.lua"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll"

local clients = {} -- connected clients
local socket
local server
local logFile
local JSON



-- called on mission start
-- setup socket server
function LuaExportStart()
	logFile = io.open(lfs.writedir().."/Logs/oggi.log", "w")
	socket = require("socket")
	server = socket.bind("*", 8666)
	server:settimeout(0)
	--server:setoption("tcp-nodelay", true)
	server:setoption("keepalive", true)
  JSON = loadfile("Scripts/JSON.lua")()

	oggiLog('socket server started')
	if PrevLuaExportStart then
		PrevLuaExportStart()
	end
end



-- called before each simulation frame
function LuaExportBeforeNextFrame()
	for _, client in pairs(clients) do
    local data, error, something = client:receive('*l')
    if data then
  		oggiLog(data)
  		local args = getArgs(data)
  		local command = args[1]
  		if command == 'c' then
  			local device = args[2]
  			local action = args[3]
  			local parameter = args[4]
  			oggiLog('command: '..command)
  			oggiLog('device: '..device)
  			oggiLog('action: '..action)
  			oggiLog('parameter: '..parameter)
				local result = GetDevice(device):performClickableAction(action, parameter)
				oggiLog(result)
  		end
  		if command == 'g' then
  			local device = args[2]
  			local action = args[3]
  			oggiLog('command: '..command)
  			oggiLog('device: '..device)
  			oggiLog('action: '..action)
				local result = GetDevice(device):get_argument_value(action)
				if result ~= nil then
					client:send(data..'response:'..result)
				end
				oggiLog(result)
  		end
  		if command == 'l' then
  			local device = args[2]
  			oggiLog('command: '..command)
  			oggiLog('device: '..device)
				local result = list_indication(device)
				if result ~= nil then
					client:send(data..'response:'..result)
				end
				oggiLog(data..'response:'..result)
  		end
  		if command == 'bg' then
  			local buttonsAndSwitches = strsplit(args[2],',')
				local result = 'bulkGaugesresponse:'
				if buttonsAndSwitches ~= nil then
					for key,thing in pairs(buttonsAndSwitches) do
						result = result..thing..':'..GetDevice(device):get_argument_value(thing)..','
					end
				end
					client:send(result)
  		end
    end
  end
	if PrevLuaExportBeforeNextFrame then
		PrevLuaExportBeforeNextFrame()
	end
end



-- called after each simulation frame
function LuaExportAfterNextFrame()
	acceptClient()

	if PrevLuaExportAfterNextFrame then
		PrevLuaExportAfterNextFrame()
	end
end



-- called on mission end
-- close socket server
function LuaExportStop()
	socket.protect(function()
		for _, client in pairs(clients) do
			socket.try(client:close())
			clients[client] = nil
		end
	end)

	if PrevLuaExportStop then
		PrevLuaExportStop()
	end
end



-- accept new client
function acceptClient()
	local client = server:accept()
	if client then
		oggiLog('connection accepted')
		client:settimeout(0)
		client:setoption("tcp-nodelay", true)
		client:setoption("keepalive", true)
		--clients[#clients+1] = client
		table.insert(clients,client)
		local result, error, something = client:send('welcome')
	end
end



function oggiLog(msg)
  --logFile:write(string.format("%8.3f %s\r\n", LoGetModelTime(), msg))
end

function getArgs(s)
  local i = 1
  local list = {}
  s:gsub("[^%s]+", function(s) list[i] = s; i = i + 1 end)
  return list
end

function strsplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end