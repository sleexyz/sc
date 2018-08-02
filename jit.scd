(
b = Dictionary.new();
b.add(\kick -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/kick_wavetable_01.wav"));
b.add(\break -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/Ricochet Break.wav"));
p=ProxySpace.push(s);
p.fadeTime = 2;
p.makeTempoClock;
p.clock.tempo = 160/60;
p.quant = 1.0;

~out.play;
)


// TODO try proxyspace instead of In.kr, or at least a helper function
(
~out = {
	var x = 0;
	x = SinOsc.ar(110*In.kr(c[0]) + 440);
	x!2;
};
)

(
c = Array.fill(16, {
	var bus = Bus.control(s, 1);
	bus
});
d = Array.fill(16, {|i|
	{|value = 0| Out.kr(c[i], [value]) }.play;
})
)

MIDIClient.init;
MIDIIn.connectAll;
// looper control
(
MIDIdef.cc(\test1, {|val, chan|
	var v = val.linlin(0, 127, 0, 1);
	d[chan].set(\value, v);
});
)




(
~out = {
	x = Mix.new([
		// ~out1.ar(2),
		~out2.ar(2),
		// ~out3.ar(2)
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
		bufnum: b[\kick],
		phase: phase * BufSamples.kr(b[\kick])/16;
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

~out3 = {
	var x = [0, 0];
	var n = 2;
	var phase = LFSaw.ar(1/12);
	//var phase = Select.ar(LFSaw.ar(160/60/1).linlin(-1, 1, 0, n), Array.fill(n, {|i| LFSaw.ar(1/12, i/n)}));
	phase = phase - (LFPulse.ar(160/60*2).linlin(-1, 1, 0, 1)/4);
	// phase = phase - (LFSaw.ar(1/12).round(3/8) * LFPulse.ar(160/60).linlin(-1, 1, 0, 1));
	x = BufRd.ar(2, b[\break], phase * BufSamples.kr(b[\break]));
	x = x + DelayN.ar(x, 0.2, LFSaw.ar(160/60/2).linlin(-1, 1, 0, 0.001)); //laser flanger
	// x = HPF.ar(x, 2000);
	x = x;
	x;
};
)
