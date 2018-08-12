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
		~out2.ar(2),
		~out3.ar(2)
	]);
	//x = x + DelayN.ar(x, 160/60 * 4, LFSaw.ar(LFSaw.ar(160/60/32).linexp(-1, 1, 0.25, 160/60)).linexp(-1, 1, 0.001, 160/60*4)/4, 1).tanh; //TODO: modulate weirdness
    x = x.tanh;
	x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.2, room: 0.2, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);

    //x = Normalizer.ar(in: x, level: 1, dur: 2);
	x;
};



//dumb
~out1 = {
	var x = 0;
	var phase = 0;
	phase = LFSaw.ar(160/60/4);
    x = BufRd.ar(
		numChannels: 2,
		bufnum: k,
		phase: phase * BufSamples.kr(k)/16;
	);
    x = CombC.ar(x, delaytime: Decay.ar(in: Impulse.ar(160/60*16), decayTime: 60/160/16).linlin(0, 1, 0.01, 16), decaytime: -0.125);
	x = DelayN.ar(x, 1, LFPar.ar(160/60).linexp(-1, 1, 0.1, 16)/16); //laser flanger

    x = x.tanh;
};


~out2 = {
	var x = 0;
	var n = 4;
	x = Mix.fill(n, {|i|
		var pulse = Impulse.ar(160/60, i/n);
		var x = 0;
		x = x + LFPar.ar((36 + (2*i/n)).midicps,0, 2).cubed.cubed;
		x = x * Decay.ar(pulse, 0.075); // TODO: modulate gating
	})/n;
	x = x.softclip;
	x = x ! 2;
    x = x*0.9;
	x;
};

// breaks
~out3 = {
	var x = [0, 0];
	var n = 2;
	var phase = LFSaw.ar(1/12);
	//var phase = Select.ar(LFSaw.ar(160/60/1).linlin(-1, 1, 0, n), Array.fill(n, {|i| LFSaw.ar(1/12, i/n)}));
	phase = phase - (LFPulse.ar(160/60*2).linlin(-1, 1, 0, 1)/4);
	// phase = phase - (LFSaw.ar(1/12).round(3/8) * LFPulse.ar(160/60).linlin(-1, 1, 0, 1));
	x = BufRd.ar(2, b, phase * BufSamples.kr(b));
	x = x + DelayN.ar(x, 0.2, LFSaw.ar(160/60/2).linlin(-1, 1, 0, 0.001)); //laser flanger
	// x = HPF.ar(x, 2000);
	x = x;
	x;
};
)
