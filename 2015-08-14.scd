MIDIIn.connectAll;

(
~fract = {|iterations = 10, baserate = 100|
		Mix.kr(Array.fill(iterations, {|i| LFDClipNoise.kr(freq: baserate*(2**i), mul: 2**(iterations - (i + 1)))}))/(2**(iterations));
	};
)


b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
b = Buffer.read(s, "/Users/slee2/Music/yutaka_evening_star.aif");

c = Buffer.alloc(s, 44100  * (2)); //80bpm/160bpm



//sc house
(
SynthDef(\looper, {|pos = 0, rate = 1|
	var in, mix, trig;
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
	trig = Impulse.ar(10);


	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), pos * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)))!2;
	Out.ar(0 ,mix);

}).add;
)

(
x = Synth(\looper, 0);

MIDIdef.cc(\test1, {|val, chan|
	chan.postln;
	if (chan === 1, {
		x.set(\rate, val/128);
	});
	if(chan === 5, {
		x.set(\pos, val/128);
	});
});
)

//
//
// Looper

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100  * (60/60)); //80bpm/160bpm

(
~bufs =Array.fill(8, {
	Buffer.alloc(s, 44100  * (60/80));
});
)

// if soft, record to buf
// if hard, play
(
SynthDef(\looper, {|pos = 0, rate = 1, triggerFreq = 1, dur=1|
	var in, mix, trig;
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
/*	in = GrainBuf.ar(1,
		trigger: Impulse.ar(triggerFreq),
		dur: dur,
		sndbuf: b,
		rate: rate
	);*/


	BufWr.ar(in, c, Phasor.ar(trig, 1, 0, BufFrames.kr(c), pos * BufFrames.kr(c)),1);

	mix = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(c)))!2;
	Out.ar(0 ,mix);

}).add;
)

// looper control
(
x = Synth(\looper, 0);

MIDIdef.cc(\test1, {|val, chan|
	chan.postln;
	if (chan === 1, {
		x.set(\rate, val/128);
	});
	if(chan === 5, {
		x.set(\pos, val/128);
	});
	if(chan === 6, {
		x.set(\triggerFreq, (val/128).linlin(0, 1, 1, 10));
	});
});
)






(
MIDIdef.noteOn(\test2, {|val, chan|
	chan.postln;
});
)