
(
o = Server.local.options;
o.maxNodes = 2**16;
o.memSize = 2 ** 21;

b = Dictionary.new();
b.add(\kick -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/kick_wavetable_01.wav"));
b.add(\break -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/Ricochet Break.wav"));
p=ProxySpace.push(s);
p.fadeTime = 2;
p.makeTempoClock;
p.clock.tempo = 160/60;
p.quant = 1.0;

MIDIClient.init;
MIDIIn.connectAll;
)

(

Routine {
	16.do {|chan|
		("Initializing cc" ++ chan).postln;
		p[("cc" ++ chan).asSymbol] = {|value = 0| value };
		0.005.wait;
	};

	1.do {|chan|
		127.do {|pitch|
			("Initializing vel_" ++ chan ++ "_" ++ pitch).postln;

			p[("vel_" ++ chan ++ "_" ++ pitch).asSymbol] = {|value = 0| value };
			0.005.wait;
		};
	};
}.play;
)

(



MIDIdef.cc(\cc, {|val, chan|
	var v = val.linlin(0, 127, 0, 1);
	p[("cc" ++ chan).asSymbol].set(\value, v);
});

MIDIdef.noteOn(\noteOn, {|val, pitch, chan|
	var v = val.linlin(0, 127, 0, 1);
	p[("vel_" ++ chan ++ "_" ++ pitch).asSymbol].set(\value, v);

});
MIDIdef.noteOff(\noteOff, {|val, pitch, chan|
	p[("vel_" ++ chan ++ "_" ++ pitch).asSymbol].set(\value, 0);

});

~out.play;
)

(
~out = {
	x = Mix.new([
		// ~out1.ar(2),
		~bass.ar(2),
		//~out3.ar(2)
	]);
	//x = x + DelayN.ar(x, 160/60 * 4, LFSaw.ar(LFSaw.ar(160/60/32).linexp(-1, 1, 0.25, 160/60)).linexp(-1, 1, 0.001, 160/60*4)/4, 1).tanh; //TODO: modulate weirdness
	x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.2, room: 0.9, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);

    //x = Normalizer.ar(in: x, level: 1, dur: 2);
	x;
};



/*//dumb
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

    x = x.tanh;
};*/



~bass = {
	var sawFreqMultiplier = ~cc3.kr.linexp(0, 1, 1, 8);
	var x = Mix.arFill(127, {|i|
		var pulse = p[("vel_0_" ++ i).asSymbol].kr;
		var x = 0;
		var dustDensity = ~cc1.kr.linexp(0, 1, 1, 100);
		var decayTime = ~cc2.kr.linexp(0, 1, 0.01, 10);
		//pulse = EnvGen.kr(Env.perc( 0.01, 0.01, 1, \welch), pulse);
		pulse = EnvGen.kr(Env.adsr(0.01, 0.1, 0.5, 1, 1, -4), pulse);
		x = x + LFPar.ar((i + ~cc0.kr).midicps,0, 1).cubed.cubed;

		x = x * pulse;
		x = CombC.ar(x, 1, delaytime: Decay.kr(in: Decay.kr(pulse*Dust2.kr(dustDensity), 0.01), decayTime: 10000/i.midicps).linexp(0, 1, 0.1, 10)/i.midicps, decaytime: decayTime);
		x.softclip;
		x = x/16;

	}).softclip;
    x = x + DelayC.ar(x, 1, LFSaw.ar(160/60 * sawFreqMultiplier).linlin(-1, 1, 0, 1)); //laser flanger

	x = x ! 2;
};
)


(

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
