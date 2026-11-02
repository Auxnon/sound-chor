"""How noisy a voice recording is: tools/hiss.py a.wav [b.wav ...]

Per 40ms frame of the sounding parts: harmonics-to-noise ratio (from the
normalised correlation at a pitch lag, 80-650 Hz) and the share of energy above
4 kHz, where a formant vowel has almost nothing and hiss lives. Prints the
median HNR, how much of the sounding time is noise-dominated (HNR < 3 dB), and
the high-band share, for comparing a voice before and after a change.
"""
import sys
import wave

import numpy as np


def load(path):
    with wave.open(path) as w:
        sr = w.getframerate()
        ch = w.getnchannels()
        width = w.getsampwidth()
        raw = w.readframes(w.getnframes())
    if width == 2:
        x = np.frombuffer(raw, dtype="<i2").astype(np.float32) / 32768
    else:
        x = np.frombuffer(raw, dtype="<f4")
    return x.reshape(-1, ch).mean(axis=1), sr


def best_corr(f, lo, hi):
    """Highest normalised correlation of the frame with itself shifted by a
    pitch period. Each lag compares only the overlapping parts, scaled by their
    own energies: dividing by the whole frame's energy instead would cap a
    perfectly clean vowel at (n - lag) / n and score low voices as noisy."""
    best = 1e-4
    for lag in range(lo, hi):
        a, b = f[:-lag], f[lag:]
        d = np.sqrt((a * a).sum() * (b * b).sum())
        if d > 0:
            best = max(best, (a * b).sum() / d)
    return min(best, 0.9999)


def report(path):
    x, sr = load(path)
    n, hop = int(0.04 * sr), int(0.01 * sr)
    lo, hi = int(sr / 650), int(sr / 80)
    frames = [x[i:i + n] for i in range(0, len(x) - n, hop)]
    levels = np.array([np.sqrt((f ** 2).mean()) for f in frames])
    gate = levels.max() * 10 ** (-30 / 20)
    hnr = []
    for f, lv in zip(frames, levels):
        if lv < gate:
            continue
        r = best_corr(f - f.mean(), lo, hi)
        hnr.append(10 * np.log10(r / (1 - r)))
    hnr = np.array(hnr)
    X = np.abs(np.fft.rfft(x)) ** 2
    fr = np.fft.rfftfreq(len(x), 1 / sr)
    share = 100 * X[fr > 4000].sum() / X.sum()
    print(f"{path}: median HNR {np.median(hnr):5.1f} dB, noisy {100 * (hnr < 3).mean():4.1f}% of "
          f"sounding time, >4kHz {share:4.1f}% of energy")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        report(p)
