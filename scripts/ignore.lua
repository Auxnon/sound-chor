-- Codex 3.0.0 "Artichoke"
---@diagnostic disable: duplicate-doc-field, missing-return
---@meta

---@class mouse
---@field x number
---@field y number
---@field dx number delta x
---@field dy number delta y
---@field m1 boolean mouse 1
---@field m2 boolean mouse 2
---@field m3 boolean mouse 3
-- @field scroll number scroll delta
---@field vx number unprojection x
---@field vy number unprojection y
---@field vz number unprojection z
---@return mouse

---@class attributes
---@field resolution number artificial resolution
---@field lock boolean
---@field fog number 0 is off
---@field fullscreen boolean
---@field mouse_grab boolean
---@field size integer[] width, height of window
---@field title string
---@field modernize boolean must be false or 0 for the remainder to work
---@field dark number
---@field glitch number[]
---@field curvature number
---@field flatness number
---@field high number
---@field low number
---@field bleed number

---@class cam_params
---@field pos number[]? x, y, z
---@field rot number[]? azimuth, altitude
---@field ortho (number|boolean)? orthographic half-height in world units; 0 or false for perspective

--- @class model_data
--- @field t (string|string[])? texture asset(s)
--- @field q number[][]? quads
--- @field v number[][]? vertices
--- @field u number[][]? uvs
--- @field i integer[]? indices

--- @class entity
--- @field x number x position
--- @field y number y position
--- @field z number z position
--- @field rx number rotation x
--- @field ry number rotation y
--- @field rz number rotation z
--- @field vx number velocity x
--- @field vy number velocity y
--- @field vz number velocity z
--- @field flipped number texture flip x axis
--- @field scale number uniform scale factor 1 is 100%
--- @field offset number[]? x, y, z position to offset model
--- @field id integer assigned by engine, used for destroying
--- @field tex string texture asset
--- @field asset string model or blocked texture asset
--- @field anim fun(self:entity,animation:string,force?:boolean) change animation, force marks change even if already playing
--- @field kill fun(self:entity) destroy entity

--- @alias gunit number | integer | string
--- @alias rgb number[] | integer[] | string | integer

--- @class image
--- @field line fun(self:image, x:gunit, y:gunit, x2:gunit, y2:gunit, rgb?:rgb) draw line on image
--- @field rect fun(self:image, x:gunit, y:gunit, w:gunit, h:gunit, rgb?:rgb) draw rectangle on image
--- @field rrect fun(self:image ,x:gunit, y:gunit, w:gunit, h:gunit,ro:gunit, rgb?:rgb) draw rounded rectangle on image
--- @field text fun(self:image, txt:string, x?:gunit, y?:gunit, rgb?:rgb) draw text on image
--- @field img fun(self:image, im:image, x?:gunit, y?:gunit) draw another image on image
--- @field pixel fun(self:image, x:integer, y:integer,rgb?:rgb) draw pixel directly on image
--- @field clr fun(self:image) clear image
--- @field fill fun(self:image, rgb?:rgb) fill image with color
--- @field raw fun(self:image):integer[] image return raw pixel data
--- @field copy fun(self:image):image clones to new image

--- @class connection
--- @field send fun(self:connection, data:string) send data to connection
--- @field recv fun(self:connection):string | nil receive data from connection
--- @field test fun(self:connection):string | nil test if connection is still alive, returns string for error, 'safe close' for no error
--- @field kill fun(self:connection) close connection


--- @type number ~3.1457
pi = nil
--- @type number ~6.2914
tau = nil
--- @type image image raster for the front screen
gui = nil
--- @type image image raster for the back screen or 'sky'
sky = nil

--- shorthand for gui:text
function text(...) end

--- shorthand for gui:line
function line(...) end

--- shorthand for gui:rect
function rect(...) end

--- shorthand for gui:rrect
function rrect(...) end

--- shorthand for gui:img
function img(...) end

--- shorthand for gui:pixel
function pixel(...) end

--- shorthand for gui:fill
function fill(...) end

--- shorthand for gui:clr
function clr(...) end



-- Absolute value
---@param f number
---@return number
function abs(f) end


-- Check how much a gamepad is pressed, axis gives value between -1 and 1
---@param button string
---@return number
function abtn(button) end


-- Every currently-overlapping ent-vs-ent pair in this bundle: array of {a=id, b=id, normal={x,y,z}, depth=n}
---@return table[]
function hit.all() end


-- Set an animation by passing in series of textures
---@param name string
---@param items string[]
---@param speed number?
function anim(name, items, speed) end


