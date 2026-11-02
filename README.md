# sound-chor

A sound workbench for [Petrichor64](https://github.com/Auxnon/petrichor64),
written in Petrichor Lua.

Today it's a ten-key piano: number keys `1`–`0` play a C-major scale (chords
work), clicking or touching a key plays it, `q`–`p` sing syllables, and `z`
bitcrushes the sample channel. `j` plays a 172bpm jungle track built on the
engine's sequencer (a chopped amen, sub bass, electric piano, pad, arp and a
sung vocal); `k` makes it talk like an Animal Crossing villager, `l` the same
spelled out letter by letter. It's growing into a tool for making
instruments, effects and songs for Petrichor games.

```sh
chor ~/projects/sound-chor        # native
chor -w ~/projects/sound-chor     # in the browser
```

Sound files go in `sounds/` as `.ogg` (see `sounds/README.md`).

Working on it, or pointing an agent at it: read `AGENTS.md`.
