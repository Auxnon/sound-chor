-- seq() with no id pushes onto the channel's queue, and a sequence's own bpm
-- takes over on its first beat. Three sequences on one channel, 1-beat steps:
--   A at 120bpm, 2 passes of {440, rest}   -> 440 at 0.0s and 1.0s
--   B with bpm = 240, 4 passes of {660}    -> 2.0, 2.25, 2.5, 2.75s
--   C (no bpm, keeps 240), 2 passes {880}  -> 3.0, 3.25s
--   D (keeps 240), forever {330}           -> 3.5, 3.75, ... every 0.25s
-- then a live bpm(120) ~4.6s in slows D to every 0.5s, with no burst or gap.
-- Run with playtests/run.sh playtests/push.lua 9
TT = { t0 = -1, step = 0 }

function TEST_HOOK(dt)
	local n = now()
	if TT.t0 < 0 then
		TT.t0 = n
	end
	local t = n - TT.t0
	if TT.step == 0 and t > 0.5 then
		TT.step = 1
		bpm(120)
		local a = seq(nil, { { 1, 440, 0, 1, len = 0.1 }, { 1, 0 } }, { ch = 1, loop = 2 })
		local b = seq(nil, { { 1, 660, 0, 1, len = 0.1 } }, { ch = 1, loop = 4, bpm = 240 })
		local c = seq(nil, { { 1, 880, 0, 1, len = 0.1 } }, { ch = 1, loop = 2 })
		TT.d = seq(nil, { { 1, 330, 0, 1, len = 0.1 } }, { ch = 1, loop = true })
		print("push ids", a, b, c, TT.d, "after c ~= a", c ~= a)
		TT.at = t
	elseif TT.step == 1 and t > TT.at + 4.6 then
		TT.step = 2
		bpm(120)
	elseif TT.step == 2 and t > TT.at + 6.2 then
		TT.step = 3
		seq()
		quit()
	end
end