-- Angle of the point (x, y) from the +x axis
---@param y number
---@param x number
---@return number
function atan2(y, x) end


-- Set app state params or get attributes if no args
---@param attributes attributes?
function attr(attributes) end


-- Set the transport tempo, shared by every channel
---@param tempo number beats per minute
function bpm(tempo) end


-- Check if gamepad button is held down
---@param button string
---@return boolean
function btn(button) end


-- Set the camera position and/or rotation
---@param params cam_params
function cam(params) end


-- Ceil value
---@param f number
---@return integer
function ceil(f) end


-- Every solid tile entity `id`'s collider currently overlaps: array of {tile={x,y,z}, normal={x,y,z}, depth=n}
---@param id integer
---@return table[]
function hit.cell(id) end


-- Get or set the graphics chip preset: r00 (modern), r43 (N64-ish), r30 (PS1-ish)
---@param code string?
---@return string?
function chip(code) end


-- Play several frequencies at once as a chord
---@param freqs number[]
---@param length number?
---@param instrument integer?
function chord(freqs, length, instrument) end


-- Get a string of all keys pressed
---@return string
function cin() end


-- Open a connection: ws://, wss:// or /path for a websocket, else ip:port tcp
--- @param addr string
--- @param udp? boolean
--- @param server? boolean
--- @return connection
function conn(addr,udp,server) end


-- Copy text to the clipboard
---@return table
function help() end


-- Cosine value
---@param f number  
---@return number
function cos(f) end


-- Prints string to console
---@param ... string|number|integer|boolean|image|entity|connection|nil
function cout(...) end


-- Bitcrush a channel: (channel, bits 1..16, rate Hz). bits<=0 disables it
---@param channel integer
---@param bits number target bit depth 1..16 (<=0 disables, 16 = no quantizing)
---@param rate number? target sample rate in Hz for decimation (default 0 = none)
function crsh(channel, bits, rate) end


-- Play a note on the transport: at a beat, or quantized to a grid
---@param freq number
---@param length number?
---@param channel integer?
---@param instrument integer?
---@param at number? absolute transport beat (default: as soon as possible)
---@param grid number? snap up to the next multiple of this many beats
function cue(freq, length, channel, instrument, at, grid) end


-- Crude deletion of a 16x16x16 chunk. Extremely efficient for large area tile changes. Not including arguments delete all tiles.
---@param x? integer
---@param y? integer
---@param z? integer
function dtile( x, y, z) end


-- Add a feedback-delay echo to a channel: (channel, secs, feedback 0..1, wet mix). secs<=0 disables it
---@param channel integer
---@param secs number delay time between echoes (<=0 disables)
---@param feedback number? echo decay per repeat 0..1 (default 0.4)
---@param mix number? wet level, echo loudness (default 0.5)
function echo(channel, secs, feedback, mix) end


-- Fade a channel's volume to target (0..1, default 0) over secs — fade in/out or crossfade channels
---@param channel integer
---@param secs number fade duration in seconds
---@param target number? target gain 0..1 (default 0 = fade out)
function fade(channel, secs, target) end


-- Resonant filter on a channel: (channel, kind 'low'|'high'|'band'|'notch', cutoff Hz, q, sweep secs). kind off/nil disables
---@param channel integer
---@param kind string? 'low' | 'high' | 'band' | 'notch' (off/nil disables)
---@param cutoff number? corner/center frequency Hz (default 1000)
---@param q number? resonance: 0.707 flat, higher peaks at cutoff (default 0.707)
---@param secs number? sweep the cutoff over this many seconds (default 0 = instant)
function filt(channel, kind, cutoff, q, secs) end


-- Floor value
---@param f number
---@return integer
function flr(f) end


-- Set distance fog: color (rgb 0..1) blended in by dist (far, world units; 0 = off)
---@param params fog_params
function fog(params) end


-- Find first occurence of a tile in a given direction
---@param x integer 
---@param y integer
---@param z integer
---@return string
function gtile(x, y, z) end


-- load a file relative to the game directory
---@return table
function get() end


-- Get image buffer userdata for editing or drawing
---@param asset string  
---@return image
function gimg(asset) end


-- Write mesh tables to a .glb/.gltf in the app folder, or read one back <path:string, data?:{v,i,n,u,t,up}>
---@param path string
---@param data {v:number[3][], i?:integer[], n?:number[3][], u?:number[2][], t?:string, up?:string}?
---@return boolean|{v:number[3][], i:integer[], n:number[3][], u:number[2][]}|nil
function glb(path, data) end


-- List models by search
---@param model string  
---@param bundle integer?
---@return string[]
function lmod(model, bundle) end


