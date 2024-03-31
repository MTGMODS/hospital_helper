---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local

script_name("Hospital Helper")
script_description('Cross-platform script helper for Medical Center')
script_author("MTG MODS")
script_version("3.1 Beta")
script_properties("work-in-pause")

require('lib.moonloader')
require ('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')
local sampev = require('samp.events')

-------------------------------------------- JSON SETTINGS ---------------------------------------------

local settings = {}
local default_settings = {
	general = {
		version = thisScript().version,
		expel_reason = 'Н.П.Б.',
		accent_enable = true,
		anti_trivoga = true,
		heal_in_chat = false,
		auto_uval = false,
		rp_chat = true,
		moonmonet_theme_enable = true,
		moonmonet_theme_color = 16742777,
		bind_mainmenu = '[113]',
		bind_fastmenu = '[69]',
		bind_leader_fastmenu = '[71]',
		bind_healme = '[114]',
		bind_fastheal = '[13]',
	},
	player_info = {
		name_surname = '',
		accent = '[Иностранный акцент]:',
		fraction = 'Не имеется',
		fraction_tag = 'Неизвестно',
		fraction_rank = 'Неизвестно',
		fraction_rank_number = 0,
		sex = 'Неизвестно',
	},
	price = {
		ant = 50000,
		recept = 50000,
		heal = 20000,
		heal_vc = 100,
		healactor = 400000,
		healactor_vc = 1000,
		medosm = 400000,
		mticket = 3400000,
		tatu = 400000,
		med7 = 50000,
		med14 = 100000,
		med30 = 150000,
		med60 = 200000,
	},
	note = {
		
		{ note_name = 'Заметка №1', note_text = 'Вы можете указывать у себя в заметках абсолюто любую информацию!&Ваши заметки будут сохранены и доступны в любое время!' },
		
		
		
	},
	commands = {
	
		{ cmd = 'zd' , description = 'Привествие игрока' , text = 'Здраствуйте, я {my_ru_nick} - {fraction_rank} {fraction_tag}.&Чем я могу вам помочь?', arg = '' , enable = true , waiting = '1.500'  },
		
		{ cmd = 'go' , description = 'Позвать игрока за собой' , text = 'Хорошо {get_ru_nick({arg_id})}, следуйте за мной.', arg = '{arg_id}' , enable = true, waiting = '1.500'  },
		
		{ cmd = 'cure' , description = 'Поднять игрока из стадии' ,  text = '/me наклоняется над человеком, затем прощупывает пульс на сонной артерии&/do Пульс отсутствует.&/cure {arg_id}&/me начинает делать человеку непрямой массаж сердца, время от времени проверяя пульс&/do Спустя несколько минут сердце человека началось биться.&/do Человек пришел в сознание.&/todo Отлично*улыбаясь' , arg = '{arg_id}' , enable = true , waiting = '1.500' },
		
		{ cmd = 'gd' , description = 'Экстренный вызов (/godeath)' ,  text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me просматривает информацию и включает навигатор к выбранному месту экстренного вызова&/godeath {arg_id}' , arg = '{arg_id}' , enable = true, waiting = '1.500'  },
	
		{ cmd = 'hl' , description = 'Обычное лечение игроков' , text = '/me достаёт из своего мед.кейса нужное лекарство и передаёт его человеку напротив&/todo Принимайте это лекарство, оно вам поможет*улыбаясь&/heal {arg_id} {price_heal}', arg = '{arg_id}' , enable = true, waiting = '1.500'  },
		
		{ cmd = 'hme' , description = 'Лечение самого себя' ,  text = '/me достаёт из своего мед.кейса лекарство и принимает его&/heal {my_id} {price_heal}' , arg = '' , enable = true, waiting = '1.500' },
		
		{ cmd = 'hla' , description = 'Лечение охранника игрока' ,  text = '/me достаёт из своего мед.кейса лекарство и передаёт его человеку напротив&/todo Давайте своему охраннику это лекарство, оно ему поможет*улыбаясь&/healactor {arg_id} {price_actorheal}' , arg = '{arg_id}' , enable = true , waiting = '1.500' },
		
		{ cmd = 'hlb' , description = 'Лечение игрока от наркозависимости' ,  text = '/me достаёт из своего мед.кейса таблетки от наркозависимости и передаёт их пациенту напротив&/todo Принимайте эти таблетки, и в скором времени Вы излечитесь от наркозависимости*улыбаясь&/healbad {arg_id}' , arg = '{arg_id}' , enable = true , waiting = '1.500' },
		
		{ cmd = 'medin' , description = 'Оформление мед.страховки игроку' ,  text = 'Для оформления мед.страховки Вам необходимо оплатить определнную cумму.&Стоимость зависит от срока действия будущей мед.страховки.&На 1 неделю - $4ОО.ООО. На 2 недели - $8ОО.ООО. На 3 недели - $1.2ОО.ООО.&И так, скажите, на какой срок Вам оформить мед.страховку?&/me достаёт из своего мед.кейса пустой бланк мед.страховки, ручку и печать {fraction_tag}&/me открывает бланк мед.страховки и начинает его заполнять, затем ставит печать {fraction_tag}&/me полностю заполнив бланк мед.страховки убирает ручку и печать обратно в свой мед.кейс&/givemedinsurance {arg_id}&/todo Вот ваша мед.страховка, берите*протягивая бланк с мед.страховкой человеку напротив себя' , arg = '{arg_id}' , enable = true, waiting = '1.500'  },
		
		{ cmd = 'expel' , description = 'Выгнать игрока из больницы' ,  text = 'Вы больше не можете здесь находиться, я выгоняю вас из больницы!&/me схватив человека ведёт к выходу из больницы и закрывает за ним дверь&/expel {arg_id} {expel_reason}' , arg = '{arg_id}' , enable = true , waiting = '1.500' },
		
		{ cmd = 'unstuff' , description = 'Удаление татуировки у игрока' ,  text = 'Хорошо, сейчас я удалю ваши татуировки.&/do Аппарат для выведения тату находится в правом кармане.&/me засовывает руку в карман и достаёт из него аппарат для выведения тату&/do Аппарат в правой руке.&/me держа аппарат в руках осмотривает пациента&/me начинает аппаратом выводить татутировки с тела пациента&/unstuff {arg_id} {price_tatu}&/me закончив процесс выведения татуировки выключает аппрарат и убирает его в карман' , arg = '{arg_id}' , enable = true, waiting = '1.500'  },
		
		{ cmd = 'mt' , description = 'Мед.обследования для военного билета' ,  text = 'Хорошо, сейчас я проведу вам мед.обследование для получения военного билета&/me достаёт из мед.кейса стерильные перчатки и надевает их на руки&/do Перчатки на руках.&/todo Начнём мед.обследование*улыбаясь.&/mticket {arg_id} {price_mticket}&/n {get_nick({arg_id})}, примите предложение в /offer для продолжения мед.обследования!' , arg = '{arg_id}' , enable = true, waiting = '1.500'  },

		{ cmd = 'pilot' , description = 'Мед.осмотр для пилотов' ,  text = 'Хорошо, сейчас я проведу вам мед.осмотр для пилотов.&/medcheck {arg_id} {price_medosm}&/n {get_nick({arg_id})}, примите предложение в /offer для продолжения мед.осмотра!&/n Пока вы не примите предложение, мы не сможем начать!&/me достаёт из мед.кейса стерильные перчатки и надевает их на руки&/do Перчатки на руках.&/todo Начнём мед.осмотр*улыбаясь.&Сейчас я проверю ваше горло, откройте рот и высуните язык.&/me достаёт из мед.кейса фонарик и включив его осматривает горло человека напротив&Хорошо, можете закрывать рот, сейчас я проверю ваши глаза.&/me проверяет реакцию человека на свет, посветив фонарик в глаза&/do Зрачки глаз обследуемого человека сузились.&/todo Отлично*выключая фонарик и убирая его в мед.кейс&Такс, сейчас я проверю ваше сердцебиение, поэтому приподнимите верхную одежду!&/me достаёт из мед.кейса стетоскоп и приложив его к груди человека проверяет сердцебиение&/do Сердцебиение в районе 65 ударов в минуту.&/todo С сердцебиением у вас все в порядке*убирая стетоскоп обратно в мед.кейс&/me снимает со своих рук использованные перчатки и выбрасывает их&Ну что-ж я могу вам сказать, со здоровьем у вас все в порядке, вы свободны!' , arg = '{arg_id}' , enable = true, waiting = '1.500'  },
	
	},
	commands_manage = {
	
		{ cmd = 'inv' , description = 'Принятие игрока в фракцию' , text = '/do В кармане халата есть связка с ключами от раздевалки.&/me достаёт из халата один ключ из связки ключей от раздевалки&/todo Возьмите, это ключ от нашей раздевалки*передавая ключ человеку напротив&/invite {arg_id}' , arg = '{arg_id}', enable = true, waiting = '1.500'  },
		
		{ cmd = 'uval' , description = 'Увольнение игрока из фракции' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает свой телефон обратно в карман&/uninvite {arg_id} {arg2}&/r Сотрудник {get_ru_nick({arg_id})} был уволен по причине: {arg2}' , arg = '{arg_id} {arg2}', enable = true, waiting = '1.500'  },
		
		{ cmd = 'vig' , description = 'Выдача выговора игроку' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/fwarn {arg_id} {arg2}&/r Сотруднику {get_ru_nick({arg_id})} выдан выговор! Причина: {arg2}' , arg = '{arg_id} {arg2}', enable = true, waiting = '1.500'  },
		
		{ cmd = 'unvig' , description = 'Снятие выговора игроку' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/unfwarn {arg_id}&/r Сотруднику {get_ru_nick({arg_id})} был снят выговор!' , arg = '{arg_id}', enable = true, waiting = '1.500'  },
		
		{ cmd = 'gr' , description = 'Повышение/понижение игрока' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/giverank {arg_id} {arg2}&/r Сотрудник {get_ru_nick({arg_id})} получил новую должность!' , arg = '{arg_id} {arg2}', enable = true, waiting = '1.500' },
	
	}
}
local configDirectory = getWorkingDirectory() .. "/config"
local path = configDirectory .. "/Hospital_Helper_Settings.json"
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path) then
        settings = default_settings
		print('[Hospital Helper] Файл с настройками не найден, использую стандартные настройки!')
        save_settings()
    else
        local file = io.open(path, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print('[Hospital Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
					for category, _ in pairs(default_settings) do
						settings[category] = settings[category] or {}
						for key, value in pairs(default_settings[category]) do
							settings[category][key] = settings[category][key] or value
						end
					end
					print('[Hospital Helper] Настройки успешно загружены!')

				else
					print('[Hospital Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('[Hospital Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
			save_settings()
        end
    end
end
function save_settings()
    local file, errstr = io.open(path, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print('[Hospital Helper] Настройки сохранены!')
        return result
    else
        print('[Hospital Helper] Не удалось сохранить настройки хелпера, ошибка: ', errstr)
        return false
    end
end
load_settings()

if tostring(settings.general.version) ~= tostring(thisScript().version) then 
	print('[Hospital Helper] Обнаружена иная версия хелпера от той что у вас была раньше!') 
	print('[Hospital Helper] Рекомендуеться сделать сброс настроек хелпера!') 
	settings.general.version = thisScript().version
	save_settings()
end

------------------------------------------- MonetLoader --------------------------------------------------

function isMonetLoader() return MONET_VERSION ~= nil end

if isMonetLoader() then
	gta = ffi.load('GTASA') 
	ffi.cdef[[ void _Z12AND_OpenLinkPKc(const char* link); ]] -- функция для открытия ссылок
end

if not isMonetLoader() and MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

---------------------------------------------- Mimgui -----------------------------------------------------

local imgui = require('mimgui')
local fa = require('fAwesome6_solid')

local sizeX, sizeY = getScreenResolution()

local MainWindow = imgui.new.bool()
local checkbox_accent_enable = imgui.new.bool(settings.general.accent_enable)
local input_expel_reason = imgui.new.char[256](u8(settings.general.expel_reason))
local input_accent = imgui.new.char[256](u8(settings.player_info.accent))
local input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
local input_fraction_tag = imgui.new.char[256](u8(settings.player_info.fraction_tag))
local input_heal = imgui.new.char[256](u8(settings.price.heal))
local input_heal_vc = imgui.new.char[256](u8(settings.price.heal_vc))
local input_healactor = imgui.new.char[256](u8(settings.price.healactor))
local input_healactor_vc = imgui.new.char[256](u8(settings.price.healactor_vc))
local input_medosm = imgui.new.char[256](u8(settings.price.medosm))
local input_mticket = imgui.new.char[256](u8(settings.price.mticket))
local input_recept = imgui.new.char[256](u8(settings.price.recept))
local input_ant = imgui.new.char[256](u8(settings.price.ant))
local input_tatu = imgui.new.char[256](u8(settings.price.tatu))
local input_med7 = imgui.new.char[256](u8(settings.price.med7))
local input_med14 = imgui.new.char[256](u8(settings.price.med14))
local input_med30 = imgui.new.char[256](u8(settings.price.med30))
local input_med60 = imgui.new.char[256](u8(settings.price.med60))
local theme = imgui.new.int(0)
if settings.general.moonmonet_theme_enable and monet_no_errors then theme[0] = 1 end

local BinderWindow = imgui.new.bool()
local waiting_slider = imgui.new.float(0)
local ComboTags = imgui.new.int()
local item_list = {u8'Без аргумента', u8'{arg} - принимает что угодно, буквы/цифры/символы', u8'{arg_id} - принимает только ID игрока', u8'{arg_id} {arg2} - принимает 2 аругмента: ID игрока и второе что угодно'}
local ImItems = imgui.new['const char*'][#item_list](item_list)
local change_cmd_bool = false
local change_cmd = ''
local change_description = ''
local change_text = ''
local change_arg = ''
local binder_create_command_9_10 = false
local tagReplacements = {
	my_id = function() return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) end,
    my_nick = function() return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) end,
	my_ru_nick = function() return TranslateNick(settings.player_info.name_surname) end,
	fraction_rank_number = function() return settings.player_info.fraction_rank_number end,
	fraction_rank = function() return settings.player_info.fraction_rank end,
	fraction_tag = function() return settings.player_info.fraction_tag end,
	fraction = function() return settings.player_info.fraction end,
	expel_reason = function() return settings.general.expel_reason end,
	price_heal = function()
		if u8(sampGetCurrentServerName()):find("Vice City") then
			return settings.price.heal_vc
		else
			return settings.price.heal
		end
	end,
	price_actorheal = function()
		if u8(sampGetCurrentServerName()):find("Vice City") then
			return settings.price.healactor_vc
		else
			return settings.price.healactor
		end
	end,
	price_medosm = function() return settings.price.medosm end,
	price_mticket = function() return settings.price.mticket end,
	price_ant = function() return settings.price.ant end,
	price_recept = function() return settings.price.recept end,
	price_tatu = function() return settings.price.tatu end,
	price_med7 = function() return settings.price.med7 end,
	price_med14 = function() return settings.price.med14 end,
	price_med30 = function() return settings.price.med30 end,
	price_med60 = function() return settings.price.med60 end,
	sex = function() 
		if settings.player_info.sex == 'Женщина' then
			local temp = 'а'
			return temp
		else
			local temp = ''
			return temp
		end
	end,
	
}
local binder_tags_text = [[
{my_id} - Ваш игровой ID
{my_nick} - Ваш игровой Nick
{my_ru_nick} - Ваше Имя и Фамилия указанные в хелпере
{fraction} - Ваша фракция указанная в хелпере
{fraction_tag} - Ваш фракционнфый тэг указанный в хелпере
{fraction_rank} - Название вашего фракционного ранга в хелпере
{expel_reason} - Причина для выгона из хелпера
{price_heal} - Цена лечения пациентов
{price_actorheal} - Цена лечения охранников
{price_medosm} - Цена мед.осмотра для пилота
{price_tatu} - Цена удаления татуировки
{price_mticket} - Цена обследования военного билета
{price_ant} - Цена антибиотика
{price_recept} - Цена рецепта
{price_med7} - Цена медккарты на 7 дней
{price_med14} - Цена медккарты на 14 дней
{price_med30} - Цена медккарты на 30 дней
{price_med60} - Цена медккарты на 60 дней

{sex} - Добавляет букву "а" если в хелпере указан женский пол

{get_nick({arg_id})} - получить Nick игрока из аргумента ID игрока
{get_rp_nick({arg_id})}  - получить Nick игрока без символа _ из аргумента ID игрока
{get_ru_nick({arg_id})}  - получить Nick игрока на кирилице из аргумента ID игрока 
]]

local MembersWindow = imgui.new.bool()
local members = {}
local members_new = {}
local members_check = false
local members_fraction = ''
local update_members_check = false
function update_members()
	lua_thread.create(function()
		update_members_check = true
		wait(1500)
		if MembersWindow[0] then
			members_new = {} 
			members_check = true 
			sampSendChat("/members") 
		end
		wait(1500)
		update_members_check = false
	end)
end

local MedCardMenu = imgui.new.bool()
local medcard_days = imgui.new.int()

local ReceptMenu = imgui.new.bool()
local recepts = imgui.new.int()

local AntibiotikMenu = imgui.new.bool()
local antibiotiks = imgui.new.int(1)

local LeaderFastMenu = imgui.new.bool()
local FastMenu = imgui.new.bool()
local FastMenuButton = imgui.new.bool()
local FastMenuPlayers = imgui.new.bool()

local FastHealMenu = imgui.new.bool()
local heal_in_chat = false
local heal_in_chat_player_id = nil
local world_heal_in_chat = { 'вылечите', 'вылечи', 'похиль', ' хил ', 'хилл', ' лек', 'лекни', 'heal', 'hil', 'lek' }

local MedOsmotrMenu1, MedOsmotrMenu2, MedOsmotrMenu3, MedOsmotrMenu4, MedOsmotrMenu5 = imgui.new.bool(), imgui.new.bool(), imgui.new.bool(), imgui.new.bool(), imgui.new.bool()
local medosmtype = imgui.new.int()
local medcheck = false
local medcheck_no_medcard = false
local medcard_narko = 0
local medcard_status = ''

local NoteWindow = imgui.new.bool()
local show_note_name = ''
local show_note_text = ''

-------------------------------------------- MoonMonet ----------------------------------------------------

local monet_no_errors, moon_monet = pcall(require, 'MoonMonet') -- безопасно подключаем библиотеку

local message_color 
local message_color_hex 

if settings.general.moonmonet_theme_enable and monet_no_errors then
	function rgbToHex(rgb)
		local r = bit.band(bit.rshift(rgb, 16), 0xFF)
		local g = bit.band(bit.rshift(rgb, 8), 0xFF)
		local b = bit.band(rgb, 0xFF)
		local hex = string.format("%02X%02X%02X", r, g, b)
		return hex
	end
	message_color = settings.general.moonmonet_theme_color
	message_color_hex = '{' ..  rgbToHex(settings.general.moonmonet_theme_color) .. '}'
else
	message_color_hex = '{FF7E7E}'
	message_color = 0xFF7E7E
end

local tmp = imgui.ColorConvertU32ToFloat4(settings.general.moonmonet_theme_color)
local mmcolor = imgui.new.float[3](tmp.z, tmp.y, tmp.x)

------------------------------------------- Mimgui Hotkey  -----------------------------------------------------

if not isMonetLoader() then
	
	hotkey = require('mimgui_hotkeys')
	hotkey.Text.NoKey = u8'< Бинд не установлен >'
    hotkey.Text.WaitForKey = u8'< Ожидание выбора клавиш >'

	MainMenuHotKey = hotkey.RegisterHotKey('Open MainMenu', false, decodeJson(settings.general.bind_mainmenu), function() end)
	FastMenuHotKey = hotkey.RegisterHotKey('Open FastMenu', false, decodeJson(settings.general.bind_fastmenu), function() end)
	LeaderFastMenuHotKey = hotkey.RegisterHotKey('Open LeaderFastMenu', false, decodeJson(settings.general.bind_leader_fastmenu), function() end)
	HealMeHotKey = hotkey.RegisterHotKey('Healme', false, decodeJson(settings.general.bind_healme), function() end)
	FastHealHotKey = hotkey.RegisterHotKey('FastHeal Player', false, decodeJson(settings.general.bind_fastheal), function() end)

    
	function IsHotkeyClicked(keys_id)
		local keysArray = decodeJson(keys_id)
		if next(keysArray) == nil then
			return false
		end
		local allKeysPressed = true
		for _, element in ipairs(keysArray) do
			if not isKeyDown(element) then
				allKeysPressed = false
				break
			end
		end
		return allKeysPressed
	end
	function getNameKeysFrom(keys)
		local keys = decodeJson(keys)
		local keysStr = {}
		for _, keyId in ipairs(keys) do
			local keyName = require('vkeys').id_to_name(keyId) or ''
			table.insert(keysStr, keyName)
		end
		return tostring(table.concat(keysStr, ' + '))
	end

end

------------------------------------------------- Other --------------------------------------------------------

local PlayerID = nil
local player_id = 0
local check_stats = false
local anti_flood_auto_uval = false
local spawncar_bool = false

local vc_vize_bool = false
local vc_vize_player_id = 0
local godeath_player_id = 0
local godeath_locate = ''
local godeath_city = ''

local clicked = false

------------------------------------------- Main -----------------------------------------------------

function main()

	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 

	if not sampIsLocalPlayerSpawned() then 
		sampAddChatMessage('[Hospital Helper] {ffffff}Инициализация хелпера прошла успешно!',message_color)
		sampAddChatMessage('[Hospital Helper] {ffffff}Для полной загрузки хелпера сначало заспавнитесь (войдите на сервер)',message_color)
	end

	repeat wait(0) until sampIsLocalPlayerSpawned()
	
	sampAddChatMessage('[Hospital Helper] {ffffff}Загрузка хелпера прошла успешно!', message_color)
	if isMonetLoader() or settings.general.bind_mainmenu == nil then
		sampAddChatMessage('[Hospital Helper] {ffffff}Чтоб открыть меню хелпера введите команду ' .. message_color_hex .. '/hh', message_color)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Чтоб открыть меню хелпера нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_mainmenu) .. ' {ffffff}или введите команду ' .. message_color_hex .. '/hh', message_color)
	end
	
	if settings.player_info.name_surname == '' then
		settings.player_info.name_surname = TranslateNick(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
		input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
		check_stats = true
		sampSendChat('/stats')
	end

	sampRegisterChatCommand("hh", function() MainWindow[0] = not MainWindow[0]  end)
	sampRegisterChatCommand("hm", show_fast_menu)
	if not isMonetLoader() then sampRegisterChatCommand("hlm", show_leader_fast_menu) end
	sampRegisterChatCommand("mb", function() members_new = {} members_check = true sampSendChat("/members") end)
	sampRegisterChatCommand("osm",medosm)
	sampRegisterChatCommand("spawncar",spawncar)
	sampRegisterChatCommand("vc",vc_vize)
	sampRegisterChatCommand("recept",recept)
	sampRegisterChatCommand("ant",antibiotik)
	sampRegisterChatCommand("mc",medcard)
	
	registerCommandsFrom(settings.commands)
	if tonumber(settings.player_info.fraction_rank_number) >= 9 then registerCommandsFrom(settings.commands_manage) end

	while true do
		wait(0)
		
		if MembersWindow[0] and not update_members_check then
			update_members()
		end
		
		if isMonetLoader() and tonumber(#get_players()) > 0 and not FastMenu[0] and not FastMenuPlayers[0] then
			FastMenuButton[0] = true
		else
			FastMenuButton[0] = false
		end
		
		if not isMonetLoader() then
		
			if heal_in_chat and isKeyDown(VK_RETURN) and not sampIsDialogActive() and not sampIsChatInputActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
			    command("/heal {arg_id}", heal_in_chat_player_id)
				heal_in_chat = false
				heal_in_chat_id = nil
			end
			
			if IsHotkeyClicked(settings.general.bind_mainmenu) and not MainWindow[0] then
				MainWindow[0] = true
			end

			if IsHotkeyClicked(settings.general.bind_healme) then
				wait(500)
				command("/heal {my_id}", 0)
				wait(500)
			end
			
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(ped) then
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result and id ~= -1 and IsHotkeyClicked(settings.general.bind_fastmenu) and not LeaderFastMenu[0] then
					show_fast_menu(id)
				elseif result and id ~= -1 and IsHotkeyClicked(settings.general.bind_leader_fastmenu) and not FastMenu[0] then
					if tonumber(settings.player_info.fraction_rank_number) >= 9 then 
						show_leader_fast_menu(id)
					end
				end
			end

			if clicked then
				local cmd = "clickMinigame"
				local bs = raknetNewBitStream()
				raknetBitStreamWriteInt8(bs, 220)
				raknetBitStreamWriteInt8(bs, 18)
				raknetBitStreamWriteInt8(bs, #cmd)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteString(bs, cmd)
				raknetBitStreamWriteInt32(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetSendBitStreamEx(bs, 1, 7, 1)
				raknetDeleteBitStream(bs)
				setGameKeyState(1, 255)
				wait(0)
				setGameKeyState(1, 0)

			end
		
		end
		
	end

end

function medosm(id)
	if isParamID(id) then
		lua_thread.create(function()
			player_id = tonumber(id)
			sampSendChat("Сейчас я проведу Вам мед.осмотр, дайте мне вашу мед.карту для проверки.")
			medcheck = true
			MedOsmotrMenu2[0] = true
			wait(1500)
			sampSendChat("/n "..sampGetPlayerNickname(player_id)..", введите /showmc "..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)).." чтоб показать мне мед.карту.")
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/osm [ID игрока]',message_color)
		play_error_sound()
	end
end
function medcard(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("Для оформления мед. карты Вам необходимо оплатить определенную сумму.")
			wait(1500)
			sampSendChat("Эта сумма зависит от строка действия будущей медкарты.")
			wait(1500)
			sampSendChat("Мед. карта на 7 дней - $"..settings.price.med7..", на 14 дней - $"..settings.price.med14..".")
			wait(1500)
			sampSendChat("Мед. карта на 30 дней - $"..settings.price.med30..", на 60 дней - $"..settings.price.med60..".")
			wait(1500)
			sampSendChat("Скажите, на какой срок Вам оформить мед. карту?")
			player_id = tonumber(id)
			MedCardMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/mc [ID] {ffffff}или ' .. message_color_hex .. '/medcard [ID]',message_color)
		play_error_sound()
	end
end
function recept(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("Хорошо, стоимость одного рецепта составляет $"..settings.price.recept..".")
			wait(1500)
			sampSendChat("Скажите сколько Вам требуется рецептов, после чего мы продолжим.")
			wait(1500)
			sampSendChat("/n Внимание! В течении часа выдаётся максимум 5 рецептов!")
			player_id = tonumber(id)
			ReceptMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/rec [ID] {ffffff}или ' .. message_color_hex .. '/recept [ID]',message_color)
		play_error_sound()
	end
end
function antibiotik(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("Хорошо, cтоимость одного антибиотика составляет $"..settings.price.ant..".")
			wait(1500)
			sampSendChat("Скажите сколько Вам требуется антибиотиков, после чего мы продолжим.")
			wait(1500)
			sampSendChat("/n Внимание! Вы можете купить от 1 до 20 антибитиков!")
			player_id = tonumber(id)
			AntibiotikMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex.. '/ant [ID] {ffffff}или ' .. message_color_hex .. '/antibiotik [ID]',message_color)
		play_error_sound()
	end
end
function spawncar()
	if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
		lua_thread.create(function()
			sampSendChat("/rb Внимание! Через 10 секунд будет спавн транспорта больницы.")
			wait(2000)
			sampSendChat("/rb Займите транспорт, иначе он будет заспавнен.")
			wait(8000)	
			spawncar_bool = true
			sampSendChat("/lmenu")
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Эта команда доступна только лидеру и заместителям!',message_color)
		play_error_sound()
	end
end
function vc_vize(id)
	if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
		if isParamID(id) then
			lua_thread.create(function()
				sampSendChat("/me достаёт из кармана свой телефон и заходит в базу данных " .. settings.player_info.fraction_tag)
				wait(1500)
				sampSendChat("/me изменяет информацию о сотруднике " .. TranslateNick(sampGetPlayerNickname(tonumber(id))) .. " и убирает телефон обратно в карман")
				wait(1500)
				vc_vize_player_id = tonumber(id)
				vc_vize_bool = true
				sampSendChat("/lmenu")
			end)
		elseif id:find('^(%w+_%w+)') then
			lua_thread.create(function()
				sampSendChat("/me достаёт из кармана свой телефон и заходит в базу данных " .. settings.player_info.fraction_tag)
				wait(1500)
				sampSendChat("/me изменяет информацию о сотруднике " .. TranslateNick(id) .." и убирает телефон обратно в карман")
				wait(1500)
				if sampIsConnectedByNick(id) then
					vc_vize_player_id = tonumber(sampGetIDByNick(id))
					vc_vize_bool = true
					sampSendChat("/lmenu")
				else
					sampAddChatMessage('[Hospital Helper] {ffffff}Игрока с таким ником сейчас нет на сервере!',message_color)
				end
			end)
		else
			sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/vc [ID] {ffffff}или ' .. message_color_hex .. '/vc [Nick_Name]', message_color)
			play_error_sound()
		end

	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Эта команда доступна только лидеру и заместителям!',message_color)
		play_error_sound()
	end
end

function sampev.onServerMessage(color,text)
	
	--sampAddChatMessage('color = ' .. color .. ' , text = '..text,-1)

	if color == 766526463 and settings.general.auto_uval  and tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then -- autouval
		if text:find("%[(.-)%] (.-) (.-)%[(.-)%]: (.+)") then -- /f /fb или /r /rb без тэга 
			local tag, rank, name, playerID, message = string.match(text, "%[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			if not message:find("], отправьте (.+) +++ чтобы уволится ПСЖ!") and not message:find("Сотрудник (.+) был уволен по причине (.+)") and message:find("ПСЖ") or message:find("псж") or message:find("увольте") or message:find("Увольте") or message:find("Увал") or message:find("увал") then
				PlayerID = playerID
				lua_thread.create(function()
					wait(10)
					anti_flood_auto_uval = true
					if tag == "R" then
						sampSendChat("/rb "..name.."["..playerID.."], отправьте /rb +++ чтобы уволится ПСЖ!")
					elseif tag == "F" then
						sampSendChat("/fb "..name.."["..playerID.."], отправьте /fb +++ чтобы уволится ПСЖ!")
					end
					wait(5000)
					anti_flood_auto_uval = false
				end)
			elseif message == "(( +++ ))" and PlayerID == playerID then
				lua_thread.create(function()
					wait(10)
					temp = playerID .. ' ПСЖ'
					command("/uninvite {arg_id} {arg2}", temp)
				end)
			end
		elseif text:find("%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)") then -- /r или /f с тэгом
			local tag, tag2, rank, name, playerID, message = string.match(text, "%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			if not message:find("], чтобы уволится ПСЖ,") and not message:find("], отправьте (.+) +++ чтобы уволится ПСЖ!") and not message:find("Сотрудник (.+) был уволен по причине (.+)") and message:find("ПСЖ") or message:find("псж") or message:find("увольте") or message:find("Увольте") or message:find("Увал") or message:find("увал") then
				lua_thread.create(function()
					wait(10)
					PlayerID = playerID	
					anti_flood_auto_uval = true
					if tag == "R" then
						sampSendChat("/rb "..name.."["..playerID.."], отправьте /rb +++ чтобы уволится ПСЖ!")
					elseif tag == "F" then
						sampSendChat("/fb "..name.."["..playerID.."], отправьте /fb +++ чтобы уволится ПСЖ!")
					end
					wait(5000)
					anti_flood_auto_uval = false
				end)
			elseif message == "(( +++ ))" and PlayerID == playerID then
				lua_thread.create(function()
					wait(10)
					temp = playerID .. ' ПСЖ'
					command("/uninvite {arg_id} {arg2}", temp)
				end)
			end
		end
	end
	
	if text:find("{ffffff} Вам поступило предложение от игрока (.+)") and medcheck then
		lua_thread.create(function()
			wait(10)
			sampSendChat("/offer")
		end)
	end
	
	if settings.general.heal_in_chat and text:find('(.+)%[(%d+)%] говорит:{B7AFAF} (.+)') then
		local nick, id, message = text:match('(.+)%[(%d+)%] говорит:{B7AFAF} (.+)')
		if nick ~= nil and id ~= nil and message ~= nil then
			for _, keyword in ipairs(world_heal_in_chat) do
				if message:rupper():find(keyword:rupper()) then
					fast_heal_in_chat(id)
					break
				end
			end
		end
	end
	
	if settings.general.heal_in_chat and text:find('(.+)%[(%d+)%] кричит: (.+)') then
		local nick, id, message = text:match('(.+)%[(%d+)%] кричит: (.+)')
		if nick ~= nil and id ~= nil and message ~= nil then
			for _, keyword in ipairs(world_heal_in_chat) do
				if message:rupper():find(keyword:rupper()) then
					fast_heal_in_chat(id)
					break
				end
			end
		end
	end
	
	if text:find('Очевидец сообщает о пострадавшем человеке в районе (.+) %((.+)%).') then
		godeath_locate, godeath_city = text:match('Очевидец сообщает о пострадавшем человеке в районе (.+) %((.+)%).')
		return false
	end
	
	if text:find('%(%( Чтобы принять вызов, введите /godeath (%d+). Оплата за вызов (.+) %)%)') then
		godeath_player_id = text:match('%(%( Чтобы принять вызов, введите /godeath (%d+). Оплата за вызов (.+) %)%)')
		godeath_player_id = tonumber(godeath_player_id)
		local cmd = '/godeath'
		for _, command in ipairs(settings.commands) do
			if command.enable and command.text:find('/godeath') then
				cmd =  '/' .. command.cmd
			end
		end
		sampAddChatMessage('[Hospital Helper] {ffffff}Из города ' .. message_color_hex .. godeath_city .. ' {ffffff}поступил экстренный вызов о пострадавшем человеке ' .. message_color_hex .. sampGetPlayerNickname(godeath_player_id), message_color)
		sampAddChatMessage('[Hospital Helper] {ffffff}Чтобы принять экстренный вызов, используйте команду ' .. message_color_hex .. cmd .. ' '.. godeath_player_id, message_color)
		return false
	end
	
	if text:find("{FFFFFF}(.-) принял ваше предложение вступить к вам в организацию.") then
		local PlayerName = text:match("{FFFFFF}(.-) принял ваше предложение вступить к вам в организацию.")
		sampSendChat("/r "..TranslateNick(PlayerName).." - наш новый сотрудник!")
	end
	
end
function sampev.onSendChat(text)

	local ignore = {
		[";)"] = true,
		[":D"] = true,
		[":O"] = true,
		[":|"] = true,
		[")"] = true,
		["))"] = true,
		["("] = true,
		["(("] = true,
		["xD"] = true,
		["q"] = true,
		["(+)"] = true,
		["(-)"] = true,
		[":)"] = true,
		[":("] = true,
		["=)"] = true,
		[":p"] = true,
		[";p"] = true,
		["(rofl)"] = true,
		["XD"] = true,
		["(agr)"] = true,
		["O.o"] = true,
		[">.<"] = true,
		[">:("] = true,
		["<3"] = true,
	}
	if ignore[text] then
		return {text}
	end
	
	if settings.general.rp_chat then
		text = text:sub(1, 1):rupper()..text:sub(2, #text) 
		if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
			text = text .. '.'
		end
	end
	
	if settings.general.accent_enable then
		text = settings.player_info.accent .. ' ' .. text 
	end
	
	return {text}

end
function sampev.onSendCommand(text)

	if settings.general.rp_chat then
	
		local chats =  { '/vr', '/fam', '/al', '/s', '/b', '/n', '/r', '/rb', '/f', '/fb', '/j', '/jb', '/m' } 
	
		for _, cmd in ipairs(chats) do
		
			if text:find('^'.. cmd .. ' ') then
			
				local cmd_text = text:match('^'.. cmd .. ' (.+)')
				
				if cmd_text ~= nil then
				
					cmd_text = cmd_text:sub(1, 1):rupper()..cmd_text:sub(2, #cmd_text)
					
					text = cmd .. ' ' .. cmd_text
					
					if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
						text = text .. '.'
					end
				
				end
			end
			
			
		
		end
		
	end
	
	return {text}

end
function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
	
	if title:find('Мед. карта') and text:find("Мед. Карта %[(.+)%]\n") and medcheck then -- medcard
		
		medcard_narko = math.floor(text:match("{CEAD2A}Наркозависимость: (.+){FFFFFF}"))
		medcard_status = text:match("Мед. Карта %[(.+)%]\n")
		
		MedOsmotrMenu2[0] = false
		MedOsmotrMenu3[0] = true
		
		sampSendChat("/me берёт в руки мед.карту и начинает осматриват её, после отдает мед.карту обратно")
		
		sampSendDialogResponse(1234, 1,0,0)
		return false
		
	end

	if text:find('{FFFFFF}Медик {DAD540}(.+){FFFFFF} хочет вылечить вас за {DAD540}') and text:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) then -- /hme
		sampSendDialogResponse(dialogid, 1,0,0)
		return false
	end
	
	if text:find("Проверьте и подтвердите данные перед выдачей мед карты") and text:find("Полностью здоров") then  -- автовыдача мед.карты
		sampAddChatMessage('[Hospital Helper] {ffffff}Ожидайте пока игрок подтвердит получение мед. карты', message_color)
		sampSendDialogResponse(dialogid, 1,0,0)
		return false
	end
	
	if text:find('Вы действительно хотите вызвать сотрудников полиции?') and settings.general.anti_trivoga then -- тревожная кнопка
		sampSendDialogResponse(dialogid, 0, 0, 0)
		return false
	end
	
	if title:find('Основная статистика') and check_stats then -- получение статистики
	
		if text:find("{FFFFFF}Пол: {B83434}%[(.-)]") then
			settings.player_info.sex = text:match("{FFFFFF}Пол: {B83434}%[(.-)]")
		end
		
		if text:find("{FFFFFF}Организация: {B83434}%[(.-)]") then
			settings.player_info.fraction = text:match("{FFFFFF}Организация: {B83434}%[(.-)]")
			if settings.player_info.fraction == 'Не имеется' then
				sampAddChatMessage('[Hospital Helper] {ffffff}Вы не состоите в организации!',message_color)
				settings.player_info.fraction_tag = "Неизвестно"
			else
				sampAddChatMessage('[Hospital Helper] {ffffff}Ваша организация обнаружена, это: '..settings.player_info.fraction, message_color)
				
				if settings.player_info.fraction == 'Больница ЛС' or settings.player_info.fraction == 'Больница LS' then
					settings.player_info.fraction_tag = 'LSMC'
				elseif settings.player_info.fraction == 'Больница ЛВ' or settings.player_info.fraction == 'Больница LV' then
					settings.player_info.fraction_tag = 'LVMC'
				elseif settings.player_info.fraction == 'Больница СФ' or settings.player_info.fraction == 'Больница SF' then
					settings.player_info.fraction_tag = 'SFMC'
				elseif settings.player_info.fraction == 'Больница Jefferson' or settings.player_info.fraction == 'Больница Джефферсон' then
					settings.player_info.fraction_tag = 'JMC'
				else
					settings.player_info.fraction_tag = 'Medical Center'
				end
				
				input_fraction_tag = imgui.new.char[256](u8(settings.player_info.fraction_tag))
				
				sampAddChatMessage('[Hospital Helper] {ffffff}Вашей организации присвоен тэг '..settings.player_info.fraction_tag .. ". Но вы можете изменить тэг в настройках", message_color)
				
			end
	
		end
		
		if text:find("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)") then
			settings.player_info.fraction_rank, settings.player_info.fraction_rank_number = text:match("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)(.+)Уровень розыска")
			if tonumber(settings.player_info.fraction_rank_number) >= 9 then registerCommandsFrom(settings.commands_manage) end
			sampAddChatMessage('[Hospital Helper] {ffffff}Ваша должность обнаружена, это: '..settings.player_info.fraction_rank.." ("..settings.player_info.fraction_rank_number..")", message_color)
		else
			settings.player_info.fraction_rank = "Неизвестно"
			settings.player_info.fraction_rank_number = 0
			sampAddChatMessage('[Hospital Helper] {ffffff}Произошла ошибка, не могу получить ваш ранг!',message_color)
		end
		
		save_settings()
		sampSendDialogResponse(235, 0,0,0)
		check_stats = false
		return false
	end

	if spawncar_bool and title:find('$') and text:find('Спавн транспорта') then -- спавн т/с
		sampSendDialogResponse(dialogid, 2, 3, 0)
		spawncar_bool = false
		return false 
		
	end
	
	if vc_vize_bool and text:find('Управление разрешениями на командировку в Vice City') then -- VS Visa [0]
		sampSendDialogResponse(dialogid, 1, 8, 0)
		return false 
	end
	
	if vc_vize_bool and title:find('Выдача разрешений на поезди Vice City') then -- VS Visa [1]
		lua_thread.create(function()
			vc_vize_bool = false
			sampSendDialogResponse(dialogid, 1, 0, tostring(vc_vize_player_id))
			wait(get_my_wait())
			sampSendChat("/r Сотруднику "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." выдана виза для Vice City!")
		end)
		return false 
	end
	
	if vc_vize_bool and title:find('Забрать разрешение на поезди Vice City') then -- VS Visa [2]
		lua_thread.create(function()
			vc_vize_bool = false
			sampSendDialogResponse(dialogid, 1, 0, tostring(sampGetPlayerNickname(vc_vize_player_id)))
			wait(get_my_wait())
			sampSendChat("/r У сотрудника "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." изьята виза для Vice City!")
		end)
		return false 
	end

	if title:find('Сущности рядом') then
		sampSendDialogResponse(dialogid, 0, 2, 0)
		return false 
	end

	if members_check and title:find('(.+)%(В сети: (%d+)%)') then -- мемберс 

        local count = 0
        local next_page = false
        local next_page_i = 0
		
		members_fraction = string.match(title, '(.+)%(В сети')
		members_fraction = string.gsub(members_fraction, '{(.+)}', '')
		

        for line in text:gmatch('[^\r\n]+') do

            count = count + 1

            if not line:find('Ник') and not line:find('страница') then

				local color, nickname, id, rank, rank_number, warns, afk = string.match(line, '{(.+)}(.+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+)')
			
				if color ~= nil and nickname ~= nil and id ~= nil and rank ~= nil and rank_number ~= nil and warns ~= nil and afk ~= nil then
				
					local working = false

					if color:find('FF3B3B') then
						working = false
					elseif color:find('FFFFFF') then
						working = true
					end
				
					table.insert(members_new, { nick = nickname, id = id, rank = rank, rank_number = rank_number, warns = warns, afk = afk, working = working })
				
				end

            end

            if line:match('Следующая страница') then
                next_page = true
                next_page_i = count - 2
            end
        end
		
        if next_page then
            sampSendDialogResponse(dialogid, 1, next_page_i, 0)
            next_page = false
            next_pagei = 0
        else
            sampSendDialogResponse(dialogid, 0, 0, 0)
			
			members = members_new
			
			members_check = false
		  
			MembersWindow[0] = true
		  
        end

        return false

    end

end
function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
   if text and text:find('Тревожная кнопка') and settings.general.anti_trivoga then -- удаление тревожной кнопки
		return false
	end
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function TranslateNick(name)
	if name:match('%a+') then
        for k, v in pairs({['ph'] = 'ф',['Ph'] = 'Ф',['Ch'] = 'Ч',['ch'] = 'ч',['Th'] = 'Т',['th'] = 'т',['Sh'] = 'Ш',['sh'] = 'ш', ['ea'] = 'и',['Ae'] = 'Э',['ae'] = 'э',['size'] = 'сайз',['Jj'] = 'Джейджей',['Whi'] = 'Вай',['lack'] = 'лэк',['whi'] = 'вай',['Ck'] = 'К',['ck'] = 'к',['Kh'] = 'Х',['kh'] = 'х',['hn'] = 'н',['Hen'] = 'Ген',['Zh'] = 'Ж',['zh'] = 'ж',['Yu'] = 'Ю',['yu'] = 'ю',['Yo'] = 'Ё',['yo'] = 'ё',['Cz'] = 'Ц',['cz'] = 'ц', ['ia'] = 'я', ['ea'] = 'и',['Ya'] = 'Я', ['ya'] = 'я', ['ove'] = 'ав',['ay'] = 'эй', ['rise'] = 'райз',['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', ['Un'] = 'Ан', ['un'] = 'ан', ['Ci'] = 'Ци', ['ci'] = 'ци', ['yse'] = 'уз', ['cate'] = 'кейт', ['eow'] = 'яу', ['rown'] = 'раун', ['yev'] = 'уев', ['Babe'] = 'Бэйби', ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', ['ame'] = 'ейм'}) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs({['B'] = 'Б',['Z'] = 'З',['T'] = 'Т',['Y'] = 'Й',['P'] = 'П',['J'] = 'Дж',['X'] = 'Кс',['G'] = 'Г',['V'] = 'В',['H'] = 'Х',['N'] = 'Н',['E'] = 'Е',['I'] = 'И',['D'] = 'Д',['O'] = 'О',['K'] = 'К',['F'] = 'Ф',['y`'] = 'ы',['e`'] = 'э',['A'] = 'А',['C'] = 'К',['L'] = 'Л',['M'] = 'М',['W'] = 'В',['Q'] = 'К',['U'] = 'А',['R'] = 'Р',['S'] = 'С',['zm'] = 'зьм',['h'] = 'х',['q'] = 'к',['y'] = 'и',['a'] = 'а',['w'] = 'в',['b'] = 'б',['v'] = 'в',['g'] = 'г',['d'] = 'д',['e'] = 'е',['z'] = 'з',['i'] = 'и',['j'] = 'ж',['k'] = 'к',['l'] = 'л',['m'] = 'м',['n'] = 'н',['o'] = 'о',['p'] = 'п',['r'] = 'р',['s'] = 'с',['t'] = 'т',['u'] = 'у',['f'] = 'ф',['x'] = 'x',['c'] = 'к',['``'] = 'ъ',['`'] = 'ь',['_'] = ' '}) do
            name = name:gsub(k, v) 
        end
        return name
    end
	return name
end
function isParamID(id)
	
	if id ~= nil and tostring(id):find('%d') and not tostring(id):find('%D') and string.len(id) >= 1 and string.len(id) <= 3 then
		return true
	else
		return false
	end

end
function get_my_wait()
	return 1500
	
end
function play_error_sound()
	if not isMonetLoader() then
		if sampIsLocalPlayerSpawned() then
			addOneOffSound(getCharCoordinates(PLAYER_PED),1149)
		end
	end
end
function show_fast_menu(id)
	if isParamID(id) then 
		player_id = tonumber(id)
		FastMenu[0] = true
	else
		if isMonetLoader() or settings.general.bind_fastmenu == nil then
			if not FastMenuPlayers[0] then
				sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/hm [ID]',message_color)
			end
		else
			sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/hm [ID] {ffffff}или наведитесь на игрока через ' .. message_color_hex .. 'ПКМ + ' .. getNameKeysFrom(settings.general.bind_fastmenu), message_color) 
		end 
	end 
end
function show_leader_fast_menu(id)
	if isParamID(id) then
		player_id = tonumber(id)
		LeaderFastMenu[0] = true
	else
		if settings.general.bind_leader_fastmenu == nil then
			sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/hlm [ID]',message_color)
		else
			sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/hlm [ID] {ffffff}или наведитесь на игрока через ' .. message_color_hex .. 'ПКМ + ' .. getNameKeysFrom(settings.general.bind_leader_fastmenu), message_color) 
		end 
	end
end
function get_players()
	
	local myPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	
	local playersInRange = {}
	
	for _, h in pairs(getAllChars()) do
		__, id = sampGetPlayerIdByCharHandle(h)
		___, m = sampGetPlayerIdByCharHandle(PLAYER_PED)
		
		id = tonumber(id)
		
		if id ~= -1 and id ~= m and doesCharExist(h) then
			local x, y, z = getCharCoordinates(h)
			local mx, my, mz = getCharCoordinates(PLAYER_PED)
			local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)
			if dist <= 5 then
				table.insert(playersInRange, id)
			end
		end
		
		
		
	end
	
	return playersInRange
		
end
function sampIsConnectedByNick(nick_arg)
	local result = false
	for i = 0, sampGetMaxPlayerId() do
		if sampIsPlayerConnected(tonumber(i)) then
			local rnick = sampGetPlayerNickname(tonumber(i))
			if rnick == nick_arg then
				result = true
			end
		end
	end
	return result
end
function sampGetIDByNick(nick_arg)
	for i = 0, sampGetMaxPlayerId() do
		if sampIsPlayerConnected(tonumber(i)) then
			local rnick = sampGetPlayerNickname(tonumber(i))
			if rnick == nick_arg then
				return tonumber(i)
			end
		end
	end
end
function registerCommandsFrom(array)

	for _, command in ipairs(array) do
	
		if command.enable then
		
			sampRegisterChatCommand(command.cmd, function(arg)
			
				local arg_check = false
				
				local modifiedText = command.text
				
				if command.arg == '{arg}' then
				
					if arg and arg ~= '' then
						modifiedText = modifiedText:gsub('{arg}', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '{arg_id}' then
				
					if arg and arg ~= '' and isParamID(arg) then
						arg = tonumber(arg)
						modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
						modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
						modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '{arg_id} {arg2}' then
				
					if arg and arg ~= '' then
						local arg_id, arg2 = arg:match('(%d+) (.+)')
						if arg_id and arg2 and isParamID(arg_id) then
							arg_id = tonumber(arg_id)
							modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
							modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
							modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
							modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
							modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
							play_error_sound()
						end
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '' then
					arg_check = true
				end

				if arg_check then
				
					lua_thread.create(function()
					
						local lines = {}

						for line in string.gmatch(modifiedText, "[^&]+") do
							table.insert(lines, line)
						end

						for _, line in ipairs(lines) do
						
							for tag, replacement in pairs(tagReplacements) do
								local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
								if success then
									line = result
								else
									
								end
							end

							sampSendChat(line)
							
							
							
								wait( tonumber(command.waiting) * 1000 )
						end
						
					end)
				end
			end)
		end
	end
	
end
function command(cmd, arg)

	local checker = false

	for _, command in ipairs(settings.commands) do
		
		if command.text:find(cmd) then
	
				checker = true

				local arg_check = false
				local modifiedText = command.text
				
				if command.arg == '{arg}' then
				
					if arg and arg ~= '' then
						modifiedText = modifiedText:gsub('{arg}', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '{arg_id}' then
				
					if arg and arg ~= '' and isParamID(arg) then
						arg = tonumber(arg)
						modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
						modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
						modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '{arg_id} {arg2}' then
				
					if arg and arg ~= '' then
						local arg_id, arg2 = arg:match('(%d+) (.+)')
						if arg_id and arg2 and isParamID(arg_id) then
							arg_id = tonumber(arg_id)
							modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
							modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
							modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
							modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
							modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
							play_error_sound()
						end
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
						play_error_sound()
					end
					
				elseif command.arg == '' then
					arg_check = true
				end

				if arg_check then
					lua_thread.create(function()
						local lines = {}
						for line in string.gmatch(modifiedText, "[^&]+") do
							table.insert(lines, line)
						end
						for _, line in ipairs(lines) do
							for tag, replacement in pairs(tagReplacements) do
								local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
								if success then
									line = result
								end
							end
							sampSendChat(line)
							wait( tonumber(command.waiting) * 1000 )
						end
					end)
				end
				
		end
	end

	if not checker then
		
		for _, command in ipairs(settings.commands_manage) do
		
			if command.text:find(cmd) then
		
					local arg_check = false
					local modifiedText = command.text
					
					if command.arg == '{arg}' then
					
						if arg and arg ~= '' then
							modifiedText = modifiedText:gsub('{arg}', arg or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
							play_error_sound()
						end
						
					elseif command.arg == '{arg_id}' then
					
						if arg and arg ~= '' and isParamID(arg) then
							arg = tonumber(arg)
							modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
							modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
							modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
							modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
							play_error_sound()
						end
						
					elseif command.arg == '{arg_id} {arg2}' then
					
						if arg and arg ~= '' then
							local arg_id, arg2 = arg:match('(%d+) (.+)')
							if arg_id and arg2 and isParamID(arg_id) then
								arg_id = tonumber(arg_id)
								modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
								modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
								modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
								modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
								modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
								arg_check = true
							else
								sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
								play_error_sound()
							end
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
							play_error_sound()
						end
						
					elseif command.arg == '' then
						arg_check = true
					end

					if arg_check then
						lua_thread.create(function()
							local lines = {}
							for line in string.gmatch(modifiedText, "[^&]+") do
								table.insert(lines, line)
							end
							for _, line in ipairs(lines) do
								for tag, replacement in pairs(tagReplacements) do
									local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
									if success then
										line = result
									end
								end
								sampSendChat(line)
								wait( tonumber(command.waiting) * 1000 )
							end
						end)
					end
					
			end
		end

	end

end
function fast_heal_in_chat(id)
	if isMonetLoader() then
		sampAddChatMessage('[Hospital Helper] {ffffff}Чтоб вылечить игрока ' .. sampGetPlayerNickname(id) .. ', в течении 5-ти секунд нажмите кнопку',message_color)
		heal_in_chat_player_id = id
		lua_thread.create(function() 
			heal_in_chat = true
			FastHealMenu[0] = true
			wait(5000)
			FastHealMenu[0] = false
			heal_in_chat = false
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}Чтобы вылечить игрока ' .. sampGetPlayerNickname(id) .. ' нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_fastheal) .. ' {ffffff}в течении 5-ти секунд!',message_color)
		heal_in_chat_player_id = id
		lua_thread.create(function() 
			heal_in_chat = true
			wait(5000)
			heal_in_chat = false
		end)
	end
end
function openLink(link)
	if isMonetLoader() then
		gta._Z12AND_OpenLinkPKc(link)
	else
		os.execute("explorer " .. link)
	end
end
function onReceivePacket(id, bs) -- автоматический клик для "Крушение самолета" и "Авария на шосе" (взято из кода Chapo)
	if id == 220 then
		raknetBitStreamIgnoreBits(bs, 8)
		if raknetBitStreamReadInt8(bs) == 17 then
			raknetBitStreamIgnoreBits(bs, 32)
			local cmd = raknetBitStreamReadString(bs, raknetBitStreamReadInt32(bs))
			local view = string.match(cmd, "^window.executeEvent%('event%.setActiveView', [`']%[[\"%s]?(.-)[\"%s]?%][`']%);$")
			if view ~= nil then
				clicked = (view == "Clicker")
			end
		end
	end
end

imgui.OnInitialize(function()

	imgui.GetIO().IniFilename = nil

	fa.Init(14 * MONET_DPI_SCALE)

	if settings.general.moonmonet_theme_enable and monet_no_errors then
		apply_moonmonet_theme()
	else 
		apply_dark_theme()
	end
	
end)

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##main", MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		if imgui.BeginTabBar('Tabs') then	
			if imgui.BeginTabItem(fa.HOUSE..u8' Главное меню') then
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 172 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.USER_DOCTOR .. u8' Информация про сотрудника')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Имя и Фамилия:")
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.name_surname))
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##name_surname') then
						settings.player_info.name_surname = TranslateNick(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
						input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
						save_settings()
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' Имя и Фамилия##name_surname')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' Имя и Фамилия##name_surname', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						imgui.PushItemWidth(405 * MONET_DPI_SCALE)
						imgui.InputText(u8'##name_surname', input_name_surname, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.name_surname = u8:decode(ffi.string(input_name_surname))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Пол:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.sex))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##sex') then
						if settings.player_info.sex == 'Неизвестно' then
							settings.player_info.sex = 'Женщина'
							save_settings()
						elseif settings.player_info.sex == 'Мужчина' then
							settings.player_info.sex = 'Женщина'
							save_settings()
						elseif settings.player_info.sex == 'Женщина' then
							settings.player_info.sex = 'Мужчина'
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Акцент:")
					imgui.NextColumn()
					if checkbox_accent_enable[0] then
						imgui.CenterColumnText(u8(settings.player_info.accent))
					else 
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##accent') then
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' Акцент персонажа##accent')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' Акцент персонажа##accent', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						if imgui.Checkbox('##checkbox_accent_enable', checkbox_accent_enable) then
							settings.general.accent_enable = checkbox_accent_enable[0]
							save_settings()
						end
						imgui.SameLine()
						imgui.PushItemWidth(375 * MONET_DPI_SCALE)
						imgui.InputText(u8'##accent_input', input_accent, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then 
							settings.player_info.accent = u8:decode(ffi.string(input_accent))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Организация:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##fraction') then
						check_stats = true
						sampSendChat('/stats')
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Тэг организации:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_tag))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##fraction_tag') then
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' Тэг организации##fraction_tag')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' Тэг организации##fraction_tag', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						imgui.PushItemWidth(405 * MONET_DPI_SCALE)
						imgui.InputText(u8'##input_fraction_tag', input_fraction_tag, 256)
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.fraction_tag = u8:decode(ffi.string(input_fraction_tag))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Должность в организации:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_rank) .. " (" .. settings.player_info.fraction_rank_number .. ")")
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8"Изменить##rank") then
						check_stats = true
						sampSendChat('/stats')
					end
					imgui.Columns(1)
				
				imgui.EndChild()
				end
				if imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 53 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.CIRCLE_INFO .. u8' Дополнительная информация')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Причина выгона для /expel:")
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.general.expel_reason))
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##expel_reason') then
						imgui.OpenPopup(fa.DOOR_OPEN .. u8' Изменить причину для выгона##expel_reason')
					end
					if imgui.BeginPopupModal(fa.DOOR_OPEN .. u8' Изменить причину для выгона##expel_reason', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						imgui.PushItemWidth(405 * MONET_DPI_SCALE)
						imgui.InputText(u8'##expel_reason', input_expel_reason, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.general.expel_reason = u8:decode(ffi.string(input_expel_reason))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
				imgui.EndChild()
				end
				if imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 125 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.SITEMAP .. u8' Дополнительные функции')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Анти Тревожная Кнопка")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Убирает тревожную кнопку которая находится за стойкой на 1 этаже\nТем самым вы не будете случайно вызывать МЮ из-за этой кнопки")
					end
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if settings.general.anti_trivoga then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if settings.general.anti_trivoga then
						if imgui.CenterColumnSmallButton(u8'Отключить##anti_trivoga') then
							settings.general.anti_trivoga = false
							save_settings()
						end
						else
						if imgui.CenterColumnSmallButton(u8'Включить##anti_trivoga') then
							settings.general.anti_trivoga = true
							save_settings()
						end
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Хил из чата")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Позволяет нажатием одной кнопки быстро лечить пациентов которые просят чтоб их вылечили")
					end
					imgui.NextColumn()
					if settings.general.heal_in_chat then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.heal_in_chat then
						if imgui.CenterColumnSmallButton(u8'Отключить##heal_in_chat') then
							settings.general.heal_in_chat = false
							save_settings()
						end
						else
						if imgui.CenterColumnSmallButton(u8'Включить##heal_in_chat') then
							settings.general.heal_in_chat = true
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"RP Общение")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Все ваши сообщения в чат автоматически будут с заглавной буквы и с точкой в конце")
					end
					imgui.NextColumn()
					if settings.general.rp_chat then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.rp_chat then
						if imgui.CenterColumnSmallButton(u8'Отключить##rp_chat') then
							settings.general.rp_chat = false
							save_settings()
						end
						else
						if imgui.CenterColumnSmallButton(u8'Включить##rp_chat') then
							settings.general.rp_chat = true
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Авто Увал")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Автоматическое увольнение сотрудников, которые хотят увал ПСЖ\nФункция доступна только если вы 9/10 ранг!")
					end
					imgui.NextColumn()
					if settings.general.auto_uval then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.auto_uval then
						if imgui.CenterColumnSmallButton(u8'Отключить##auto_uval') then
							settings.general.auto_uval = false
							save_settings()
						end
					else
						if imgui.CenterColumnSmallButton(u8'Включить##auto_uval') then
							if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
								settings.general.auto_uval = true
								save_settings()
							else
								settings.general.auto_uval = false
								sampAddChatMessage('[Hospital Helper] {ffffff}Эта Функция доступна только лидеру и заместителям!',message_color)
							end
						end
					end
				imgui.EndChild()
				end
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.RECTANGLE_LIST..u8' Команды и отыгровки') then 
				if imgui.BeginTabBar('Tabs2') then
					if imgui.BeginTabItem(fa.BARS..u8' Общие команды для всех рангов ') then 
						if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 303 * MONET_DPI_SCALE), true) then
							imgui.Columns(3)
							imgui.CenterColumnText(u8"Команда")
							imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Описание")
							imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Действие")
							imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/hh")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть главное меню хелпера")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/hm")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть быстрое меню взаимодействия")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							if not isMonetLoader() then
								imgui.Separator()
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/hlm")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Открыть быстрое меню управления")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
							end
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/mb")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть список сотрудников в сети")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/mс")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Выдать игроку мед.карту")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/ant")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Выдать игроку антибиотики")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/recept")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Выдать игроку рецепты")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/osm")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Провести полный мед.осмотр игрока")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							for index, command in ipairs(settings.commands) do
								imgui.Columns(3)
								if command.enable then
									imgui.CenterColumnText('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnText(u8(command.description))
									imgui.NextColumn()
								else
									imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnTextDisabled(u8(command.description))
									imgui.NextColumn()
								end
								imgui.Text(' ')
								imgui.SameLine()
								if command.enable then
									if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
										command.enable = not command.enable
										save_settings()
										sampUnregisterChatCommand(command.cmd)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Отключение команды /"..command.cmd)
									end
								else
									if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
										command.enable = not command.enable
										save_settings()
										sampRegisterChatCommand(command.cmd, function(arg)
			
											local arg_check = false
											
											local modifiedText = command.text
											
											if command.arg == '{arg}' then
											
												if arg and arg ~= '' then
													modifiedText = modifiedText:gsub('{arg}', arg or "")
													arg_check = true
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
													play_error_sound()
												end
												
											elseif command.arg == '{arg_id}' then
											
												if arg and arg ~= '' and isParamID(arg) then
													arg = tonumber(arg)
													modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
													modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
													modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
													modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
													arg_check = true
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
													play_error_sound()
												end
												
											elseif command.arg == '{arg_id} {arg2}' then
											
												if arg and arg ~= '' then
													local arg_id, arg2 = arg:match('(%d+) (.+)')
													if arg_id and arg2 and isParamID(arg_id) then
														arg_id = tonumber(arg_id)
														modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
														modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
														modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
														modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
														modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
														play_error_sound()
													end
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
													play_error_sound()
												end
												
											elseif command.arg == '' then
												arg_check = true
											end

											if arg_check then
											
												lua_thread.create(function()
												
													local lines = {}

													for line in string.gmatch(modifiedText, "[^&]+") do
														table.insert(lines, line)
													end

													for _, line in ipairs(lines) do
													
														for tag, replacement in pairs(tagReplacements) do
															local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
															if success then
																line = result
															else
																
															end
														end

														sampSendChat(line)
														
														
														
															wait( tonumber(command.waiting) * 1000 )
													end
													
												end)
											end
										end)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Включение команды /"..command.cmd)
									end
								end
								imgui.SameLine()
								if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
									change_description = command.description
									input_description = ffi.new("char[256]", u8(change_description))
									change_arg = command.arg
									if command.arg == '' then
										ComboTags[0] = 0
									elseif command.arg == '{arg}' then	
										ComboTags[0] = 1
									elseif command.arg == '{arg_id}' then
										ComboTags[0] = 2
									elseif command.arg == '{arg_id} {arg2}' then
										ComboTags[0] = 3
									end
									change_cmd = command.cmd
									input_cmd = ffi.new("char[256]", command.cmd)
									change_text = command.text:gsub('&', '\n')
									input_text = ffi.new("char[8192]", u8(change_text))
									waiting_slider = imgui.new.float( tonumber(command.waiting) )	
									BinderWindow[0] = true
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"Изменение команды /"..command.cmd)
								end
								imgui.SameLine()
								if imgui.SmallButton(fa.TRASH_CAN .. '##'..command.cmd) then
									imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. command.cmd)
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"Удаление команды /"..command.cmd)
								end
								if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. command.cmd, _, imgui.WindowFlags.NoResize ) then
									imgui.CenterText(u8'Вы действительно хотите удалить команду /' .. u8(command.cmd) .. '?')
									imgui.Separator()
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										table.remove(settings.commands, index)
										save_settings()
										imgui.CloseCurrentPopup()
									end
									imgui.End()
								end
								imgui.Columns(1)
								imgui.Separator()
							end
						imgui.EndChild()
					end
					if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую команду##new_cmd',imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
						local new_cmd = {cmd = '', description = 'Новая команда созданная вами', text = '', arg = '', enable = true , waiting = '1.500'}
						table.insert(settings.commands, new_cmd)
						change_description = new_cmd.description
						input_description = ffi.new("char[256]", u8(change_description))
						change_arg = new_cmd.arg
						ComboTags[0] = 0
						change_cmd = new_cmd.cmd
						input_cmd = ffi.new("char[256]", new_cmd.cmd)
						change_text = new_cmd.text:gsub('&', '\n')
						input_text = ffi.new("char[8192]", u8(change_text))
						waiting_slider = imgui.new.float( 1.500 )
						BinderWindow[0] = true
					end
					imgui.EndTabItem()
					end
					if imgui.BeginTabItem(fa.BARS..u8' Команды для 9-10 рангов') then 
						if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then
							if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 303 * MONET_DPI_SCALE), true) then
								imgui.Columns(3)
								imgui.CenterColumnText(u8"Команда")
								imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Описание")
								imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Действие")
								imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
								imgui.Columns(1)
								imgui.Separator()
								for index, command in ipairs(settings.commands_manage) do
									imgui.Columns(3)
									if command.enable then
										imgui.CenterColumnText('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnText(u8(command.description))
										imgui.NextColumn()
									else
										imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnTextDisabled(u8(command.description))
										imgui.NextColumn()
									end
									imgui.Text('  ')
									imgui.SameLine()
									if command.enable then
										if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
											command.enable = not command.enable
											save_settings()
											sampUnregisterChatCommand(command.cmd)
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Отключение команды /"..command.cmd)
										end
									else
										if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
											command.enable = not command.enable
											save_settings()
											sampRegisterChatCommand(command.cmd, function(arg)
			
												local arg_check = false
												
												local modifiedText = command.text
												
												if command.arg == '{arg}' then
												
													if arg and arg ~= '' then
														modifiedText = modifiedText:gsub('{arg}', arg or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
														play_error_sound()
													end
													
												elseif command.arg == '{arg_id}' then
												
													if arg and arg ~= '' and isParamID(arg) then
														arg = tonumber(arg)
														modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
														modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
														modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
														modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
														play_error_sound()
													end
													
												elseif command.arg == '{arg_id} {arg2}' then
												
													if arg and arg ~= '' then
														local arg_id, arg2 = arg:match('(%d+) (.+)')
														if arg_id and arg2 and isParamID(arg_id) then
															arg_id = tonumber(arg_id)
															modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
															modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
															modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
															modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
															modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
															arg_check = true
														else
															sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
															play_error_sound()
														end
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
														play_error_sound()
													end
													
												elseif command.arg == '' then
													arg_check = true
												end

												if arg_check then
												
													lua_thread.create(function()
													
														local lines = {}

														for line in string.gmatch(modifiedText, "[^&]+") do
															table.insert(lines, line)
														end

														for _, line in ipairs(lines) do
														
															for tag, replacement in pairs(tagReplacements) do
																local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
																if success then
																	line = result
																else
																	
																end
															end

															sampSendChat(line)
															
															
															
																wait( tonumber(command.waiting) * 1000 )
														end
														
													end)
												end
											end)
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Включение команды /"..command.cmd)
										end
									end
									imgui.SameLine()
									if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
										change_description = command.description
										input_description = ffi.new("char[256]", u8(change_description))
										change_arg = command.arg
										if command.arg == '' then
											ComboTags[0] = 0
										elseif command.arg == '{arg}' then	
											ComboTags[0] = 1
										elseif command.arg == '{arg_id}' then
											ComboTags[0] = 2
										elseif command.arg == '{arg_id} {arg2}' then
											ComboTags[0] = 3
										end
										change_cmd = command.cmd
										input_cmd = ffi.new("char[256]", command.cmd)
										change_text = command.text:gsub('&', '\n')
										input_text = ffi.new("char[8192]", u8(change_text))
										binder_create_command_9_10 = true
										waiting_slider = imgui.new.float( tonumber(command.waiting) )	
										BinderWindow[0] = true
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Изменение команды /"..command.cmd)
									end
									imgui.SameLine()
									if imgui.SmallButton(fa.TRASH_CAN .. '##'..command.cmd) then
										imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##9-10' .. command.cmd)
									end
									if imgui.IsItemHovered() then	
										imgui.SetTooltip(u8"Удаление команды /"..command.cmd)
									end
									if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##9-10' .. command.cmd, _, imgui.WindowFlags.NoResize ) then
										imgui.CenterText(u8'Вы действительно хотите удалить команду /' .. u8(command.cmd) .. '?')
										imgui.Separator()
										if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											imgui.CloseCurrentPopup()
										end
										imgui.SameLine()
										if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											table.remove(settings.commands_manage, index)
											save_settings()
											imgui.CloseCurrentPopup()
										end
										imgui.End()
									end
									imgui.Columns(1)
									imgui.Separator()
								end
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/vc")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Выдать/изьять VC визу сотруднику")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
								imgui.Separator()
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/spawncar")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Заспавнить т/с организации")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
								imgui.Separator()							
								imgui.EndChild()
							end
							if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую команду##new_cmd_9-10', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
								binder_create_command_9_10 = true
								local new_cmd = {cmd = '', description = 'Новая команда созданная вами', text = '', arg = '', enable = true }
								table.insert(settings.commands_manage, new_cmd)
								change_description = new_cmd.description
								input_description = ffi.new("char[256]", u8(change_description))
								change_arg = new_cmd.arg
								ComboTags[0] = 0
								change_cmd = new_cmd.cmd
								input_cmd = ffi.new("char[256]", new_cmd.cmd)
								change_text = new_cmd.text:gsub('&', '\n')
								input_text = ffi.new("char[8192]", u8(change_text))
								waiting_slider = imgui.new.float( 1.500 )
								BinderWindow[0] = true
							end
						else
							imgui.Text(u8" У вас нет доступа к данным командам, потому что вы "..settings.player_info.fraction_rank_number..u8" ранг.")
						end
						imgui.EndTabItem() 
					end
					if isMonetLoader() then
						if imgui.BeginTabItem(fa.BARS..u8' Дополнительные функции') then 
							imgui.Text(u8'Открыть быстрое меню взаимодействия с игроком:')
							imgui.Text(u8'Подойдите к игроку и нажмите на кнопку "Взаимодействие" в левом углу ')
							imgui.EndTabItem() 
						end
						imgui.EndTabBar() 
					else
						if imgui.BeginTabItem(fa.BARS..u8' Дополнительные функции') then 
						
							if imgui.BeginChild('##99', imgui.ImVec2(589 * MONET_DPI_SCALE, 333 * MONET_DPI_SCALE), true) then

								if isMonetLoader() then
									imgui.Text(u8'Открыть быстрое меню взаимодействия с игроком:')
									imgui.Text(u8'Подойдите к игроку и нажмите на кнопку "Взаимодействие" в левом углу ')
								else
		
									imgui.CenterText(fa.KEYBOARD .. u8' Бинды')
									imgui.Separator()

									imgui.CenterText(u8'Открытие главного меню хелпера (аналог /hh):')
									imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 )
									if MainMenuHotKey:ShowHotKey() then
										settings.general.bind_mainmenu = encodeJson(MainMenuHotKey:GetHotKey())
										save_settings()
									end
		
									imgui.Separator()
		
									imgui.CenterText(u8'Открытие быстрого меню взаимодействия с игроком (аналог /hm):')
									imgui.CenterText(u8'Навестись на игрока через ПКМ и нажать')
									imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 )
									if FastMenuHotKey:ShowHotKey() then
										settings.general.bind_fastmenu = encodeJson(FastMenuHotKey:GetHotKey())
										save_settings()
									end
		
									imgui.Separator()
		
									imgui.CenterText(u8'Открытие быстрого меню управления игроком (аналог /hlm):')
									imgui.CenterText(u8'Навестись на игрока через ПКМ и нажать')
									imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 )
									if LeaderFastMenuHotKey:ShowHotKey() then
										settings.general.bind_leader_fastmenu = encodeJson(LeaderFastMenuHotKey:GetHotKey())
										save_settings()
									end
		
									imgui.Separator()
		
									imgui.CenterText(u8'Вылечить самого себя (аналог /hme):')
									imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 )
									if HealMeHotKey:ShowHotKey() then
										settings.general.bind_healme = encodeJson(HealMeHotKey:GetHotKey())
										save_settings()
									end

									imgui.Separator()
		
									imgui.CenterText(u8'Вылечить игрока (бинд для функции "Хил из чата"):')
									imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 )
									if FastHealHotKey:ShowHotKey() then
										settings.general.bind_fastheal = encodeJson(FastHealHotKey:GetHotKey())
										save_settings()
									end
		
									
		
								end

								imgui.EndChild()
							end

							
							imgui.EndTabItem() 
						end
						imgui.EndTabBar() 
					end
				end
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.MONEY_CHECK_DOLLAR..u8' Ценовая политика') then 
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Лечение игрока (SA $)', input_heal, 6) then
					settings.price.heal = u8:decode(ffi.string(input_heal))
					save_settings()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(300 * MONET_DPI_SCALE)
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Лечение игрока (VC $)', input_heal_vc, 6) then
					settings.price.heal_vc = u8:decode(ffi.string(input_heal_vc))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Лечение охранника (SA $)', input_healactor, 8) then
					settings.price.healactor = u8:decode(ffi.string(input_healactor))
					save_settings()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(300 * MONET_DPI_SCALE)
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Лечение охранника (VC $)', input_healactor_vc, 8) then
					settings.price.healactor_vc = u8:decode(ffi.string(input_healactor_vc))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Проведение мед. осмотра для пилотов', input_medosm, 8) then
					settings.price.medosm = u8:decode(ffi.string(input_medosm))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Проведение мед. обследования для военного билета', input_mticket, 8) then
					settings.price.mticket = u8:decode(ffi.string(input_mticket))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Проведение сеанса сведения татуировки', input_tatu, 8) then
					settings.price.tatu = u8:decode(ffi.string(input_tatu))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача рецепта', input_recept, 8) then
					settings.price.recept = u8:decode(ffi.string(input_recept))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача антибиотика', input_ant, 8) then
					settings.price.ant = u8:decode(ffi.string(input_ant))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача мед.карты на 7 дней', input_med7, 8) then
					settings.price.med7 = u8:decode(ffi.string(input_med7))
					save_settings()
				end
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача мед.карты на 14 дней', input_med14, 8) then
					settings.price.med14 = u8:decode(ffi.string(input_med14))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача мед.карты на 30 дней', input_med30, 8) then
					settings.price.med30 = u8:decode(ffi.string(input_med30))
					save_settings()
				end
				imgui.Separator()
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  Выдача мед.карты на 60 дней', input_med60, 8) then
					settings.price.med60 = u8:decode(ffi.string(input_med60))
					save_settings()
				end
			imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.FILE_PEN..u8' Заметки') then 
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 330 * MONET_DPI_SCALE), true) then
					imgui.Columns(2)
					imgui.CenterColumnText(u8"Список всех ваших заметок:")
					imgui.SetColumnWidth(-1, 500 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8"Действие")
					imgui.SetColumnWidth(-1, 120 * MONET_DPI_SCALE)
					imgui.Columns(1)
					imgui.Separator()
					for i, note in ipairs(settings.note) do
						imgui.Columns(2)
						imgui.CenterColumnText(u8(note.note_name))
						imgui.NextColumn()
						if imgui.SmallButton(fa.UP_RIGHT_FROM_SQUARE .. '##' .. i) then
							show_note_name = u8(note.note_name)
							show_note_text = u8(note.note_text)
							NoteWindow[0] = true
						end
						if imgui.IsItemHovered() then
							imgui.SetTooltip(u8'Открыть заметку "' .. u8(note.note_name) .. '"')
						end
						imgui.SameLine()
						if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##' .. i) then
							local note_text = note.note_text:gsub('&','\n')
							input_text_note = imgui.new.char[8192](u8(note_text))
							input_name_note = imgui.new.char[256](u8(note.note_name))
							imgui.OpenPopup(fa.PEN_TO_SQUARE .. u8' Изменение заметки' .. '##' .. i)	
						end
						if imgui.IsItemHovered() then
							imgui.SetTooltip(u8'Редактирование заметки "' .. u8(note.note_name) .. '"')
						end
						if imgui.BeginPopupModal(fa.PEN_TO_SQUARE .. u8' Изменение заметки' .. '##' .. i, _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
							if imgui.BeginChild('##9992', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true) then	
								imgui.PushItemWidth(578 * MONET_DPI_SCALE)
								imgui.InputText(u8'##note_name', input_name_note, 256)
								imgui.InputTextMultiline("##note_text", input_text_note, 8192, imgui.ImVec2(578 * MONET_DPI_SCALE, 320 * MONET_DPI_SCALE))
								imgui.EndChild()
							end	
							if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								imgui.CloseCurrentPopup()
							end
							imgui.SameLine()
							if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								note.note_name = u8:decode(ffi.string(input_name_note))
								local temp = u8:decode(ffi.string(input_text_note))
								note.note_text = temp:gsub('\n', '&')
								save_settings()
								imgui.CloseCurrentPopup()
							end
							imgui.End()
						end
						imgui.SameLine()
						if imgui.SmallButton(fa.TRASH_CAN .. '##' .. i) then
							imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. note.note_name)
						end
						if imgui.IsItemHovered() then
							imgui.SetTooltip(u8'Удаление заметки "' .. u8(note.note_name) .. '"')
						end
						if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. note.note_name, _, imgui.WindowFlags.NoResize ) then
							imgui.CenterText(u8'Вы действительно хотите удалить заметку "' .. u8(note.note_name) .. '" ?')
							imgui.Separator()
							if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
								imgui.CloseCurrentPopup()
							end
							imgui.SameLine()
							if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
								table.remove(settings.note, i)
								save_settings()
								imgui.CloseCurrentPopup()
							end
							imgui.End()
						end
						imgui.Columns(1)
						imgui.Separator()
					end
					imgui.EndChild()
				end
				
				if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую заметку', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
							
					local new_note = {note_name = 'Новая заметка', note_text = '' }

					table.insert(settings.note, new_note)
					
				end
							
					
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.GEAR..u8' Настройки') then 
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 145 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.CIRCLE_INFO .. u8' Дополнительная информация про хелпер')
					imgui.Separator()
					imgui.Text(fa.CIRCLE_USER..u8" Разработчик данного хелпера: MTG MODS")
					imgui.Separator()
					imgui.Text(fa.CODE..u8" Благодарность за помощь в разработке: OSPx & Dobrui Kola")
					imgui.Separator()
					imgui.Text(fa.CIRCLE_INFO..u8" Версия хелпера которая сейчас установлена у вас: "..thisScript().version)
					imgui.Separator()
					imgui.Text(fa.HEADSET..u8" Тех.поддержка по хелперу (баги, предложения):")
					imgui.SameLine()
					if imgui.SmallButton('https://discord.com/invite/qBPEYjfNhv') then
						openLink('https://discord.com/invite/qBPEYjfNhv')
					end
					imgui.Separator()
					imgui.Text(fa.GLOBE..u8" Тема хелпера на форуме BlastHack:")
					imgui.SameLine()
					if imgui.SmallButton('https://www.blast.hk/threads/195388') then
						openLink('https://www.blast.hk/threads/195388')
					end
				imgui.EndChild()
				end
				if imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 87 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.PALETTE .. u8' Цветовая тема хелпера:')
					imgui.Separator()
					if imgui.RadioButtonIntPtr(u8" Dark Theme ", theme, 0) then	
						theme[0] = 0
						settings.general.moonmonet_theme_enable = false
						settings.general.message_color = 0xFF7E7E
						settings.general.message_color_hex = '{FF7E7E}'
						message_color = settings.general.message_color 
						message_color_hex = settings.general.message_color_hex
						apply_dark_theme()
						save_settings()
					end
					if monet_no_errors then
						if imgui.RadioButtonIntPtr(u8" MoonMonet Theme ", theme, 1) then
							theme[0] = 1
							local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
							local argb = join_argb(0, r, g, b)
							settings.general.moonmonet_theme_enable = true
							settings.general.moonmonet_theme_color = argb
							settings.general.message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
							settings.general.message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
							message_color = settings.general.message_color 
							message_color_hex = settings.general.message_color_hex
							apply_moonmonet_theme()
							save_settings()
						end
						imgui.SameLine()
						if theme[0] == 1 and imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
							local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
							local argb = join_argb(0, r, g, b)
							settings.general.message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
							settings.general.message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
							settings.general.moonmonet_theme_color = argb
							message_color = settings.general.message_color 
							message_color_hex = settings.general.message_color_hex
							if theme[0] == 1 then
								apply_moonmonet_theme()
								save_settings()
							end
						end

					
					else
					
						if imgui.RadioButtonIntPtr(u8" MoonMonet Theme | "..fa.TRIANGLE_EXCLAMATION .. u8' Ошибка: отсуствуют файлы библиотеки!', theme, 1) then
							theme[0] = 0
						end
						
						
					
					end
			
			
				
					


				imgui.EndChild()
				end
				if imgui.BeginChild("##3",imgui.ImVec2(589 * MONET_DPI_SCALE, 80 * MONET_DPI_SCALE),true) then
					
				end imgui.EndChild()
				if imgui.BeginChild("##4",imgui.ImVec2(589 * MONET_DPI_SCALE, 35 * MONET_DPI_SCALE),true) then
					if imgui.Button(fa.POWER_OFF .. u8" Выгрузить хелпер ", imgui.ImVec2(imgui.GetMiddleButtonX(3), 25 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off')
					end
					if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off', _, imgui.WindowFlags.NoResize ) then
						imgui.CenterText(u8'Вы действительно хотите выгрузить (отключить) хелпер?')
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.POWER_OFF .. u8' Да, выгрузить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							reload_script = true
							sampAddChatMessage('[Hospital Helper] {ffffff}Хелпер приостановил свою работу до следущего входа в игру!', message_color)
							thisScript():unload()
						end
						imgui.End()
					end
					imgui.SameLine()
					if imgui.Button(fa.CLOCK_ROTATE_LEFT .. u8" Сброс настроек хелпера ", imgui.ImVec2(imgui.GetMiddleButtonX(3), 25 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##reset')
					end
					if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##reset', _, imgui.WindowFlags.NoResize ) then
						imgui.CenterText(u8'Вы действительно хотите сбросить все настройки хелпера?')
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.CLOCK_ROTATE_LEFT .. u8' Да, сбросить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings = default_settings
							save_settings()
							imgui.CloseCurrentPopup()
							reload_script = true
							thisScript():reload()
						end
						imgui.End()
					end
					imgui.SameLine()
					if imgui.Button(fa.TRASH_CAN .. u8" Удалить хелпер ", imgui.ImVec2(imgui.GetMiddleButtonX(3), 25 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete')
					end
					if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete', _, imgui.WindowFlags.NoResize ) then
						imgui.CenterText(u8'Вы действительно хотите удалить Hospital Helper?')
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.TRASH_CAN .. u8' Да, я хочу удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							sampAddChatMessage('[Hospital Helper] {ffffff}Хелпер полностю удалён из вашего устройства!', message_color)
							sampShowDialog(999999, message_color_hex .. "Hospital Helper", "Мне очень жаль что вы удалили Hospital Helper из своего устройства.\nЕсли удаление связано с негативным опытом использования, и вы сталкивались с багами или проблемами, то\nсообщите мне что именно заставило вас удалить хелпер на нашем Discord сервере или на форуме BlastHack\n\nDiscord: https://discord.com/invite/qBPEYjfNhv\nBlastHack: https://www.blast.hk/threads/195388/\n\nЕсли что, вы можете заново скачать и установить хелпер в любой момент :)", "Закрыть", '', 0)
							os.remove(getWorkingDirectory() .. "\\Hospital_Helper.lua")
							os.remove(getWorkingDirectory() .. "\\config\\Hospital_Helper_Settings.json")
							reload_script = true
							thisScript():unload()
						end
						imgui.End()
					end
				end imgui.EndChild()
				imgui.EndTabItem()
			end
		imgui.EndTabBar() end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return MedCardMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100  * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 115 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##med", MedCardMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar )
		
		
		imgui.CenterText(u8'Мед.карта для игрока '..sampGetPlayerNickname(player_id))
		
		if imgui.RadioButtonIntPtr(u8" 7 дней ##0",medcard_days,0) then
			medcard_days[0] = 0
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 14 дней ##1",medcard_days,1) then
			medcard_days[0] = 1
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 30 дней ##2",medcard_days,2) then
			medcard_days[0] = 2
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 60 дней ##3",medcard_days,3) then
			medcard_days[0] = 3
		end
		
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"Выдать мед.карту")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.ID_CARD_CLIP..u8" Выдать мед.карту") then
			
			lua_thread.create(function()
			
				sampSendChat("Хорошо, тогда приступим к оформлению.")
				wait(get_my_wait())
				sampSendChat("/me достаёт из своего мед.кейса пустую мед.карту, ручку и печать ".. settings.player_info.fraction_tag)
				wait(get_my_wait())
				sampSendChat("/me открывает пустую мед.карту и начинает её заполнять, затем ставит печать ".. settings.player_info.fraction_tag)
				wait(get_my_wait())
				sampSendChat("/me полностю заполнив мед.карту убирает ручку и печать обратно в свой мед.кейс")
				wait(get_my_wait())
				sampSendChat("/todo Вот ваша мед.карта, берите*протягивая заполненную мед.карту человеку напротив себя")
				wait(get_my_wait())
	
				if medcard_days[0] == 0 then
					sampSendChat("/medcard "..player_id.." 3 0 "..settings.price.med7)
				elseif medcard_days[0] == 1 then
					sampSendChat("/medcard "..player_id.." 3 1 "..settings.price.med14)
				elseif medcard_days[0] == 2 then
					sampSendChat("/medcard "..player_id.." 3 2 "..settings.price.med30)
				elseif medcard_days[0] == 3 then
					sampSendChat("/medcard "..player_id.." 3 3 "..settings.price.med60)
				end
				
			end)
			MedCardMenu[0] = false
			
		end
		
		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return ReceptMenu[0] end,
    function(player)
	

		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100  * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##recept", ReceptMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar )

		
        imgui.CenterText(u8'Рецепты для игрока '..sampGetPlayerNickname(player_id))
        imgui.CenterText(u8'(укажите кол-во рецептов для выдачи)')
	
		local buttonWidth = 40 * MONET_DPI_SCALE -- Adjust the width of the radio buttons as needed
		local totalButtonWidth = buttonWidth * 5 + imgui.GetStyle().ItemSpacing.x * 4
		local startPosX = imgui.GetWindowWidth() / 2 - totalButtonWidth / 2

		imgui.SetCursorPosX(startPosX)
		if imgui.RadioButtonIntPtr(u8" 1 ##rec0", recepts, 0) then
			recepts[0] = 0
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + buttonWidth + imgui.GetStyle().ItemSpacing.x)
		if imgui.RadioButtonIntPtr(u8" 2 ##rec1", recepts, 1) then
			recepts[0] = 1
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 2 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 3 ##rec2", recepts, 2) then
			recepts[0] = 2
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 3 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 4 ##rec3", recepts, 3) then
			recepts[0] = 3
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 4 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 5 ##rec4", recepts, 4) then
			recepts[0] = 4
		end

		imgui.Separator()

        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(u8"Выдать рецепты")
        imgui.SetCursorPosX(width / 2 - calc.x / 2)


		if imgui.Button(fa.RECEIPT..u8" Выдать рецепты") then
			
			lua_thread.create(function()
				sampSendChat("Хорошо, сейчас я выдам вам рецепты.")
				wait(get_my_wait())
				sampSendChat("/me достаёт из своего мед.кейса бланк для оформления рецептов и начает его заполнять")
				wait(get_my_wait())
				sampSendChat("/do Бланк успешно заполнен.")
				wait(get_my_wait())
				sampSendChat("/todo Вот, держите!*передавая бланк с рецептами человеку напротив")
				wait(get_my_wait())
				sampSendChat("/recept "..player_id.." "..tonumber(recepts[0])+1)
			end)
			ReceptMenu[0] = false
			
		end

        imgui.End()
		
    end
)

imgui.OnFrame(
    function() return AntibiotikMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##ant", AntibiotikMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar )
		
		
		imgui.CenterText(u8'Антибиотики для игрока '..sampGetPlayerNickname(player_id))
		imgui.CenterText(u8'(укажите кол-во антибиотиков для выдачи)')
		--imgui.SetCursorPosX(30)
		
		
		imgui.PushItemWidth(300*MONET_DPI_SCALE)
		imgui.SliderInt('', antibiotiks, 1, 20)

		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"Выдать антибиотики")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CAPSULES..u8" Выдать антибиотики") then
			
			lua_thread.create(function()
				sampSendChat("Хорошо, сейчас я выдам вам антибиотики.")
				wait(get_my_wait())
				sampSendChat("/me открывает свой мед.кейс и достаёт из него пачку антибиотиков, после чего закрывает мед.кейс")
				wait(get_my_wait())
				sampSendChat("/do Антибиотики находятся в руках.")
				wait(get_my_wait())
				sampSendChat("/todo Вот держите, употребляйте их строго по рецепту!*передавая антибиотики человеку напротив")
				wait(get_my_wait())
				sampSendChat("/antibiotik "..player_id.." "..antibiotiks[0])
			end)
			AntibiotikMenu[0] = false
			
		end
		
		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return  MedOsmotrMenu2[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm2",  MedOsmotrMenu2, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'Проведение мед.осмотра для игрока '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(u8"Ожидайте пока человек покажет вам мед.карту.")
			
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"У игрока нет мед.карты")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.TRIANGLE_EXCLAMATION..u8" У игрока нет мед.карты") then
			lua_thread.create(function()
				MedOsmotrMenu2[0] = false
				sampSendChat("Это очень плохо что у вас нету мед.карты, её нужно будет оформить обязательно!")
				wait(get_my_wait())
				sampSendChat("/me достаёт из мед.кейса стерильные перчатки и надевает их на руки")
				wait(get_my_wait())
				sampSendChat("/do Перчатки на руках.")
				wait(get_my_wait())
				sampSendChat("/todo Начнём мед.осмотр*улыбаясь.")
				wait(get_my_wait())
				sampSendChat("Сейчас я проверю ваше горло, откройте рот и высуните язык.")
				wait(get_my_wait())
				sampSendChat("/n Используйте /me открыл(-а) рот чтоб мы продолжили")
				medcheck_no_medcard = true
				MedOsmotrMenu4[0] = true
			end)
		end
		
		imgui.End()
		
    end
)
imgui.OnFrame(
    function() return  MedOsmotrMenu3[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm3",  MedOsmotrMenu3, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'Проведение мед.осмотра для игрока '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(fa.ID_CARD_CLIP..u8" Статус мед.карты: "..u8(medcard_status))
		imgui.CenterText(fa.CANNABIS..u8" Наркозависимость: "..medcard_narko)
		
		imgui.Separator()
		
		if not medcard_status == "Полностью здоровый(ая)" or tonumber(medcard_narko) > 0 then
		
			local width = imgui.GetWindowWidth()
			local calc = imgui.CalcTextSize(u8"Сообщить о проблеме и продолжить")
			imgui.SetCursorPosX( width / 2 - calc.x / 2 )
			
			if imgui.Button(fa.CIRCLE_RIGHT..u8" Сообщить о проблеме и продолжить") then
				lua_thread.create(function()
					MedOsmotrMenu3[0] = false
					if not medcard_status == "Полностью здоровый(ая)" and tonumber(medcard_narko) > 0 then
						sampSendChat("У вас есть наркозависимость "..tonumber(medcard_narko).." едениц, и статус здоровья "..medcard_status.."!")
					elseif tonumber(medcard_narko) > 0 then
						sampSendChat("У вас есть наркозависимость "..tonumber(medcard_narko).." едениц!")
					elseif not medcard_status == "Полностью здоровый(ая)" then
						sampSendChat("У вас статус здоровья "..medcard_status..", это очень плохо!")
					end
					wait(get_my_wait())
					sampSendChat("/me достаёт из мед.кейса стерильные перчатки и надевает их на руки")
					wait(get_my_wait())
					sampSendChat("/do Перчатки на руках.")
					wait(get_my_wait())
					sampSendChat("/todo Начнём мед.осмотр*улыбаясь.")
					wait(get_my_wait())
					sampSendChat("Сейчас я проверю ваше горло, откройте рот и высуните язык.")
					wait(get_my_wait())
					sampSendChat("/n Используйте /me открыл(-а) рот.")
					MedOsmotrMenu4[0] = true
				end)
			end
			
		else
		
			local width = imgui.GetWindowWidth()
			local calc = imgui.CalcTextSize(u8"Продолжить")
			imgui.SetCursorPosX( width / 2 - calc.x / 2 )
			
			if imgui.Button(fa.CIRCLE_RIGHT..u8" Продолжить") then
				lua_thread.create(function()
					MedOsmotrMenu3[0] = false
					sampSendChat("Что-ж, с мед.картой у вас все в порядке, продолжим...")
					wait(get_my_wait())
					sampSendChat("/me достаёт из мед.кейса стерильные перчатки и надевает их на руки")
					wait(get_my_wait())
					sampSendChat("/do Перчатки на руках.")
					wait(get_my_wait())
					sampSendChat("/todo Начнём мед.осмотр*улыбаясь.")
					wait(get_my_wait())
					sampSendChat("Сейчас я проверю ваше горло, откройте рот и высуните язык.")
					wait(get_my_wait())
					sampSendChat("/n Используйте /me открыл(-а) рот чтоб мы продолжили.")
					MedOsmotrMenu4[0] = true
				end)
			end
			
		end
		
		imgui.End()
		
    end
)
imgui.OnFrame(
    function() return  MedOsmotrMenu4[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm4",  MedOsmotrMenu4, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'Проведение мед.осмотра для игрока '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(u8"Ожидайте пока человек откроет рот и нажмите кнопку.")
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"Продолжить")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CIRCLE_RIGHT..u8" Продолжить") then
			lua_thread.create(function()
				MedOsmotrMenu4[0] = false
				sampSendChat("/me достаёт из мед.кейса фонарик и включив его осматривает горло человека напротив")
				wait(get_my_wait())
				sampSendChat("Хорошо, можете закрывать рот, сейчас я проверю ваши глаза.")
				wait(get_my_wait())
				sampSendChat("/me проверяет реакцию человека на свет, посветив фонарик в глаза")
				wait(get_my_wait())
				sampSendChat("/do Зрачки глаз обследуемого человека сузились.")
				wait(get_my_wait())
				sampSendChat("/todo Отлично*выключая фонарик и убирая его в мед.кейс")
				wait(get_my_wait())
				sampSendChat("Такс, сейчас я проверю ваше сердцебиение, поэтому приподнимите верхную одежду!")
				wait(get_my_wait())
				sampSendChat("/n Используйте команду /showtatu чтоб снять верхную одежду!")
				MedOsmotrMenu5[0] = true
			end)
			
		end
		
		imgui.End()
		
    end
)
imgui.OnFrame(
    function() return MedOsmotrMenu5[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm5",  MedOsmotrMenu5, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'Проведение мед.осмотра для игрока '..sampGetPlayerNickname(player_id))
		imgui.Separator()

		imgui.CenterText(u8"Ожидайте пока человек приподнимит одежду и нажмите кнопку.")
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"Продолжить")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CIRCLE_RIGHT..u8" Продолжить") then
			lua_thread.create(function()
				MedOsmotrMenu5[0] = false
				sampSendChat("/me достаёт из мед.кейса стетоскоп и приложив его к груди человека проверяет сердцебиение")
				wait(get_my_wait())
				sampSendChat("/do Сердцебиение в районе " .. math.random(55,85) .. " ударов в минуту.")
				wait(get_my_wait())
				sampSendChat("/todo С сердцебиением у вас все в порядке*убирая стетоскоп обратно в мед.кейс")
				wait(get_my_wait())
				sampSendChat("/me снимает со своих рук использованные перчатки и выбрасывает их")
				wait(get_my_wait())
				sampSendChat("Ну, что-ж я могу вам сказать...")
				wait(get_my_wait())
				
				if tonumber(medcard_narko) > 0 and not medcard_status == "Полностью здоровый(ая)" then
					sampSendChat("У вас есть наркозависимость и проблемы с мед.картой!")
					wait(get_my_wait())
					sampSendChat("Никуда не уходите, ожидайте пока я скажу что вам нужно делать")
				elseif tonumber(medcard_narko) > 0 then
					sampSendChat("У вас есть наркозависимость!")
					wait(get_my_wait())
					sampSendChat("Никуда не уходите, ожидайте пока я скажу что вам нужно делать")
				elseif medcheck_no_medcard then
					medcheck_no_medcard = false
					sampSendChat("Со здоровьем у вас все в порядке, но у вас нету мед.карты!")
					wait(get_my_wait())
					sampSendChat("Никуда не уходите, ожидайте пока я скажу что вам нужно делать")
				else
					sampSendChat("Со здоровьем у вас все в порядке!")
				end
				
				medcard_narko = 0
				medcard_status = ''
				
				medcheck = false
				
			end)
			
		end

		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return BinderWindow[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.PEN_TO_SQUARE .. u8' Редактирование команды /' .. change_cmd, BinderWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  )
		if imgui.BeginChild('##binder_edit', imgui.ImVec2(589 * MONET_DPI_SCALE, 361 * MONET_DPI_SCALE), true) then
			imgui.CenterText(fa.FILE_LINES .. u8' Описание команды:')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_description", input_description, 256)
			imgui.Separator()
			imgui.CenterText(fa.TERMINAL .. u8' Команда для использования в чате (без /):')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_cmd", input_cmd, 256)
			imgui.Separator()
			imgui.CenterText(fa.CODE .. u8' Аргументы которые принимает команда:')
	    	imgui.Combo(u8'',ComboTags, ImItems, #item_list)
	 	    imgui.Separator()
	        imgui.CenterText(fa.FILE_WORD .. u8' Текстовый бинд команды:')
		    if imgui.InputTextMultiline("##text_multiple", input_text, 8192, imgui.ImVec2(579 * MONET_DPI_SCALE, 173 * MONET_DPI_SCALE)) then
				input_text_string = u8:decode(ffi.string(input_text))
				input_text_string = input_text_string:gsub('\n', '&')
			end
		imgui.EndChild() end
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(4), 0)) then
			BinderWindow[0] = false
		end
		imgui.SameLine()
		if imgui.Button(fa.CLOCK .. u8' Изменить задержку',imgui.ImVec2(imgui.GetMiddleButtonX(4), 0)) then
			imgui.OpenPopup(fa.CLOCK .. u8' Задержка (мс) ')
		end
		if imgui.BeginPopupModal(fa.CLOCK .. u8' Задержка (мс) ', _, imgui.WindowFlags.NoResize ) then
			imgui.PushItemWidth(200 * MONET_DPI_SCALE)
			imgui.SliderFloat(u8'##waiting', waiting_slider, 1, 3)
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()
		if imgui.Button(fa.TAGS .. u8' Доступные тэги', imgui.ImVec2(imgui.GetMiddleButtonX(4), 0)) then
			imgui.OpenPopup(fa.TAGS .. u8' Список всех доступных тэгов')
		end
		if imgui.BeginPopupModal(fa.TAGS .. u8' Список всех доступных тэгов', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar ) then
			imgui.Text(u8(binder_tags_text))
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(500 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()
		if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(4), 0)) then	
			if ffi.string(input_cmd):find('%W') or ffi.string(input_cmd) == '' or ffi.string(input_description) == '' or ffi.string(input_text) == '' then
				imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Ошибка сохранения команды!')
			else
				local new_arg = ''
				if ComboTags[0] == 0 then
					new_arg = ''
				elseif ComboTags[0] == 1 then
					new_arg = '{arg}'
				elseif ComboTags[0] == 2 then
					new_arg = '{arg_id}'
				elseif ComboTags[0] == 3 then
					new_arg = '{arg_id} {arg2}'
				end
				local new_waiting = waiting_slider[0]
				local new_description = u8:decode(ffi.string(input_description))
				local new_command = u8:decode(ffi.string(input_cmd))
				local new_text = u8:decode(ffi.string(input_text)):gsub('\n', '&')
				if binder_create_command_9_10 then
					for _, command in ipairs(settings.commands_manage) do
						if command.cmd == change_cmd and command.description == change_description and command.arg == change_arg and command.text:gsub('&', '\n') == change_text then
							command.cmd = new_command
							command.arg = new_arg
							command.description = new_description
							command.text = new_text
							command.waiting = new_waiting
							save_settings()
							if command.arg == '' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [аргумент] {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg_id}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg_id} {arg2}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] [аргумент] {ffffff}успешно сохранена!', message_color)
							end
							sampUnregisterChatCommand(change_cmd)
							sampRegisterChatCommand(command.cmd, function(arg)
				
								local arg_check = false
								
								local modifiedText = command.text
								
								if command.arg == '{arg}' then
								
									if arg and arg ~= '' then
										modifiedText = modifiedText:gsub('{arg}', arg or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '{arg_id}' then
								
									if arg and arg ~= '' and isParamID(arg) then
										arg = tonumber(arg)
										modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
										modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
										modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
										modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '{arg_id} {arg2}' then
								
									if arg and arg ~= '' then
										local arg_id, arg2 = arg:match('(%d+) (.+)')
										if arg_id and arg2 and isParamID(arg_id) then
											arg_id = tonumber(arg_id)
											modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
											modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
											modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
											modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
											modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
											arg_check = true
										else
											sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
											play_error_sound()
										end
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '' then
									arg_check = true
								end

								if arg_check then
								
									lua_thread.create(function()
									
										local lines = {}

										for line in string.gmatch(modifiedText, "[^&]+") do
											table.insert(lines, line)
										end

										for _, line in ipairs(lines) do
										
											for tag, replacement in pairs(tagReplacements) do
												local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
												if success then
													line = result
												else
													
												end
											end

											sampSendChat(line)
											
											
											
												wait( tonumber(command.waiting) * 1000 )
										end
										
									end)
								end
								
							end)
							
							
						end

							end
				
					binder_create_command_9_10 = false
				
				else
				
					for _, command in ipairs(settings.commands) do

						if command.cmd == change_cmd and command.description == change_description and command.arg == change_arg and command.text:gsub('&', '\n') == change_text then
							
							command.cmd = new_command
							command.arg = new_arg
							command.description = new_description
							command.text = new_text
							command.waiting = new_waiting
							
							save_settings()
							
							if command.arg == '' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [аргумент] {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg_id}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] {ffffff}успешно сохранена!', message_color)
							elseif command.arg == '{arg_id} {arg2}' then
								sampAddChatMessage('[Hospital Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] [аргумент] {ffffff}успешно сохранена!', message_color)
							end
							
						
							
							sampUnregisterChatCommand(change_cmd)
							
							sampRegisterChatCommand(command.cmd, function(arg)
				
								local arg_check = false
				
								local modifiedText = command.text
								
								if command.arg == '{arg}' then
								
									if arg and arg ~= '' then
										modifiedText = modifiedText:gsub('{arg}', arg or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [аргумент]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '{arg_id}' then
								
									if arg and arg ~= '' and isParamID(arg) then
										arg = tonumber(arg)
										modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
										modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
										modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
										modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '{arg_id} {arg2}' then
								
									if arg and arg ~= '' then
										local arg_id, arg2 = arg:match('(%d+) (.+)')
										if arg_id and arg2 and isParamID(arg_id) then
											arg_id = tonumber(arg_id)
											modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
											modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
											modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
											modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
											modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
											arg_check = true
										else
											sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
											play_error_sound()
										end
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. command.cmd .. ' [ID игрока] [аргумент]', message_color)
										play_error_sound()
									end
									
								elseif command.arg == '' then
									arg_check = true
								end

								if arg_check then
								
									lua_thread.create(function()
									
										local lines = {}

										for line in string.gmatch(modifiedText, "[^&]+") do
											table.insert(lines, line)
										end

										for _, line in ipairs(lines) do
										
											for tag, replacement in pairs(tagReplacements) do
												local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
												if success then
													line = result
												else
													
												end
											end

											sampSendChat(line)
											
											
											
												
											
												wait( tonumber(command.waiting) * 1000 )
										end
										
									end)
								end
								
							end)
							
							
						end

					end
				
				end

				
				BinderWindow[0] = false
			
			end
			
		end
		if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Ошибка сохранения команды!', _, imgui.WindowFlags.AlwaysAutoResize ) then
			
			if ffi.string(input_cmd):find('%W') then
				imgui.BulletText(u8" В команде можно использовать только англ. буквы и/или цифры!")
			elseif ffi.string(input_cmd) == '' then
				imgui.BulletText(u8" Команда не может быть пустая!")
			end
			
			if ffi.string(input_description) == '' then
				imgui.BulletText(u8" Описание команды не может быть пустое!")
			end
			
			if ffi.string(input_text) == '' then
				imgui.BulletText(u8" Бинд команды не может быть пустой!")
			end
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(300 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			
			imgui.End()
		end	
			
		
		
		imgui.End()
    end
)

