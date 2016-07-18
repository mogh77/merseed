-- data saved to moderation.json
-- check moderation plugin

-- make sure to set with value that not higher than stats.lua
local NUM_MSG_MAX = 3
local TIME_CHECK = 4 -- seconds

local function create_group(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin(msg) then
    return "You're not admin!"
  end
  local group_creator = msg.from.print_name
  create_group_chat (group_creator, group_name, ok_cb, false)
	return 'Group '..string.gsub(group_name, '_', ' ')..' has been created.'
end

local function set_description(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'description'
	data[tostring(msg.to.id)][data_cat] = deskripsi
	save_data(_config.moderation.data, data)
	return 'Set group description to:\n'..deskripsi
end

local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
		return 'No description available.'
	end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'About '..about
end

local function export_chat_link_callback(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local chat_id = cb_extra.chat_id
  local group_name = cb_extra.group_name
  if success == 0 then
    return send_large_msg(receiver, "Can't generate invite link for this group")
  end
  data[tostring(chat_id)]['link'] = result
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver,'Newest generated invite link for '..group_name..' is:\n'..result)
end

local function set_rules(msg, data)
  vardump(data)
  vardump(msg)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'rules'
	data[tostring(msg.to.id)][data_cat] = rules
	save_data(_config.moderation.data, data)
	return 'Set group rules to:\n'..rules
end

local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
		return 'No rules available.'
	end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = string.gsub(msg.to.print_name, '_', ' ')..' rules:\n\n'..rules
  return rules
end

-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
  local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'yes' then
	  return 'Group name is already locked'
	else
	  data[tostring(msg.to.id)]['settings']['lock_name'] = 'yes'
	  save_data(_config.moderation.data, data)
	  data[tostring(msg.to.id)]['settings']['set_name'] = string.gsub(msg.to.print_name, '_', ' ')
	  save_data(_config.moderation.data, data)
	  return 'Group name has been locked'
	end
end

local function unlock_group_name(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
  local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'no' then
	  return 'Group name is already unlocked'
	else
	  data[tostring(msg.to.id)]['settings']['lock_name'] = 'no'
	  save_data(_config.moderation.data, data)
	  return 'Group name has been unlocked'
	end
end

--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'yes' then
	  return 'Group members are already locked'
	else
	  data[tostring(msg.to.id)]['settings']['lock_member'] = 'yes'
	  save_data(_config.moderation.data, data)
	end
	return 'Group members has been locked'
end

local function unlock_group_member(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'no' then
	  return 'Group members are not locked'
	else
	  data[tostring(msg.to.id)]['settings']['lock_member'] = 'no'
	  save_data(_config.moderation.data, data)
	  return 'Group members has been unlocked'
	end
end

--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'yes' then
	  return 'Group photo is already locked'
	else
	  data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	  save_data(_config.moderation.data, data)
	end
	return 'Please send me the group photo now'
end

local function unlock_group_photo(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'no' then
	  return 'Group photo is not locked'
	else
	  data[tostring(msg.to.id)]['settings']['lock_photo'] = 'no'
	  save_data(_config.moderation.data, data)
	  return 'Group photo has been unlocked'
	end
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    chat_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end
-- show group settings
local function show_group_settings(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local settings = data[tostring(msg.to.id)]['settings']
  local text = "Group settings:\nLock group name : "..settings.lock_name.."\nLock group photo : "..settings.lock_photo.."\nLock group member : "..settings.lock_member
  return text
end

--lock/unlock spam protection
local function lock_group_spam(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
    local group_spam_lock = data[tostring(msg.to.id)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'Spam protection already enabled'
  else
    data[tostring(msg.to.id)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'Spam protection has been enabled'
end

local function unlock_group_spam(msg, data)
  if not is_mod(msg) then
    return "For moderators only!"
  end
  local group_spam_lock = data[tostring(msg.to.id)]['settings']['lock_spam']
	if group_spam_lock == 'no' then
    return 'Spam protection is not enabled'
	else
    data[tostring(msg.to.id)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
	return 'Spam protection has been disabled'
	end
end

local function is_anti_spam(msg)
	local data = load_data(_config.moderation.data)
	local group_spam_lock = data[tostring(msg.to.id)]['settings']['lock_spam']
	if group_spam_lock == 'yes' then
    return true
	else
		return false
	end
end

local function pre_process(msg)
  -- media handler
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end

  --vardump(msg)
  if msg.action and msg.action.type then
    local action = msg.action.type
    local receiver = get_receiver(msg)
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
      local settings = data[tostring(msg.to.id)]['settings']
      if action == 'chat_rename' then
        local group_name_set = settings.set_name
        local group_name_lock = settings.lock_name
        local to_rename = 'chat#id'..msg.to.id
        if group_name_lock == 'yes' then
          if group_name_set ~= tostring(msg.to.print_name) then
            rename_chat(to_rename, group_name_set, ok_cb, false)
          end
        elseif group_name_lock == 'no' then
          return nil
        end
      end
      if action == 'chat_add_user' or action == 'chat_add_user_link' then
        if msg.action.link_issuer then
          user_id = 'user#id'..msg.from.id
        else
          user_id = 'user#id'..msg.action.user.id
        end
        if action == 'chat_add_user' and msg.action.user.flags == 4352 and msg.from.id ~= 0 then -- Anti Bot !! to prevent Spammers
          chat_del_user(receiver, user_id, ok_cb, true)
        end
        local group_member_lock = settings.lock_member
        if group_member_lock == 'yes' and msg.from.id ~= 0 then
          chat_del_user(receiver, user_id, ok_cb, true)
        end
      end
      if action == 'chat_delete_photo' then
        local group_photo_lock = settings.lock_photo
        if group_photo_lock == 'yes' then
          chat_set_photo(receiver, settings.set_photo, ok_cb, false)
        end
      end
      if action == 'chat_change_photo' and msg.from.id ~= 0 then
        local group_photo_lock = settings.lock_photo
        if group_photo_lock == 'yes' then
          chat_set_photo(receiver, settings.set_photo, ok_cb, false)
        end
      end
      return msg
    end
  end
	local hash = 'floodc:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
	if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id..':floodc'
    local msgs = tonumber(redis:get(hash) or 0)
    if msgs > NUM_MSG_MAX then
      if is_anti_spam(msg) and not is_momod(msg) then
        send_large_msg(get_receiver(msg), 'Don\'t spam!')
        chat_del_user(receiver, 'user#id'..msg.from.id, ok_cb, true)
        msg = nil
      end
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
  end
	return msg
end

function run(msg, matches)
  --vardump(msg)

  -- media handler
  if msg.media then
    if msg.media.type == 'document' then
      print('Document file')
    end
    if msg.media.type == 'photo' then
      print('Photo file')
    end
    if msg.media.type == 'video' then
      print('Video file')
    end
    if msg.media.type == 'audio' then
      print('Audio file')
    end
  end

  -- create group
  if matches[1] == 'group' and matches[2] == 'create' and matches[3] then
    group_name = matches[3]
    return create_group(msg)
  end

  if not is_chat_msg(msg) then
	  return "This is not a group chat."
	end
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if msg.media then
  	if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_chat_msg(msg) and is_mod(msg) then
  		load_photo(msg.id, set_group_photo, msg)
  	end
  end

  if data[tostring(msg.to.id)] then
		local settings = data[tostring(msg.to.id)]['settings']

    -- group {about|rules|settings}
    if matches[1] == 'group' then
      if matches[2] == 'about' then
        return get_description(msg, data)
      end
      if matches[2] == 'rules' then
        return get_rules(msg, data)
      end
      if matches[2] == 'settings' then
        return show_group_settings(msg, data)
      end
    end

    -- group link {get|revoke}
    if matches[1] == 'group' and matches[2] == 'link' then
      if matches[3] == 'get' and is_mod(msg) then
        if data[tostring(msg.to.id)]['link'] then
          local link = data[tostring(msg.to.id)]['link']
          return link
        else
          local chat = 'chat#id'..msg.to.id
          msgr = export_chat_link('chat#id'..msg.to.id, export_chat_link_callback, {receiver=receiver, data=data, chat_id=msg.to.id})
        end
      end
      if matches[3] == 'revoke' and is_mod(msg) then
        local chat = 'chat#id'..msg.to.id
        msgr = export_chat_link('chat#id'..msg.to.id, export_chat_link_callback, {receiver=receiver, data=data, chat_id=msg.to.id, group_name=msg.to.print_name})
      end
	  end

    -- group set {about|rules|name|photo}
    if matches[1] == 'group' and matches[2] == 'set' then
      if matches[3] == 'about' and is_mod(msg) then
        deskripsi = matches[4]
        return set_description(msg, data)
      end
      if matches[3] == 'rules' and is_mod(msg) then
        rules = matches[4]
        return set_rules(msg, data)
      end
      if matches[3] == 'name' and is_mod(msg) then
        local new_name = string.gsub(matches[4], '_', ' ')
        data[tostring(msg.to.id)]['settings']['set_name'] = new_name
        save_data(_config.moderation.data, data)
        local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
        local to_rename = 'chat#id'..msg.to.id
        rename_chat(to_rename, group_name_set, ok_cb, false)
      end
      if matches[3] == 'photo' and is_mod(msg) then
        data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	      save_data(_config.moderation.data, data)
	      return 'Please send me new group photo now'
      end
	  end

    -- group lock {name|member|photo}
    if matches[1] == 'group' and matches[2] == 'lock' then
      if matches[3] == 'name' then
        return lock_group_name(msg, data)
      end
      if matches[3] == 'member' then
        return lock_group_member(msg, data)
      end
      if matches[3] == 'photo' then
        return lock_group_photo(msg, data)
      end
      if matches[3] == 'spam' then
        return lock_group_spam(msg, data)
      end
    end

    -- group unlock {name|member|photo}
    if matches[1] == 'group' and matches[2] == 'unlock' then
      if matches[3] == 'name' then
        return unlock_group_name(msg, data)
      end
      if matches[3] == 'member' then
        return unlock_group_member(msg, data)
      end
      if matches[3] == 'photo' then
        return unlock_group_photo(msg, data)
      end
      if matches[3] == 'spam' then
        return unlock_group_spam(msg, data)
      end
    end

    -- if group name is renamed
    if matches[1] == 'chat_rename' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_name_set = settings.set_name
      local group_name_lock = settings.lock_name
      local to_rename = 'chat#id'..msg.to.id
      if group_name_lock == 'yes' then
        if group_name_set ~= tostring(msg.to.print_name) then
          rename_chat(to_rename, group_name_set, ok_cb, false)
        end
      elseif group_name_lock == 'no' then
        return nil
      end
    end

    -- if a user added to group
    if matches[1] == 'chat_add_user' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_member_lock = settings.lock_member
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      if group_member_lock == 'yes' then
        chat_del_user(chat, user, ok_cb, true)
      elseif group_member_lock == 'no' then
        return nil
      end
    end

    -- if group photo is removed
    if matches[1] == 'chat_delete_photo' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end

    -- if group photo is changed
    if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end
  end
end

return {
  description = "Plugin to manage group chat.",
  usage = {
    user = {
    "!group about : Read group description",
    "!group rules : Read group rules",
    "!group link get : Get invite link",
    },
    moderator = {
    "!group create <group_name> : Create a new group (admin only)",
    "!group link revoke : Revoke invite link",
    "!group create <group_name> : Create a new group (admin only)",
    "!group set rules <rules> : Set group rules",
    "!group set name <new_name> : Set group name",
    "!group set photo : Set group photo",
    "!group <lock|unlock> name : Lock/unlock group name",
    "!group <lock|unlock> photo : Lock/unlock group photo",
    "!group <lock|unlock> member : Lock/unlock group member",
    "!group <lock|unlock> spam : Enable/disable spam protection",
    "!group settings : Show group settings"
    },
  },
  patterns = {
  "^!(group) (create) (.*)$",
  "^!(group) (link) (get)$",
  "^!(group) (link) (revoke)$",
  "^!(group) (set) (about) (.*)$",
  "^!(group) (about)$",
  "^!(group) (set) (rules) (.*)$",
  "^!(group) (rules)$",
  "^!(group) (set) (name) (.*)$",
  "^!(group) (set) (photo)$",
  "^!(group) (lock) (.*)$",
  "^!(group) (unlock) (.*)$",
  "^!(group) (settings)$",
  "^!!tgservice (.+)$",
  "%[(photo)%]",
  '%[(document)%]',
  '%[(photo)%]',
  '%[(video)%]',
  '%[(audio)%]'
  },
  run = run,
  hide = true,
  pre_process = pre_process
}