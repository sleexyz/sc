//___________________________________________________________________________________________

// 2015-05-09
// Fractal sound generation in synthdefs
// TODO: model natural energy distributions, i.e. low freq, more inertia, slower acceleration. high freq, less innertia, faster acceleration

(
/* f (hz, number) -> signal w/ range [-1,1] */
f = {|baserate = 0.1, octaves=10|
		Mix.kr(Array.fill(octaves, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(octaves - (i + 1)))}))/(2**(octaves));
};

SynthDef(\pinksprite, {|freq=440, dur=60|
	var density, mix;
	density = 0.1;
	mix = Resonz.ar(
		in: PinkNoise.ar(f.value(f.value(0.00001).linexp(-1,1,density,1))),
		freq: freq,
		bwr: f.value(f.value(0.001).linexp(-1,1,0.001, 10)).linexp(-1,1,0.00001, 0.1),
		mul: f.value(f.value(0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1,density, 1)
	);
	Out.ar(0,
		Pan2.ar(mix, f.value(f.value(0.001).linexp(-1,1,0.001, 1)), 5)
		* EnvGen.kr(Env.linen(dur*0.1, dur * 0.9, dur * 0.1, 1, \sine), doneAction:2);
	);
}).add;
)

(
Synth(\pinksprite, [\freq,
	Array.fill(88, _ * 1).collect(_ + 20).choose.midicps]);
)
Stethoscope.new(s);


// Finally learn patterns...
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
p.refresh;
)
r = ~pfract.value(10).linlin(-1, 1, -100, 100).floor.asStream;
10.do({r.next.postln;});


(
Pdef(\fscale,
	Pn(
		Prand(Array.fill(40, {|i| Scale.nahawand.degreeToFreq(-1*20 + i, 60.midicps, 1);}))
	)
);
)

(
Pdef(\fscale,
	Pn(
		Pseq(Array.fill(30, {|i| Scale.nahawand.degreeToFreq(-1*20 + i, 60.midicps, 1);}))
	)
);
)

//wtf accidental? This shit is crazy
// makes 30 instruments, one for each degree
//Glitches up, though...
(
Pdef(\fscale,
	Array.fill(30, {|i| Scale.superLocrian.degreeToFreq(i, 20.midicps, 1);}))
)

(
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(40, {|i| Scale.nahawand.degreeToFreq(i, 20.midicps, 1);}).wrapAt(item);
	},~pfract.value(7).linlin(-1, 1, 0, 100).floor);
)
)

(
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(36, {|i| Scale.iraq.degreeToFreq(i, 20.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 100).floor);
)
)


(
36.do({
	Pbind(\instrument, \pinksprite,
		\freq, Pdef(\fscale),
		\dur, ~pfract.value(3).linexp(-1, 1, 0.1, 300)
	).play;
});
)
TempoClock.beats.default;

//Sweet! Iraq
//2015-05-10 4:30 am
(
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(24, {|i| Scale.iraq.degreeToFreq(i, 10.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 100).floor);
)
)


(
12.do({
	Pbind(\instrument, \pinksprite,
		\freq, Pdef(\fscale),
		\dur, ~pfract.value(3).linexp(-1, 1, 0.1, 300)
	).play;
});
)

Scale.directory
Scale.suznak
Scale.iraq
Scale.spanish
Tuning.directory
//
(
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(40, {|i| Scale.chromatic.degreeToFreq(i, 20.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 40).floor, inf));
)

(
Pdef(\fscale,
	Pcollect({|item|
		Array.fill(30, {|i| Scale.suznak.degreeToFreq(i, 20.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 30).floor, inf));
)


(
20.do({
	Pbind(\instrument, \pink,
		\freq, Pdef(\fscale),
		\dur, ~pfract.value(3).linexp(-1, 1, 0.1, 300)
		//research how to link freq with mul
	).play;
});
)



// 2015-05-11
// Pink-sprite retuning
(
/* f (hz, number) -> signal w/ range [-1,1] */
f = {|baserate = 0.1, octaves=5|
		Mix.kr(Array.fill(octaves, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(octaves - (i + 1)))}))/(2**(octaves));
};

SynthDef(\pinksprite, {|freq=440, dur=60, mul=1|
	var density, mix;
	density = 0.1;
	mix = Resonz.ar(
		in: PinkNoise.ar(f.value(f.value(0.00001).linexp(-1,1,density,1))),
		freq: freq,
		bwr: f.value(f.value(0.001).linexp(-1,1,0.001, 10)).linexp(-1,1,0.00001, 0.1),
		mul: f.value(f.value(0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1,density, 1)
	);
	mix = Pan2.ar(mix, f.value(f.value(0.001).linexp(-1,1,0.001, 1)), 5)
		* EnvGen.kr(Env.linen(dur*0.1, dur * 0.9, dur * 0.1, mul, \sine), doneAction:2);

	Out.ar(0,
		FreeVerb.ar(mix, room: f.value(0.0001).linexp(-1, 1, 0.001, 1000))
	);
}).add;
)















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
{|octaves=2|
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


