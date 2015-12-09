// 8 bit, 8kHz ( and other bitdepths/sampling rates) bytebeat exploration
// NYC supercollider meetup
// 11/18/2015

{
	var t, output;
	t = PulseCount.ar(Impulse.ar(8000));


}.play




// 8-bit magic
(
play {
	var srate, bitdepth, r, t;
	srate = 8000;
	bitdepth = 2**8;

	t = PulseCount.ar(Impulse.ar(srate));
    HPF.ar(
        (
            ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3 % (bitdepth)
		) / (bitdepth/2 -1) -1 * 3
        , 20
    ).tanh
}
)


// 8-bit magic
(
{
	var srate, bitdepth, r, t;
	srate = 8000;
	bitdepth = 2**8;

	t = PulseCount.ar(Impulse.ar(srate));
	t =             ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3;

	t = (t% (bitdepth)) / (bitdepth/2 -1) -1 * 3;
    HPF.ar(t, 20).tanh
}.play
)

// 8-bit magic
(
{
	var srate, bitdepth, r, t, x;
	srate = 8000;
	bitdepth = 3**7;
	t = PulseCount.ar(Impulse.ar(srate));

	// t = (t*3) | (t >> 7) & (t >> 6) & (t >> 5);

	t = (t*3) | (t / (3**7)).floor;

/*	t =   ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3;*/

	t = (t % (bitdepth)) / (bitdepth/2 -1) -1 * 3;
    HPF.ar(t, 20).tanh
}.scope
)


// migos flow
(
{
	var srate, bitdepth, r, t, x;
	srate = 8000;
	bitdepth = 3**5;
	t = PulseCount.ar(Impulse.ar(srate));

	// t = (t*3) | (t >> 7) & (t >> 6) & (t >> 5);

	t = (t*3) | (t >>7);

/*	t =   ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3;*/

	t = (t % (bitdepth)) / (bitdepth/2 -1) -1 * 3;
    HPF.ar(t, 20).tanh
}.scope
)

// 8-bit magic
(
{
	var srate, bitdepth, t, x;
	srate = 8000;
	bitdepth = 3**5;
	t = PulseCount.ar(Impulse.ar(srate));

	// t = (t*3) | (t >> 7) & (t >> 6) & (t >> 5);

	//t = (t*3) | (t << 24);
	t = (t*3) ;
	t = (t * 3) | (t >> 12);


/*	t =   ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3;*/

	t = (t % (bitdepth)) / (bitdepth/2 -1) -1 * 3;
    HPF.ar(t, 20).tanh
}.freqscope
)


// 8-bit magic
(
{
	var srate, bitdepth, out, t, x;
	srate = 8000;
	bitdepth = 3**5;
	t = PulseCount.ar(Impulse.ar(srate));

	// t = (t*3) | (t >> 7) & (t >> 6) & (t >> 5);

	//t = (t*3) | (t << 24);
	t = (t*3) ;
	t = (t * 3) | (t >> 12);


/*	t =   ((t * 15) & (t >> 5)) |
			((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
			- 3;*/

	t = (t % (bitdepth)) / (bitdepth/2 -1) -1 * 3;

    out = HPF.ar(t, 20).tanh;
	out = out + CombC.ar(out, 0.2, 0.6)/2;
	Out.ar(0, out);
}.freqscope
)


8 >> 0;
246.
