MIDIClient.init;
MIDIIn.connectAll;



//Synth
(
SynthDef(\foo, {|note=60, rq=0.001, gate=0, dsrate=2000, vol=1|
	var env, mix;
	env = EnvGen.ar(Env.adsr, gate, Latch.kr(gate, gate), 0, 1);

	mix = RHPF.ar(PinkNoise.ar(0.5), note.midicps, rq, env);
	mix = Latch.ar(mix, LFPulse.ar(dsrate));
	mix = LPF.ar(mix, dsrate);
	mix = mix*vol;

	Out.ar(0, mix!2);
}).add
)

(
~rq = Bus.control(s);
~dsrate = Bus.control(s);
~vol = Bus.control(s);

~rq.set(0.001);
~dsrate.set(2000);
~vol.set(1);


~keys = Array.fill(128, {|i|
	var synth = Synth(\foo, [
		\note, i
	]);
	synth.map(\rq, ~rq,
		\dsrate, ~dsrate,
		\vol, ~vol
	);
	synth;
});

MIDIdef.cc(\test1, {|val, chan|
	switch (chan,
		1, {
			~rq.set(val.linexp(0, 127, 0.001, 1));
		},
		3, {
			~dsrate.set(val.linexp(0, 127, 400, 44100));
		},
		4, {
			~vol.set(val.linexp(0, 127, 0.01, 5));
		}
	);
});

MIDIdef.noteOn(\test2, {|val, chan|
	~keys[chan].set(\gate, val/128);
});
MIDIdef.noteOff(\test3, {|val, chan|
	~keys[chan].set(\gate, 0);
});
)



~keys[0]
~keys[60].set(\gate, 0);
s.dumpOSC(1);
s.dumpOSC(0);
