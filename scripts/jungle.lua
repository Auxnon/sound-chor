-- A 2001-style liquid jungle track at 172bpm, written as data for seq(): a
-- chopped amen (sounds/amen2.ogg, one bar at ~137bpm, sliced into 16ths and
-- pitched up to tempo), a sub bass, Rhodes-ish electric piano chords, a pad, a
-- bell arp and a sung vocal, all in F minor (Fm9 - Dbmaj7 - Bbm9 - Cm7).
--
-- The arrangement is chained with seq's `after`: an 8-bar intro (keys and pad),
-- then drums, bass and the verse come in together on the bar the intro ends;
-- the verse plays twice (a counted loop), then the second verse, and the arp
-- joins after the first verse. Everything else loops until jungle_stop().

-- Channels. The keyboard in main.lua plays on 2 and sings on 0.
JG = {
	on = false,
	drums = 3, bass = 4, keys = 5, pad = 6, vocal = 7, hats = 9, arp = 10,
	amen_bpm = 137.0, -- amen2.ogg is one bar: 1.752s = 4 beats at 137bpm
	slice = 20, -- instruments 20..35 are the 16 slices of the break
}

-- The progression, two bars a chord: bass root, and the chord voicing.
JG_CHORDS = {
	"f3 ab3 c4 eb4 g4",
	"db3 f3 ab3 c4 eb4",
	"bb2 db3 f3 ab3 c4",
	"c3 eb3 g3 bb3",
}
JG_ARP = {
	"f4 ab4 c5 eb5 g5 eb5 c5 ab4",
	"f4 ab4 c5 eb5 f5 eb5 c5 ab4",
	"f4 ab4 db5 f5 ab5 f5 db5 ab4",
	"g4 bb4 c5 eb5 g5 eb5 c5 bb4",
}

function jungle_instruments()
	-- The break, chopped into sixteenths. Each slice is its own instrument that
	-- shares the one decoded file; a short release keeps the cuts clean.
	for k = 0, 15 do
		local a = k / 16
		local b = (k + 1) / 16
		local cfg = { from = a, to = b, atk = 0.001, rel = 0.012 }
		smpl(JG.slice + k, "amen2", cfg)
	end
	-- Sub bass: a sine with a little drive so it reads on small speakers too.
	instr(3, "sine", { atk = 0.008, dec = 0.3, sus = 0.8, rel = 0.08 })
	grit(JG.bass, 0.25, "soft")
	-- Electric piano: a strong fundamental, a bell-ish 2nd and a touch of the
	-- upper partials, that rings and decays like a struck tine.
	instr(4, { 1, 0.45, 0.12, 0.18, 0.04, 0.06 }, { atk = 0.003, dec = 0.9, sus = 0.25, rel = 0.45 })
	echo(JG.keys, 0.26, 0.35, 0.25) -- a dotted eighth at 172
	verb(JG.keys, 0.5, 0.5, 0.25)
	-- Pad: a slow saw swell under a low-pass, in a big room.
	instr(5, "saw", { atk = 0.9, dec = 0.5, sus = 0.7, rel = 1.6 })
	filt(JG.pad, "low", 900, 1.2)
	verb(JG.pad, 0.85, 0.6, 0.5)
	-- Hats: tight noise ticks.
	instr(6, "noise", { atk = 0.0, dec = 0.03, sus = 0.0, rel = 0.02 })
	filt(JG.hats, "high", 7000, 0.8)
	-- Arp: a soft triangle bell.
	instr(7, "tri", { atk = 0.002, dec = 0.2, sus = 0.15, rel = 0.2 })
	echo(JG.arp, 0.52, 0.4, 0.35)
	-- The singer: a little breath and vibrato, in the same space as the keys.
	vox(JG.vocal, { breath = 0.12, vib = 0.025, hz = 5.2 })
	echo(JG.vocal, 0.26, 0.25, 0.2)
	verb(JG.vocal, 0.55, 0.5, 0.3)
	-- Levels: the master bus soft-limits, so leave it headroom rather than
	-- letting the break and the sub push everything into the limiter. The
	-- vocal sits ~2 dB under the band.
	fade(JG.drums, 0, 0.41)
	fade(JG.bass, 0, 0.38)
	fade(JG.pad, 0, 0.19)
	fade(JG.hats, 0, 0.19)
	fade(JG.arp, 0, 0.26)
	fade(JG.keys, 0, 0.38)
	fade(JG.vocal, 0, 0.6)
end

-- Four bars of chopped amen: straight, a variation, a rearrangement, a fill.
-- Upper case = ghosted slice.
function jungle_drums()
	local f = 440 * 172 / JG.amen_bpm
	local b1 = chop("0123456789abcdef", JG.slice, f, 0.25)
	local b2 = chop("0123456789ab4c4E", JG.slice, f, 0.25)
	local b3 = chop("0123014589ab47ef", JG.slice, f, 0.25)
	local b4 = chop("01234567444477Ee", JG.slice, f, 0.25)
	return join(b1, b2, b3, b4)
end

