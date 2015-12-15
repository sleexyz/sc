//crap
GUI.skin.plot.plotColor = (10..0).normalize(0.1, 1).collect { |i| Color.rand(i) };
GUI.skin.plot.background = Color.black;


(1<<32 )

2**32
Array.fill(32, {|i| (2**i) -  (1<<i)})
(0..31).collect(2**_)

// easy plot
(
(0..8000).collect({|t|
	t & (t >> 8);
}).plot
)


//fun
(
{
	var trig, t, x, mx, rand;
	trig = Impulse.ar(8000);
	t = PulseCount.ar(trig);

	mx = MouseX.kr(0, 16).floor;

	rand = Demand.ar(trig, 0, Diwhite(0, 256, inf));

	//t = t * (t >> mx);
	//t = (t << 2)  & (t  >> 2 ) | (t  >> 3 * 3 ); //polyrhythm
	//t = (t >> 6) & ((t * 0) | (t * mx));


	// t = (t >> 4) & rand | ((t >> 3) * (t >> 11)); //electro (without drop..)

	//t = (t<<5 & (t >> 9)) - (((t >> 2) & (t>>3) << 5) >>(t>>5));

	t = (t<<2  & ((t >> 9) | (t >> 7))) - (((t >> 2) & (t>>3) << 5) >>(t>>5 | rand)) +64;

	//q = t/16;
	//t = (q & rand) | (q/5 & rand); //| ((t >> 3) * (t >> 11)); //electro (without drop..)


	x = t & (1 << 8 -1); //8-bit
	x = x/(1<<7) -1; //normalize to [-1, 1]
	Out.ar(0,[x,x]);

}.scope
)




