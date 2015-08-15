(
// osteophagia redux....
// 2015.03.31 ---> 2015.07.27
///
SynthDef(\rt, { |out=0|
	var in, grainSize,  mix, arr, pitchRatio, timeDispersion, pitchDispersion;
	timeDispersion = MouseX.kr(0.0001, 10000, 1);
	pitchRatio = MouseY.kr(0, 1);
	pitchDispersion = 0;
	in = SoundIn.ar(0);
	grainSize = 0.1;
	arr = 2**([-1,0,1] * pitchRatio);
	mix = in;
	5.do({

		mix = (0.5*mix) + (0.5*Mix.new(arr.collect({|pitchRatio|
			PitchShift.ar(mix, grainSize, pitchRatio, pitchDispersion, timeDispersion, 0.5);
		})));
	});
	Out.ar(out, Pan2.ar(Normalizer.ar(Mix.new(mix), 0.5), LFNoise1.ar(0.2, 0.4), 4));
}).add;
)


(
Synth(\rt)
)
