if not GMR then 
	GMR = {} 
end

GMR.Titles = {}

function GMR.CreateTitle(name, x, y, parent, text, point, rel_point)
	if not GMR.Titles[name] then
		if not point then point = "CENTER" end
		if not rel_point then rel_point = "CENTER" end
		local f = parent:CreateFontString(name.."Title", "ARTWORK","GameFontNormal")
		f:SetPoint(point, parent, rel_point, x, -y)
		f:SetText(text)
		GMR.Titles[name] = f
	end
	return GMR.Titles[name]
end

GMR.CheckButtons = {}

function GMR.CreateCheckButton(name, x, y, parent, point, rel_point, tooltip)
	if not GMR.CheckButtons[name] then
		local f = CreateFrame("CheckButton" , name.."CheckButton", parent, "CheckButtonGMRTemplate")
		f:EnableMouse(true)
		f:SetPoint(point, parent, rel_point, x, -y)
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
		f:SetScript("OnClick", 
			function()
		        GMR.Click()
		    end
		)
		GMR.CheckButtons[name] = f
	end
	return GMR.CheckButtons[name]
end

GMR.Buttons = {}

function GMR.CreateButton(name, x, y, width, height, parent, point, rel_point, text, tooltip)
	if not GMR.Buttons[name] then
		local f = CreateFrame("Button" , name.."Button", parent, "UIPanelButtonTemplate")
		f:SetWidth(width)
		f:SetHeight(height)
		f:EnableMouse(true)
		f:SetAlpha(0.8)
		f:SetPoint(point, parent, rel_point, x, -y)
		GMR.CreateTitle(name, 0, 0, f, text, "CENTER", "CENTER")
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
		f:SetScript("OnClick", 
			function()
		        GMR.Click()
		    end
		)
		GMR.Buttons[name] = f
	end
	return GMR.Buttons[name]
end

