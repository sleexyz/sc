s = Server.local;
s.boot;

//OSC bus
Bus;

{SinOsc.ar(440)}.play;

// "https://github.com/NickColvin/MMH_SC_Intro/blob/master/01.EventOverview.scd"

().play
(note: 2).play
(note: 2, octave: 4).play
(note: 2, octave: 4, amp: 1).play

r = Routine({12.do({|i| i .yield})});
r.next;
r.reset;

(
fork {
	loop {
		var noteVal = r.next;
		if (noteVal == nil) {r.reset; this.yield};
		(degree: noteVal, mtranspose: 1, root: 0, dur: 0.25).play;
		0.3.wait;
	}
}
)


p = Pseries(0, 1, 12);

q = p.asStream;

12.do({ Post << Char.tab << r.next << " " << q.next << Char.nl; });



p = Pseries(start: 0, step: 1, length: inf);
q = p.asStream;

35.do({q.next.postln});

//Pseq
~list = [0, 2, 4, 1, 3, 5, 6, 8];

p = Pseq(list: ~list, repeats: 1, offset: 0);
q = p.asStream;

8.do({q.next.postln});

//Prand
p = Prand(~list, repeats: 10);
q = p.asStream;

10.do({q.next.postln});

(
SynthDef(\sawWall, {
	|freq = 440 ,amp=0.2, gate=1, filterFreq, pan=0, out=0|
	var sig, env;
	env = EnvGen.ar(Env.adsr(0.25, 0, 1, 0.5), gate, doneAction: 2);
	sig = Saw.ar(freq * [1, 1.005, 1.003]);
	sig = RLPF.ar(sig, freq*2);

	sig = sig * env * amp;
	sig = Pan2.ar(Mix(sig), pan);
	Out.ar(out, sig);
}).add;
)
x = Synth(\sawWall);
x.set(\gate, 0);

(
x = Pbind(
	\instrument, \sawWall,
	\note, Pseq([0, 2], 4) + [ 0, 2, 5, 9],
	\legato, 1,
	\dur, 4)
)
x.play;

CuspN
Hasher
GingerBread

