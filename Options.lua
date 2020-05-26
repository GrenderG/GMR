if not GMR then 
	GMR = {} 
end

GMR.ChatFrame_OnEvent_Old = ChatFrame_OnEvent

GMR.CurrentChatFrame = {}

function GMR.ChatFrame_OnEvent_New(event)
	if not (event == "CHAT_MSG_SYSTEM" and SLib.GetTimer("DelayOnSendGetCommand")) then
		GMR.ChatFrame_OnEvent_Old(event)
	end
end

function GMR.SetSystemMessHook(pos)
	if pos then
		ChatFrame_OnEvent = GMR.ChatFrame_OnEvent_New
	else
		ChatFrame_OnEvent = GMR.ChatFrame_OnEvent_Old
	end
end

function GMR.CreateOptionsFrame()
	local f = CreateFrame("Frame", "GMR_OptionsFrame", UIParent)
	GMR.MakeMoovable(f)
	f:SetFrameStrata("HIGH")
	f:SetWidth(400)
	f:SetHeight(600)
	f:SetBackdrop( { 
  		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
  		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
  		tile = true, tileSize = 32, edgeSize = 32, 
  		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	f:SetPoint("CENTER", UIParent, "CENTER")
	GMR.AddCloseButton(f)
	f:Hide()
	return f
end

function GMR.BuildOptionsFrame()
	GMR.OptionFrame = GMR.CreateOptionsFrame()
	local cb1 = GMR.CreateCheckButton("HideSysMess", 50, 100, GMR.OptionFrame, "TOPLEFT", "TOPLEFT", "Hide System Messages")
	local s = cb1:GetScript("OnClick")
	cb1:SetScript("OnClick", function() 	
		GMR.SetSystemMessHook(this:GetChecked())
		s()
	end)
	GMR.CreateTitle("HideSysMess", 10, 0, cb1, "Hide System Messages: ", "LEFT", "RIGHT")
end