
/*

2015-04-23
wow... this chaos thing is additive....
Much easier trigger mechanism now...
Pros: more efficient
Cons: less responsive

frac:
Maps [0, 1] to infinite binary tree
Every number is a unique path
Each iteration is orthogonal

Fractal binary noise
rate=1, i=0:                    LFClipNoise(freq: 1, mul: 0.5)
rate=1, i=(iterations - 1):     LFClipNoise(freq: 2**n, mul: 0.5**(iterations + 1)

iterations must be > 0
*/
(
{
	var plotarr = {
		var arr, baserate, iterations;
		baserate = 2;
		iterations = 10;
		//arr = Array.fill(iterations, {|i| LFDClipNoise.ar(freq: baserate*(2**i), mul: 0.5**(i + 1))});

		arr = Array.fill(iterations, {|i| LFDNoise3.ar(freq: baserate*(2**i), mul: 0.5**(i + 1))});
		//cumsum
		1.for(iterations -1, {|i|
			arr[i] = arr.at(i-1) + arr.at(i);
		});
		arr;
	};

	p = plotarr.plot(1);
	p.superpose = true;
	p.plotMode = \steps;
	p.refresh;
}.value
)
{SinOsc.ar}.play
//Oneliner
(
f = {|iterations = 10, baserate = 100|
	Mix.ar(Array.fill(iterations, {|i| LFNoise2.ar(freq: baserate*(2**i), mul: 0.5**(i + 1))}))
};

{
	Out.ar(0, f.value(100, 500)!2);
}.freqscope;
)

// More fun
(
f = {|iterations = 10, baserate = 100|
	Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 0.5**(i + 1))}));
};

{
	var fractal, mix;
	fractal = f.value(10, 0.01);
	mix = Mix.ar([

		RLPF.ar(PinkNoise.ar(fractal * 0.5 + 0.5), 200, 0.1);

	]);
	Out.ar(0, mix!2);
}.play;
)

// A better way to interface with this fractal guy is with integers. Then we can simply bitshift for selection
// |F(t)| - 0.5 =~= F(t/2)
(
{
	var fract, fract_scale;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDNoise3.kr(freq: baserate*(2**i), mul: 2**(iterations - i))}));
	};

	fract_scale = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDNoise3.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};

	{
		var arr, mix;

		arr = [
			PinkNoise.ar(fract_scale.value(15, 0.001)),
			RLPF.ar(PinkNoise.ar(fract_scale.value(15, 0.001)),fract_scale.value(15, 0.001).abs * 440, fract_scale.value(15, 0.001).abs),
			Dust2.ar(fract_scale.value(15, 0.001).abs * 10);
		];
		mix = SelectX.ar(fract_scale.value(15, 0.1).abs * arr.size, arr);
		Out.ar(0, mix!2);

	}.play
}.value();
)


//___________________________________________________________________________________
// oh snap, what if we plug in fract into fract, to control the base rate?
// Nice! I like this very much
// 2015-04-25

// microtextural subtractive synths
// resonator drones
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




// Simple granular synth
// Needs work...
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
{
	var fract, ffract;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};

	{
    var trate, dur, clk, pos, pan;
	trate = fract.value(10, fract.value(10, 0.001).linexp(-1, 1,0.001, 1)).linlin(-1, 1, 8,120);
    dur = fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1, 0.1, 12) / trate;
    clk = Impulse.kr(trate);
		pos = fract.value(3,fract.value(3, 0.001).linexp(-1,1,0.0001, 1)).linlin(-1,1,0, BufDur.kr(b));
    pan = fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1));
		TGrains.ar(2, clk, b, 1, pos, dur, pan, fract.value(10,fract.value(10, 0.001).linexp(-1,1,0.0001, 1)).linexp(-1,1, 0.001, 5));
}.scope(zoom: 4);

	}.value;
)



// orchestrated self-similar
(
{
	var fract, ffract;
	fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};

	{
		var mix, tones, sig1, sig2;
		sig1 = fract.value(10, fract.value(10, 1));
		sig2 = fract.value(3, fract.value(3, 0.0001));
		tones = Array.fill(20, _*(2**3.rand)).collect(_ + (4 * sig1.linexp(-1, 1, 1, 10))).midicps;
		mix = Mix.ar(Array.fill(8, {|i|
			var sigi, mmix;
			sigi = fract.value(10, fract.value(10, 0.001));
			mmix = Limiter.ar(
				RLPF.ar(Dust2.ar(1000,1),Select.kr(sigi.linlin(-1,1, 0, tones.size), tones), 0.01, 1),
			5);
			Pan2.ar(mmix, sig2, sig1.linexp(-1, 1, 0.001, 1));
		}));
		Out.ar(0, mix);
	}.play
}.value
)
