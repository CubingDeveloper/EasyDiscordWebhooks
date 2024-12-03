--Module by CubingDeveloper 2024
--Version RELEASE.0.1

local EasyDiscordWebhooks = {}
local HttpService = game:GetService("HttpService")

local JobId = function() return game.JobId ~= "" and game.JobId or "[NO ID FOUND (IN STUDIO?)]" end
local PlayTimes = {}
local timestamp = function() return `<t:{DateTime.now().UnixTimestamp}:f>` end

type Webhook = {
	URL: string?,
	WebhookConfig: WebhookConfiguration?
}
EasyDiscordWebhooks.CurrentHook = {} :: Webhook

type WebhookConfiguration = {
	AlertOnConnection: boolean?,

	AlertOnJoin: boolean?,
	AlertOnStarCreatorJoin: boolean?,
	
	AlertOnLeave: boolean?,
	EmbedColor: Color3?,
	
	DebugPrintContentBeforePOST: boolean?
	
}

type Author = {
	name: string,
	url: string,
	icon_url: string
}

type EmbedField = {
	name: string,
	description: string,
	inline: boolean?
}

type Embed = {
	
	Title: string?,
	EmbedContent: string?,
	Color: Color3?,
	Author: Author?,
	Footer: {
		name: string,
		icon_url: string
	}?,
	ImageUrl: string?,
	ThumbnailUrl: string?,
	Fields: {{
		name:string,
		value:string,
		inline:boolean?
	}}?,
	
	Send: (self: Embed) -> nil,
	ExportTable: (self: Embed) -> {
		color: number,
		author: Author,
		title:string,
		url: string,
		description: string,
		image: string,
		thumbnail: string,
		footer: {
			name: string,
			icon_url: StylingService
		}?,
		
	},
	AddFields: (self: Embed, ...EmbedField) -> nil
}

type Profile = {
	Name: string?,
	Image: string?,
	
	Send: (self: Profile, ...(Embed|string)) -> nil
}

local function toInteger(color)
	return math.floor(color.r*255)*256^2+math.floor(color.g*255)*256+math.floor(color.b*255)
end
--Sets the variable for the current webhook for using methods like <code>Profile:Send()</code> or <code>Embed:Send()</code>
function EasyDiscordWebhooks:ConnectWebhook(url: string, configuration: WebhookConfiguration?)
	
	if not (url and string.match(url, "^https://discord.com/api/webhooks")) then
		error("Webhook url can't be nil or not be a Discord webhook")
		return
	end
	
	local configuration = configuration or {}::WebhookConfiguration
	
	EasyDiscordWebhooks.CurrentHook = {
		URL = url,
		WebhookConfig = configuration
	}
	
	if configuration.AlertOnConnection then
		
		HttpService:PostAsync(url,
			HttpService:JSONEncode({["embeds"] = {
				{
					title = "Server started",
					description = `Server \`{JobId()}\` connected to webhook at time {timestamp()}\n\n-# Time and date is synced with your client - Module by CubingDeveloper`,
					color = toInteger(configuration.EmbedColor or Color3.new(0, 0.94902, 1))
				}
			}})
		)
		
	end
	
end

-- EVENTS

