include "shared.lua"

local htmlBaseUrl = MediaPlayer.GetConfigValue('html.base_url')

DEFINE_BASECLASS( "mp_service_browser" )

local TwitchUrl = "https://player.twitch.tv/?channel=%s"

local JS_Play = "if(window.player) player.play();"
local JS_Pause = "if(window.player) player.pause();"
local JS_SetVolume = "if(window.player) player.setVolume(%s);"

local JS_Stuff = [[
	function check() {
		var mature = document.querySelector('#mature-link');
		if (!!mature) { mature.click(); clearInterval(intervalId); }
	}
	var intervalId = setInterval(check, 100);
]]

function SERVICE:OnBrowserReady( browser )

	BaseClass.OnBrowserReady( self, browser )

	local channel = self:GetTwitchChannel()
	local url = TwitchUrl:format(channel)

	browser:OpenURL( url )
	browser.OnFinishLoading = function(self)
		browser:RunJavascript(JS_Stuff)
	end

end

function SERVICE:Pause()
	BaseClass.Pause( self )

	if ValidPanel(self.Browser) then
		self.Browser:RunJavascript(JS_Pause)
		self._YTPaused = true
	end
end

function SERVICE:SetVolume( volume )

	if ValidPanel(self.Browser) then
		local js = JS_SetVolume:format( volume )
		self.Browser:RunJavascript(js)
	end

end
