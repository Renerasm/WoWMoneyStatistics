local _, addon = ...

local mt = addon.mt
local util = addon.utility
local _G = _G

local player = UnitName("player")
local realm = GetRealmName()

local WARBAND_BANK_UUID = 'WARBANDBANK_01'  -- Deposits/Withdrawals to the Warband Bank (not Earned or Spent, just relocated)

local WBTracker = CreateFrame("Frame") -- Hidden Frame used for updating information about the Warband Bank

local function IsWarbandBankAvailable()
   return C_Bank and C_Bank.FetchDepositedMoney and Enum.BankType and Enum.BankType.Account
end

local function GetWarbandBankMoney()
   if not IsWarbandBankAvailable() then
      return 0
   end
   return C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0
end

local function UpdateWarbandBankMoney()
   local money = GetWarbandBankMoney()
   addon.debugPrint("WarbandBankMoney", money)
   _G.WOWMMGlobal.WarbandBankMoney = money
end

-- Money moved to/from the Warband Bank never leaves the player's control, it's
-- just stored elsewhere, so it should not be counted towards Earned or Spent.
local function OnTrigger(uuid, t, m)
   local pcash = _G.WOWMMGlobal[realm].Chars[player].Cash
   util.UpdatePlayerCash(pcash + m)
end

local function Classify(uuid)
   local before = _G.WOWMMGlobal.WarbandBankMoney or 0
   local after = GetWarbandBankMoney()
   UpdateWarbandBankMoney()

   local delta = after - before
   if delta == 0 then
      return
   end

   return uuid, -delta
end

local function EventHandler(self, event, ...)
   addon.debugPrint("WarbandBankTracker Event", event, ...)
   UpdateWarbandBankMoney()
end

mt.RegisterTracker(WARBAND_BANK_UUID, 'WARBANDBANK', 'BANKFRAME_OPENED', 'BANKFRAME_CLOSED', OnTrigger)
mt.RegisterDeterminant(WARBAND_BANK_UUID, 'ACCOUNT_MONEY', Classify)

util.RegisterEvents(WBTracker, EventHandler,  'PLAYER_ENTERING_WORLD',
                                              'BANKFRAME_OPENED',
                                              'BANKFRAME_CLOSED')
