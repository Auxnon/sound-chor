-- Plays the jungle song, then both talk keys, then stops it. Run with
-- playtests/run.sh playtests/jungle.lua 46
TT = { t = 0, step = 0, t0 = -1 }
function TEST_HOOK(dt)
	local n = now()
	if TT.t0 < 0 then
		TT.t0 = n
	end
	TT.t = n - TT.t0
	if TT.step == 0 and TT.t > 1 then
		TT.step = 1
		jungle_start()
	elseif TT.step == 1 and TT.t > 30 then
		TT.step = 2
		talk_next(false)
	elseif TT.step == 2 and TT.t > 34 then
		TT.step = 3
		talk_next(true)
	elseif TT.step == 3 and TT.t > 38 then
		TT.step = 4
		jungle_toggle()
		print("stopped")
	elseif TT.step == 4 and TT.t > 41 then
		quit()
	end
end
