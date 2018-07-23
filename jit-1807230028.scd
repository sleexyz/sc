//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;
//boot the server
s.boot;
//display the oscilloscope
s.scope;
//start proxyspace
p=ProxySpace.push(s);
p.fadeTime = 2;
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 160/60;
p.quant = 1.0;

~out.play;
~baby = Buffer.read(s, "/home/slee2/.BitwigStudio/installed-packages/1.0/samples/Bitwig/Percussion/Vocal Drums and Percussion/Vocal kick/Vocal Drum-Percussion Kick 09.wav");

)


(
~out = {

	x = Mix.ar([
		//~out1.ar(2).tanh,
		~out2.ar(2).tanh

	]);

	//x = LinSelectX.ar(0.5,[x,PitchShift.ar(in: x, windowSize: 160/60, pitchRatio: 4, timeDispersion: 4)]);
	x = FreeVerb2.ar(in: x[0], in2: x[1], x: 0.2, room: 0.9, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);
    //x = Normalizer.ar(in: x, level: 1, dur: 2);
	x;
};

~out1 = {
	var x;
    x = BufRd.ar(
		numChannels: 1,
		bufnum: ~baby,
		phase: ~phase.ar * BufSamples.kr(~baby);
	);
	x = CombC.ar(x, delaytime: Decay.ar(in: Impulse.ar(160/60 *2), decayTime: 60/160/16).linlin(0, 1, 0.01, 10), decaytime: -1);
    x = x + DelayN.ar(x, 1, LFSaw.ar(160/60*4, 0, 160/60/8).cubed);

    x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 10);
    //x = CombC.ar(x, maxdelaytime: 1, delaytime: LFSaw.ar(160/60/2, 0, 1, 1), decaytime: -1);

	x = x ! 2;
    x = x * 0.9;
};

~phase = {
	var x;
	x = LFSaw.ar(160/60/2).linlin(-1, 1, 0, 0.5);
	//x = x + LFSaw.ar(~spirit.ar);
	x;
};


~out2 = {
	var x, cicadaFactor;
	var seq = Dseq([0, 14, 19, 22] + 48);
	var pulse = Impulse.ar(160/60 * 4);
	x = LFTri.ar(Demand.ar(pulse, 0, Dseq(seq, inf)).midicps).cubed;
	x = x + LFTri.ar(Demand.ar(pulse + DelayN.ar(pulse, 1, 160/60/2), 0, Dseq(seq + 7, inf)).midicps).cubed;
	x = x * Decay.ar(pulse, 160/60/4);
	cicadaFactor = LFSaw.ar(0.1, 0).linexp(-1, 1, 1, 16);
	x = x + DelayN.ar(x, 160/60 * 2, 160/60 + LFSaw.ar(160/60 * cicadaFactor), 0.4); //nice sound
	//x = LPF.ar(x, 4000, 1);
	//x = PitchShift.ar(x, windowSize: 160/60, pitchRatio: 2/3, timeDispersion: 0, mul: 2);
	x = x ! 2;
    //x = Compander.ar(x, ~out1.ar(2);, thresh: 0.01, slopeBelow: 1, slopeAbove: 0, clampTime: 0.01, relaxTime: 0.01);
    x = x * 0.9;
	x;
};

~spirit = {
	var x;
	x = SinOsc.ar(0.1).linexp(-1, 1, 0.001, 10);
	x;
}
)

~phase.scope;