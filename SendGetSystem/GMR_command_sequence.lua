if not GMR then 
	GMR = {} 
end
---scan character - get table of all chars on his IP---
function GMR.GetList(data, mess_iter, com, str)
	if data and getn(data) > 0 then
		SLib.NewTimer("AddElementToDataTable", GMR.DELAY)
		GMR.SendCommandSafe(".pinfo "..data[1], "pinfo", GMR.common_handle)
	end
end

function GMR.GetIp(data, mess_iter)
	if data and data[8] and mess_iter == 1 then
		GMR.SendCommandSafe(".lookup player ip "..data[8], "lookup player ip", GMR.GetList)
		GMR.NameMas = {}
		GMR.NameMas_Iter = 1
	end
end

function GMR.ScanTarget(name)
	SLib.NewTimer("AddElementToDataTable", 0)
	GMR.SendCommandSafe(".pinfo "..name, "pinfo", GMR.GetIp)
end

---get data from all ticket creator chars---

function GMR.LoadCharacterTicketInfo(data, mess_iter, com, str, message)
	if data and getn(data) > 0 then
		local name
		if mess_iter == 1 then
			name = data[3]
			GMR.CharacterBase[name] = {}
			GMR.TempObjects["LoadCharacterTicketInfoLastName"] = name
		else
			name = GMR.TempObjects["LoadCharacterTicketInfoLastName"]
		end
		for i = 1, getn(data) do
			GMR.CharacterBase[name][getn(GMR.CharacterBase[name])+1] = data[i]
		end
	end
	SLib.CallStack.NewCall(GMR.Tables._Update, 0.5, "Ticket")
end

function GMR.ScanTicketChars()
	for i = 1, getn(GMR.TicketData) do
		local name = GMR.TicketData[i].creator
		if name and not GMR.CharacterBase[name] then
			GMR.SendCommandSafe(".pinfo "..name, "pinfo", GMR.LoadCharacterTicketInfo)
		end
	end
end