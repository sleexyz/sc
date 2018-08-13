b = Buffer.read(s, "/home/slee2/Downloads/Serato_Control_Signal__75min.wav");


(
x = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
    Out.ar( out,
		        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * 1, loop: 1)
    )
}).play(s,[\bufnum, b]);
)