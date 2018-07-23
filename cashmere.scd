// init
(
s.boot;
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~master = Bus.audio(s, 2);
)

// play
(
f = {|baserate = 0.1, octaves=10|
		Mix.kr(Array.fill(octaves, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(octaves - (i + 1)))}))/(2**(octaves));
};

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

SynthDef(\pinksprite, {|freq=440, dur=60|
	var density, mix;
	density = 0.1;
	mix = Resonz.ar(
		in: PinkNoise.ar(f.value(f.value(0.00001).linexp(-1,1,density,1))),
		freq: freq,
		bwr: f.value(f.value(0.001).linexp(-1,1,0.001, 10)).linexp(-1,1,0.00001, 0.01),
		mul: f.value(f.value(0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1,density, 1)
	);
	Out.ar(~master,
		Pan2.ar(mix, f.value(f.value(0.001).linexp(-1,1,0.001, 1)), 5)
		* EnvGen.kr(Env.linen(dur*0.1, dur * 0.9, dur * 0.1, 1, \sine), doneAction:2);
	);
}).add;

Pdef(\fscale,
	Pcollect({|item|
		Array.fill(36, {|i| Scale.iraq.degreeToFreq(i, 5.midicps, 1);}).wrapAt(item);
	}, ~pfract.value(8).linlin(-1, 1, 0, 100).floor);
);



SynthDef(\master, {
	var mix = In.ar(~master, 2);
	mix = LinSelectX.ar(0.5, [mix, PitchShift.ar(in: mix, windowSize: f.value(0.001).linexp(-1, 1, 0.01, 2), pitchRatio: 1.5, timeDispersion: 2)]);
    mix = FreeVerb2.ar(in: mix[0], in2: mix[ 1], mix: 0.2, room: 0.9, damp: 0.01);
	mix = BPeakEQ.ar(in: mix, freq: 60, rq: 1, db: 15);
    //mix = Normalizer.ar(in: mix, level: 1, dur: 2);

	Out.ar(0, mix);
}).play;


36.do({
	Pbind(\instrument, \pinksprite,
		\freq, Pdef(\fscale),
		\dur, ~pfract.value(3).linexp(-1, 1, 0.1, 300)
	).play;
});


{
	var fract, ffract;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};

	SynthDef(\granularsprite, {
        var trate, dur, clk, pos, pan;
        trate = fract.value(10, fract.value(10, 0.001).linexp(-1, 1,0.001, 1)).linlin(-1, 1, 8,40);
        dur = fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1, 0.1, 12) / trate;
        clk = Impulse.kr(trate);
        pos = fract.value(3,fract.value(3, 0.001).linexp(-1,1,0.0001, 1)).linlin(-1,1,0, BufDur.kr(b));
        pan = fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1));
		//Out.ar(~master, TGrains.ar(numChannels: 2, trigger: clk, bufnum: b, rate: 1, centerPos: pos, dur: dur, pan: pan, amp: fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1, 0.001, 1)));
	}).play;

}.value;
)
