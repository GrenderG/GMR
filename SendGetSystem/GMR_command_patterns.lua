if not GMR then 
	GMR = {} 
end

GMR.Patterns = {
	account 	= {
		[1] = {"(%d+)$", {"name"}}
	},
	["lookup player ip"] = {
		[1] = {"%[(.+)%]"},
		table_type = true
	},
	["lookup creature"] = {
		[1] = {"(%d+).-%[(.+)%]", 
				{"Id", "Name"}, 
				{{".go creature id %s", ".list creature %s"}, {".go creature %s"}},
				{"num"}
		},
		table_type = true
	},
	pinfo = {
		--[[  [1] : first message from command - 4 blocks:
			first - patern for regular expressions - data in ( ) will extracted from message
			second - name of labels = titles of columns
			third - commands to interract with some column - array for every command - like {{command1_for1, command2_fo1}, {command1_for2, command2_for2}}
			fourth - type of column to sort, "common" if nothing (usual text sort)- nothing may be _ or nil; (num, ip, ti,e, money, common) - enabled methods
		]]
		
		[1] = {	"(.+) (%w+).+%[(.+)%] %(guid: (%d+)%) Account: %[(.+)%] %(id: (%d+)%) GMLevel: (%d+) Last IP: %[(.+)%] Last login: (.+) Latency: (%d+)ms Client: (.+)", 
				{"Race",  "Class", "Name"	,"guid"	,"Account"	,"id"	,"GMLevel"	,"Last IP"	,"Last Login"	,"Latency", "Client"	}, 
				{{".go name %s"}}, 
				{ _, 			_,	_		,"num"	,_			,"num"	,"num"		,"ip"		,"time"			,"num"		}
			},
		-- second message from command
		[2] = {	"Played time: (.+) Level: (.+) Money: ([%dgsc]+)", 
				{"Played time"	,"Level"	,"Money"	}, 
				{},
				{"time"			,"num"		,"money"	},
		 	},
		[3] = {	"Guild: %[(.+)%]", 
				{"Guild"}, 
		 	},		 
		-- if you want join some messages to one - put there number in array join
		join = {1, 2, 3},
	},
	["ticket"] = {
		[1] = {"<or1> Ticket Message: %[(.-)%]<\or1><or2> Ticket Message: %[(.*)<\or2><or3>^(.*)%]GM Comment: %[.+%]$<\or3><or4>^(.*)%]$<\or4><or5>^(.+)$<\or5>"},
		table_type = true
	},
	["ticket list"] = {
		[1] = {	"Ticket: (%d+)%. Creator%: %[(.-)%] Created: (.-) ago<or1_4> Changed: (.-) ago<\or1_4><or2_5> Assigned to: %[(.+)%]<\or2_5>",
			  	{"Id"	, "Creator"	, "Created"	, "Changed", "Assigned to"},
			  	{{"open ticket %s"},{".go name %s"}},
			  	{"num"	, _			, "time"	, "time"},
			  },
		table_type = true
	},
	["ticket online"] = {
		[1] = {	"Ticket: (%d+)%. Creator%: %[(.-)%] Created: (.-) ago<or1_4> Changed: (.-) ago<\or1_4><or2_5> Assigned to: %[(.+)%]<\or2_5>",
			  	{"Id", "Creator", "Created", "Changed", "Assigned to"},
			  	{{"open ticket %s"},{".go name %s"}},
			  	{"num"	, _			, "time"	, "time"},
			  },
		table_type = true
	},
	["ticket escalatedlist"] = {
		[1] = {	"Ticket: (%d+)%. Creator%: %[(.-)%] Created: (.-) ago<or1_4> Changed: (.-) ago<\or1_4><or2_5> Assigned to: %[(.+)%]<\or2_5> : Level (%d+)",
			  	{"Id", "Creator", "Created", "Changed", "Assigned to", "GM Level"},
			  	{{"open ticket %s"},{".go name %s"}},
			  	{"num"	, _			, "time"	, "time", _	, "num"},
			  },
		table_type = true
	},

}