game.Players.PlayerAdded:Connect(function(playerWhoJoined)
	
	PlayTimes[playerWhoJoined.UserId] = os.time()
	
	if EasyDiscordWebhooks.CurrentHook and (
		EasyDiscordWebhooks.CurrentHook.WebhookConfig.AlertOnJoin or
		EasyDiscordWebhooks.CurrentHook.WebhookConfig.AlertOnStarCreatorJoin
	) then
		local isStarCreator = playerWhoJoined:IsInGroup(4199740)
		
		if (EasyDiscordWebhooks.CurrentHook.WebhookConfig.AlertOnStarCreatorJoin and isStarCreator) then
			HttpService:PostAsync(EasyDiscordWebhooks.CurrentHook.URL,
				HttpService:JSONEncode({["embeds"] = {
					{
						title = `**:star: Star creator @{playerWhoJoined.Name} ({playerWhoJoined.DisplayName}) with userID {playerWhoJoined.UserId} joined the game. :star:**`,
						description = `**A star creator joined server \`{JobId()}\` at time {timestamp()}. You can join their server by going [here](https://www.roblox.com/games/{game.PlaceId}) and pasting \`javascript:window.Roblox.GameLauncher.joinGameInstance({game.PlaceId}, "{JobId()}");\` into the search bar.\n\n-# Time and date is synced with your client - Module by CubingDeveloper **`,
						color = toInteger((EasyDiscordWebhooks.CurrentHook.WebhookConfiguraton or {EmbedColor=Color3.new(0, 0.94902, 1)}).EmbedColor or Color3.new(0, 0.94902, 1))
					}
				}})
			)
		else
			HttpService:PostAsync(EasyDiscordWebhooks.CurrentHook.URL,
				HttpService:JSONEncode({["embeds"] = {
					{
						title = `Player @{playerWhoJoined.Name} ({playerWhoJoined.DisplayName}) with userID {playerWhoJoined.UserId} joined the game.`,
						description = `A player joined server \`{JobId()}\` at time {timestamp()}. You can join their server by going [here](https://www.roblox.com/games/{game.PlaceId}) and pasting \`javascript:window.Roblox.GameLauncher.joinGameInstance({game.PlaceId}, "{JobId()}");\` into the search bar.\n\n-# Time and date is synced with your client - Module by CubingDeveloper`,
						color = toInteger((EasyDiscordWebhooks.CurrentHook.WebhookConfiguraton or {EmbedColor=Color3.new(0, 0.94902, 1)}).EmbedColor or Color3.new(0, 0.94902, 1))
					}
				}})
			)
		end
	end
	
end)

game.Players.PlayerRemoving:Connect(function(playerWhoLeft)
	local playTime = os.time() - PlayTimes[playerWhoLeft.UserId]

	if EasyDiscordWebhooks.CurrentHook and EasyDiscordWebhooks.CurrentHook.WebhookConfig.AlertOnLeave then

		HttpService:PostAsync(EasyDiscordWebhooks.CurrentHook.URL,
			HttpService:JSONEncode({["embeds"] = {
				{
					title = `Player @{playerWhoLeft.Name} ({playerWhoLeft.DisplayName}) with userID {playerWhoLeft.UserId} left the game.`,
					description = `A player left server \`{JobId()}\` at time {timestamp()} after playing for {playTime//60}m and {playTime - playTime//60}s.\n\n-# Time and date is synced with your client - Module by CubingDeveloper`,
					color = toInteger((EasyDiscordWebhooks.CurrentHook.WebhookConfiguraton or {EmbedColor=Color3.new(0, 0.94902, 1)}).EmbedColor or Color3.new(0, 0.94902, 1))
				}
			}})
		)

	end

end)

-- PROFILES

EasyDiscordWebhooks.Profiles = {}

--Creates a new profile that can send embeds, messages and images with the <code>Profile:Send(Content)</code> method.<br>Profiles are useful for changing the image and name of the webhook without requiring the module more than once and creating new webhooks.
function EasyDiscordWebhooks.Profiles.New(): Profile
	local self = {} :: Profile
	
	--Sends the strings/embed provided using this profile.
	function self:Send(...)
		
		local toSend = {
			username = self.Name,
			avatar_url = self.Image,
			content = ""
		}
		
		local hasEmbed = false
		
		for _,content: (Embed|string) in {...} do
			
			if typeof(content) == "string" then
				toSend.content = toSend.content..`\n{content}`
			else
				if not hasEmbed then
					toSend.embeds = {}
					hasEmbed = true
				end
				table.insert(toSend.embeds,content:ExportTable())
			end
			
		end
		if EasyDiscordWebhooks.CurrentHook.WebhookConfig.DebugPrintContentBeforePOST then print(toSend) end

		HttpService:PostAsync(
			EasyDiscordWebhooks.CurrentHook.URL,
			HttpService:JSONEncode(toSend)
		)

		
	end
	
	
	
	return self
end

--Creates a profile from an author. Can be generated using <code>EasyDiscordWebhooks.Embeds.AuthorFromUsername()</code> or <code>EasyDiscordWebhooks.Embeds.AuthorFromID()</code>
function EasyDiscordWebhooks.Profiles.FromAuthor(Author: Author)
	
	local self = EasyDiscordWebhooks.Profiles.New()
	self.Image = Author.icon_url
	self.Name = Author.name
	return self
	
	