-- Enable Gouraud (per-vertex) shading, or disable it with gour(false) to go back to per-fragment
---@param on boolean?
function gour(on) end


-- Every hit between entity `id`'s collider and any other entity's tile grid: array of {owner=id, tile={x,y,z}, normal={x,y,z}, depth=n}
---@param id integer
---@return table[]
function hit.grid(id) end


-- Drive/distort a channel: (channel, amount 0..1, curve 'soft'|'hard'|'fold'). amount<=0 disables it
---@param channel integer
---@param amount number drive amount 0..1 (<=0 disables)
---@param mode string? curve: 'soft' (default, tanh) | 'hard' (clip) | 'fold' (foldback)
function grit(channel, amount, mode) end


-- Return the asset name of the tile at a given location
---@param x integer 
---@param y integer
---@param z integer
---@return string
function gtile(x, y, z) end


-- List all commands
---@return table
function help() end


-- Resets lua context and reloads all assets and scripts fresh
function reload() end


-- Define instrument `id`: a waveform name (square/saw/tri/pulse/noise/sine) or a harmonic-amplitude table; cfg = { wid, atk, dec, sus, rel }
---@param id integer
---@param spec string|number[] waveform name, or harmonic amplitudes (additive)
---@param cfg? { wid?: number, atk?: number, dec?: number, sus?: number, rel?: number } pulse duty + ADSR envelope
function instr(id, spec, cfg) end


-- An imperfect random number generator for integers. May suffer from modulo bias.
---@param a integer?
---@param b integer?
---@return integer
function irnd(a, b) end


-- Check if a tile is present at a given location
---@param x integer 
---@param y integer
---@param z integer
---@return boolean
function istile(x, y, z) end


-- Check if key is held down
---@param key string
---@param volatile boolean? only true on first frame of key press
---@return boolean
function key(key, volatile) end


-- Removes an entity
---@param ent entity | integer
function kill(ent) end


-- Base 10 logarithm of the value
---@param f number target
---@return number
function log(f) end


-- Groups an entity onto another entity
---@param parent entity
---@param child entity
function lot(parent, child) end


-- Set the one light: shape ("sun"/"cone"/"sphere", default sun), dir/pos (xyz), color (rgb 0..1), ambient (0..1), sky/ground (hemisphere, sun only), range, angle (cone half-angle, radians)
---@param params lum_params
function lum(params) end


-- Spawn an entity from an asset
---@param asset string?
---@param x number?
---@param y number?
---@param z number?
---@param scale number?
---@return entity
function make(asset, x, y, z, scale) end


-- Grab (capture) the mouse for relative look, or release it with mgrab(false)
---@param on boolean?
function mgrab(on) end


-- Record a microphone snippet into a sample slot: mic(id, secs?). mic() = is a capture running?
---@param id integer? sample/instrument slot to record into (omit to query)
---@param secs number? capture length in seconds (default 1, max 10)
---@return boolean started (or, with no args, whether a capture is running)
function mic(id, secs) end


-- MIDI in: midi() drains events, midi('ports'|'port'), midi('open', name?), midi('close')
---@param action string? nil = drain events; 'ports' | 'port' | 'open' | 'close'
---@param name string? port name substring for 'open'
---@return table|string|nil
function midi(action, name) end


-- insert model data into an asset <name:string, {v=[float,float,float][],i=int[],u=[float,float][]}>
---@param asset string
---@param t model_data
---@return string stating what mode the model was built in
function mod(asset, t) end


-- Get or set the display monitor preset: lcd (modern flat panel), slot (slot-mask CRT), grille (aperture-grille CRT)
---@param code string?
---@return string?
function mon(code) end


-- Get mouse position, delta, button states, and unprojected vector
---@return mouse
function mus() end


-- Stop sounds on a channel, or all channels if omitted
---@param channel integer?
function mute(channel) end


-- Create new image buffer userdata, does not set as asset
---@param w integer
---@param h integer
---@return image
function nimg(w, h) end


-- Play a note; optional channel + instrument. Overlapping notes voice separately.
---@param freq number
---@param length number?
---@param channel integer?
---@param instrument integer?
function note(freq, length, channel, instrument) end


-- Seconds since the engine started, as of this frame. Steps are paced by the display, so use the difference between frames to move things at a steady speed
---@return number
function now() end


-- load an overlaying bundle
---@param str string
function over(str) end


-- Pairwise collision test between two entities: nil or {normal={x,y,z}, depth=n}
---@param a entity
---@param b entity
---@return table?
function hit.pair(a, b) end


