# EasyDiscordWebhooks
## A Roblox Studio module for easily intergrating Discord webhooks into Rolox Studio

### Importing

**Importing using the .rbxm file**

Go to the [releases](https://github.com/CubingDeveloper/EasyDiscordWebhooks/releases) tab and download the latest release. There should be a `.rbxm` file. Download the file by opening Roblox Studio and right clicking the object you want to import the module to and clicking import from file. Select your downloaded file and you are done.

**Importing using the .lua file**

Create a new ModuleScript in Roblox Studio and paste the Luau code into the ModuleScript.

### Making a webhook on Discord
Go onto your Discord server and right click the channel this webhook should have access to. Then click Edit Channel > Intergrations. Then click the webhooks tab and press "New Webhook". The webhook should show up under the blue button. Here you can change the name of the webhook and even the icon, and if you ever want to change the channel simply use the dropdown box. You can change the icon and name using the modules profile (`EasyDiscordWebhooks.Profiles`) branch. Having issues? This [article](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) explains webhooks in more detail.

### Sending your first message
In Roblox Studio create a new Script. I recommend putting it in ServerScriptService to keep it organized. Now in this new script require the module you imported. It might look like this:
```lua

local EasyDiscordWebhooks = require(game.ReplicatedStorage.EasyDiscordWebhooks)

```
