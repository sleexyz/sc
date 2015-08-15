
// ugen version
(
~fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};
)
(
{
	var plotarr = {
		var arr, baserate, iterations;
		baserate = 2;
		iterations = 10;
		arr = Array.fill(iterations, {|i| LFClipNoise.ar(freq: baserate*(2**i), mul: 0.5**(i + 1))});
		
		//accumulated sum
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


// pattern version
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

// plot
(
a = ~pfract.value(10).asStream;
p = Array.fill(2**10, {a.next}).plot;
p.plotMode = \steps;
p.refresh;
)

// http://www.firstpr.com.au/dsp/pink-noise/#Introduction