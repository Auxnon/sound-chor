-- The jungle song with every channel but the singer muted, so the sung vocal
-- (with its echo and reverb) can be heard and measured on its own. The verse
-- comes in after the 8-bar intro, ~11s. Run with
-- playtests/run.sh playtests/vocal.lua 36
TT = { t = 0, step = 0, t0 = -1 }

function TEST_HOOK(dt)
	local n = now()
	if TT.t0 < 0 then
		TT.t0 = n
	end
	TT.t = n - TT.t0
	if TT.step == 0 and TT.t > 0.5 then
		TT.step = 1
		jungle_start()
		local others = { JG.drums, JG.bass, JG.keys, JG.pad, JG.hats, JG.arp }
		for i = 1, #others do
			fade(others[i], 0, 0)
		end
	elseif TT.step == 1 and TT.t > 33 then
		TT.step = 2
		jungle_stop()
		quit()
	end
end
