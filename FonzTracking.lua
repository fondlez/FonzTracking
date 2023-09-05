local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, { __index = _G }))

local loglevel = 0

do
  local select, tostring, strjoin = select, tostring, strjoin
  
  function strvarg(...)
    if select("#", ...) > 0 then
      return tostring((...)), strvarg(select(2, ...))
    end
  end
  
  function print(...)
    DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", strvarg(...)))
  end
  
  function debug(...)
    if loglevel == 0 then return end
    print("|cff9900ffdebug:|r", GetTime(), ...)
  end
end

local SHAPESHIFT_AURAS = {
  --EN
  ["Cat Form"] = true,
  --ES
  ["Forma felina"] = true,
  --DE
  ["Katzengestalt"] = true,
  --FR
  ["Forme de félin"] = true,
  --KR
  ["표범 변신"] = true,
  --RU
  ["Облик кошки"] = true,
  --TW
  ["猎豹形态"] = true,
}
local FORCED_AURAS = {
  --EN
  ["Track Humanoids"] = true,
  --ES
  ["Rastrear humanoides"] = true,
  --DE
  ["Humanoide aufspüren"] = true,
  --FR
  ["Pistage des humanoïdes"] = true,
  --KR
  ["인간형 추적"] = true,
  --RU
  ["Выслеживание гуманоидов"] = true,
  --TW
  ["追踪人型生物"] = true,
}

local GetNumTrackingTypes = GetNumTrackingTypes
local GetTrackingInfo = GetTrackingInfo
local SetTracking = SetTracking
local InCombatLockdown = InCombatLockdown

-- Tracking ids can change depending on shapeshift. Using name is more reliable.
function getTrackingByName(required_name)
  for id = 1, GetNumTrackingTypes() do
    local name, _, active = GetTrackingInfo(id)
    if name == required_name then
      return id
    end
  end
end

local frame = CreateFrame("Frame")
-- Fires when an addon and its saved variables are loaded
frame:RegisterEvent("ADDON_LOADED")
-- Fired when the player enters the world, reloads
-- the UI, enters/leaves an instance or battleground, or respawns at a
-- graveyard. Also fires any other time the player sees a loading screen
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Fires when a combat log event is received
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(...)
  _M[event](...)
end)

local dispatcher = CreateFrame("Frame")
dispatcher:SetScript("OnUpdate", function()
  if dispatcher.func and GetTime() >= dispatcher.timestamp then
    debug("dispatcher")
    pcall(dispatcher.func, unpack(dispatcher.args))
    dispatcher.func = nil
    dispatcher:Hide()
  end
end)
dispatcher:Hide()

function ADDON_LOADED(self, event, addon_name)
  if addon_name == "FonzTracking" then
    -- Saved variable, to allow client tracking to persist across sessions and 
    -- reloads
    _G["FonzTrackingCDB"] = _G["FonzTrackingCDB"] or {}
    
    -- Hook for client initiated tracking type changes. Track the name, not id.
    hooksecurefunc("SetTracking", function(id)
      FonzTrackingCDB.tracking = GetTrackingInfo(id)
    end)
  end
end

function PLAYER_ENTERING_WORLD()
  SetTracking(getTrackingByName(FonzTrackingCDB.tracking))
end

local form_changed = 0

--[[
  Assumptions:
  1. forced auras can never be initiated by the client API (SetTracking)
  2. forced aura checks relies on them appearing as combat log events.
  
  Using other events, e.g. MINIMAP_UPDATE_TRACKING, seems unreliable because
  those events can arrive out of order (before a shapeshift).
--]]
function COMBAT_LOG_EVENT_UNFILTERED(
    self, event, timestamp, event_type, 
    source_guid, source_name, source_flags, 
    dest_guid, dest_name, dest_flags, 
    spell_id, spell_name, spell_school, 
    aura_type, amount, ...)
  -- Not me
  if bit.band(dest_flags, COMBATLOG_OBJECT_AFFILIATION_MASK) 
    ~= COMBATLOG_OBJECT_AFFILIATION_MINE then return end
  -- In combat
  if InCombatLockdown() then return end
  -- Not an aura
  if event_type ~= "SPELL_AURA_APPLIED" then return end
  
  local tracking = FonzTrackingCDB.tracking
  
  if SHAPESHIFT_AURAS[spell_name] then
    debug("COMBAT_LOG_EVENT_UNFILTERED", spell_name, form_changed, 
      tracking)
  
    form_changed = form_changed + 1
  elseif FORCED_AURAS[spell_name] then
    debug("COMBAT_LOG_EVENT_UNFILTERED", spell_name, form_changed,
      tracking)
    -- Ignore aura changes when no shapeshift happened first
    if form_changed < 1 then return end

    debug(" - form changed")
    form_changed = 0
    
    -- Schedule an API call after global cooldown (GCD) to reset tracking 
    -- to prior/client-selected tracking type
    dispatcher.func = SetTracking
    dispatcher.args = { getTrackingByName(tracking) }
    -- Standard GCD = 1.5s
    dispatcher.timestamp = GetTime() + 1.5
    dispatcher:Show()
  end
end
