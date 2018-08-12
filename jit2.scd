
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
	var decayTime = ~cc2.kr.linexp(0, 1, 0.1, 100);
	var detune = ~cc0.kr*24;


	var x = 0;
	var pulse = gate;
	var combTime = 1/freq;
	freq = (freq.cpsmidi + detune).midicps/2;
	pulse = EnvGen.kr(Env.adsr(60/160*2, 60/160*8, 0.1, 60/160*8), pulse, doneAction: 2);
	x = PinkNoise.ar(1);
	x = HPF.ar(x, freq, 10);
	x = x * pulse;
	x = CombC.ar(x, combTime, delaytime: Decay.kr(in: pulse, decayTime: freq.reciprocal).linexp(0, 1, 0.001, 1)* combTime, decaytime: -0.5);
	x = x/16;
	x = x;
	x = x + CombC.ar(x, delaytime: LFSaw.ar(160/60*4).linexp(-1, 1, 0.01, 1)/freq, decaytime: -1)/16;
    x = x.softclip;
	Out.ar(c[0], x! 2);
}).add;

SynthDef(\chan1,  {|freq = 440, gate = 1|
	var rate = ~cc4.kr.linexp(0, 1, 0.5, 16);

	var x = 0;
	var pulse = 0;
	var phase = 0;
	freq = (freq.cpsmidi + Rand.new(0, 1)).midicps;
	pulse = EnvGen.ar(Env.linen(freq.reciprocal*200, 0, 0), gate, doneAction: 0);
	phase = pulse.linlin(0, 1, 0, BufFrames.ir(b[\kick])); //original duration

	x = BufRd.ar(
		numChannels: 2,
		bufnum: b[\kick],
		phase: phase,
	);

	x = x/2 + CombC.ar(x, 1,delaytime: LFSaw.ar(160/60*16).linlin(0, 1, 0, rate)/freq, decaytime: -100)/8;

	x = BPeakEQ.ar(in: x, freq: 40, rq: 1, db: 26);
	x = x * EnvGen.ar(Env.perc, gate, doneAction: 2);


	x = x.softclip;
	Out.ar(c[1], x!2);
}).add;

// TODO: add panning;


~out = {
	var chan0 = In.ar(c[0], 2);
	var chan1 = In.ar(c[1], 2);
	var mix = 0.9;
	var chan0_ = Compander.ar(chan0, chan1, mix, 1, 0, 0.01, 0.1);
	var chan1_ = Compander.ar(chan1, chan0, 1 - mix, 1, 0, 0.01, 0.1);

	x = Mix.new([
		chan0_,
		chan1_
		// ~out3.ar(2)
	]).softclip;
	//x = x + DelayN.ar(x, 160/60 * 4, LFSaw.ar(LFSaw.ar(160/60/32).linexp(-1, 1, 0.25, 160/60)).linexp(-1, 1, 0.001, 160/60*4)/4, 1).tanh; //TODO: modulate weirdness
	//x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.1, room: 0.9, damp: 1);
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


100.softclip;