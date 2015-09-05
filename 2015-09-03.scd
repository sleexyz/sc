(
SynthDef(\foo, {|note=60|
	var mix;
	mix = RLPF.ar(WhiteNoise.ar(1), note, 0.01);
	Out.ar(0, mix!2);
}).add;
)
{SinOsc.ar}.play
x = Synth(\foo, [\note, 60]);


Scale.directory

(
x = Synth(\foo, [\note, 60]);

t = TempoClock.default();

t.sched(0, {
	var scale;
	scale = Scale.ushaqMashri;
	x.set(\note, Array.fill(4, {|i|scale.degrees + 12*i + 20}).flatten.choose);
	0.01 * (2**[0, 1, 2, 3, 4, 5].choose)
})
)


(
Pdefn(\notes, Pseq(Array.fill(3, {|i| Scale.yu.degrees + 12*i + 0}).flatten, inf));
)



(
Pdefn(\durations, Pseq(
	[Pstutter(100, Prand(2**[-2, 1, 2] * 0.01 , inf))], inf
))
)

(
Pdefn(\durations, 0.01)
)

(
10.do({|i|
	Pmono(\foo,
		\note, Pdefn(\notes) + ((i%2) * 12),
		\dur, Pdefn(\durations)
	).play
})
)




s.dumpOSC;

























// combine looper with patterns



(
SynthDef(\looper, {|trigfreq=1, rate=1|
	var in, mix, trig, resetpos,readpos;
	trig = Impulse.kr(trigfreq);

	resetpos = Phasor.ar(0, -0.25, 0, BufFrames.kr(b),0); //goes backwards at a constant rate

	readpos = Phasor.ar(trig, rate, 0, BufFrames.kr(b),resetpos); //resets on trig to resetpos


	in = 	EnvGen.ar(Env.new(curve:\sine), trig, 1, 0, 1/trigfreq)*BufRd.ar(1, b, readpos);
	mix = LPF.ar(in, MouseY.kr.linexp(0, 1, 100, 22050));
	mix = mix * 0.1;
	Out.ar(0, mix!2);
}).add
)



(
Pdefn(\rates, Prand(2**[-2,-1, 0, 1, 2], inf));
)




(
Pdefn(\durations, Prand(2**[-2, 1, 0, 1], inf))
)

(
10.do({|i|
	Pmono(\looper,
		\rate, Pdefn(\rates),
		\dur, Pdefn(\durations)
	).play
})
)