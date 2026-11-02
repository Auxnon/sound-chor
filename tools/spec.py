# spec.py in.wav out.png [t0 t1] : waveform strip + log spectrogram (0-6kHz), 1s ticks
import wave,sys,zlib,struct,numpy as np
w=wave.open(sys.argv[1]); sr=w.getframerate(); n=w.getnframes()
x=np.frombuffer(w.readframes(n),dtype=np.int16).astype(np.float32)/32768
t0=float(sys.argv[3]) if len(sys.argv)>3 else 0; t1=float(sys.argv[4]) if len(sys.argv)>4 else n/sr
x=x[int(t0*sr):int(t1*sr)]
hop=256; N=2048; cols=(len(x)-N)//hop
win=np.hanning(N); fr=np.fft.rfftfreq(N,1/sr); keep=fr<6000
S=np.array([np.abs(np.fft.rfft(x[i*hop:i*hop+N]*win))[keep] for i in range(cols)]).T
S=20*np.log10(S+1e-6); S=np.clip((S+40)/70,0,1)[::-1]
H=S.shape[0]; img=np.zeros((H+80,cols,3),np.uint8)
img[80:,:,0]=(S*255).astype(np.uint8); img[80:,:,1]=(S**2*220).astype(np.uint8); img[80:,:,2]=(np.sqrt(S)*120).astype(np.uint8)
for c in range(cols):
    seg=x[c*hop:c*hop+hop]; a=int(min(1,np.abs(seg).max())*39)
    img[40-a:40+a+1,c]=(120,200,255)
for s in range(int(t1-t0)+1):
    c=int(s*sr/hop)
    if c<cols: img[:,c]=(255,255,255) if s%5==0 else (90,90,90)
def png(a,path):
    h,wd,_=a.shape; raw=b''.join(b'\x00'+a[r].tobytes() for r in range(h))
    ch=lambda t,d: struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n'+ch(b'IHDR',struct.pack('>IIBBBBB',wd,h,8,2,0,0,0))+ch(b'IDAT',zlib.compress(raw,6))+ch(b'IEND',b''))
png(img,sys.argv[2]); print(img.shape)
