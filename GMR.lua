if not GMR then 
	GMR = {} 
end

GMR.vers = 1.0 --rewrite config case othe vers
GMR.AccessLevel = 256

--config variables for Scanner
SLib.StartScan = false
SLib.ScanSpeed = 0.01
SLib.ScanI = 65
SLib.ScanJ = 97

--temp mas for any local moments like if some variable is ture, then other func check it and make something
GMR.TempObjects = {}

function GMR.getn_keymas(mas)
	local i = 0
	for key in pairs(mas) do
		i = i+1
	end
	return i
end

function GMR.FindInMas(value, mas)
	local result_mas = nil
	for i = 1, getn(mas) do
		if mas[i] == value then
			if not result_mas then result_mas = {} end
			result_mas[getn(result_mas)+1] = i
		end
	end
	return result_mas
end

function GMR.Print(mess)
	DEFAULT_CHAT_FRAME:AddMessage(mess)
end

function GMR.ClearCurrCommand()
	GMR.CurrCommand = nil
end

function GMR.UnblockSend()
	SLib.NewTimer("DelayOnSendGetCommand", -1)
end

function GMR.Click()
	local name = this:GetName()
	if name then
	if name == "GMR_MinimapButton" then
		if arg1 == "LeftButton" then
			if GMR.MenuFrame:IsVisible() then
				 GMR.MenuFrame:Hide()
			else
				 GMR.MenuFrame:Show()
			end
		elseif arg1 == "RightButton" then

		end
	elseif string.find(name, "CommandTable") then
		GMR.CommandTableClick()
	end
	end
end

function GMR.MinimapButtonReposition()
	local t = GMRConfig.MinimapPos
	--usual booring circle
	--local x = cos(t)
	--local y = sin(t)
	--Epycicloid
	--local x = cos(t) - cos(6.5*t)/6.5
	--local y = sin(t) - sin(6.5*t)/6.5
	------Astroid
	--local x = sin(t)*sin(t)*sin(t)
	--local y = cos(t)*cos(t)*cos(t)
	------Hypocycloid
	--local x = cos(t)+cos(5*t)/5
	--local y = sin(t)-sin(5*t)/5
	t = -t + 94  --fix direction for this trajectory
	local x = cos(t) + cos(6.2*t)/6.2
	local y = sin(t) - sin(6.2*t)/6.2
	GMR_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*y),(80*x)-52)
end

function GMR.MinimapDrag()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	GMRConfig.MinimapPos = math.deg(math.atan2(ypos,xpos))
	GMR.MinimapButtonReposition()
end

function GMR.BuildGraphic()
	GMR.BuildTableFrame()
	GMR.BuildDataFrame()
	GMR.MinimapButtonReposition()
	GMR.BuildTicketFrame()
	GMR.BuildOptionsFrame()
	GMR.BuildMenu()
end

function GMR.LoadConfig()
	if not GMRConfig or (GMRConfig and GMRConfig.vers and GMRConfig.vers ~= GMR.vers) then
		GMRConfig = {}
		GMRConfig.vers = 1.0
		GMRConfig.MinimapPos = 0
	end
	if not GMRConfig.Templates then
		GMRConfig.Templates = {}
	end
	if not GMRConfig.ticket_template_data then
		GMRConfig.ticket_template_data = {}
	end
	if not GMRConfig.DataVizualization then
		GMRConfig.DataVizualization = {}
	end
end

function GMR.Initialization()
	SLib.CallStack.Init()
	SLib.UpdateTime = 0.02
	GMR.LoadConfig()
	GMR.DELAY = 0.5 --delay between sending coomand and getting message
end

function GMR.OnLoad()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	this:RegisterEvent("PLAYER_LOGIN")
end


function GMR.OnEvent(event)
	if event == "PLAYER_LOGIN" then		
		GMR.Initialization()
		GMR.BuildGraphic()
		GMR.ExecCommandStack()
	elseif event == "CHAT_MSG_SYSTEM" then
		if GMR.CurrCommand and arg1 then
			--SLib.CallStack.NewCall(GMR.ClearCurrCommand, GMR.DELAY)
			GMR.ParseCommand(arg1)
		end
	end
end

function GMR.OnUpdate()
	if not SLib.GetTimer("UpdateTime") then
		SLib.NewTimer("UpdateTime", SLib.UpdateTime)
		SLib.CallStack.Call()
		GMR.ExecCommandStack()
	end
end

GMR.args = {}
SLASH_GMR1 = "/gmr"
SLASH_GMR2 = "/GMR"
SlashCmdList["GMR"] = function(message)	
	GMR.WindowBehavior(GMR.TicketFrame)
end