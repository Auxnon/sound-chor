"""How abrupt a voice's joins are: tools/joins.py a.wav [b.wav ...]

Speech sounds jarring when sound starts and stops like a switch, or when the
spectrum jumps instead of sliding from one shape to the next. Per WAV:
- hard on/off: places the level jumps by more than 15 dB within 4ms, either
  way (a beep starting or cutting); fewer is smoother
- dropouts: times the level falls 30 dB under the phrase and comes back within
  60ms (the voice stopping between syllables); fewer is more connected
- flux p90: 90th-percentile spectral change between 10ms frames (log-mel
  distance); lower means shapes slide rather than jump
"""
import sys
import wave

import numpy as np


def load(path):
    with wave.open(path) as w:
        sr = w.getframerate()
        ch = w.getnchannels()
        raw = w.readframes(w.getnframes())
    x = np.frombuffer(raw, dtype="<i2").astype(np.float32) / 32768
    return x.reshape(-1, ch).mean(axis=1), sr


def mel_bank(n_fft, sr, bands=40):
    def mel(f):
        return 2595 * np.log10(1 + f / 700)

    edges = 700 * (10 ** (np.linspace(mel(60), mel(8000), bands + 2) / 2595) - 1)
    fr = np.fft.rfftfreq(n_fft, 1 / sr)
    bank = np.zeros((bands, len(fr)))
    for i in range(bands):
        a, c, b = edges[i], edges[i + 1], edges[i + 2]
        bank[i] = np.clip(np.minimum((fr - a) / (c - a), (b - fr) / (b - c)), 0, None)
    return bank


def report(path):
    x, sr = load(path)
    # Level over an 8ms window (longer than a 130 Hz voice's period, so single
    # glottal pulses don't read as jumps), stepped every 2ms; a jump is a change
    # of more than 15 dB across 4ms.
    hop, win = int(0.002 * sr), int(0.008 * sr)
    lv = np.array([np.sqrt((x[i:i + win] ** 2).mean()) for i in range(0, len(x) - win, hop)])
    db = 20 * np.log10(lv + 1e-6)
    top = np.percentile(db, 99)
    loud = db > top - 40
    jumps = np.abs(db[2:] - db[:-2])
    edges = (jumps > 15) & (loud[2:] | loud[:-2])
    hard = int((edges[1:] & ~edges[:-1]).sum())
    # dropouts: below top-30 for 4..60ms, with sound on both sides
    low = db < top - 30
    drops, run = 0, 0
    for k in range(1, len(low)):
        if low[k]:
            run += 1
        else:
            if 0 < run <= 30 and not low[k - run - 1]:
                drops += 1
            run = 0
    n = int(0.02 * sr)
    step = int(0.01 * sr)
    bank = mel_bank(n, sr)
    frames, gate = [], []
    win = np.hanning(n)
    for i in range(0, len(x) - n, step):
        f = x[i:i + n]
        frames.append(np.log(bank @ (np.abs(np.fft.rfft(f * win)) ** 2) + 1e-9))
        gate.append(np.sqrt((f ** 2).mean()))
    frames = np.array(frames)
    gate = np.array(gate)
    on = gate > gate.max() * 10 ** (-30 / 20)
    flux = np.sqrt(((frames[1:] - frames[:-1]) ** 2).mean(axis=1))[on[1:] & on[:-1]]
    print(f"{path}: hard on/off {hard:4d}, dropouts {drops:3d}, flux p90 {np.percentile(flux, 90):.2f}")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        report(p)
