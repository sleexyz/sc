(
b = Dictionary.new();
b.add(\kick -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/kick_wavetable_01.wav"));
b.add(\break -> Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/samples/Ricochet Break.wav"));


Routine {
	16.do {|chan|
		("Initializing cc" ++ chan).postln;
		p[("cc" ++ chan).asSymbol] = {|value = 0| value };
		0.005.wait;
	};
	n = Dictionary.new();
	8.do {|chan|
		("Initializing channel " ++ (chan + 1)).postln;
		n[("note" ++ (chan + 1)).asSymbol] = nil;
		127.do {|pitch|

			n[("note" ++ (chan + 1) ++ "_" ++ pitch).asSymbol] = nil;
		};
		SynthDef(("chan" ++ (chan + 1)), { |gate=0| FreeSelf.kr(gate) }).add;

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
	var sym = ("note_" ++ (chan + 1) ++ "_" ++ pitch).asSymbol;
	var node = n[sym];


	if (node.notNil, {
		node.release;
		n[sym] = nil;
	});

	n[sym] = Synth(("chan" ++ (chan + 1)).asSymbol, [\freq, pitch.midicps, \gate, 1, \vel, v ]);

	p[("mono" ++ (chan + 1)).asSymbol].set(\freq, pitch.midicps);
	p[("mono" ++ (chan + 1)).asSymbol].set(\gate, 1);
	p[("mono" ++ (chan + 1)).asSymbol].set(\vel, v);


});

MIDIdef.noteOff(\noteOff, {|val, pitch, chan|
	var sym = ("note_" ++ (chan + 1) ++ "_" ++ pitch).asSymbol;
	var node = n[sym];
	if (node.notNil, {
		node.release;
		n[sym] = nil;
	});
	p[("mono" ++ (chan + 1)).asSymbol].set(\gate, 0);
});

~mono1 = {|freq = 440, vel = 0.75|
    var x = 0;
	var chain;
	var curve = ~cc0.kr;
	var smear = ~cc1.kr;
	freq = Lag.kr(freq, 1);
	x = LFPulse.ar(freq);
	x = x + WhiteNoise.ar(0.1);
	chain = FFT(LocalBuf(2048), x);
	chain = PV_MagBelow(chain, LinSelectX.ar(curve, [LFSaw.ar(10), LFPulse.ar(10)]).linexp(-1, 1, 1, 10));
	chain = PV_MagSquared(chain);
	chain = PV_MagFreeze(chain, LFPar.ar(20));
	chain = PV_MagSmear(chain, LinSelectX.kr(smear, [0, SinOsc.kr(0.1).linexp(-1, 1, 1, 10)]));
	chain = PV_MagSquared(chain);
	//chain = PV_MagShift(chain, LFPar.ar(0.1).linexp(-1, 1, 1, 20), 0);
	chain = PV_MagSquared(chain);

	x = IFFT(chain);
	//x = x*EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);

	x = Compander.ar(x, x, 0.01, 1, 0, 0.01, 0.01)/0.01;
	x = BPeakEQ.ar(x, 40, 1, 40);
	//x = x.distort;
	//x = x + CombC.ar(x, 0.2, 1/10, -0.1);


	//Out.ar(0, x!2);
};

SynthDef(\chan2, {|freq = 440, gate = 1, vel = 0.75|
    var x = 0;
	var chain;
	var curve = ~cc0.kr;
	var smear = ~cc1.kr;
	var pulse = EnvGen.ar(Env.linen(1), gate, vel, doneAction: 2);

	x = Pluck.ar(WhiteNoise.ar, Impulse.ar(10), 1, 1/pulse.linexp(0, 1, freq, 10), 0.1, 0.8);
	chain = FFT(LocalBuf(2048), x);
	chain = PV_MagSmear(chain, 10);
	chain = PV_MagBelow(chain, 1);
	chain = PV_MagFreeze(chain, LFSaw.ar(10));
	chain = PV_MagSquared(chain);

	x = IFFT(chain);
	x = Compander.ar(x, x, 0.01, 1, 0, 0.01, 0.1)/0.01;
	x = BPeakEQ.ar(x, 40, 1, 40);

	Out.ar(2, x!2);
}).add;
)
s.scope();