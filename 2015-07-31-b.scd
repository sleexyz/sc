

// Buffer Exploration:






// BufRd

// DIY granular synth
// Super sick looper

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100);

(
{
	var in, mix, rate, trig;
	rate = MouseY.kr(0, 1);
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
	trig = Impulse.ar(10);

	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), MouseX.kr(0, 1) * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)))!2;


}.scope
)


b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100  * (60/80)); //80bpm/160bpm

//sc house
(
{
	var in, mix, rate, trig, downsamplerate;
	rate = LFDNoise0.kr(0.5, 1.5, 0.1);
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
	trig = Impulse.ar(10);

	downsamplerate = MouseY.kr(1000, 22050, 1);
	in = Latch.ar(in, Impulse.ar(downsamplerate));

	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), MouseX.kr(0, 1) * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)))!2;



}.scope
)
// Make a buf write duplicator




//Sleep


// Finish first song with supercollider pink noise overlay
(
a = c.plot;
)
(
a.value_(c);
a.refresh;
)

