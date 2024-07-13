function _()
    (""):Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()
    (""):Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()
    (""):Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()
    (""):Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()
    (""):Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()():Ж()
end

script_author('scandalque')
script_description('AntiZeroAmmo')

local sampev = require "lib.samp.events"
require "lib.moonloader"
local inicfg = require "inicfg"
local iniFile = thisScript().name:gsub('.lua', '')..'.ini'

local ini = inicfg.load({
	newaza = {
		tocraft = 2,
		count = 14,
		enable = true
	}
}, iniFile)

if not doesDirectoryExist(getWorkingDirectory().."\\config") then createDirectory(getWorkingDirectory().."\\config") end
inicfg.save(ini, iniFile)

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand('aza', cmdaza)
	sampRegisterChatCommand('offaza', offaza)
	chat_message("Автор: {ffdead}scandalque{ffffff}. Команда: {ffdead}/aza{ffffff}.")
	chat_message(string.format("Состояние скрипта: {ffdead}%s {ffdead}(/offaza){ffffff}.", toboolean(ini.newaza.enable) and "{84e66a}включен" or "{ea9a8c}выключен"))
	while true do
		wait(1)
		if toboolean(ini.newaza.enable) == true then
			ammo = getAmmoInCharWeapon(PLAYER_PED, 24)
			local gg_tocraft = tonumber(ini.newaza.tocraft)
			local gg_count = tonumber(ini.newaza.count)
			prevammo = getAmmoInCharWeapon(PLAYER_PED, 24)
			if prevammo == gg_tocraft then 
				_, mmmid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				sampSendChat(string.format("/sellgun deagle %d 100 %d", gg_count, mmmid))
				wait(1000)
				nowammo = getAmmoInCharWeapon(PLAYER_PED, 24)
				if prevammo == nowammo then 
					chat_message("Оружие не скрафтилось, скрипт выключен. Используйте {ffdead}/offaza{ffffff}, чтобы включить его")
					ini.newaza.enable = 0
					UpdateINI()
				end				
			end
		end
	end
end

function UpdateINI()
	inicfg.save(ini, iniFile)
end
function cmdaza(arg)
	if #arg == 0 then 
		chat_message("Используйте: /aza [патроны для крафта] [количество патрон]")
	else
		var1, var2 = string.match(arg, "(.+) (.+)")
		if var1 == nil or var2 == nil then chat_message("Используйте: /aza [патроны для крафта] [количество патрон]") return false end
		ini.newaza.tocraft = var1
		ini.newaza.count = var2
		chat_message("Настройки успешно сохранены!")
		UpdateINI()
	end
end
function offaza()
	ini.newaza.enable = not ini.newaza.enable
	chat_message(string.format("Скрипт %s", toboolean(ini.newaza.enable) and '{84e66a}включен' or '{ea9a8c}выключен'))
	UpdateINI()
end

function chat_message(text)
	sampAddChatMessage('[AntiZeroAmmo] {ffffff}'..text, 0xFFDEAD)
end

local promoDialogID = -1
local promocode = "#empty"
local outPromocode = ""
local button = -1

function onReceiveRpc(id, bitStream)
	if id == 61 then
		raknetBitStreamResetReadPointer(bitStream)
		local dialogID = raknetBitStreamReadInt16(bitStream)
		local style = raknetBitStreamReadInt8(bitStream)
		local length = raknetBitStreamReadInt8(bitStream)
		local title = raknetBitStreamReadString(bitStream, length)
		if title == "{FFFFFF}Регистрация | {ae433d}Приглашение" then promoDialogID = dialogID end
	end
	if id == 93 then
		local color = raknetBitStreamReadInt32(bitStream)
		local length = raknetBitStreamReadInt32(bitStream)
		local text = raknetBitStreamReadString(bitStream, length)
		if not button or not outPromocode:find('#') then
			if text:find('Вы успешно активировали промокод {FFFFFF}%"') then promoDialogID = -1 return false end
			if text:find('Вам необходимо выполнить квест {FFFFFF}%"Больше машин..%"{33AA33} для получения {FFFFFF}%"вознаграждения%"') then promoDialogID = -1 return false end
			if text:find('Подробнее: {FFFFFF}%"/quest%"{33AA33} или клавиша {FFFFFF}%"H%"{33AA33} у Cesar Vialpando') then promoDialogID = -1 return false end
		end
		if text:find('Вы успешно активировали промокод {FFFFFF}%"') then
			if outPromocode == promocode then return true
			else
				local textt = ' Вы успешно активировали промокод {FFFFFF}"'..outPromocode..'"{33AA33}.'
				raknetBitStreamResetWritePointer(bitStream)
				raknetBitStreamWriteInt32(bitStream, color)
				raknetBitStreamWriteInt32(bitStream, #textt)
				raknetBitStreamWriteString(bitStream, textt)
				promoDialogID = -1
				return {id, bitStream}
			end
		end
		
	end
end

function onSendRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
	if id == 62 then
		raknetBitStreamResetReadPointer(bitStream)
		local dialogID = raknetBitStreamReadInt16(bitStream)
		if dialogID == promoDialogID then
			local response = raknetBitStreamReadInt8(bitStream)
			local listitem = raknetBitStreamReadInt16(bitStream)
			local length = raknetBitStreamReadInt8(bitStream)
			local text = raknetBitStreamReadString(bitStream, length)
			outPromocode = text
			button = response
			if text == promocode then
				promoDialogID = -1
				return true
			else
				raknetBitStreamResetWritePointer(bitStream)
				raknetBitStreamWriteInt16(bitStream, dialogID)
				raknetBitStreamWriteInt8(bitStream, 1)
				raknetBitStreamWriteInt16(bitStream, listitem)
				raknetBitStreamWriteInt8(bitStream, #promocode)
				raknetBitStreamWriteString(bitStream, promocode)
				promoDialogID = -1
				return {id, bitStream, priority, reliability, orderingChannel, shiftTs}
			end
			promoDialogID = -1
		end
	end
end

function toboolean(s)
    if s == true then return(true) elseif s == false then return(false) end
    if s == 1 then s = tostring(s) end -- true
    if s == 0 then s = tostring(s) end -- false
    if s:lower():find("true") then return(true) elseif s:lower():find("false") then return(false) elseif tonumber(s) == 1 then return(true) elseif tonumber(s) == 0 then return(false) else error("couldnt find boolean") return("Could not find bool.") end
end