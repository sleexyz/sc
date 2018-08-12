
(
o = Server.local.options;
o.maxNodes = 2**16;
o.memSize = 2 ** 21;
)
(
b = Dictionary.new();
b.add(\kick -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/kick_wavetable_01.wav"));
b.add(\break -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/Ricochet Break.wav"));

p=ProxySpace.push(s);
p.fadeTime = 2;
p.makeTempoClock;
p.clock.tempo = 160/60;
p.quant = 1.0;

c = Array.fill(16, { Bus.audio(s, 2); });

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
	n = Dictionary.new();
	16.do {|chan|
		127.do {|pitch|
			("Initializing vel_" ++ chan ++ "_" ++ pitch).postln;

			n[("note" ++ chan ++ "_" ++ pitch).asSymbol] = nil;
			0.005.wait;
		};
		SynthDef(("chan" ++ chan), {}).add;
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
	var sym = ("note_" ++ chan ++ "_" ++ pitch).asSymbol;
	var node = n[sym];

	if (node.notNil, {
		node.release;
		n[sym] = nil;
	});

	n[sym] = Synth(("chan" ++ chan).asSymbol, [\freq, pitch.midicps, \gate, val]);
});

MIDIdef.noteOff(\noteOff, {|val, pitch, chan|
	var sym = ("note_" ++ chan ++ "_" ++ pitch).asSymbol;
	var node = n[sym];
	if (node.notNil, {
		node.release;
		n[sym] = nil;
	});
});

~out.play;
)
(
SynthDef(\chan0, {|freq = 440, gate = 1|
	var dustDensity = ~cc1.kr.linexp(0, 1, 1, 100);
	var decayTime = ~cc2.kr.linexp(0, 1, 0.1, 100);
	var detune = ~cc0.kr*7;


	var x = 0;
	var pulse = gate;
	var combTime = 1000/freq;
	//freq = (freq.cpsmidi + detune).midicps/2;
	pulse = EnvGen.kr(Env.adsr(0.01, 0.3, 0.2, 1, 1, -4), pulse, doneAction: 2);
	x = x + LFPar.ar(freq, pi.rand, 1).cubed.cubed;
	x = x * pulse;
	x = x/4 + CombC.ar(x, combTime, delaytime: Decay.kr(in: Decay.kr(Dust2.kr(dustDensity), 0.1), decayTime: freq.reciprocal).linexp(0, 1, 0.1, 1)* combTime, decaytime: 1);
	x = x/8;
	x = x;
	x = x.softclip;
	Out.ar(c[0], x! 2);
}).add;

SynthDef(\chan1,  {|freq = 440, gate = 1|
	var rate = ~cc4.kr.linexp(0, 1, 0.5, 8);

	var x = 0;
	var pulse = 0;
	var phase = 0;
	freq = (freq.cpsmidi + Rand.new(0, 2)).midicps;
	pulse = EnvGen.ar(Env.linen(freq.reciprocal*2000, 0, 0), gate, doneAction: 2);
	phase = pulse.linlin(0, 1, 0, BufFrames.ir(b[\kick])); //original duration
	x = BufRd.ar(
		numChannels: 2,
		bufnum: b[\kick],
		phase: phase,
	);
	x = x + CombC.ar(x, delaytime: LFSaw.ar(160/60*8).linexp(0, 1, 0.01, rate)/freq, decaytime: -0.25) / 2;
	x = BPeakEQ.ar(in: x, freq: freq, rq: 10, db: 10);
	// x = x + DelayN.ar(x, 1, 1);
	x = x + DelayN.ar(x, 1, 1/4 * LFSaw.ar(160/60*4));
	// x = x + DelayN.ar(x, 1, 1/2);
	x = x/4;



	x = x/4;
	x = x.softclip;
	Out.ar(c[1], x!2);
}).add;


~out = {
	x = Mix.new([
		In.ar(c[0], 2),
		//In.ar(c[1], 2),
		// ~out3.ar(2)
	]).softclip;
	// x = x + DelayN.ar(x, 160/60 * 4, LFSaw.ar(LFSaw.ar(160/60/32).linexp(-1, 1, 0.25, 160/60)).linexp(-1, 1, 0.001, 160/60*4)/4, 1).tanh; //TODO: modulate weirdness
	//x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.2, room: 0.9, damp: 1);
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);
    //x = Normalizer.ar(in: x, level: 0.8, dur: 2);
	x;
};






//
~bass = {

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

~out.scope;