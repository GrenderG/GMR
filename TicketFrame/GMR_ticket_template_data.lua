if not GMR then 
	GMR = {} 
end

GMR.ticket_template_data = {
	TicketMailAnswer = {
			["Greetings"] = {
				["Gold Spam"] =  "Greetings! I have reviewed your gold spammer ticket. These accounts will be noted and looked into. Thank you for your assistance with this matter and thank you for your patronage!",
				["Gold Spam NO SS"] = "Greetings! Unfortunately without a screenshot as evidence we are unable to take any action at this time. Feel free to open a new ticket and provide links to screenshots if you have them. ",
				["Generic - OfflinePlayer"] = "Greetings! It seems the player you listed is offline. We will make a note of the player's name and look into this the next time the player is online. Thank you for your patronage!",
				["Generic"] = "Greetings! We will make a note of the player's name and look into this. Thank you for your patronage and have a magical day!",
				["Ban Appeal Filed"] = "Greetings! We cannot provide details about bans using the in-game ticket system. Please keep an eye on your ban appeal for more information. Have a magical evening!",
				["Ban Appeal"] = "Greetings! Please file an appeal on the Ban Appeals section of the Elysium forums to have a Game Master look into your ban. We can only assist with in-game issues with these tickets.",
				["Not Enough Detail"] = "Greetings! Unfortunately I cannot determine the nature of your ticket from what you put in it. Please create a new ticket and provide more information if you are still having trouble.",
				["Lost Account"] = "Greetings! Unfortunately we cannot assist with recovering a lost account. If you forgot the name please check the WTF folder in your WoW installation. Thanks for your patronage!",
				["Bug Tracker"] = "Greetings! Unfortunately bugs must be submitted to the bug tracker on our main website. Please login to the website and submit a bug report so our developers can look into this further.",
				["Name Violation"] = "Greetings! We will be looking into this character name. Thank you for assisting us in these situations. Thank you for your patronage and have a magical evening.",
				["Gameplay/Cant Intervene"] = "Greetings! Unfortunately, based on our Terms of Use, we unfortunately cannot intervene in situations where players may steal items, pull monsters, or similar situations.  -GM Skeith",
				["Rollback Loss -No- Item"] = "Greetings! I apologize but only raid items of Epic quality and above can be restored in the case of a server crash/roll-back.",
				["Rollback Loss -No- Quest"] = "Greetings! I apologize but we cannot restore quest completions that were lost due to a server crash/roll-back.",
				["Hacked Account ItmGld 1"] = "Greetings! Unfortunately according to our Terms of Use we are unable to recover items or gold that have been lost in most situations. A message will follow with the two exceptions to this.",
				["Hacked Account ItmGld 2"] = "Please view our Terms of Use on the forum under section 3: Character/Currency/Item Restoration paragraph 2 through 4 for details on items that can be restored and how to proceed.",
				["Hacked Account ItmGld No"] = "Greetings! Unfortunately according to our Terms of Use we are unable to recover items or gold that have been lost through accident, very rare failure of the server, or otherwise.",
				["Ignore Player"] = "Greetings! I am sorry to hear this has happened to you. I suggest that you add this player to your ignore list as this will prevent them from speaking to you in the future.",
				["Deleted Character"] = "Greetings! Unfortunately Elysium staff will not recover any lost or deleted characters, regardless of circumstances. Thank you for your patronage!",
				["Unmuted/Gold Seller"] = "Greetings! You have been unmuted. Please note this was because you were advertising gold selling websites. Please be sure to change your password to something strong!",
				["Unmuted/Generic"] = "Greetings! You have been unmuted. Apologies for any inconvenience. Thank you for your patronage and have a magical day.",
				["Clear WDB"] = "Greetings! Please try clearing your WDB folder inside your WoW game folder. If this does not fix the issue please create a new ticket noteing this.",
				["No Name Chg Service"] = "Greetings! Unfortunately, at this time, we do not offer name changes as a service and your name does not violate our Terms of Use.",
				['NostXfer - No'] = "Greetings! Unfortunately characters that were not already transferred from Nostalrius to Elysium can no longer be retreieved. I apologize for this inconvenience.",
				["Bug Tracker - Nice"] = "Greetings! It seems this may be a bug which would need to be submitted to our bug tracker for our developers to look into this issue. I apologize for not being able to assist you further with this issue.",
				["Unstuck"] = "Greetings! I have moved you safely away from where you were stuck. Have a magical evening!",
				["Name Violation - Guild"] = "Greetings! We will be looking into this guild name. Thank you for assisting us in these situations. Thank you for your patronage and have a magical evening.",
				["Raid - Cannot Kick"] = "Greetings! Unfortunately we are not able to remove players from the raid as they are saved to that ID and have a right to be there unless they are wiping the raid or pulling to grief.",
				["zChineseResubmit"] = "请您重发一遍求助，尽可能详述下问题。这样我们的中文GM团队才能更好的帮助到您。"
			},
			["Warnings"] = {
				["Multiboxer"] = "Greetings, you appear to be multiboxing...",
				["BG AFK"] = "Greetings, You are reminded that being AFK in a BG is against our rules, doing this again may lead to further action being taken.",
				["Safe spotting"] = "Greetings, Safe Spotting is against our rules. I will be placing a warning on your account. Performing this action again may result in further sanction being taken."
			}
	},
	TicketWhisperAnswer = {
			["Greetings"] = {
				["!!Basic Intro"] = "Greetings! I've been summoned from the void for your ticket.",
				["Bot"] = "I have received your report about a player botting. We will look into this.",
				["Cant Help More"] = "Sorry I can't help you any more. :(",
				["Goldseller"] = "Thank you for reporting this gold seller to us, we will look into this.",
				["Safespotting"] = "I have received your report of a player safespotting. We will be looking into this. :)",
				["Generic Look Into"] = "We will take note of this player's name and will look into this. :)",
				["Chat Harassment"] = "I am sorry to hear this has happened to you. I suggest that you add this player to your ignore list as this will prevent them from speaking to you in the future.",
				["Goldseller SS?"] = "Thank you for reporting this, do you happen to have a screenshot of the player spamming this?",
				["Goldseller SS/No"] = "Unfortunately without a screenshot as evidence we are unable to take any action at this time. Feel free to open a new ticket and provide links to screenshots if you find any others.",
				["Part of the game"] = "Thanks for reporting this behaviour. Although this may be inconvenient to your game play, the GM team will not get involved until this becomes excessive as it is a mechanic of the game.",
				["Corpse Camping"] = "I am sorry to hear this is happening to you. Unfortunately, corpse camping is not against the Terms Of Use on Elysium. Players are free to kill and corpse camp players."
			},
			["Warnings"] = {
				["Multiboxer"] = "Greetings, you appear to be multiboxing...",
				["BG AFK"] = "Greetings, You are reminded that being AFK in a BG is against our rules, doing this again may lead to further action being taken.",
				["Safe spotting"] = "Greetings, Safe Spotting is against our rules. I will be placing a warning on your account. Performing this action again may result in further sanction being taken."
			}
	},
	Mail = {
	},
	TicketComment = {
			["Standard"] = {
				["Item Restore - Quest"] = "R3+ Quest Validation, R4+ Item Restoration - Skeith"
			}
	}
}