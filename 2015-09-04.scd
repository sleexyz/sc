MIDIClient.init;
MIDIIn.connectAll;


//Synth
(
SynthDef(\foo, {|note=60, rq=0.001, vol=0.1|
	var mix;
	mix = RLPF.ar(PinkNoise.ar(vol), note.midicps, rq);
	Out.ar(0, mix);
}).add
)

(
x = Synth(\foo, [\note, 60]);

MIDIdef.cc(\test1, {|val, chan|
	switch (chan,
		1, {
			val.postln;
			x.set(\rq, val.linexp(0, 128, 0.00001, 1));
		},
		2, {
			val.postln;
			x.set(\vol, val.linexp(0, 128, 0.01, 1));
		}
	);
});

MIDIdef.noteOn(\test2, {|val, chan|
	x.set(\note, chan);
});
)



//Patterns!


//Synth
(
SynthDef(\foo, {|note=60, rq=0.001, dur=1, downsampleRate=2000, vol=1|
	var env, mix;
	env = EnvGen.ar(Env.sine, 1, 1, 0, dur *5, doneAction:2);
	mix = RHPF.ar(PinkNoise.ar(0.1), note.midicps, rq, env);
	mix = RLPF.ar(mix.tanh, note.midicps, rq, env);
	mix = Latch.ar(mix.tanh, Impulse.ar(downsampleRate));
	mix = LPF.ar(mix, downsampleRate);
	mix = mix*vol;

	Out.ar(0, mix!2);
}).add
)


(
Pbind(\instrument, \foo,
	\note,  Pdefn(\notes),
	\rq, Pdefn(\rq),
	\dur, Pdefn(\durations),
	\downsampleRate, Pdefn(\downsampleRate),
	\vol, Pdefn(\vol)
).play;

~keys = Array.new(8);
~index = 0;

MIDIdef.cc(\test1, {|val, chan|
	switch (chan,
		1, {
			Pdefn(\rq, val.linexp(0, 127, 0.001, 1));
		},
		2, {
			Pdefn(\durations, val.linexp(0, 127, 0.1, 1));
		},
		3, {
			Pdefn(\downsampleRate, val.linexp(0, 127, 400, 44100));
		},
		4, {
			Pdefn(\vol, val.linexp(0, 127, 0.01, 5));
		}
	);
});

MIDIdef.noteOn(\test2, {|val, chan|
	(~keys.size - 8 + 1).do({
		~keys.removeAt(0);
	});
	~keys.add(chan);
	Pdefn(\notes, Pseq(~keys,inf));

});
)
~keys
~keys.removeAt(0);
s.dumpOSC(0);
