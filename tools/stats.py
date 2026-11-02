import wave,sys,numpy as np
w=wave.open(sys.argv[1]); sr=w.getframerate(); n=w.getnframes()
x=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float32)/32768
nz=np.nonzero(np.abs(x)>0.002)[0]; st=nz[0]/sr
print('secs',round(n/sr,2),'first sound',round(st,3))
print('rms/s:',' '.join(f"{float(np.sqrt((x[s*sr:(s+1)*sr]**2).mean())):.2f}" for s in range(int(n/sr))))
print('peak/s:',' '.join(f"{float(np.abs(x[s*sr:(s+1)*sr]).max()):.2f}" for s in range(int(n/sr))))
print('frac |x|>0.95:',round(float((np.abs(x)>0.95).mean()),4))
# drum onsets: high-band flux
from numpy.fft import rfft
hop=128;N=512
E=[];
for i in range(0,len(x)-N,hop):
    S=np.abs(rfft(x[i:i+N]*np.hanning(N))); E.append(S[40:].sum())
E=np.log(np.array(E)+1e-3); d=np.maximum(0,np.diff(E))
thr=np.percentile(d,97); on=[]
for i in range(1,len(d)-1):
    if d[i]>thr and d[i]>=d[i-1] and d[i]>=d[i+1] and (not on or i-on[-1]>12): on.append(i)
t=np.array([(i+1)*hop/sr for i in on]); six=60/172/4
start=float(sys.argv[2]) if len(sys.argv)>2 else st
intro=32*60/172
sel=t[(t>start+intro+0.5)&(t<start+intro+10)]
ref=start  # music starts on grid at first sound
ph=(sel-ref)/six; dev=(ph-np.round(ph))*six*1000
print('drum-section onsets',len(sel),'dev from 16th grid (ms) mean',round(float(np.abs(dev).mean()),2),'p90',round(float(np.percentile(np.abs(dev),90)),2))
print('drums enter at', round(start+intro,3), 'nearest onset', round(float(t[np.argmin(np.abs(t-(start+intro)))]),3))
