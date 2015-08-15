//Initialize function
(
n=5;
~fn = {|freq=200, width=1|
		var out;
		out = Array.fill(n, {|i| i*width});
		out = out.collect({|val, i|
			SinOsc.ar(freq + val);
		});
		out = Mix.ar(out/n);
};
)

(
SynthDef(\p, {|gate=1, freq=200, width=1, amp=1, dur=5|
	var out = ~fn.value(freq, width);

	out = out* EnvGen.ar(Env.linen(1, 6, 3), gate, timeScale: dur/10, doneAction: 3);
	Out.ar(0, out!2);
}).add;
)
(
Synth(\p);
)

//rhythm
(
Pmono(\p, \freq, 300, \width, 2.66, \amp,0.5, \dur, 10).play;
)



//solo
(
SynthDef(\p_solo, {|amp=1, dur=5, gate=1|
	var out = Decimator.ar(~fn.value(MouseY.kr(1, 10000), MouseY.kr(1, 100, 1)), MouseX.kr(400, 44100,1));
	out = FreeVerb.ar(out);
	out = out* EnvGen.ar(Env.linen(3, 5, 2),gate,  timeScale: dur/10, doneAction: 2);
	Out.ar(0, out!2);
}).add;
)


//tada
(
Pmono(\p, \freq, 300, \width, 2, \amp, 0.1, \dur, 50).play;

Pmono(\p, \freq, 50, \width, 2.6666, \amp, 0.1, \dur, 50).play;

Pmono(\p_solo, \amp, 0.6, \dur, 50).play;
)



//tada
(
Pmono(\p, \freq, 300, \width, 2, \amp,0.1, \dur, 50).play;

Pmono(\p, \freq, 2000, \width, 0.3333, \amp,0.1, \dur, 50).play;

Pmono(\p_solo, \amp, 0.6, \dur, 50).play;
)




(
~pfract_piece = {|octaves=5, i=0|
	Pn(
		Pstutter(2**(octaves-i-1), //i=0, n=2**(octaves-1), i=octaves-1, n=1
			Prand([-1,1]) * (2**(-1*i -1)) //i=0, n=0.5, i=octaves-1, n=2**(-octaves)
		)
	)
};

~pfract = {|octaves=5|
	Array.fill(octaves, ~pfract_piece.value(octaves, _)).sum;
};
)

///////////////////////////////////////////

(
SynthDef(\p_solo, {| freq=200, gate, srate=44100, width=1, bitdepth=16, amp=1|
	var out = ~fn.value(freq, width);
	out = Decimator.ar(out, srate, bitdepth,amp);
	out = LPF.ar(out, 11025);
	Out.ar(0, out!2);
}).add;
)




(
100.do{
	Pmono(\p_solo,
		\freq, 22050,
		\width, ~pfract.value(10).linexp(-1, 1, 0.0001, 30),
		\srate, ~pfract.value(10).linexp(-1, 1, 1, 44100),
		\amp, 0.02,
		\dur, ~pfract.value(10).linexp(-1, 1, 0.01, 30)).play;
}
)

//////////////////////


(
SynthDef(\p_solo, {| freq=200, gate, srate=44100, width=1, bitdepth=16, amp=1, pan=0|
	var out = ~fn.value(freq, width);
	out = Decimator.ar(out, srate, bitdepth,amp);
	out = Pan2.ar(out, pan);
	Out.ar(0, out!2);
}).add;
)




(
100.do{
	Pmono(\p_solo,
		\freq, 22050,
		\width, ~pfract.value(10).linexp(-1, 1, 0.1, 30),
		\srate, ~pfract.value(10).linexp(-1, 1, 1, 44100),
		\pan, ~pfract.value(10),
		\amp, 0.1,
		\dur, ~pfract.value(10).linexp(-1, 1, 0.01, 5)).play;
}
)

/////////////////////



(
SynthDef(\p_solo, {| freq=200, gate, srate=44100, width=1, bitdepth=16, amp=1, pan=0|
	var out = ~fn.value(freq, width);
	out = Decimator.ar(out, srate, bitdepth,amp);
	out = Pan2.ar(out, pan);
	Out.ar(0, out!2);
}).add;
)




(
10.do{
	Pmono(\p_solo,
		\freq, ~pfract.value(10).linexp(-1, 1, 1, 22050),
		\width, ~pfract.value(10).linexp(-1, 1, 0.1, 30),
		\bitdepth, ~pfract.value(10).linlin(-1, 1, 1, 16),
		\pan, ~pfract.value(10),
		\amp, 0.2,
		\dur, ~pfract.value(10).linexp(-1, 1, 1, 5)).play;
}
)





