-- Squareroot value
---@param f number target
---@param e number raise by
---@return number
function pow(f,e) end


-- Hard quit or exit to console
---@param u integer? >0 soft quits
function quit(u) end


-- Random float from 0-1, or provide a range
---@param a number?
---@param b number?
---@return number
function rnd(a, b) end


-- Round value
---@param f number
---@return integer
function rou(f) end


-- Play a sequence of steps on the transport: once, a counted number of times, or looped; chain with after
---@alias SeqStep { [1]: number, [2]: number|number[]|nil, [3]: integer?, [4]: number?, len?: number, at?: number, say?: string }
---@param id integer? the sequence's handle; nil pushes it after the channel's last sequence; seq() alone stops every sequence
---@param steps SeqStep[]? {beats, freq|{freqs}|0 (rest), instrument?, volume?, len=beats, at=beat, say='la'}; omit to stop `id`
---@param cfg? { ch?: integer, loop?: integer|boolean, len?: number, at?: number, grid?: number, after?: integer|false, choke?: boolean, bpm?: number }
---@return integer? id the sequence's id (the new one, for a push)
function seq(id, steps, cfg) end


-- load a file relative to the game directory
---@return table
function get() end


-- Enable the shadow map (from the current lum light), disable it with shdw(false), or tune it with shdw{size=texels, range=tiles}
---@class shdw_params
---@field on? boolean
---@field size? integer shadow map edge length in texels (default 128)
---@field range? number sun shadow half-width around the camera, in tiles (default 25)

---@param on boolean|shdw_params?
function shdw(on) end


-- Sine value
---@param f number
---@return number
function sin(f) end


-- Sing a syllable or space-separated phrase over a melody (a pitch, or a table of pitches / {freq,len} pairs)
---@param lyrics string a syllable ('sa') or phrase ('la la laa'); vowels a/e/i/o/u + optional consonant
---@param melody number|number[]|number[][] one pitch, or a pitch (or {freq,len}) per syllable
---@param length number? default per-syllable length
---@param channel integer?
function sing(lyrics, melody, length, channel) end


-- Define instrument `id` from a loaded sound name, or raw PCM samples (-1..1); cfg = { base, atk, dec, sus, rel, from, to }
---@param id integer
---@param data string|number[] a loaded sound name (sounds/<name>.ogg), or raw PCM samples in -1..1
---@param cfg? { base?: number, atk?: number, dec?: number, sus?: number, rel?: number, from?: number, to?: number } base pitch (default 440) + ADSR envelope; from/to slice a loaded file (0..1)
function smpl(id, data, cfg) end


-- Make a song
---@param notes number[][] | number[] nested array first is frequency, second is length
function song(notes) end


-- Squareroot value
---@param f number
---@return number
function sqrt(f) end


-- Load a sub bundle
---@param str string
function sub(str) end


-- Sets image data as a texture
---@param asset string
---@param im image
function tex(asset, im) end


-- Set a tile within 3d space. Nil asset deletes.
---@param asset string
---@param x integer
---@param y integer
---@param z integer
---@param rot integer?
function tile(asset, x, y, z, rot) end


-- Mesh tiles together on the dual grid: blocky, smooth, or your own model pieces
---@param name string
---@param tiles string[]|nil
---@param opts {look?: 'block'|'smooth', pieces?: table<string|integer, string>}?
function tileset(name, tiles, opts) end


-- Lay a mesh's triangles flat onto a w x h image: new v/n/u/i to pass to mod() <mesh:{v,i,n?}, opts?:{w,h,pad,mode}>
---@param mesh {v:number[3][], i?:integer[], n?:number[3][]}
---@param opts? {w?:integer, h?:integer, pad?:integer, mode?:string}
---@return {v:number[3][], n:number[3][]?, u:number[2][], i:integer[], from:integer[], charts:integer}
function unwrap(mesh, opts) end


-- Add reverb to a channel: (channel, room/decay 0..1, damp 0..1, wet mix). room<=0 disables it
---@param channel integer
---@param room number tail length/decay 0..1 (<=0 disables)
---@param damp number? high-frequency damping of the tail 0..1 (default 0.5)
---@param wet number? reverb level mixed over the dry signal (default 0.3)
function verb(channel, room, damp, wet) end


-- Set a channel's singing voice character for its later sing() notes: (channel, { breath, vib, hz })
---@param channel integer? channel to configure (default 0)
---@param cfg { breath?: number, vib?: number, hz?: number } breath 0..1, vibrato depth (~0.03), rate Hz (~5.5)
function vox(channel, cfg) end


