if not GMR then 
	GMR = {} 
end

GMR.FrameLinkToMenu = {}

function GMR.WindowBehavior(frame)
	local link_button = this
	if not GMR.FrameLinkToMenu[frame:GetName()] then
		 GMR.FrameLinkToMenu[frame:GetName()] = 1
		 local s = frame:GetScript("OnHide")
		 frame:SetScript("OnHide", function()
		 	if s then s() end
		 end)
	end
	if frame:IsVisible() then
		frame:Hide()
	else
		frame:Show()
	end
end

function GMR.OnInsetClick()
	local _, _, name = string.find(this:GetName(), "(.+)_GMRMenu")
	if name then
		if name == "Command" then
			GMR.WindowBehavior(GMR.TableFrame)
		elseif name == "Ticket" then
			GMR.WindowBehavior(GMR.TicketFrame)
		elseif name == "Options" then
			GMR.WindowBehavior(GMR.OptionFrame)
		elseif name == "Ban" then
			GMR.TableFrame:Show()
			GMR.EditBoxes["sort".."Command".."Table"]:SetText("ban character")
			if getn(GMR.CurrentCommandTableElements) > 0 then
				GMR.Tables._AllObjects["Command"][1]:Click()
			end
		elseif name == "TicketTable" then
			if IsAltKeyDown() and arg1 == "LeftButton" then
				GMR.SendCommandSafe(".ticket escalatedlist", "ticket escalatedlist", GMR.common_handle)
			elseif arg1 == "LeftButton" then
				GMR.SendCommandSafe(".ticket list", "ticket list", GMR.common_handle)
			elseif arg1 == "RightButton" then
				GMR.SendCommandSafe(".ticket online", "ticket online", GMR.common_handle)
			end
		end
	end
end

GMR.Insets = {}

function GMR.CreateInset(name, parent, point, relpoint,  x, y, width, height, texture, tooltip)
	local f = CreateFrame("CheckButton" , name, parent, "TabPanelTemplate")
	f:SetPoint(point, parent, relpoint, x, -y)
	f:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	f:SetScript("OnClick", GMR.OnInsetClick)
	if tooltip then
		f:SetScript("OnEnter", 
			function()
		        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
		        if type(tooltip) == "table" then
		        	for i = 1, getn(tooltip) do
		        		GameTooltip:AddLine(tooltip[i]);
		        	end
		        else
		        	GameTooltip:AddLine(tooltip);
		        end
		        GameTooltip:Show();
		    end
		)
	end
	f:SetScript("OnLeave", 
		function()
	        GameTooltip:Hide();
	    end
	)
	f:SetNormalTexture(texture)
	GMR.Insets[name] = f
end

GMR.MenuData = {
	[1] = {
		name = "Command",
		texture = [[Interface\Cursor\Cast.blp]],
		tooltip = "Command interface"
	},
	[2] = {
		name = "Ticket",
		texture = [[Interface\MailFrame\Mail-Icon.blp]],
		tooltip = "Tickets"
	},
	[3] = {
		name = "Options",
		texture = [[Interface\Icons\Trade_Engineering]],
		tooltip = "Options"
	},
	[4] = {
		name = "Ban",
		texture = [[Interface\Icons\INV_Hammer_13.blp]],
		tooltip = "Fast access for .ban character"
	}, 
	[5] = {
		name = "TicketTable",
		texture = [[Interface\Cursor\Inspect.blp]],
		tooltip = {"Fast access for ticket table.", "Left click: ticket list", "Right click: ticket online list", "Left click + Alt: ticket escalate"}
	}
}

function GMR.CreateMenuFrame()
	local f = CreateFrame("Frame", "GMR_MenuFrame", UIParent)
	GMR.MakeMoovable(f)
	f:SetFrameStrata("HIGH")
	f:SetWidth(350)
	f:SetHeight(150)
	f:SetBackdrop( { 
  		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
  		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
  		tile = true, tileSize = 32, edgeSize = 32, 
  		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	f:SetPoint("RIGHT", UIParent, "RIGHT", 0, -50)
	GMR.AddCloseButton(f)
	f:Hide()
	return f
end

function GMR.BuildMenu()
	GMR.MenuFrame = GMR.CreateMenuFrame()
	local indent = 50
	local M_width, M_height = 400, 600
	local I_width, I_height, I_space_x, I_space_y = 30, 50, 20, 20
	local x, y = 0 + indent, 0 + indent
	for i = 1, getn(GMR.MenuData) do
		GMR.CreateInset(GMR.MenuData[i].name.."_GMRMenu", GMR.MenuFrame, "TOPLEFT", "TOPLEFT",  x, y, I_width, I_height, GMR.MenuData[i].texture, GMR.MenuData[i].tooltip)
		x = x + I_width + I_space_x
		if x + I_width > M_width - indent then
			x = 0
			y = y + I_height + I_space_y
		end
	end
end