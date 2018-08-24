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
	var delayTime = Saw.ar((42-12).midicps).linexp(-1, 1, (42-24).midicps.reciprocal, (42-36).midicps.reciprocal);
	var splitFreq = 200;
	var delPhase;
	var delayBuf = {LocalBuf(48000)}!2;
	x = [SoundIn.ar(60, 20), SoundIn.ar(61, 20)];
	delPhase = DelTapWr.ar(delayBuf, x);

	x = x + DelTapRd.ar(delayBuf, delPhase, delayTime);
	//x = BufDelayC.ar(delayBuf,x, 1);
	chain = FFT({LocalBuf(2048)}!2, x);
	chain = PV_MagBelow(chain, 10);
	chain = PV_MagSmear(chain, 2);
	chain = PV_MagSquared(chain);
	x = x + (IFFT(chain));
	x = Compander.ar(x, x, 0.1, 1, 0, 0.01, 0.1)/0.1;
	//x = BPeakEQ.ar(x, 40, 1,40);
	Out.ar(62, x);
};

)
s.scope(64);