end

-- EMBEDS

EasyDiscordWebhooks.Embeds = {}
EasyDiscordWebhooks.Embeds.ProxyServer = "roproxy.com"
EasyDiscordWebhooks.Embeds.ThumbnailEndpoint = "https://thumbnails.%s/v1/users/avatar-headshot?size=420x420&format=Png&isCircular=false&userIds="
EasyDiscordWebhooks.Embeds.ProfileURL = "https://www.roblox.com/users/%s/profile"

--Makes an <code>Embed</code> object that can be send using it's built in <code>:Send()</code> method or with `Profile:Send(Embed)`.

function EasyDiscordWebhooks.Embeds.New(): Embed
	
	local self = {} :: Embed
	
	function self:ExportTable()
		return {
			title = self.Title,
			description = self.EmbedContent,
			color = toInteger(self.Color and self.Color or (EasyDiscordWebhooks.CurrentHook.WebhookConfig.EmbedColor or Color3.new(0, 1, 0.917647))),
			image = self.ImageUrl and {url = self.ImageUrl} or nil,
			thumbnail = self.ThumbnailUrl and {url = self.ThumbnailUrl} or nil,
			author = (self.Author and (self.Author.name or self.Author.icon_url or self.Author.url)) and self.Author or nil,
			footer = (self.Footer and (self.Footer.text  or self.Footer.icon_url)) and self.Footer or nil,
			fields = self.Fields
		}
			
	end
	
	--Sends this Embed using the primary webhook.
	function self:Send()
		
		local toSend = self:ExportTable()
		if EasyDiscordWebhooks.CurrentHook.WebhookConfig.DebugPrintContentBeforePOST then print(toSend) end
		
		HttpService:PostAsync(
			EasyDiscordWebhooks.CurrentHook.URL,
			HttpService:JSONEncode({embeds = {toSend}})
		)
		
	end
	
	--Adds the field(s) to the embed by formatting it and appending it/them to the embeds <code>Field</code> table.
	function self:AddFields(...: {EmbedField})
		if not self.Fields then self.Fields = {} end
		for _, Field: EmbedField in {...} do
			table.insert(self.Fields, {
				name = Field.name,
				value = Field.description,
				inline = Field.inline
			})
		end
	end
	return self
end

--Creates a new <code>EmbedField</code> that can be used to be added to an embed. Inline is optional and changes if multiple fields should be on the same line or not.
function EasyDiscordWebhooks.Embeds.NewField(Name: string, Description: string, Inline: boolean?): EmbedField
	local self = {} :: EmbedField
	self.name = Name
	self.description = Description
	self.inline = Inline or false
	return self
end


--[[

<strong>This function usess RoProxy.com to retrieve the thumbnail. If it's down this function wont work. To replace this proxy server simply edit the <code>EasyDiscordWebhooks.Embeds.ProxyServer<code> to your desired URL.</strong>

Generates an author  table from a UserID

]]
function EasyDiscordWebhooks.Embeds.AuthorFromID(UserID: number): Author?
	
	local username = game.Players:GetNameFromUserIdAsync(UserID)
	if not username then
		warn(`User {UserID} does not exist.`)
	end
	local thumbnail_url = string.format(EasyDiscordWebhooks.Embeds.ThumbnailEndpoint, EasyDiscordWebhooks.Embeds.ProxyServer)..tostring(UserID)
	local result = HttpService:JSONDecode(HttpService:GetAsync(thumbnail_url))
	if not result then warn(`Could not retrieve thumbnail of {username} ({UserID})`) return end
	
	return {
		icon_url = result.data[1].imageUrl,
		url = string.format(EasyDiscordWebhooks.Embeds.ProfileURL, UserID),
		name = username
	}
	
end
--[[

<strong>This function usess RoProxy.com to retrieve the thumbnail. If it's down this function wont work. To replace this proxy server simply edit the <code>EasyDiscordWebhooks.Embeds.ProxyServer<code> to your desired URL.</strong>

Generates an author table from a username

]]
function EasyDiscordWebhooks.Embeds.AuthorFromUsername(Username: string): Author?
	
	return EasyDiscordWebhooks.Embeds.AuthorFromID(game.Players:GetUserIdFromNameAsync(Username))
	
end

return EasyDiscordWebhooks
