local names = {}

minetest.register_chatcommand("ignore", {
    func = function(param)
      minetest.run_server_chatcommand("msg", param .." I have put you on my ignore list. I will only receive PMs from you")
      names[tostring(param)] = true
    end})

minetest.register_chatcommand("unignore", {
    func = function(param)
      minetest.run_server_chatcommand("msg", param .." You are no longer on my ignore list")
      names[tostring(param)] = false
    end})

if not minetest.register_on_receiving_chat_message then
    minetest.register_on_receiving_chat_message = minetest.register_on_receiving_chat_messages
end

minetest.register_on_receiving_chat_messages(function(msg)
    local name = string.split(msg, ">")[1]
    name = string.sub("test".. name, 6)
    if name ~= nil then
      return names[name]
    end
  end)

