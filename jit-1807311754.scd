(
k = Buffer.read(s, "/home/slee2/.BitwigStudio/installed-packages/1.0/samples/Bitwig/Bitwig Drum Machines/Justin3am Drums and Sounds/Kick Wavetable 04 Justin3am.wav");

b = Buffer.read(s, "/home/slee2/samples/Jungle Jungle - 1989 to 1999 Samplepack/Breaks/Ricochet Break.wav");


//start proxyspace
p=ProxySpace.push(s);
p.fadeTime = 2;
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 160/60;
p.quant = 1.0;

~out.play;
)


(
~out = {

	x = Mix.new([
		//~out1.ar(2),
		//~out2.ar(2),
		~out3.ar(2)

	]);

	//x = LinSelectX.ar(0.5,[x,PitchShift.ar(in: x, windowSize: 160/60, pitchRatio: 4, timeDispersion: 4)]);
	//x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.2, room: 0.9, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);
    //x = x * 0.5 + DelayN.ar(x, 160/60 * 2, 160/60 + LFSaw.ar(160/60 * LFSaw.ar(0.1, 0).linexp(-1, 1, 1, 16)), 1); //nice sound

    //x = Normalizer.ar(in: x, level: 1, dur: 2);
	x;
};



~out3 = {
	var x = [0, 0];
	var n = 2;
	var phase = LFSaw.ar(1/12);
	//var phase = Select.ar(LFSaw.ar(160/60/1).linlin(-1, 1, 0, n), Array.fill(n, {|i| LFSaw.ar(1/12, i/n)}));
	phase = phase - (LFPulse.ar(160/60)/16);
	//phase = phase.frac;
	//phase = phase - (LFSaw.ar(1/12).round(3/8) * LFPulse.ar(160/60).linlin(-1, 1, 0, 1));
    //phase = phase - (LFSaw.ar(1/6, 0.25).round(1/4) * LFPulse.ar(160/60/8).linlin(-1, 1, 0, 1));


	x = BufRd.ar(2, b, phase * BufSamples.kr(b));
	//x = HPF.ar(x, 1000);
	//x = CombC.ar(x, 160/60, 1, -2);
	x = x * 0.5;
	x;
};


~out1 = {
	var x;
    x = BufRd.ar(
		numChannels: 1,
		bufnum: k,
		phase: ~phase.ar * BufSamples.kr(k)/4;
	);
    //x = CombC.ar(x, delaytime: Decay.ar(in: Impulse.ar(160/60*4), decayTime: 60/160/16).linlin(0, 1, 0.01, 16), decaytime: -0.125);
    //x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 10);
    x = x + DelayN.ar(x, 160/60 * 4, 160/60 + LFSaw.ar(160/60/16 * LFSaw.ar(0.1, 0).linexp(-1, 1, 1, 16)).linexp(-1, 1, 0.01, 160/60*3)); //nice sound

	//x = Compander.ar(x, ~out2.ar(1), thresh: 0.1, slopeBelow: 1, slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.01);
	x = x ! 2;

    x = x * 0.9;
};

~phase = {
	var x = 0;
	// x = LFSaw.ar(160/60*4);
	// x = x.linlin(-1, 1, 0, 1);
	x = x + LFSaw.ar(~spirit.ar).linlin(-1, 1, 0, 1);
	x;
};


~out2 = {
	var x = 0;
	var n = 4;
	x = Mix.fill(n, {|i|
		var pulse = Impulse.ar(160/60*4);
		var x = LFPar.ar(60.midicps + (i*5)).cubed.cubed;
		x = x*Decay.ar(pulse, 60/160);
    	x = DelayN.ar(x, 1, LFSaw.ar(i*160/60*2).linlin(-1, 1, 0, i*60/160));
		x;
	})/n;

	//x = x + DelayN.ar(x, 160/60 * 4, 160/60 + LFSaw.ar(160/60/16 * LFSaw.ar(0.1, 0).linexp(-1, 1, 1, 16)).linexp(-1, 1, 0.01, 160/60*3)); //nice sound
	//x = x + PitchShift.ar(x, windowSize: 160/60, pitchRatio: 4, timeDispersion: 0, mul: 2);
	x = x ! 2;
    x = x * 0.9;
	x;
};

~spirit = {
	var x;
	x = LFTri.ar(160/60/16).linexp(-1, 1, 0.001, 10);
	x;
}
)

~phase.scope;