function jungle_hats()
	local h = grid("..x...x...x...xo", 8000, 6, 0.25)
	return h
end

function jungle_bass()
	local a = melody("f2:1.5 f2:1 r:.5 ab2:1 f2:1.5 r:.5 c2:1.5 eb2:.5", 3, 1, 0.85)
	local b = melody("db2:1.5 db2:1 r:.5 f2:1 db2:1.5 r:.5 ab1:1.5 c2:.5", 3, 1, 0.85)
	local c = melody("bb1:1.5 bb1:1 r:.5 db2:1 bb1:1.5 r:.5 f2:1.5 ab1:.5", 3, 1, 0.85)
	local d = melody("c2:1.5 c2:1 r:.5 eb2:1 g2:1.5 r:.5 bb1:1 c2:1", 3, 1, 0.85)
	return join(a, b, c, d)
end

-- The keys: syncopated stabs (hits on 1, the "and" of 2, 1 and the "and" of 2
-- again across each chord's two bars). The intro holds each chord instead.
function jungle_keys(rhythm)
	local text = ""
	for i = 1, #JG_CHORDS do
		local sep = ""
		if i > 1 then
			sep = ", "
		end
		text = text .. sep .. JG_CHORDS[i] .. "|" .. rhythm
	end
	return chords(text, 4, 0.92)
end

function jungle_pad()
	local text = ""
	for i = 1, #JG_CHORDS do
		local sep = ""
		if i > 1 then
			sep = ", "
		end
		text = text .. sep .. JG_CHORDS[i] .. "|8"
	end
	return chords(text, 5, 1.0)
end

-- Sixteenth-note arp over each chord: the 8-note figure four times = 2 bars.
function jungle_arp()
	local out = {}
	local n = 0
	for c = 1, #JG_ARP do
		local fig = melody(JG_ARP[c], 7, 0.25, 0.6)
		for r = 1, 4 do
			for i = 1, #fig do
				local st = fig[i]
				n = n + 1
				local vol = 0.5
				if i == 1 then
					vol = 0.8
				end
				local copy = { st[1], st[2], st[3], vol, len = st.len }
				out[n] = copy
			end
		end
	end
	return out
end

-- The vocal: one line per chord (two bars), one syllable per note. The lyric
-- respells itself (speech.lua); `respell(text)` shows how.
function jungle_verse_a()
	local m = melody("c4:1.5 ab3:.5 c4:1 eb4:1 c4:3 r:1 "
		.. "bb3:1 ab3:1 f3:1 ab3:4 r:1 "
		.. "f4:1.5 eb4:.5 db4:1 c4:4 r:1 "
		.. "bb3:1 c4:1 eb4:1 c4:1 g3:3 r:1", 0, 1, 0.92)
	return lyric("feel the rain come down, over the town, light up the night, we keep on moving", m)
end

function jungle_verse_b()
	local m = melody("c4:1 c4:1 eb4:1 f4:1 eb4:3 r:1 "
		.. "db4:1 c4:1 ab3:2 f3:3 r:1 "
		.. "f4:1 f4:1 eb4:1 db4:1 c4:3 r:1 "
		.. "bb3:1 c4:1 db4:1 c4:1 c4:3 r:1", 0, 1, 0.92)
	return lyric("and the bass line rolls, deep in the sound, hear the amen break, keep it moving on", m)
end

function jungle_start()
	if JG.on then
		return
	end
	JG.on = true
	tempo(172)
	jungle_instruments()
	local intro = jungle_keys("4 4")
	local keys = jungle_keys("1.5 2.5 1.5 2.5")
	local pad = jungle_pad()
	local drums = jungle_drums()
	local hats = jungle_hats()
	local bass = jungle_bass()
	local arp = jungle_arp()
	local va = jungle_verse_a()
	local vb = jungle_verse_b()
	-- grid = 4: everything starts on the next bar line.
	seq(10, intro, { ch = JG.keys, grid = 4 })
	seq(11, pad, { ch = JG.pad, grid = 4, loop = true })
	seq(12, keys, { ch = JG.keys, after = 10, loop = true })
	seq(20, drums, { ch = JG.drums, after = 10, loop = true, choke = true })
	seq(21, hats, { ch = JG.hats, after = 10, loop = true })
	seq(30, bass, { ch = JG.bass, after = 10, loop = true })
	seq(40, va, { ch = JG.vocal, after = 10, loop = 2 })
	seq(41, vb, { ch = JG.vocal, after = 40, loop = true })
	seq(50, arp, { ch = JG.arp, after = 40, loop = true })
	print("jungle: 172bpm, intro 8 bars then the break")
	local ra = respell("feel the rain come down, over the town, light up the night, we keep on moving")
	local rb = respell("and the bass line rolls, deep in the sound, hear the amen break, keep it moving on")
	print("verse a: " .. ra)
	print("verse b: " .. rb)
end

function jungle_stop()
	if not JG.on then
		return
	end
	JG.on = false
	seq()
	mute()
end

function jungle_toggle()
	if JG.on then
		jungle_stop()
	else
		jungle_start()
	end
end
