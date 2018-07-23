(
~baby = Buffer.read(s, "/home/slee2/.BitwigStudio/installed-packages/1.0/samples/Bitwig/Percussion/Vocal Drums and Percussion/Vocal kick/Vocal Drum-Percussion Kick 09.wav");


~boop = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


~phase = Bus.audio(s, 1);
~channel1 = Bus.audio(s, 2);
~channel2 = Bus.audio(s, 2);

~pulse = Bus.control(s, 1);
)

(
SynthDef(\master, {
	var x;
	var bass = 	Mix.ar([
		In.ar(~channel1, 2).tanh
	]);
	var melody = Mix.ar([
		In.ar(~channel2, 2).tanh
	]);
	melody = Compander.ar(melody, bass, thresh: 0.4, slopeBelow: 1, slopeAbove: -1, clampTime: 0.01, relaxTime: 0.01);

	x = Mix.ar([
		bass,
		//melody
	]);

	//x = LinSelectX.ar(0.5,[x,PitchShift.ar(in: x, windowSize: 160/60, pitchRatio: 4, timeDispersion: 4)]);
    x = FreeVerb2.ar(in: x[0], in2: x[1], x: 0.2, room: 0.1, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);
    //x = Normalizer.ar(in: x, level: 1, dur: 2);
	Out.ar(0, x);
}).play;


SynthDef(\channel1, {
	var x;
    x = BufRd.ar(
		numChannels: 1,
		bufnum: ~baby,
		phase: In.ar(~phase) * BufSamples.kr(~baby);
	);
	x = CombC.ar(x, delaytime: Decay.ar(in: Impulse.ar(160/60 * 4), decayTime: 60/160/16).linlin(0, 1, 0.01, 10), decaytime: -1);
    x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 10);
    x = x * 0.9;
	Out.ar(~channel1, [x, x]);
}).play;


SynthDef(\channel2, {
	var x;
	var seq = Dseq([0, 12, 19, 22, 29, 31, 32, 41] + 60);
	x = LFPulse.ar(Demand.kr(In.kr(~pulse), 0, Dseq(seq, inf)).midicps).cubed;
	x = CombC.ar(x, delaytime: Decay.kr(in: In.kr(~pulse), decayTime: SinOsc.ar(0.01).linexp(0, 1, 1/64, 1)).linexp(0, 1, 0.1, 1)/16, decaytime: -1 );
	x = LPF.ar(x, 4000, 1);
	//x = PitchShift.ar(x, windowSize: 160/60, pitchRatio: 2/3, timeDispersion: 0, mul: 2);
    x = x * 0.9;
	Out.ar(~channel2, [x, x]);
}).play;




SynthDef(\wavetableTimeDisplacement, {
	var x;
	x = LFSaw.ar(160/60).linlin(-1, 1, 0, 0.5);
	//x = LFSaw.ar(LFSaw.ar(0.01).linexp(-1, 1, 0.01, 10)).linlin(-1, 1, 0, 1);
	//x = LinSelectX.ar(0.5, [x, LFTri.ar(160/60).linlin(-1, 1, 0, 0.25)]);
	x = x * LFSaw.ar(SinOsc.ar(0.1).linexp(-1, 1, 0.0001, 10)).linlin(-1, 1, 0, 1);
	Out.ar(~phase, x);
}).play;

SynthDef(\pulse, {
	var x;
	x = Impulse.kr(160/60 * 4);
	//x = x * SinOsc.ar(10).linexp(-1, 1, 0.1, 10);
	//x = x + Impulse.kr(LFSaw.kr(0.1).linexp(-1, 1, 0.01, 100));

	Out.kr(~pulse, x);
}).play;
)
