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


SynthDef(\chan0, {|freq = 440, gate = 1, vel = 0.75|
	var x = 0;
	var ball = Ball.ar(Impulse.ar(0), 1, 0.5, 0.1);
	var laser = EnvGen.ar(Env.perc(0.001, 1), ball);
	var coeff = 0.7;
	x = Mix.arFill(4, {|i|
		var x = 0;
		var freq2 = freq*(1.5**(i));
		x = Pluck.ar(LFPar.ar(freq2, 0, laser).cubed, ball, 1, 1/freq2, -2, coeff);
	});
	DetectSilence.ar(x, amp: 0.0001, time: 2, doneAction: 2);
	Out.ar(0,x ! 2);
}).add;
)

(
{ var in, chain;
	in = PlayBuf.ar(2, b[\break], 1, 1, 0, 1, doneAction: 0);
    chain = FFT(LocalBuf(2048), in);
    chain = PV_RandComb(chain, 0.95, Impulse.kr(0.4));
    IFFT(chain);
}.play;
)


(
{ var in, chain;
    in = Ringz.ar(Impulse.ar([2, 3]), [700, 800], 0.1) * 5;
    chain = FFT({ LocalBuf(2048) } ! 2, in);
    chain = PV_RandComb(chain, 0.95, Impulse.kr(0.4));
    IFFT(chain);
}.play;
)

s.scope();