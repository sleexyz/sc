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

d = Bus.control(s, 2);
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
	var delayTime = LFSaw.ar((42-24).midicps).linexp(-1, 1, (42).midicps.reciprocal, (42-36).midicps.reciprocal);
	var splitFreq = 200;
	var delPhase;
	var delBuf = {LocalBuf(48000)}!2;
	var feedback;
	x = [SoundIn.ar(60, 20), SoundIn.ar(61, 20)];
	x = BufDelayC.ar({LocalBuf(48000)}!2,x, delayTime);
	chain = FFT({LocalBuf(2048)}!2, x);
	chain = PV_MagBelow(chain, SinOsc.ar(160/60/8).linexp(-1, 1, 1, 10));
	chain = PV_MagFreeze(chain, LFSaw.ar(160/60/2));
	chain = PV_MagSquared(chain);
	chain = PV_MagSmear(chain, LFSaw.ar(160/60/2).linexp(-1, 1, 1, 100));
	chain = PV_MagSquared(chain);
	x = x + (IFFT(chain));
	delPhase = DelTapWr.ar(delBuf, ~efx.ar);
	feedback = DelTapRd.ar(delBuf, delPhase, delayTime, 1, 0.5);
	feedback = LPF.ar(feedback, 8000,1);
	feedback = HPF.ar(feedback, 400,1);

	feedback = feedback;
	//x = x * Lag.ar(LFPulse.ar(160/60*4, 0, 0.25), 0.0001);

	x = x + feedback;

	x
};

~efxOut = {
	var x = ~efx.ar;
    x = Compander.ar(x, x, 0.01, 1, 0, 0.01, 0.1)/0.01;
	x = BPeakEQ.ar(x, 40, 1, 20);
	Out.ar(62, x);
};

)

s.scope(64);
Quarks.gui;