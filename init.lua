--Variables     Line 8
--Compatability Line 15
--Functions     Line 20
--Setup on Join Line 75
--Chatcommands  Line 95
--Catching MSGs Line 153
 
--Variables
local modstorage = core.get_mod_storage()
local bpriority = 1
local inform = 0
local blocked = {}
local names = {}
 
--Compatability
if not minetest.register_on_receiving_chat_message then
    minetest.register_on_receiving_chat_message = minetest.register_on_receiving_chat_messages
end
 
--Functions
local informmsg = function(msg)
    if inform == 1 then
        minetest.run_server_chatcommand("msg",msg)
    end
end
 
local findname = function(msg,id)
    local temp
    if string.sub(msg,1,8) == "PM from " and id == 0 then
        temp = string.split(msg,":")[1]
        return string.sub(temp,-10,-1)
    elseif string.sub(string.split(msg,":")[1],-9) == " whispers" and id == 0 then
        return string.sub(string.split(msg,":")[1],1,-10)
    else
        temp = "test"..string.split(msg,">")[1]
        return string.sub(temp,6)
    end
end
 
local add_block = function(name)
    if not blocked[name] then
        blocked[name] = true
        if modstorage:get_string("blocked") ~= "" then
            modstorage:set_string("blocked",modstorage:get_string("blocked")..">"..name)
        else
            modstorage:set_string("blocked",name)
        end
    end
end
 
local remove_block = function(name)
    if blocked[name] then
        blocked[name] = false
        local blockedp = ""
        for i,nameold in pairs(string.split(modstorage:get_string("blocked"),">",false,-1,false)) do
            if nameold ~= name then
                blockedp = blockedp..">"..nameold
            end
        end
        modstorage:set_string("blocked",string.sub(blockedp,2))
    end
end
 
local showblocked = function(id)
    if id <= bpriority then
        if modstorage:get_string("blocked") ~= "" then
            minetest.display_chat_message(minetest.colorize("red","Blocked People:"))
            for i,name in pairs(string.split(modstorage:get_string("blocked"),">",false,-1,false)) do
                    minetest.display_chat_message(minetest.colorize("red",name))
            end
        end
    end
end
 
--Setting up the blocklist and the informsetting after joining
minetest.register_on_connect(function()
    if modstorage:get_string("setup") == "" then
        modstorage:set_int("inform",1)
        modstorage:set_int("bpriority",1)
        modstorage:set_string("blocked","")
        modstorage:set_string("setup","done")
    end
    inform = modstorage:get_int("inform")
    bpriority = modstorage:get_int("bpriority")
    if modstorage:get_string("blocked") ~= "" then
        for i,name in pairs(string.split(modstorage:get_string("blocked"),">",false,-1,false)) do
            blocked[name] = true
        end
    end
    minetest.after(1,function()
        showblocked(1)
    end)
end)
 
--Chatcommands
minetest.register_chatcommand("priority",{
description = "Default: Show current priority|1: Show Blocklist only on Join|2: Show Blocklist on Join and when unblocking|3: Showb Blocklist on Blocking,Unblockung and on Join",
func = function(param)
    if param == "" then
        minetest.display_chat_message("Priority: "..bpriority)
    elseif tonumber(param) ~= nil then
        if tonumber(param) > 0 and tonumber(param) < 4 then
            bpriority = tonumber(param)
            modstorage:set_int("bpriority",bpriority)
        end
    end
end})
 
minetest.register_chatcommand("block",{
description = "Default: Show blocklist|Otherwise block Player",
func = function(param)
    if param == "" then
        showblocked(1)
    else
        add_block(param)
        showblocked(3)
    end
end})
 
minetest.register_chatcommand("unblock",{
func = function(param)
    remove_block(param)
    showblocked(2)
end})
 
minetest.register_chatcommand("ignore",{
func = function(param)
            informmsg(param.." I have put you on my ignore list. I will only receive PMs from you")
            names[tostring(param)] = true
       end
})
 
minetest.register_chatcommand("unignore",{
func = function(param)
            informmsg(param.." You are no longer on my ignore list")
            names[tostring(param)] = false
       end
})
 
minetest.register_chatcommand("inform",{
    func = function()
        if inform == 0 then
            minetest.display_chat_message("Inform on")
            modstorage:set_int("inform",1)
            inform = 1
        else
            minetest.display_chat_message("Inform off")
            modstorage:set_int("inform",0)
            inform = 0
        end
end})
 
--Catching the chatmessagess of ignored/blocked players
minetest.register_on_receiving_chat_message(function(msg)
    local bname = findname(msg,0)
    local iname = findname(msg,1)
    if iname ~= nil then
        return names[iname] or blocked[bname]
    end
end)
