(
{
	var fract, ffract;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};
	20.do({{
		var density, mix;
		//density = fract.value(5,0.00001).linexp(-1, 1, 0.000001, 1);
		density = 0.1;
		mix = Resonz.ar(
			in: PinkNoise.ar(fract.value(10,fract.value(10, 0.00001).linexp(-1,1,density,1))),
			freq: Array.fill(60, _ * 1).collect(_ + 20).choose.midicps,
			bwr: fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.001, 10)).linexp(-1,1,0.00001, 0.1),
			mul: fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1,density, 1)
		);
		Pan2.ar(mix, fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.001, 1)), 5);
	}.play});

	}.value
)


(
{
	var fract, ffract;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};
	{
		var tone, mix;
		tone = Array.fill(60, _*1).collect (_ + 20).choose.midicps;
		mix = SinOsc.ar(tone * fract.value(10, 1).linexp(-1, 1, 0.001, 1));
		Out.ar(0, mix!2);
	}.play
}.value
)