GMR.EditBoxes = {}
function GMR.CreateEditBox(name, x, y, parent, width, height, point, rel_point, tooltip)
	if not GMR.EditBoxes[name] then
		local frame = CreateFrame("EditBox", name.."EditBox", parent, "InputBoxTemplate")
		frame:SetWidth(width)
		frame:SetHeight(height)
		frame:ClearAllPoints()
		frame:SetPoint(point, parent, rel_point, x, -y)
		frame:SetAutoFocus(false)
		if tooltip then
			frame:SetScript("OnEnter", 
				function()
			        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
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
		frame:SetScript("OnLeave", 
			function()
		        GameTooltip:Hide();
		    end
		)

		GMR.EditBoxes[name] = frame
	end
	return GMR.EditBoxes[name]
end

GMR.EditNumBoxes = {}
function GMR.CreateEditNumberBox(name, x, y, parent, width, height, point, rel_point, tooltip)
	if not GMR.EditNumBoxes[name] then
		local frame = CreateFrame("EditBox", name.."EditNumBox", parent, "InputBoxTemplate")
		frame:SetWidth(width)
		frame:SetHeight(height)
		frame:ClearAllPoints()
		frame:SetPoint(point, parent, rel_point, x, -y)
		frame:SetAutoFocus(false)
		if tooltip then
			frame:SetScript("OnEnter", 
				function()
			        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
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
		frame:SetScript("OnLeave", 
			function()
		        GameTooltip:Hide();
		    end
		)
		frame:SetScript("OnTextChanged",
			function()
				local temp_t = this:GetText()
				temp_t = gsub(temp_t, "([^0-9%-%.a-fA-F]+)", "")
				this:SetText(temp_t)
			end
		)
		frame:EnableMouseWheel(true)
		frame:SetScript("OnMouseWheel", 
			function()
				local temp_t = this:GetText()
				if not string.find(temp_t, "%d+") then
					temp_t = "0"
				end
				temp_t = tonumber(temp_t)
				temp_t = temp_t+arg1
				this:SetText(temp_t)
			end
		)

		GMR.EditNumBoxes[name] = frame
	end
	return GMR.EditNumBoxes[name]
end

GMR.EditScrollBoxes_text = {}
GMR.EditScrollBoxes = {}

function GMR.UnblockUpdateScrollBox(name)
	GMR.TempObjects[name.."blockupdate"] = false
end

function GMR.CreateEditScrollBox(name, x, y, parent, width, height, point, rel_point, tooltip, blocktext)
	if not GMR.EditScrollBoxes[name] then
		if blocktext then
			GMR.EditScrollBoxes_text[name] = ""
		end
		local frame = CreateFrame("EditBox", name.."EditScrollBox", parent)
		frame:SetFontObject("ChatFontNormal")
		frame:SetWidth(width)
		frame:SetHeight(height)
		frame:ClearAllPoints()
		frame:SetPoint(point, invizible_button, rel_point, x, -y)
		frame:SetAutoFocus(false)
		frame:SetMaxLetters(2000)
		frame:SetMultiLine(true)
		frame:EnableMouse()
		frame:SetScript("OnTextChanged", 
			function()
				local scrollFrame
				if ( not scrollFrame ) then
					scrollFrame = this:GetParent()
				end
				scrollFrame:UpdateScrollChildRect()
				if blocktext then
					if type(GMR.EditScrollBoxes_text[name]) == "table"  and not GMR.TempObjects[name.."blockupdate"] then
						GMR.TempObjects[name.."blockupdate"] = true
						this:SetText("")
						for i = 1, getn(GMR.EditScrollBoxes_text[name]) do
							this:Insert(GMR.EditScrollBoxes_text[name][i])
							if i ~= getn(GMR.EditScrollBoxes_text[name])+1 then
								this:Insert("\n")
							end
						end
						this:Insert(" ")
						this:ClearFocus()
						SLib.CallStack.NewCall(GMR.UnblockUpdateScrollBox, 0.01, name)
					elseif type(GMR.EditScrollBoxes_text[name]) == "string" then
						this:SetText(GMR.EditScrollBoxes_text[name])
					end
					this.cursorOffset = 0
				end
		    end
		)
		frame:SetScript("OnCursorChanged", 
			function()
				this.cursorOffset = arg2
				this.cursorHeight = arg4
		    end
		)
		frame:SetScript("OnUpdate", 
			function()
				if ( this.cursorOffset ) then
					local scrollFrame
					if ( not scrollFrame ) then
						scrollFrame = this:GetParent();
					end
					local height = scrollFrame:GetHeight();
					local range = scrollFrame:GetVerticalScrollRange();
					local scroll = scrollFrame:GetVerticalScroll();
					local slider = GMR.ScrollBars[name.."V"]
					local size = height + range;
					local cursorOffset = -this.cursorOffset;
					while ( cursorOffset < scroll ) do
						scroll = (scroll - (height / 2));
						if ( scroll < 0 ) then
							scroll = 0;
						end
						scrollFrame:SetVerticalScroll(scroll);
					end
					while ( (cursorOffset + this.cursorHeight) > (scroll + height) and scroll < range ) do
						scroll = (scroll + (height / 2));
						if ( scroll > range ) then
							scroll = range;
						end
						scrollFrame:SetVerticalScroll(scroll)
					end
					local new_max = this:GetHeight()-scrollFrame:GetHeight()
					slider:SetMinMaxValues(0, max(0, new_max))
					slider:SetValue(scrollFrame:GetVerticalScroll())
					this.cursorOffset = nil;
				end
		    end
		)
		frame:SetScript("OnEscapePressed", 
			function()
		        this:ClearFocus()
		    end
		)
		frame:SetScript("OnEditFocusLost", 
			function()
		        this:HighlightText(0, 0)
		    end
		)
		frame:SetScript("OnEditFocusGained", 
			function()
		        this:HighlightText()
		    end
		)
		local scrf = GMR.CreateScrollFrame(name, parent, frame, width, height, rel_point, point, x, y)

		local invizible_button = CreateFrame("Button", name.."EditScrollBoxButton", scrf)
		invizible_button:SetAllPoints(scrf)
		invizible_button:SetScript("OnClick", 
			function()
				frame:SetFocus()
			end
		)
		if tooltip then
			invizible_button:SetScript("OnEnter", 
				function()
			        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
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
			invizible_button:SetScript("OnLeave", 
				function()
			        GameTooltip:Hide();
			    end
			)
		end
		GMR.EditScrollBoxes[name] = frame
	end
	return GMR.EditScrollBoxes[name]
end

function GMR.SetTexture(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)
	local name, r, g, b, parent, layer, width, height, point, x, y
	if type(a1) == "string" then
		name = a1
		parent = a2
		layer = a3
		width = a4
		height = a5
		point = a6
		x = a7
		y = a8
	else
		r = a1
		g = a2
		b = a3
		alpha = a4
		parent = a5
		layer = a6
		width = a7
		height = a8
		point = a9
		x = a10
		y = a11
	end
	if not layer then
		layer = "BACKGROUND"
	end
	if  not point then
		point = "CENTER"
	end
	if not x then
		x = 0
	end
	if not y then
		y = 0
	end
	local t
	t = parent:CreateTexture(nil, layer)
	if name then
		t:SetTexture(name)
	else
		t:SetTexture(r, g, b, alpha)
	end
	if not width then
		t:SetAllPoints(parent)
	end
	if width then
		t:SetWidth(width)
	end
	if height then
		t:SetHeight(height)
		t:SetPoint(point, parent, x,-y)
	end
	parent.texture = t
	return t
end

GMR.ScrollBars = {}

function GMR.AddScrollBar(name, parent, orient, minVal, maxVal, width, height, rel_point, point, texture)
	if not GMR.ScrollBars[name] then
		if not orient then orient = "VERTICAL" end
		if not minval then minval = 0 end
		if orient == "HORIZONTAL" then
			if not rel_point then rel_point = "BOTTOM" end
			if not point then point = "TOP" end
			if not width then width = parent:GetWidth() end
			if not height then height = 25 end
			if parent:GetScrollChild() then
				if not maxval then maxval = parent:GetScrollChild():GetWidth()-parent:GetWidth() end
			else
				if not maxval then maxval = 0 end
			end
		elseif orient == "VERTICAL" then
			if not rel_point then rel_point = "RIGHT" end
			if not point then point = "LEFT" end
			if not width then width = 25 end
			if not height then height = parent:GetHeight() end
			if parent:GetScrollChild() then
				if not maxval then maxval = parent:GetScrollChild():GetHeight()-parent:GetHeight() end
			else
				if not maxval then maxval = parent:GetHeight() end
			end
		end
		if not texture then texture = "Interface\\Buttons\\UI-ScrollBar-Knob" end
		local innerhited_method = "UIPanelScrollBarTemplate"
		if orient == "HORIZONTAL" then
			innerhited_method = nil
		end
		local s = CreateFrame("Slider", name.."Slider", parent, innerhited_method)
		if orient == "HORIZONTAL" then	
			s:SetBackdrop( { 
		  		bgFile = "Interface\\Buttons\\UI-SliderBar-Background", 
		  		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", 
		  		tile = true, tileSize = 8, edgeSize = 8, 
		  		insets = { left = 3, right = 3, top = 6, bottom = 6 }})
		end
		s:SetOrientation(orient)
		s:SetMinMaxValues(minval, maxval)
		s:SetValue(0)
		s:SetValueStep(1)
		s:SetWidth(width)
		s:SetHeight(height)
		s:SetPoint(point, parent, rel_point)
		if orient == "HORIZONTAL" then
			s:SetScript("OnValueChanged", 
				function()
					parent:SetHorizontalScroll(-1 * this:GetValue())
				end
			)
		else
			s:SetScript("OnValueChanged", 
				function()
					parent:SetVerticalScroll(this:GetValue())
				end
			)
		end		
		s:SetThumbTexture(texture)
		GMR.ScrollBars[name] = s
	end
	return  GMR.ScrollBars[name]
end

GMR.ScrollFrames = {}
function GMR.CreateScrollFrame(name, parent, child, width, height, rel_point, point, x, y, HORIZONTAL)
	if not GMR.ScrollFrames[name] then
		if not width then width = parent:GetWidth() end
		if not height then height = parent:GetHeight() end
		if not rel_point then rel_point = "CENTER" end
		if not point then point = "CENTER" end
		if not x then x = 0 end
		if not y then y = 0 end
		local f = CreateFrame("ScrollFrame",name.."ScrollFrame",parent)
			f:SetWidth(width)
			f:SetHeight(height)
			GMR.SetTexture(0,0,0,0.5,f)
			f:SetPoint(point, parent, rel_point, x,-y)
		if child then
			child:SetParent(f)
			child:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
			f:SetScrollChild(child)
		end
		GMR.AddScrollBar(name.."V", f)
		if HORIZONTAL then
			--GMR.AddScrollBar(name.."H", f, "HORIZONTAL")
		end
		f:EnableMouseWheel(true)
		f:SetScript("OnMouseWheel", 
			function()
				local ScrollBar = GMR.ScrollBars[name.."V"]
				local minv, maxv = ScrollBar:GetMinMaxValues()
				if ScrollBar:GetValue() - 5*arg1 > maxv and arg1 < 0 then
					ScrollBar:SetValue(maxv)
				elseif ScrollBar:GetValue() - 5*arg1 < minv and arg1 > 0 then
					ScrollBar:SetValue(minv)
				else
					ScrollBar:SetValue(ScrollBar:GetValue() - 5*arg1)
				end
			end
		)
		GMR.ScrollFrames[name] = f
	end
	return GMR.ScrollFrames[name]
end

function GMR.AddCloseButton(parent, width, height, rel_point, point, x, y)
	if not GMR.Buttons[parent:GetName().."closeButton"] then
	    local f = CreateFrame("Button", parent:GetName().."closeButton", parent, "UIPanelCloseButton")
	    if width then f:SetWidth(width) end
	    if height then f:SetHeight(height) end
	    if not rel_point then rel_point = "TOPRIGHT" end
	    if not point then point = "CENTER" end
	    if not x then x = -26 end
	    if not y then y = 24 end
	    f:SetPoint(point, parent, rel_point, x, -y)
	    GMR.Buttons[parent:GetName().."closeButton"] = f
	end
	return GMR.Buttons[parent:GetName().."closeButton"]
end

function GMR.MakeMoovable(frame)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", 
		function()
	    	if(arg1 == "LeftButton") then
	        	this:StartMoving()
	        end
	    end
	)	
	frame:SetScript("OnDragStop", 
		function()
	    	this:StopMovingOrSizing()
	    end
	)		
end

function GMR.ShowFrame(frame)
	frame:Show()
end

function GMR.HideFrame(frame)
	frame:Hide()
end

function GMR.ClickFrame(frame)
	frame:Click()
end

function GMR.ChildGetMaxWidth(frame)
	local all_obj = {frame:GetChildren()}
	local l = 0
	for i = 1, getn(all_obj) do
		if all_obj[i]:IsShown() then
			l = max(l,  all_obj[i]:GetLeft() - frame:GetLeft() + all_obj[i]:GetWidth())
		end
	end 	 
	return l
end

--[[
So.. to create new table you must have:
mas of objects
function to find results in table, get (search_text) must return size of mas
function to sort results in table, get nothing return nothing
function to update data for element, get (element, place in array(slider value))
Run GMR.Tables._Init(name, object_mas, func_update_element, func_findInTable, func_SortTable)
after GMR.Tables._CreateTable(name, parent, object_height, width, rel_point, point, x, y, texture)
case you need to update Table use GMR.Tables._Update(name, value, [mode]); value is optional param, place of slider, case mode = "slider" then sort and find won't start
]]

GMR.Tables = {}
GMR.Tables._Params = {}
GMR.Tables._AllObjects = {}
GMR.Tables._UpdateElement = {}
GMR.Tables._FindInTable = {}
GMR.Tables._SortTable = {}

function GMR.Tables._Clear(name)
	if GMR.Tables[name] then
		local all = GMR.Tables._AllObjects[name]
		for i = 1, getn(all) do
			if all[i]:IsShown() then
				all[i]:ClearAllPoints()
				all[i]:Hide()
			end
		end
	end
end

function GMR.Tables._DrawElements(name, num)
	GMR.Tables._Clear(name)
	local all = GMR.Tables._AllObjects[name]
	if not num then num = getn(all) end
	num = min(num, getn(all)) -- normalize case num > getn(all)
	local child = getglobal(name.."Child".."Table")
	for i = 1, num do
		all[i]:SetParent(child)
		all[i]:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -1*GMR.Tables._Params[name].object_height*(i-1))
		all[i]:Show()
	end
	if not GMR.Tables._Params[name].PrevSize then
		GMR.Tables._Params[name].PrevSize = num
	end
end

function GMR.Tables._Init(name, object_mas, func_update_element, func_findInTable, func_SortTable)
	GMR.Tables._Clear(name)
	GMR.Tables._AllObjects[name] = object_mas
	GMR.Tables._FindInTable[name] = func_findInTable
	GMR.Tables._SortTable[name] = func_SortTable
	GMR.Tables._UpdateElement[name] = func_update_element
	if GMR.Tables[name] then
		GMR.Tables._DrawElements(name)
		GMR.Tables._Update(name)
	end
end

function GMR.Tables._Update(name, value, mode)
	if not mode or mode ~= "Slider" or not GMR.Tables._Params[name].CurrentSize then
		local str = ""
		if GMR.EditBoxes["sort"..name.."Table"] then
			str = GMR.EditBoxes["sort"..name.."Table"]:GetText()
		end
		GMR.Tables._Params[name].CurrentSize = GMR.Tables._FindInTable[name](string.lower(str))
		GMR.Tables._SortTable[name]()
	end
	local cur_size = GMR.Tables._Params[name].CurrentSize
	local prev_size = GMR.Tables._Params[name].PrevSize
	local all = GMR.Tables._AllObjects[name]
	if not value or value == 0 then value = 1 end
	if cur_size < getn(all) or prev_size < getn(all)  then
		GMR.Tables._DrawElements(name, cur_size)
	end

	GMR.Tables._Params[name].PrevSize = cur_size

	if value > max(1, cur_size - (getn(all) - 1)) then
		value = max(1, cur_size - (getn(all) - 1))		--check for safe UpdateElement
	end

	for i = 1, min(getn(all), cur_size) do
		GMR.Tables._UpdateElement[name](all[i], value+i-1)
	end

	if GMR.ScrollBars[name.."Table".."H"] then
		local child             = GMR.Tables[name]:GetScrollChild()
		local child_cur_size 	= child:GetWidth()
		local child_must_size 	= max(GMR.Tables[name]:GetWidth(), GMR.ChildGetMaxWidth(child))
		if child_cur_size ~= child_must_size then
			GMR.Tables[name]:GetScrollChild():SetWidth(child_must_size)
			GMR.ScrollBars[name.."Table".."H"]:SetMinMaxValues(0, child_must_size - GMR.Tables[name]:GetWidth())
		end
	end
	local slider = GMR.ScrollBars[name.."Table".."V"]
	if value and slider:GetValue() ~= value then
		slider:SetValue(value)
	end
	local s_min, s_max = slider:GetMinMaxValues()
	if s_min ~= 1 or s_max ~= max(0, cur_size - (getn(all)-1) ) then
		s_min = 1
		s_max = max(0, cur_size - (getn(all)-1) )
		if s_min > s_max then
			s_min = s_max
		end
		slider:SetMinMaxValues(s_min, s_max)
	end
end

function GMR.Tables._CreateTable(name, parent, object_height, width, rel_point, point, x, y, texture, SearchBox, horizontal_mode)
	if not GMR.Tables[name] then
		local child = CreateFrame("Frame", name.."Child".."Table", parent)
		local height = getn(GMR.Tables._AllObjects[name])*object_height
		child:SetWidth(width)
		child:SetHeight(height)
		if texture then 
			GMR.SetTexture(texture,child)
		end
		local obj = GMR.Tables._AllObjects[name]
		for i = 1, getn(obj) do
			obj[i]:SetParent(child)
		end
		local m_table = GMR.CreateScrollFrame(name.."Table", parent, child, width, height, point, rel_point, x, -y, horizontal_mode)
		local slider = GMR.ScrollBars[name.."Table".."V"]
		slider:SetMinMaxValues(1, GMR.getn_keymas(obj))
		slider:SetScript("OnValueChanged",
			function()
				local _,_,name = string.find(this:GetName(), "(.+)TableVSlider")
				GMR.Tables._Update(name, this:GetValue(), "Slider")
			end
		)
		m_table:SetScript("OnMouseWheel", 
			function()
				local _,_,name = string.find(this:GetName(), "(.+)ScrollFrame")
				local slider = GMR.ScrollBars[name.."V"]
				slider:SetValue(slider:GetValue() - arg1)
			end
		)	
		if SearchBox then
			local searchbox = GMR.CreateEditBox("sort"..name.."Table", 5, -10, m_table, width/2-10, 20, "BOTTOMLEFT", "TOPLEFT", {"Type text to find","Tips: work with lua regex too"})
			searchbox:SetScript("OnTextChanged",
				function()
					local _,_, name = string.find(this:GetName(), "sort(.+)Table")
					GMR.Tables._Update(name, 1)
				end
			)
		end
		GMR.Tables[name] = m_table
		GMR.Tables._Params[name] = {
			object_height = object_height
		}
		GMR.Tables._DrawElements(name)
	end
	return GMR.Tables[name]
end