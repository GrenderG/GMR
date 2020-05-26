if not GMR then 
	GMR = {} 
end

function GMR.CreateTicketFrame()
	local f = CreateFrame("Frame", "TicketTable", UIParent)
	GMR.MakeMoovable(f)
	--f:SetFrameStrata("HIGH")
	f:SetWidth(800) -- CUSTOM: ticket total frame
	f:SetHeight(675)
	f:SetBackdrop( { 
  		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
  		tile = true, tileSize = 32, edgeSize = 32, 
  		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	f:SetPoint("CENTER", UIParent, "CENTER")
	GMR.AddCloseButton(f)
	f:Hide()
	return f
end

GMR.CurrentTicketTableElements = {}

GMR.ButtonChilds = {}

function GMR.UpdateTicketTableElement(Button, value, text_update)
	
	if not GMR.ButtonChilds[Button] then
		GMR.ButtonChilds[Button] = {}
	end

	for key, val in pairs(GMR.ButtonChilds[Button]) do
		val:ClearAllPoints()
		val:Hide()
	end
	local elem_l
	if text_update then
		offset = 10
		for iter = 1, getn(text_update) do			
			t = GMR.CreateTitle(Button:GetName().."_"..iter, offset, 0, Button, "")
			GMR.ButtonChilds[Button][t:GetName()] = t
			t:SetPoint("LEFT", Button, "LEFT", offset, 0)
			t:SetText(text_update[iter])
			elem_l = GMR.TicketButtonText.elem_length[iter]
			if (elem_l) then
				offset = 10 + elem_l + 10*iter
			else
				offset = 10 + 10*iter
			end
			t:Show()
		end		
		local n = 5 --getn(GMR.TicketButtonText.elem_length)
		local max_l = 262.27161455639
		--local max_l = 10 + GMR.TicketButtonText.elem_length[n] + 10*n
		Button:SetWidth(max(GMR.Tables["Ticket"]:GetWidth(), max_l))
		Button:SetAlpha(0.8)
	end	
	Button:SetScript("OnEnter", 
		function()
		    GameTooltip:ClearAllPoints()
		    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		    if GMR.TicketData[GMR.CurrentTicketTableElements[value]] and GMR.TicketData[GMR.CurrentTicketTableElements[value]].num then
			    GameTooltip:AddLine("Ticket Data:")
			    GameTooltip:AddLine("Creator: "..GMR.TicketData[GMR.CurrentTicketTableElements[value]].creator)
			    GameTooltip:AddLine("Created: "..GMR.TicketData[GMR.CurrentTicketTableElements[value]].created)
			    if GMR.TicketData[GMR.CurrentTicketTableElements[value]].changed then
					GameTooltip:AddLine("Changed: "..GMR.TicketData[GMR.CurrentTicketTableElements[value]].changed)
				end
			    if GMR.TicketData[GMR.CurrentTicketTableElements[value]].assigned then
			    	GameTooltip:AddLine("Assigned: "..GMR.TicketData[GMR.CurrentTicketTableElements[value]].assigned)
			    end
			    GameTooltip:AddLine("Ticket ID: "..GMR.TicketData[GMR.CurrentTicketTableElements[value]].num)
			end
			GameTooltip:Show();
		end
	)
	Button:SetScript("OnClick", 
		function()
		    if not GMR.BlockTicketLoad then
		       	GMR.LoadTicket(GMR.CurrentTicketTableElements[value]);
		       	GMR.BlockTicketLoad = true
		    end
	    end
	)
	if MouseIsOver(Button) then
		Button:GetScript("OnLeave")()
		Button:GetScript("OnEnter")()
	end
	if not text_update then
		SLib.CallStack.NewCall(GMR.UpdateButtonsText, 0.01, value)
	end
end

function GMR.CreateTicketTableElemets(number)
	local f, t
	local result = {}
	for i = 1, number do
		f = CreateFrame("Button", "ButtonTicketTable"..i, nil, "CommandButtonTemplate")
		--f:SetFrameStrata("HIGH")
		f:SetHeight(20)
		f:SetWidth(200)
		f:SetScript("OnLeave", 
			function()
		       GameTooltip:Hide();
		    end
		)		
		t = f:GetFontString()
		t:SetPoint("LEFT", f, "LEFT", 15, 0)
		GMR.Buttons["ButtonTicketTable"..i] = f
		result[getn(result)+1] = f
	end	
	return result
end

function GMR.SortTicketTable()
--[[	local mas = GMR.CurrentTicketTableElements
	if mas then
		local access = GMR.CheckButtons["accesssortTicketTable"]:GetChecked()
		if not access then
			function sort_rule(a, b)
				return a < b
			end
		else
			function sort_rule(a, b)
				if tonumber(GMR_command_data[a][1]) == tonumber(GMR_command_data[b][1]) then
					return a < b
				else
					return (tonumber(GMR_command_data[a][1]) < tonumber(GMR_command_data[b][1]))
				end
			end
		end
		table.sort(mas, sort_rule)
	end]]
end

function GMR.FindInTicketTable(str)
	GMR.CurrentTicketTableElements = {}
	local iter = 1
	for i = 1, tonumber(GMR.MAX_TICKETS) do
		if GMR.TicketData[i] then
			if not GMR.TicketData[i].created then
				GMR.Print("index "..i)
				GMR.Print("creator ")
				GMR.Print(GMR.TicketData[i].creator)
				GMR.Print("created ")
				GMR.Print(GMR.TicketData[i].created)
				GMR.Print("changed ")
				GMR.Print(GMR.TicketData[i].changed)
				GMR.Print("assigned ")
				GMR.Print(GMR.TicketData[i].assigned)
			end
			str_find = GMR.TicketData[i].creator.." "..GMR.TicketData[i].created..GMR.TicketData[i].assigned
			local name = GMR.TicketData[i].creator
			if GMR.CheckButtons["Characters scan type"]:GetChecked() and GMR.CharacterBase[name] then
				for k = 1, getn(GMR.CharacterBase[name]) do
					str_find =  str_find..GMR.CharacterBase[name][k]
				end
			end
			if string.find(string.lower(str_find), str) then
				GMR.CurrentTicketTableElements[iter] = i
				iter = iter + 1
			end
		end
	end
	return getn(GMR.CurrentTicketTableElements)
end

GMR.TICKET_BUTTONS_NUM = 20

GMR.MAX_TICKETS = 1000000

GMR.TicketScanType = "online"


function GMR.SetDropDownFrameWidth(frame, width)
	frame:SetWidth(width)
	local t = getglobal(frame:GetName().."Middle")
	t:SetWidth(width)
end

function GMR.CreateTicketTemplate(name, parent, width, point, rel_point, x, y)
	GMR.BuildTicketTemplateFrame(name)
	local b = CreateFrame("Frame", "GMR_"..name, GMR.TicketFrame, "GMRDropDown")
	GMR.SetDropDownFrameWidth(b, width)
	b:SetPoint(point, parent, rel_point, x - 20, -y)
	b = getglobal(b:GetName().."Button")
	b:SetScript("OnClick", 
		function()
			if GMR.Tables["TicketTemplate"..name]:IsShown() then
				GMR.Tables["TicketTemplate"..name]:Hide()
			else
				GMR.CurrentTicketTemplate = name
				GMR.Tables["TicketTemplate"..name]:SetPoint("TOPLEFT", GMR.TicketFrame, "TOPLEFT", this:GetParent():GetLeft()-GMR.TicketFrame:GetLeft() + 20, this:GetParent():GetTop() - GMR.TicketFrame:GetTop() - 50)
				GMR.Tables["TicketTemplate"..name]:Show()
				GMR.Tables._Update("TicketTemplate"..name)
			end
		end
	)
	return b
end

function GMR.FillTicketFrame()
	local b, b1, b2, b3, b4, b5, b5_1, b6, e1, e2, e3, t_b, s, s1, b7, b8, b9, num_l, char_l, b8_1, zeroX, zeroY
	local offs_x = GMR.Tables["Ticket"]:GetWidth() + 75 -- CUSTOM: Ticket Table Frame
	local offs_y = 50
	char_l = GMR.CreateTitle("CurrentTicketCreator", 15, 15, GMR.TicketFrame, "Character: ", "TOPLEFT", "TOPLEFT")
	num_l = GMR.CreateTitle("CurrentTicketNum", 275, 15, GMR.TicketFrame, "Ticket num: ", "TOPLEFT", "TOPLEFT")
	GMR.CreateEditScrollBox("TicketReportText", offs_x-450, offs_y, GMR.TicketFrame, 400, 100, "TOPLEFT", "TOPLEFT", _, true)
	local t = GMR.CreateTitle("TotalTickets", 220, 175, GMR.TicketFrame, "Total Tickets: "..GMR.MAX_TICKETS, "TOPLEFT", "TOPLEFT")
 	t:Show()

	b9 = GMR.CreateButton("RefreshTickets",  0, 440, 130, 30, GMR.Tables["Ticket"], "BOTTOM", "TOP", "Refresh", "")
	b9:SetScript("OnClick",
		function()
			GMR.UpdateMaxTickets()
		end
	)

	b7 = GMR.CreateButton("CloseTicket",  offs_x-20, offs_y-35, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Close Ticket", "Close this ticket")
	b7:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.num then 
				GMR.SendCommandSafe(".ticket close "..GMR.CurrentTicketInfo.num, "ticket close")
				GMR.Print(SLib.GetRandomColor().."Ticket "..GMR.CurrentTicketInfo.num.." closed and archived.".."\124r")
			end
		end
	)
	b5_1 = GMR.CreateButton("UnAssignTicket",  offs_x-20, offs_y-5, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Unassign", {"Unassign this ticket.", ""})
	b5_1:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.num then 
				SendChatMessage(".ticket unassign "..GMR.CurrentTicketInfo.num, "GUILD")
			end
		end
	)
		b1 = GMR.CreateButton("EscalateTicket2",  offs_x-20, offs_y+25, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Escalate", "Give this problem to GM with higher rank, take a rest.")
	b1:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.num then 
				SendChatMessage(".ticket unassign "..GMR.CurrentTicketInfo.num, "GUILD")
				GMR.SendCommandSafe(".ticket escalate "..GMR.CurrentTicketInfo.num)
			end
		end
	)
	e3 = GMR.CreateEditBox("GMAssignName", offs_x-15, offs_y+55, GMR.TicketFrame, 115, 25, "TOPLEFT", "TOPLEFT", "Assign the ticket to specified GM")

	b5 = GMR.CreateButton("AssignTicket",  offs_x-20, offs_y+85, 120, 30, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Assign", {"Give this ticket to anybody.", " If textbox empty - assign to yourself."})
	b5:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.num then 
				SendChatMessage(".ticket unassign "..GMR.CurrentTicketInfo.num, "GUILD")
				local assigned_person = GMR.EditBoxes["GMAssignName"]:GetText()
				if assigned_person == "" then assigned_person = UnitName("player") end
				SendChatMessage(".ticket assign "..GMR.CurrentTicketInfo.num.." "..assigned_person, "GUILD")
				if assigned_person == UnitName("player") then GMR.Print(SLib.GetRandomColor().."Assigned to "..assigned_person.."\124r") end
			end
		end
	)
	b8 = GMR.CreateButton("GotoTicketerCreator",  offs_x+100, offs_y-35, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Go to Player", "")
	b8:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				GMR.SendCommandSafe(".goname "..GMR.CurrentTicketInfo.creator, "goname")
			end
		end
	)

	local b8_2 = GMR.CreateButton("SummonCreator",  offs_x+100, offs_y-5, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Summon Player", "")
	b8_2:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				GMR.SendCommandSafe(".namego "..GMR.CurrentTicketInfo.creator, "namego")
			end
		end
	)

	b8_1 = GMR.CreateButton("BanInfoCreator",  offs_x+100, offs_y+25,  120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Ban Info", "")
	b8_1:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				SendChatMessage(".baninfo c "..GMR.CurrentTicketInfo.creator, "GUILD")
			end
		end
	)

	local b8_3 = GMR.CreateButton("PlayerInfo",  offs_x+100, offs_y+55, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Player Info", "")
	b8_3:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				GMR.SendCommandSafe(".pinfo "..GMR.CurrentTicketInfo.creator, "pinfo")
			end
		end
	)

	local b8_4 = GMR.CreateButton("LookupPlayerIP",  offs_x+100, offs_y+85, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Lookup by IP", "")
	b8_4:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				SendChatMessage(".lookup player ip "..GMR.CurrentTicketInfo.creator, "GUILD")
			end
		end
	)

	local oAss1 = GMR.CreateButton("oAssGMCN",  offs_x+220, offs_y-5, 90, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Chinese GM", "")
	oAss1:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				SendChatMessage(".ticket assign "..GMR.CurrentTicketInfo.num.." Geemcn", "GUILD")
			end
		end
	)

	local oAss2 = GMR.CreateButton("oAssGMOnline",  offs_x+220, offs_y+25, 90, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Online GM", "")
	oAss2:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				SendChatMessage(".ticket assign "..GMR.CurrentTicketInfo.num.." Needsonline", "GUILD")
			end
		end
	)

	local oAss3 = GMR.CreateButton("oAssRank4",  offs_x+220, offs_y+55, 90, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Rank 4 GM", "")
	oAss3:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
				SendChatMessage(".ticket assign "..GMR.CurrentTicketInfo.num.." Rankfour", "GUILD")
			end
		end
	)


	local char_whisper = GMR.CreateTitle("textWhisper", offs_x-20, offs_y+140, GMR.TicketFrame, "Whisper", "TOPLEFT", "TOPLEFT")
	GMR.CreateTicketTemplate("TicketWhisperAnswer", GMR.TicketFrame, 90, "TOPLEFT", "TOPLEFT", offs_x+50, offs_y + 132)
	b3 = GMR.CreateButton("TicketSendWhisperResponce",  offs_x+175, offs_y+132, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Send Whisper", "")
		b3:SetScript("OnClick",
			function()
				if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
					local text = GMR.GetTextTable(GMR.EditScrollBoxes["TicketWhisperAnswer"]:GetText(), 255)
					for i = 1, getn(text) do
						SendChatMessage(text[i], "WHISPER", nil, GMR.CurrentTicketInfo.creator)
					end
				end
			end
		)
	GMR.CreateEditScrollBox("TicketWhisperAnswer", offs_x-20, offs_y + 175, GMR.TicketFrame, 300, 100, "TOPLEFT", "TOPLEFT")




	local line2 = GMR.CreateTitle("line2", offs_x-20, offs_y+290, GMR.TicketFrame, "__________________________________________________________", "TOPLEFT", "TOPLEFT")

	local char_mail = GMR.CreateTitle("textMail", offs_x-20, offs_y+324, GMR.TicketFrame, "Mail", "TOPLEFT", "TOPLEFT")
	GMR.CreateTicketTemplate("TicketMailAnswer", GMR.TicketFrame, 90, "TOPLEFT", "TOPLEFT", offs_x+15, offs_y + 316)
	b2 = GMR.CreateButton("TicketSendMailResponce",  offs_x+125, offs_y+316, 80, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Send Mail", "")
		b2:SetScript("OnClick",
			function()
				if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then 
					local text = GMR.GetTextTable(GMR.EditScrollBoxes["TicketMailAnswer"]:GetText(), 255-strlen(".send mail "..GMR.CurrentTicketInfo.creator.." \" Ticket Answer\" ".."\"\"")-1)
					for i = 1, getn(text) do
						GMR.SendCommandSafe(".send mail "..GMR.CurrentTicketInfo.creator.." \" Ticket Answer\" ".."\""..text[i].."\"", "send mail")
					end
				end
			end
		)
	local sendItem = GMR.CreateButton("TicketSendItem",  offs_x+215, offs_y+316, 80, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Send Item", "")
		sendItem:SetScript("OnClick",
			function()
				if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.creator then
					local itemID = GMR.EditScrollBoxes["TicketMailAnswer"]:GetText();
					if itemID == "" then
						DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000GMR: Please use the window below Send Item to enter an item number.|r");
					elseif not tonumber(itemID) then
						DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000GMR: Item number must be numeric.|r");
					elseif strlen(itemID) > 5 then
						DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000GMR: The item number you entered is too long.|r");
					elseif itemID == nil then
						DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000GMR: Invalid Item ID number entered.|r");
					else
						local iName, iLink, iRarity = GetItemInfo(itemID);
						local iColorR, iColorG, iColorB, iColorHEX = GetItemQualityColor(iRarity);
						local itemLink = iColorHEX.."|H"..iLink.."|h["..iName.."]|h|r";
						StaticPopupDialogs["sendItemPopup"] = {
						  text = "Are you sure you want to send "..itemLink.." to "..GMR.CurrentTicketInfo.creator.."?",
						  button1 = "Yes",
						  button2 = "No",
						  OnAccept = function()
						      SendChatMessage(".send item "..GMR.CurrentTicketInfo.creator.." \"GM Item Restoration\" \"Your "..iName.." has been restored by GM "..UnitName("player").." and is attached to this mail.\" "..itemID, "GUILD");
						      SendChatMessage(".ban note "..GMR.CurrentTicketInfo.creator.. " \"Restored "..iName.." by mail.\"");
						      GMR.EditScrollBoxes["TicketMailAnswer"]:SetText("");
						  end,
						  OnCancel = function()
						      GMR.EditScrollBoxes["TicketMailAnswer"]:SetText("");
						  end,
						  timeout = 0,
						  whileDead = true,
						  hideOnEscape = true,
						  preferredIndex = 3
						}
						StaticPopup_Show ("sendItemPopup")
					end
				end
				
				--
				--
				--if iName == nil then
			--		
--end
			--	
			--	DEFAULT_CHAT_FRAME:AddMessage(");
			end
		)
	GMR.CreateEditScrollBox("TicketMailAnswer", offs_x-20, offs_y+359, GMR.TicketFrame, 300, 100, "TOPLEFT", "TOPLEFT")


	local line3 = GMR.CreateTitle("line3", offs_x-20, offs_y+474, GMR.TicketFrame, "__________________________________________________________", "TOPLEFT", "TOPLEFT")


	local char_comment = GMR.CreateTitle("textComment", offs_x-20, offs_y+508, GMR.TicketFrame, "Comment", "TOPLEFT", "TOPLEFT")
	GMR.CreateTicketTemplate("TicketComment", GMR.TicketFrame, 90, "TOPLEFT", "TOPLEFT", offs_x+50, offs_y+500)
	b4 = GMR.CreateButton("SetTicketComment",  offs_x+175, offs_y+500, 120, 25, GMR.TicketFrame, "TOPLEFT", "TOPLEFT", "Set comment", "Change this comment if you want.")
	b4:SetScript("OnClick",
		function()
			if GMR.CurrentTicketInfo and GMR.CurrentTicketInfo.num then 
				GMR.SendCommandSafe(".ticket comment "..GMR.CurrentTicketInfo.num.." "..GMR.EditScrollBoxes["TicketComment"]:GetText(), "ticket comment")
			end
		end
	)
	GMR.CreateEditScrollBox("TicketComment", offs_x-20, offs_y+543, GMR.TicketFrame, 300, 50, "TOPLEFT", "TOPLEFT")
end

function GMR.BuildTicketFrame()
	local s1, s2, cb1, cb2, cb3, s3
	GMR.TicketFrame = GMR.CreateTicketFrame()
	local buttons_mas = GMR.CreateTicketTableElemets(GMR.TICKET_BUTTONS_NUM)
 	GMR.Tables._Init("Ticket", buttons_mas, GMR.UpdateTicketTableElement, GMR.FindInTicketTable, GMR.SortTicketTable)
 	GMR.Tables._CreateTable("Ticket", GMR.TicketFrame, 20, 400, "TOPLEFT", "TOPLEFT", 20, -200, "", true, true) -- CUSTOM: Ticket Table Width
 	cb1 = GMR.CreateCheckButton("Ticket scan type", 0, -5, GMR.Tables["Ticket"], "BOTTOMRIGHT", "TOPRIGHT", "Enable only online tickets")
 	s1 = cb1:GetScript("OnClick")
 	cb1:SetScript("OnClick", 
 	function() 
 		if this:GetChecked() then
 			GMR.TicketScanType = "online"
 			GMR.CheckButtons["Escalate Scan"]:SetChecked(false)
 		else
 			GMR.TicketScanType = "list"
 		end
 		s1()
 		SLib.CallStack.NewCall(GMR.UpdateMaxTickets, 1, 0)
 	end)

 	cb2 = GMR.CreateCheckButton("Escalate Scan", -25, -5, GMR.Tables["Ticket"], "BOTTOMRIGHT", "TOPRIGHT", "Scan escalatedlist")
 	s2 = cb2:GetScript("OnClick")
 	cb2:SetScript("OnClick", 
 	function()
  		if this:GetChecked() then
  			GMR.CheckButtons["Ticket scan type"]:SetChecked(false)
 			GMR.TicketScanType = "escalatedlist"
 		else
 			GMR.TicketScanType = "online"
 		end
 		SLib.CallStack.NewCall(GMR.UpdateMaxTickets, 1, 0)
 		s2()
 	end)

 	cb3 = GMR.CreateCheckButton("Characters scan type", -50, -5, GMR.Tables["Ticket"], "BOTTOMRIGHT", "TOPRIGHT", "Enable full creators info mode")
 	s3 = cb2:GetScript("OnClick")
 	cb3:SetScript("OnClick", 
 	function() 
 		SLib.CallStack.NewCall(GMR.UpdateMaxTickets, 1, 0)
 		s3()
 	end)

 	cb1:Click()
	GMR.Tables._Update("Ticket")
	GMR.TempObjects.FirstTicketUpdate = true
	GMR.FillTicketFrame()
end