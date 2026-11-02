-- Music helpers over the engine's seq(): note names, step builders for drum
-- grids, chopped breaks and melodies, and the tempo they're counted against.
-- Everything here returns plain step tables, so a song is data you can print,
-- edit and hand to seq() (and later, to the sequencer UI).

-- The tempo last set through tempo(). Lua can't read the audio thread's clock,
-- so anything that converts seconds to beats (talk()) reads it from here.
M = { bpm = 120 }

NOTE_SEMI = { c = 0, d = 2, e = 4, f = 5, g = 7, a = 9, b = 11 }

function tempo(b)
	M.bpm = b
	bpm(b)
end

-- Seconds at the current tempo, as beats.
function beats(secs)
	return secs * M.bpm / 60
end

-- A note name ("a4", "c#3", "eb2") as Hz. Numbers pass through; "r" or "-" is
-- a rest (0).
function hz(name)
	if type(name) == "number" then
		return name
	end
	local l = string.sub(name, 1, 1)
	if l == "r" or l == "-" or l == "." then
		return 0
	end
	local semi = NOTE_SEMI[l]
	if semi == nil then
		return 0
	end
	local rest = string.sub(name, 2)
	local acc = string.sub(rest, 1, 1)
	if acc == "#" then
		semi = semi + 1
		rest = string.sub(rest, 2)
	elseif acc == "b" then
		semi = semi - 1
		rest = string.sub(rest, 2)
	end
	local oct = tonumber(rest)
	if oct == nil then
		oct = 4
	end
	local midi = semi + (oct + 1) * 12
	local e = (midi - 69) / 12
	local f = pow(2, e)
	return 440 * f
end

-- Split a string on spaces into a list.
function split(s)
	local out = {}
	local n = 0
	local i = 1
	local len = #s
	while i <= len do
		local a, b = string.find(s, "[^ ]+", i)
		if a == nil then
			break
		end
		n = n + 1
		out[n] = string.sub(s, a, b)
		i = b + 1
	end
	return out
end

-- Several note names as a chord: "f3 ab3 c4 eb4" -> {174.6, 207.7, ...}.
function chord_hz(names)
	local list = split(names)
	local out = {}
	for i = 1, #list do
		local f = hz(list[i])
		out[i] = f
	end
	return out
end

-- A drum grid: one character per `step` beats. "x" hits at full volume, "o" is
-- a ghost note (half), "." rests. `freq`/`instr` say what the hit plays.
--   grid("x...x...x...x...", 440, 3, 0.25)  -- four on the floor in 16ths
function grid(pattern, freq, instr, step)
	local out = {}
	for i = 1, #pattern do
		local c = string.sub(pattern, i, i)
		local vol = 0
		if c == "x" then
			vol = 1
		elseif c == "o" then
			vol = 0.5
		end
		local f = freq
		if vol == 0 then
			f = 0
		end
		local st = { step, f, instr, vol }
		out[i] = st
	end
	return out
end

HEX = "0123456789abcdef"

-- A chopped break: one character per `step` beats naming which slice plays,
-- "0".."f" for slices 0..15 (instrument `base + n`). Upper case "0".."F" plays it
-- as a ghost (half volume); "." rests. Slices come from smpl{from, to}.
--   chop("0123456789abcdef", 20, 552, 0.25)  -- the break straight through
function chop(pattern, base, freq, step)
	local out = {}
	for i = 1, #pattern do
		local c = string.sub(pattern, i, i)
		local lc = string.lower(c)
		local n = string.find(HEX, lc, 1, true)
		local vol = 1
		if c ~= lc then
			vol = 0.5
		end
		local st = { step, 0, 0, 0 }
		if n ~= nil then
			st = { step, freq, base + n - 1, vol }
		end
		out[i] = st
	end
	return out
end

-- A melody from "name:beats" tokens, e.g. "c5:1.5 ab4:.5 r:1 eb5:2". A token
-- without ":beats" lasts `step` beats. Each note sounds for `gate` of its
-- length (default 0.9) so repeated pitches re-articulate.
function melody(text, instr, step, gate)
	local toks = split(text)
	local g = gate or 0.9
	local out = {}
	for i = 1, #toks do
		local t = toks[i]
		local len = step or 1
		local name = t
		local c = string.find(t, ":", 1, true)
		if c ~= nil then
			name = string.sub(t, 1, c - 1)
			local num = string.sub(t, c + 1)
			len = tonumber(num)
		end
		local f = hz(name)
		local st = { len, f, instr, 1, len = len * g }
		out[i] = st
	end
	return out
end

-- Chords from "names|beats" groups separated by commas:
--   chords("f3 ab3 c4 eb4|4, db3 f3 ab3 c4|4", 5)
-- Each chord can carry a rhythm instead of one hit: "f3 ab3 c4|1.5 1 1.5"
-- strikes it three times.
function chords(text, instr, gate)
	local g = gate or 0.9
	local out = {}
	local n = 0
	local i = 1
	local len = #text
	while i <= len do
		local a, b = string.find(text, "[^,]+", i)
		if a == nil then
			break
		end
		local group = string.sub(text, a, b)
		local bar = string.find(group, "|", 1, true)
		local names = group
		local rhythm = "4"
		if bar ~= nil then
			names = string.sub(group, 1, bar - 1)
			rhythm = string.sub(group, bar + 1)
		end
		local fs = chord_hz(names)
		local hits = split(rhythm)
		for k = 1, #hits do
			local h = hits[k]
			local bt = tonumber(h)
			n = n + 1
			local st = { bt, fs, instr, 0.8, len = bt * g }
			out[n] = st
		end
		i = b + 1
	end
	return out
end

-- Glue step lists end to end into one.
function join(a, b, c, d)
	local out = {}
	local n = 0
	local parts = { a, b, c, d }
	for p = 1, 4 do
		local list = parts[p]
		if list ~= nil then
			for i = 1, #list do
				n = n + 1
				out[n] = list[i]
			end
		end
	end
	return out
end

-- A step list repeated `times` times (for a pattern seq() should see as one pass).
function rep(list, times)
	local out = {}
	local n = 0
	for t = 1, times do
		for i = 1, #list do
			n = n + 1
			out[n] = list[i]
		end
	end
	return out
end

-- Print a step list as Lua, the way it'd be pasted into a game.
function dump(name, list)
	print(name .. " = {")
	for i = 1, #list do
		local st = list[i]
		local f = st[2]
		if type(f) == "table" then
			local inner = table.concat(f, ", ")
			f = "{" .. inner .. "}"
		end
		local extra = ""
		if st.say ~= nil then
			extra = ", say = '" .. st.say .. "'"
		end
		local b = tostring(st[1])
		local fs = tostring(f)
		local ins = tostring(st[3])
		local vol = tostring(st[4])
		local line = "  { " .. b .. ", " .. fs .. ", " .. ins .. ", " .. vol .. extra .. " },"
		print(line)
	end
	print("}")
end
