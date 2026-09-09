local _, addon = ...

local util = addon.utility
local _G = _G

local WBTracker = CreateFrame("Frame") -- Hidden Frame used for updating information about the Warband Bank

local function UpdateWarbandBankMoney()
   if not (C_Bank and C_Bank.FetchDepositedMoney and Enum.BankType and Enum.BankType.Account) then
      return
   end

   local money = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
   addon.debugPrint("WarbandBankMoney", money)
   _G.WOWMMGlobal.WarbandBankMoney = money or 0
end

local function EventHandler(self, event, ...)
   addon.debugPrint("WarbandBankTracker Event", event, ...)
   UpdateWarbandBankMoney()
end

util.RegisterEvents(WBTracker, EventHandler,  'PLAYER_ENTERING_WORLD',
                                              'BANKFRAME_OPENED',
                                              'BANKFRAME_CLOSED',
                                              'ACCOUNT_MONEY')
