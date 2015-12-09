
// 8-bit magic
(
~bb = {|func|
	{
		var srate, bitdepth, out, t, x;
		srate = 8000;
		bitdepth = 2**8;
		t = PulseCount.ar(Impulse.ar(srate));

		t = func.value(t);

		t = (t % (bitdepth)) / (bitdepth/2 -1) -1;

		out = HPF.ar(t, 20).tanh;
		//out = t;
		Out.ar(0, out);
		t
	}.plot(1);
};
)


(2>>10 & (2>>10).bitNot)


(1<<32 -1).asInt


(~bb.value({|t|
	t-t + 2**7;
}))

(
Array.fill(8000, {|t|
	t.bitNot
}).plot
)

1.bitNot



{LFSaw.ar(8000/(2**8)*2)}.play