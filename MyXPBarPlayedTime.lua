-- MyXPBar Played Time
-- Adds "(time at this level · total time played)" next to the level text of
-- MyXPBar, without changing MyXPBar itself.

-- "total" and the short units for days, hours and minutes, per client language
local LOCALES = {
    enUS = { total = "total",  d = "d",  h = "h",  m = "m" },
    deDE = { total = "gesamt", d = "T",  h = "h",  m = "m" },
    frFR = { total = "total",  d = "j",  h = "h",  m = "min" },
    esES = { total = "total",  d = "d",  h = "h",  m = "min" },
    ptBR = { total = "total",  d = "d",  h = "h",  m = "min" },
    ruRU = { total = "всего",  d = "д",  h = "ч",  m = "мин" },
    koKR = { total = "총",     d = "일", h = "시간", m = "분" },
    zhCN = { total = "总计",   d = "天", h = "小时", m = "分" },
    zhTW = { total = "總計",   d = "天", h = "小時", m = "分" },
}
LOCALES.esMX = LOCALES.esES
LOCALES.enGB = LOCALES.enUS
local L = LOCALES[GetLocale()] or LOCALES.enUS

-- =========================================================
-- Time played, counted locally between two /played answers
-- =========================================================
local played = { total = nil, clock = nil, levelStart = nil }

local function NowTotal()
    if not played.total then return nil end
    return played.total + (GetTime() - played.clock)
end

-- The event values can be "secret" on newer clients: only plain numbers count
local function Plain(value)
    if value == nil then return nil end
    if issecretvalue then
        local ok, secret = pcall(issecretvalue, value)
        if not ok or secret then return nil end
    end
    if type(value) ~= "number" then return nil end
    return value
end

-- Ask the server without the chat message: the chat frames stop listening to
-- the answer for a moment and get it back right after
local mutedFrames

local function RestoreChat()
    if not mutedFrames then return end
    for _, chatFrame in ipairs(mutedFrames) do
        pcall(chatFrame.RegisterEvent, chatFrame, "TIME_PLAYED_MSG")
    end
    mutedFrames = nil
end

local function RequestPlayedSilently()
    if not RequestTimePlayed or mutedFrames then return end
    mutedFrames = {}
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame and chatFrame.IsEventRegistered and chatFrame:IsEventRegistered("TIME_PLAYED_MSG") then
            chatFrame:UnregisterEvent("TIME_PLAYED_MSG")
            tinsert(mutedFrames, chatFrame)
        end
    end
    RequestTimePlayed()
    C_Timer.After(5, RestoreChat) -- In case the answer never comes
end

-- "12m", "4h 12m", "2d 3h" (units from the client language)
local function FormatDuration(seconds)
    seconds = math.max(math.floor(seconds), 0)
    local days = math.floor(seconds / 86400)
    local hours = math.floor(seconds % 86400 / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    if days > 0 then
        return days .. L.d .. " " .. hours .. L.h
    elseif hours > 0 then
        return hours .. L.h .. " " .. minutes .. L.m
    end
    return minutes .. L.m
end

-- =========================================================
-- The text next to MyXPBar's level
-- =========================================================
local levelText, playedText

-- MyXPBar's frames have no names apart from the main one. The XP bar is its
-- first status bar, and the level text the first text on that bar.
local function FindLevelText()
    local main = _G.MyXPBarFrame
    if not main then return nil end
    for _, child in ipairs({ main:GetChildren() }) do
        if child:GetObjectType() == "StatusBar" then
            for _, region in ipairs({ child:GetRegions() }) do
                if region:GetObjectType() == "FontString" then return region end
            end
            return nil
        end
    end
end

local function UpdateText()
    if not playedText then return end
    playedText:SetShown(levelText:IsShown())
    local total = NowTotal()
    if not total then
        playedText:SetText("")
        return
    end
    local text = "(" .. FormatDuration(total - (played.levelStart or total)) ..
        "  ·  " .. L.total .. " " .. FormatDuration(total) .. ")"
    if playedText:GetText() ~= text then playedText:SetText(text) end
end

local function Attach()
    if playedText then return true end
    levelText = FindLevelText()
    if not levelText then return false end
    playedText = levelText:GetParent():CreateFontString(nil, "OVERLAY")
    playedText:SetFontObject(levelText:GetFontObject() or "GameFontNormal")
    playedText:SetTextColor(0.75, 0.75, 0.75)
    playedText:SetPoint("LEFT", levelText, "RIGHT", 6, 0)
    -- Hidden together with the level text (reputation only mode)
    hooksecurefunc(levelText, "SetShown", UpdateText)
    hooksecurefunc(levelText, "Show", UpdateText)
    hooksecurefunc(levelText, "Hide", UpdateText)
    C_Timer.NewTicker(1, UpdateText)
    UpdateText()
    return true
end

-- =========================================================
-- Events
-- =========================================================
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("TIME_PLAYED_MSG")

events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not Attach() then C_Timer.After(1, Attach) end
        -- Other addons often ask at login too: only ask when nobody did
        if not played.total then
            C_Timer.After(6, function()
                if not played.total then RequestPlayedSilently() end
            end)
        end
    elseif event == "TIME_PLAYED_MSG" then
        local total, levelTime = Plain((...)), Plain((select(2, ...)))
        if total then
            played.total, played.clock = total, GetTime()
            if levelTime then played.levelStart = total - levelTime end
        end
        C_Timer.After(0, RestoreChat)
        UpdateText()
    elseif event == "PLAYER_LEVEL_UP" then
        played.levelStart = NowTotal()
        UpdateText()
    end
end)
