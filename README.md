# EasyDiscordWebhooks
## A Roblox Studio module for easily intergrating Discord webhooks into Rolox Studio

### Importing

**Importing using the .rbxm file**

Go to the [releases](https://github.com/CubingDeveloper/EasyDiscordWebhooks/releases) tab and download the latest release. There should be a `.rbxm` file. Download the file by opening Roblox Studio and right clicking the object you want to import the module to and clicking import from file. Select your downloaded file and you are done.

**Importing using the .lua file**

Create a new ModuleScript in Roblox Studio and paste the Luau code into the ModuleScript.

### Making a webhook on Discord
Go onto your Discord server and right click the channel this webhook should have access to. Then click Edit Channel > Intergrations. Then click the webhooks tab and press "New Webhook". The webhook should show up under the blue button. Here you can change the name of the webhook and even the icon, and if you ever want to change the channel simply use the dropdown box. You can change the icon and name using the modules profile (`EasyDiscordWebhooks.Profiles`) branch. Having issues? This [article](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) explains webhooks in more detail.

### Connecting to your webhook
In Roblox Studio create a new Script. I recommend putting it in ServerScriptService to keep it organized. Now in this new script require the module you imported. It might look like this:
```lua

local EasyDiscordWebhooks = require(game.ReplicatedStorage.EasyDiscordWebhooks)

```
Now to connect your webhook use the `:ConnectWebhook()` function. The first argument is the URL of your webhook, you can get the URL by going to your channel with the webhook then Edit Channel > Intergrations > Webhooks then clicking your webhook and then the "Copy Webhook URL" button. The second argument is the webhook configuration which can help you debug or automatically send messages. The second argument is completely optional, and so are the keys in the table. Here I am writing them out just to be clear. After this your code might look like this:
```lua

local EasyDiscordWebhooks = require(game.ReplicatedStorage.EasyDiscordWebhooks)
EasyDiscordWebhooks:ConnectWebhook(
  "YOUR-WEBHOOK-URL-HERE",
  {
  	AlertOnConnection = true,
  
  	AlertOnJoin = true,
  	AlertOnStarCreatorJoin = false, --If true it will only add some extra effects, not completely remove it as long as AlertOnJoin is true
  	
  	AlertOnLeave: false,
  	EmbedColor: Color3.new(0, 1, 0.0313725),
  	
  	DebugPrintContentBeforePOST: false
	
  }
)

```
Perfect! If you have the `AlertOnConnection` value set to true you should be able to run the game and see a message from the webhook!

### Sending your first message
Sending simple messages is really simple, all you need to do is use the `.Post()` function (only works if a webhook is connected). The `.Post()` function is very similar to `print()` except it sends it to the webhook. Tables will not be formatted (yet) and instead send something like `table: MEMORY-ADRESS`. To send the message "Hello World!" you could do it one of these ways:

```lua
EasyDiscordWebhooks.Post("Hello World!")
```
Or:
```lua
EasyDiscordWebhooks.Post("Hello", "World!")
```
Both of these will give the same output since the `.Post()` function separates string by space. If you have done this correctly you should see the webhook sending the message "Hello World!". 

### Sending your first embed
Sending embeds is really easy with the module. Simply create a new embed using the `EasyDiscordWebhooks.Embeds.New()` function. Then you can change the properties just like a table. Here is an example of using embeds.
```lua
local myEmbed = EasyDiscordWebhooks.Embeds.New()
myEmbed.Title = "Hello World!"
myEmbed.EmbedContent = "This is a test embed!"
myEmbed.Color = Color3.new(0.9, 0.2, 1)

myEmbed:Send()
```
Now you should see the embed in your webhook channel when you run the game! 

### Using authors
An author in this module is an object to represent either a Roblox Player or a custom author with a name, url and icon. Authors can be used for creating profiles or adding them to embeds. Here is an example of an custom author:
```lua
local myAuthor = {
	name = "CubingDeveloper",
	url = "github.com/CubingDeveloper",
	icon_url = "https://avatars.githubusercontent.com/u/171845485?s=96&v=4"
}

```
Here is an example of an author that is created using their Roblox username. **Using :GetAuthorFromUsername() or :GetAuthorFromID() both use the proxy server RoProxy.com by default. This is configurable but be aware.**
```lua
local myAuthor = EasyDiscordWebhooks.Embeds.AuthorFromUsername("CubingDeveloper")
```
Now to add this author to an embed we can simply set the `Embed.Author` to `myAuthor`. Here is that combined with the old embed example:
```lua
local myAuthor = EasyDiscordWebhooks.Embeds.AuthorFromUsername("CubingDeveloper")

local myEmbed = EasyDiscordWebhooks.Embeds.New()
myEmbed.Title = "Hello World!"
myEmbed.EmbedContent = "This is a test embed!"
myEmbed.Color = Color3.new(0.9, 0.2, 1)
myEmbed.Author = myAuthor

myEmbed:Send()
```
Now you will see the author on your embed!

### Using profiles
Profiles is a useful feature of this module that allows you to use the same webhook but for different icons and names. This could be useful for separating different messages and showing who used the webhook without using authors. You can create a profile like this:
```lua
local myProfile = EasyDiscordWebhooks.Profiles.New()
```
Profiles can also be generated using authors:
```lua
local myProfile = EasyDiscordWebhooks.Profiles.FromAuthor(EasyDiscordModule.Embeds.AuthorFromUsername("CubingDeveloper"))
```
Now to send a message using this profile you can use the `:Send()` method. It is quite similar to the `EasyDiscordWebhook.Post()` function except it uses the profile to send this message. Using `:Send()` also adds supports for embeds. For example:
```lua
myProfile:Send("Hello I am CubingDeveloper!", "I like programming.", myEmbed --[[Not defined in this code snippet and is just an example]])
```
