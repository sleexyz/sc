






//Iraq redux
//2015-05-12
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

//test
(
a = ~pfract.value(5).asStream;
p = Array.fill(2**5, {a.next}).plot;
p.plotMode = \steps;
p.
p.refresh;
)

//melancholic
(
{|octaves=5|
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(12*octaves, {|i| Scale.iwato.degreeToFreq(i, 15.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 12*octaves).floor);
)
}.value
)
//melancholic
(
{|octaves=4|
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(12*octaves, {|i| Scale.iraq.degreeToFreq(i, 20.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 12*octaves).floor);
)
}.value
)
{SinOsc.ar}.play
Scale.directory
(
1.do({
Pbind(\instrument, \pink,
	\freq, Pdef(\fscale),
	\dur, 0.5,
	\bwr, 0.001,
	\mul, ~pfract.value(3).linexp(-1, 1, 1, 200).stutter(2**3),
	\pan, ~pfract.value(3).linlin(-1, 1, 0, 1),
	\delta, 1,
	//\mod, ~mixBus.asMap
	).play();
});
)
// bus shit
(
f = {|baserate = 0.1, octaves=5|
		Mix.kr(Array.fill(octaves, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(octaves - (i + 1)))}))/(2**(octaves));
};

~mixBus = Bus.control(s, 1) ;
~mouseX = { |out| Out.kr(out, f.value(1, 10).linexp(-1,1,0.5,2)) };
~mouse = ~mouseX.play ;
)
~mouse.set(\out, ~mixBus);

(
f = {|baserate = 0.1, octaves=5|
		Mix.kr(Array.fill(octaves, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(octaves - (i + 1)))}))/(2**(octaves));
};

SynthDef(\pink, {|freq=440, dur=60, bwr=0.0001, mul=1, pan=0.5, mod=1|
	var mix, ddur;
	mix = Resonz.ar(
		in: PinkNoise.ar(1),
		freq: freq * mod,
		bwr: bwr,
		mul: mul
	);
	mix = Pan2.ar(mix, pan);
	ddur = 1000/freq * dur;

	Out.ar(0,
		FreeVerb.ar(mix, room: 100, mul: EnvGen.kr(Env.perc(ddur*0.01, ddur * 0.99), doneAction:2))
	);
}).add;
)

TempoClock.default.tempo = 160/60;

