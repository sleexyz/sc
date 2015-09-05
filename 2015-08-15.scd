MIDIIn.connectAll;


//
// Looper

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100  * (2)); //80bpm/160bpm

(
~bufs =Array.fill(8, {
	Buffer.alloc(s, 44100  * (2));
});
)

// if soft, record to buf
// if hard, play
(
SynthDef(\looper, {|pos = 0, rate = 1, triggerFreq = 10|
	var in, mix, trig;
	in = 	BufRd.ar(1, b, Phasor.ar(0, rate, 0, BufFrames.kr(b)));
	trig = LFPulse.ar(triggerFreq);
	in = in*EnvGen.ar(Env.triangle,trig,1, 0, 1/triggerFreq);

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
		x.set(\triggerFreq, (val/128).linlin(0, 1, 1, 20));
	});
});
)

(
MIDIdef.noteOn(\test2, {|...args|
	args.postln;
});
)



// DIY paulstretch
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
c = Buffer.alloc(s, 44100  * (30));

(
SynthDef(\paulstretch, {|triggerFreq=10, dur=0.1, playbackRate=1|
	var mix, trig;
	trig = Impulse.ar(triggerFreq);
	mix = GrainBuf.ar(1, trig, dur, b, 1, Phasor.ar(0, 1/BufFrames.kr(b)*playbackRate, 0, 1));
	Out.ar(0, mix!2);
}).add
)

(
x = Synth(\paulstretch, [\triggerFreq, 500, \dur, 1/800, \playbackrate, 1]);

MIDIdef.cc(\test1, {|val, num, chan, src|
	if(num === 1, {
		x.set(\triggerFreq, (val).linexp(0, 127, 1, 800));
	});
	if(num === 2, {
		x.set(\dur, (val).linexp(0, 127, 1/800, 2));
	});
	if(num === 3, {
		x.set(\playbackRate, (val).linexp(0, 127, 0.0001, 10000));
	});
});
)
(
MIDIdef.noteOn(\test2, {|val, num, chan, src|
	x.set(\triggerFreq, (num).midicps);

});
)

(
MIDIdef.bend(\test3, {|...args|
	args.postln;
});
)

