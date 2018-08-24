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

~efx = {
    var x = 0;
	var chain;
	var curve = 0;
	var splitFreq = 40;
	x = [SoundIn.ar(60, 20), SoundIn.ar(61, 20)];

	//x = x + AllpassC.ar(x, 1, LFSaw.ar(160/60*8).linexp(-1, 1, 1/800, 1), 1, 5);

	chain = FFT({LocalBuf(2048)} !2, HPF.ar(x, splitFreq));
	chain = PV_MagBelow(chain, LFSaw.ar(160/60*2).linexp(-1, 1, 1, 50));
    chain = PV_MagSquared(chain);
	chain = PV_MagFreeze(chain, LFSaw.ar(160/60*8, add: -0.5));
	chain = PV_MagSmear(chain, LFSaw.ar(160/60*2).linexp(-1, 1, 1, 100));
	chain = PV_MagSquared(chain);
	x = LPF.ar(x, splitFreq) + HPF.ar(IFFT(chain), splitFreq);
	x = Compander.ar(x, x, 0.00001, 1, 0, 0.01, 0.1)/0.00001;
	//x = x * LFPulse.ar(160/60*4, 0.05);

	x = BPeakEQ.ar(x, 40, 1, 20);
	Out.ar(62, x);
};

)
s.scope(64);