imgui.OnFrame(
    function() return MembersWindow[0] end,
    function(player)

		if tonumber(#members) >= 16 then
			sizeYY = 413
		else
			sizeYY = 24.5 * ( tonumber(#members) + 1 )
		end

		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, sizeYY * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		
		local add = ''
		
		if tonumber(#members) == 1 then
			add = u8'сотрудник'
		elseif tonumber(#members) > 1 and tonumber(#members) < 5 then
			add = u8'сотрудникa'
		elseif tonumber(#members) >= 5 then
			add = u8'сотрудников'
		end
		
		imgui.Begin(fa.BUILDING_SHIELD .. " " ..  u8(members_fraction) .. " - " .. #members .. ' ' .. add .. u8' онлайн', MembersWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  )

		
		for i, v in ipairs(members) do

			imgui.Columns(3)
			
			local r, g, b
			if v.working then r, g, b = 255, 255, 255 else r, g, b = 255, 59, 59 end
			local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
			
			if tonumber(v.afk) > 0 and tonumber(v.afk) < 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. v.afk .. 's]')
			elseif tonumber(v.afk) >= 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. math.floor( tonumber(v.afk) / 60 ) .. 'm]')
			else
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. ']')
			end
			
			imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.rank) .. ' (' .. u8(v.rank_number) .. ')')
			imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.warns .. '/3'))
			imgui.SetColumnWidth(-1, 75 * MONET_DPI_SCALE)
			imgui.Columns(1)
			imgui.Separator()
				
		end
		
		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return NoteWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.FILE_PEN .. ' '.. show_note_name, NoteWindow, imgui.WindowFlags.AlwaysAutoResize )
		imgui.Text(show_note_text:gsub('&','\n'))
		imgui.Separator()
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
			NoteWindow[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300 * MONET_DPI_SCALE, 415 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.USER_INJURED..' '..sampGetPlayerNickname(player_id)..'['..player_id..']##FastMenu', FastMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  )
		
		if imgui.Button(u8"Привествие",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("Здраствуйте", player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Позвать за собой",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("за мной",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Обычное лечение",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/heal {arg_id}",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Лечение охранника",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/healactor {arg_id}",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Лечение от наркозависимости",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/healbad {arg_id}",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Оформление мед.страховки",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/givemedinsurance {arg_id}",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Оформление мед.карты",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			medcard(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Проведение мед.осмотра пилота",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/medcheck {arg_id}",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Выдача антибиотиков",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			antibiotik(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Выдача рецептов",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			recept(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"Выгнать из больницы",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/expel {arg_id}",player_id)
			FastMenu[0] = false
		end
	
		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return LeaderFastMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		--imgui.SetNextWindowSize(imgui.ImVec2(300 * MONET_DPI_SCALE, 240 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.USER_INJURED..' '..sampGetPlayerNickname(player_id)..'['..player_id..']##LeaderFastMenu', LeaderFastMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize  )
		
		if imgui.Button(u8"Принять в организацию",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/invite {arg_id}", player_id)
			LeaderFastMenu[0] = false
		end
		
		if imgui.Button(u8"Уволить из организации",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			sampSetChatInputEnabled(true)
			sampSetChatInputText('/uval '..player_id..' ')
			LeaderFastMenu[0] = false
		end
	
		if imgui.Button(u8"Выдать выговор",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			sampSetChatInputEnabled(true)
			sampSetChatInputText('/vig '..player_id..' ')
			LeaderFastMenu[0] = false
		end
		
		if imgui.Button(u8"Снять выговор",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/unfwarn {arg_id}", player_id)
			LeaderFastMenu[0] = false
		end
		
		if imgui.Button(u8"Изменить ранг",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			sampSetChatInputEnabled(true)
			sampSetChatInputText('/gr '..player_id..' ')
			LeaderFastMenu[0] = false
		end
		
		if imgui.Button(u8"Заглушить на 10 минут",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			sampSetChatInputEnabled(true)
			sampSetChatInputText('/fmutes '..player_id..' ')
			LeaderFastMenu[0] = false
		end
		
		imgui.End()
		
    end
)

imgui.OnFrame(
    function() return FastHealMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8.5, sizeY / 1.9), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##fast_heal", FastHealMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar +  imgui.WindowFlags.AlwaysAutoResize )
		if imgui.Button(fa.KIT_MEDICAL..u8' Вылечить '..sampGetPlayerNickname(heal_in_chat_player_id)) then
			command("/heal {arg_id}",heal_in_chat_player_id)
			heal_in_chat = false
			heal_in_chat_id = nil
			FastHealMenu[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenuButton[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8.5, sizeY / 2.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##fast_menu_button", FastMenuButton, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar  )
		if imgui.Button(fa.IMAGE_PORTRAIT..u8' Взаимодействие ') then
			if tonumber(#get_players()) == 1 then
				show_fast_menu(get_players()[1])
				FastMenuButton[0] = false
			elseif tonumber(#get_players()) > 1 then
				FastMenuPlayers[0] = true
				FastMenuButton[0] = false
			end
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenuPlayers[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.HOSPITAL..u8" Выберите игрока##fast_menu_players", FastMenuPlayers, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize  )
		if tonumber(#get_players()) == 0 then
			show_fast_menu(get_players()[1])
			FastMenuPlayers[0] = false
		elseif tonumber(#get_players()) >= 1 then
			for _, playerId in ipairs(get_players()) do
				local id = tonumber(playerId)
				if imgui.Button(sampGetPlayerNickname(id), imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
					if tonumber(#get_players()) ~= 0 then show_fast_menu(id) end
					FastMenuPlayers[0] = false
				end
			end
		end
		imgui.End()
    end
)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterColumnButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
	
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() 
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count)
end
function apply_dark_theme()
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
end
function apply_moonmonet_theme()
	local generated_color = moon_monet.buildColors(settings.general.moonmonet_theme_color, 1.0, true)
	imgui.SwitchContext()
	imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
	imgui.GetStyle().Colors[imgui.Col.Text] = ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TextDisabled] = ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.WindowBg] = ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ChildBg] = ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PopupBg] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Border] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Separator] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	imgui.GetStyle().Colors[imgui.Col.FrameBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBg] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0,0,0,0)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.CheckMark] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.SliderGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Button] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ButtonActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Tab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Header] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.HeaderActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotLines] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x99):as_vec4()
end
function argbToHexWithoutAlpha(alpha, red, green, blue)
    return string.format("%02X%02X%02X", red, green, blue)
end
function join_argb(a, r, g, b)
    local argb = b 
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))    
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end
function ARGBtoRGB(color)
    return bit.band(color, 0xFFFFFF)
end
function rgb2hex(r, g, b)
    local hex = string.format("#%02X%02X%02X", r, g, b)
    return hex
end
function ColorAccentsAdapter(color)
    local a, r, g, b = explode_argb(color)
    local ret = {a = a, r = r, g = g, b = b}
    function ret:apply_alpha(alpha)
        self.a = alpha
        return self
    end
    function ret:as_u32()
        return join_argb(self.a, self.b, self.g, self.r)
    end
    function ret:as_vec4()
        return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
    end
    function ret:as_argb()
        return join_argb(self.a, self.r, self.g, self.b)
    end
    function ret:as_rgba()
        return join_argb(self.r, self.g, self.b, self.a)
    end
    function ret:as_chat()
        return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
    end  
    return ret
end

function onScriptTerminate(script, game_quit)
    if script == thisScript() and not game_quit and not reload_script then
		sampAddChatMessage('[Hospital Helper] {ffffff}Произошла неизвестная ошибка, хелпер приостановил свою работу!', message_color)
		if not isMonetLoader() then 
			sampAddChatMessage('[Hospital Helper] {ffffff}Используйте ' .. message_color_hex .. 'CTRL {ffffff}+ ' .. message_color_hex .. 'R {ffffff}чтобы перезапустить хелпер.', message_color)
		end
		play_error_sound()
    end
end