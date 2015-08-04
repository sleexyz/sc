
b = Buffer.read(s, "/Users/slee2/Music/yutaka_evening_star.aif");
//b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
{
	SinOsc.ar(
		SinOsc.kr(10).range(5, 9)
	)!2
}.play
)


(
{
	BufRd.ar(1, b, Phasor.ar(0, 1, 0, BufFrames.kr(b)))!2;
}.play
)




c = Buffer.alloc(s, 44100  * (60/80)); //80bpm

//sc house
(
{
	var in, mix, rate, trig, downsamplerate;
	in = 	BufRd.ar(1, b, Phasor.ar(0, 1, 0, BufFrames.kr(b)));
	trig = Impulse.ar(80/60 * 10);

	//downsamplerate = MouseY.kr(1000, 22050, 1);
	//in = Latch.ar(in, Impulse.ar(downsamplerate));

	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), MouseX.kr(0, 1) * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)))!2;
	//mix = LPF.ar(mix, downsamplerate);
}.scope
)