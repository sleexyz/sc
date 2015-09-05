b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100  * (60/80)); //80bpm/160bpm

//sc house
(
{
	var in, mix, rate, trig, downsamplerate;
	rate = LFDNoise0.kr(0.5, 1.5, 0.1);
	rate = 1;
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
	trig = Impulse.ar(5);


	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), MouseX.kr(0, 1) * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)));

	mix = BLowPass.ar(mix, MouseY.kr(100, 10000, 1));
	Out.ar(0, mix!2);
}.scope
)











// add some fractal, or some dust


//granular poop
(
{
	var in, mix, rate, trig, resetpos,readpos;
	rate = 1;
	trig = Impulse.kr(LFNoise0.kr(1).linexp(0, 1, 1, 100));

	resetpos = Phasor.ar(0, 0.1, 0, BufFrames.kr(b),0);
	readpos = Phasor.ar(trig, rate, 0, BufFrames.kr(b),resetpos);


	in = 	BufRd.ar(1, b, readpos);
	mix = LPF.ar(in, 1000);
	Out.ar(0, mix!2);
}.scope
)



//quantized intervals
(
{
	var in, mix, rate, trigfreq, trig, resetpos,readpos;
	rate = 1;
	trigfreq = 2**LFNoise0.kr(1).range(1, 6).floor;
	trig = Impulse.kr(trigfreq);

	resetpos = Phasor.ar(0, -0.25, 0, BufFrames.kr(b),0); //goes backwards at a constant rate

	readpos = Phasor.ar(trig, rate, 0, BufFrames.kr(b),resetpos); //resets on trig to resetpos


	in = 	EnvGen.ar(Env.new(curve:\sine), trig, 1, 0, 1/trigfreq)*BufRd.ar(1, b, readpos);
	mix = LPF.ar(in, 2000);
	Out.ar(0, mix!2);
}.scope
)



b = Buffer.read(s, "/Users/slee2/Music/yutaka_evening_star.aif");

//quantized intervals
// add beat detect trig freq scaling
(
{
	var in, mix, rate, trigfreq, trig, resetpos,readpos;
	rate = 1;
	trigfreq = 2**LFNoise0.kr(0.1).range(0, 4).floor;
	trig = Impulse.kr(trigfreq);

	resetpos = Phasor.ar(0, -0.25, 0, BufFrames.kr(b),0); //goes backwards at a constant rate

	readpos = Phasor.ar(trig, rate, 0, BufFrames.kr(b),resetpos); //resets on trig to resetpos


	in = 	EnvGen.ar(Env.new(curve:\sine), trig, 1, 0, 1/trigfreq)*BufRd.ar(1, b, readpos);
	mix = LPF.ar(in, MouseY.kr.linexp(0, 1, 100, 22050));
	Out.ar(0, mix!2);
}.play
)



// TODO:
// make into fractal beat breaker
// add beat detect trig freq scaling
(
{
	var in, mix, rate, trigfreq, trig, resetpos,readpos;
	rate = 1;
	trigfreq = 2**LFNoise0.kr(0.1).range(0, 4).floor;
	trig = Impulse.kr(trigfreq);

	resetpos = Phasor.ar(0, -0.25, 0, BufFrames.kr(b),0); //goes backwards at a constant rate

	readpos = Phasor.ar(trig, rate, 0, BufFrames.kr(b),resetpos); //resets on trig to resetpos


	in = 	EnvGen.ar(Env.new(curve:\sine), trig, 1, 0, 1/trigfreq)*BufRd.ar(1, b, readpos);
	mix = LPF.ar(in, MouseY.kr.linexp(0, 1, 100, 22050));
	Out.ar(0, mix!2);
}.play
)

