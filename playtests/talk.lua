-- Speaks one line in every talk voice, then the same in letters, with no music
-- under it, for listening to (or measuring) the voice on its own. Run with
-- playtests/run.sh playtests/talk.lua 26
TT = { t = 0, step = 0, t0 = -1, at = 1 }
TT_VOICES = { "peppy", "normal", "lazy", "cranky", "robot" }
TT_LINE = "hey there! so, did you see the shooting stars last night? it was nice."

function TEST_HOOK(dt)
	local n = now()
	if TT.t0 < 0 then
		TT.t0 = n
	end
	TT.t = n - TT.t0
	if TT.t < TT.at then
		return
	end
	TT.step = TT.step + 1
	local k = TT.step
	if k <= #TT_VOICES then
		local cfg = { voice = TT_VOICES[k] }
		local secs = talk(TT_LINE, cfg)
		TT.at = TT.t + secs + 0.6
	elseif k == #TT_VOICES + 1 then
		local cfg = { voice = "normal", letters = true }
		local secs = talk("hey there, nice night", cfg)
		TT.at = TT.t + secs + 0.6
	else
		quit()
	end
end
