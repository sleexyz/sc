
(
o = Server.local.options;
o.maxNodes = 2**16;
o.memSize = 2 ** 21;
)
(
b = Dictionary.new();
b.add(\kick -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/kick_wavetable_01.wav"));
b.add(\break -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/Ricochet Break.wav"));
)
(
p=ProxySpace.push(s);
p.fadeTime = 2;
p.makeTempoClock;
p.clock.tempo = 140/60;
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
		("Initializing channel " ++ chan).postln;
		127.do {|pitch|

			n[("note" ++ chan ++ "_" ++ pitch).asSymbol] = nil;
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

	n[sym] = Synth(("chan" ++ chan).asSymbol, [\freq, pitch.midicps, \gate, 1, \vel, v ]);
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
SynthDef(\chan0, {|freq = 440, gate = 1, vel = 0.75|
	var decayTime = ~cc2.kr.linexp(0, 1, 0.1, 100);
	var detune = ~cc0.kr*24;


	var x = 0;
	var pulse = gate;
	var combTime = 1/freq;
	freq = (freq.cpsmidi + detune).midicps/2;
	pulse = EnvGen.kr(Env.adsr(0.01, 0.1, 0.5, 1), pulse, vel, doneAction: 2);
	x = PinkNoise.ar(1);
	x = x * pulse;
	//x = CombC.ar(x, combTime, delaytime: Decay2.kr(in: gate, attackTime: 0.1, decayTime: 10).linexp(0, 1, 0.001, 1)* combTime, decaytime: -1);
	//x = x/16;
	x = x*4 + CombC.ar(x, delaytime: LFSaw.ar(140/60*4).linexp(-1, 1, 0.001, 1)/freq, decaytime: -1)/4;

	Out.ar(c[0], x! 2);
}).add;

SynthDef(\chan1,  {|freq = 440, gate = 1, vel = 0.75|
	var rate = ~cc4.kr.linexp(0, 1, 0.5, 16);

	var x = 0;
	var pulse = 0;
	var phase = 0;
	var alienness = ~cc5.kr;
	freq = (freq.cpsmidi + Rand.new(0, 1)).midicps;
	pulse = EnvGen.ar(Env.linen(freq.reciprocal*200, 0, 0), gate, doneAction: 0);
	phase = pulse.linlin(0, 1, 0, BufFrames.ir(b[\kick])); //original duration

	x = BufRd.ar(
		numChannels: 2,
		bufnum: b[\kick],
		phase: phase,
	);
	x = BPeakEQ.ar(in: x, freq: 40, rq: 10, db: 20);

	x = LinSelectX.ar(alienness, [
		x,
		CombC.ar(x, 1,delaytime: LFSaw.ar(140/60*16).linlin(0, 1, 0, rate)/freq, decaytime: -100 )
	])/16;
	x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);

	//x = x * EnvGen.ar(Env.adsr(0.01, 0, 1, 60/140), gate, vel,  doneAction: 2);
	x = x * EnvGen.ar(Env.perc(0.01, alienness.linexp(-1, 1, 0.1, 10)), gate, vel,  doneAction: 2);

    x = x.softclip;
	Out.ar(c[1], x!2);
}).add;

SynthDef(\chan2,  {|freq = 440, gate = 1, vel = 0.75|
	var x = 0;
	var n = 2;
	freq = freq + Rand.new(0, 20);
	x = WhiteNoise.ar(1);
	x = DelayN.ar(x, 1, LFSaw.ar(freq).linlin(-1, 1, freq.reciprocal*2, 0)); //metal
	x = BPeakEQ.ar(in: x, freq: 40, rq: 10, db: 1);

	x = x + CombC.ar(x, 1,delaytime: LFSaw.ar(SinOsc.ar(0.5).linexp(-1, 1, 32, 8)).linexp(-1, 1, 0.5,100)/freq/4, decaytime: -0.5)/1;

	x = x * EnvGen.ar(Env.adsr(0.05, 0.1, 0.1, 0.1), gate, vel, doneAction: 2);
	Out.ar(c[2], x!2);
}).add;




~out = {
	var chan0 = In.ar(c[0], 2);
	var chan1 = In.ar(c[1], 2);
	var mix = MouseY.kr(0, 1);
	var chan0_ = Compander.ar(chan0, chan1, mix, 1, 0, 0.01, 0.1);
	var chan1_ = Compander.ar(chan1, chan0, 1 - mix, 1, 0, 0.01, 0.1);

	x = Mix.new([
		//chan0,
		chan1,
		In.ar(c[2], 2),
	]).softclip;
	//x = x + DelayN.ar(x, 140/60 * 4, LFSaw.ar(LFSaw.ar(140/60/32).linexp(-1, 1, 0.25, 140/60)).linexp(-1, 1, 0.001, 140/60*4)/4, 1).tanh; //TODO: modulate weirdness
	//x = FreeVerb2.ar(in: x[0], in2: x[1], mix: 0.1, room: 0.9, damp: 1);
	//x = BPeakEQ.ar(in: x, freq: 60, rq: 1, db: 5);
    //x = Normalizer.ar(in: x, level: 0.8, dur: 2);
	x;
};
)

~out.scope;


100.softclip;