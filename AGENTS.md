# AGENTS.md — sound-chor

sound-chor is Petrichor64's sound workbench, written in Lua as a Petrichor app.
Today it's a **standalone app** you open with `chor`: a ten-key piano that plays
an additive instrument and a loaded sample, plus keys that `sing()` syllables.
It's where the engine's sound commands get tried out, and it's meant to grow
into a tool for **making** sounds: instruments, samples, effects, songs.

It used to be `apps/synth` in the engine repo; it moved out (history kept) so
it can grow on its own, like the image editor (image-chor) and the model editor
(model-chor).

The engine is [Petrichor64](https://github.com/Auxnon/petrichor64), locally
`~/projects/petrichor64`. Its AGENTS.md is the reference for writing Lua for
the engine and for testing without a human. Read it before changing anything
here; this file only covers what's specific to sound-chor.

## How it ships

- **Not built into `chor` yet.** Unlike image-chor and model-chor, petrichor's
  build.rs doesn't fetch this repo; nothing on the engine side depends on it.
  Run it from a checkout: `chor ~/projects/sound-chor`.
- If it becomes an overlay later (a Ctrl+key over a running game, like Ctrl+P
  and Ctrl+M), it gets the same treatment as the others: petrichor's build.rs
  fetches `main`, so `main` must never be broken; engine changes land in
  petrichor first; and this section gets rewritten. Petrichor's AGENTS.md,
  *Overlays*, covers the `app.*` table an overlay gets.
- Engine first, in any case: if a sound idea needs a new native, add it to
  petrichor (`src/command.rs` + `guide/<name>.md`, with a 3–4 letter name; see
  petrichor's CLAUDE.md) before the script here that calls it.

## Layout

```
scripts/main.lua     the whole app: scale/chorus key tables, the 3D keyboard,
                     instrument setup in main(), key + pointer playing in loop()
scripts/ignore.lua   LSP type stubs (`chor ignore`); the engine never loads it.
                     Regenerate after engine changes: `chor ignore . -y`
sounds/              .ogg files, loaded at boot by filename stem (`tone.ogg` → 'tone')
                     the .wav files are the sources oggify converted; not loaded
assets/example.png   a texture
icon.png             the app icon
```

When the app outgrows one file, split it by concern (instruments, the
keyboard, a sequencer...) with a header comment saying what each file owns.
Scripts load in sorted order; keep top-level code free of other files' globals
and compute those in `main()`.

## The engine's sound commands

Each has a page in petrichor's `guide/`. Summary:

| command | what it does |
| --- | --- |
| `instr(id, spec, cfg?)` | define an instrument: a waveform name, or a table of harmonic amplitudes (additive) |
| `smpl(id, data, cfg?)` | define a sampler instrument: a loaded file's name (`'tone'`), or a PCM table (`-1..1`) |
| `note(freq, len?, channel?, instr?)` | play one note |
| `chord(freqs, len?, instr?)` | several notes at once |
| `song(data)` | an asynchronous note sequence |
| `sing(lyrics, melody, len?, channel?)` | formant-synthesis voice singing syllables over a melody |
| `vox(channel?, cfg)` | a channel's singing voice: `breath`, `vib`, `hz` |
| `crsh(channel, bits, rate?)` | bitcrush a channel |
| `grit(channel, amount, mode?)` | drive / distort a channel |
| `filt(channel, kind?, cutoff?, q?, secs?)` | resonant filter on a channel |
| `fade(channel, secs, target?)` | fade a channel's volume |
| `echo(channel, secs, feedback?, mix?)` | feedback-delay echo on a channel |
| `mute(n?)` | stop a channel, or everything |

What the engine's design commits to (petrichor CLAUDE.md, *Sound & audio*):

- **Instruments and samples are integer ids.** Names exist only when binding a
  file with `smpl(id, 'name')`; the mixer looks up by id.
- **The envelope belongs to the instrument**, not the note: `cfg` on
  `instr`/`smpl` carries `atk`/`dec`/`sus`/`rel`, plus `wid` (pulse duty) or
  `base` (a sample's natural pitch, default 440).
- **Effects belong to channels** (`crsh`, `grit`, `filt`, `fade`, `echo`, `vox`).
- Every app load resets all sound state, so set instruments up in `main()`.
- The master bus runs into a `tanh` soft limiter: dense chords compress
  instead of clipping.
- Only `.ogg` loads at runtime. Convert `.wav`/`.mp3` with petrichor's
  `oggify` tool: `cargo run -p oggify -- ~/projects/sound-chor` from petrichor.

## Where it's going

The aim is a tool for making sounds rather than a piano demo. Nothing below is
decided; it's the space to explore, roughly from cheapest to hardest:

- An **instrument editor**: pick a waveform or draw harmonics, shape the ADSR,
  hear it on the keyboard, and print the `instr()`/`smpl()` call to paste
  into a game (the way model tools print a `mod()` call).
- **Effect racks per channel**: knobs for the `crsh`/`grit`/`filt`/`echo`/`fade`
  parameters, with the resulting calls shown.
- **Sample work**: record or synthesize PCM in Lua, trim, loop, set `base`.
  Writing a file needs an engine native; there isn't one yet.
- A **step sequencer / tracker** that plays through `song()` and exports the
  table.
- **sfx presets**: jump, coin, hit, explosion generators (sfxr-style), each a
  handful of parameters that export as a short Lua snippet.
- Becoming an **overlay** (see *How it ships*) so a game's sounds can be
  auditioned and tuned while it runs.

Write down the decisions in this file as they're made.

## Working on it

- Run it: `chor ~/projects/sound-chor`. Sound is in petrichor's default
  features natively; on the web it plays through the AudioWorklet
  (`chor -w ~/projects/sound-chor`).
- Write Lua in the silt style petrichor's AGENTS.md describes: calls hoisted
  out of argument lists, no anonymous functions, no table deletion. `key(k,
  true)` fires once on the press edge; plain `key(k)` is true every frame held
  and would retrigger a note ~60 times a second.
- Testing: an agent can't hear the output. Petrichor's AGENTS.md, *Testing
  without a human*, covers the `TEST_HOOK` harness and frame captures; use it
  to check the app runs and the UI draws, and check sound logic by what it
  calls (log the `note`/`instr` arguments) rather than by ear. Ask the user to
  listen to anything where the sound itself is the point.
