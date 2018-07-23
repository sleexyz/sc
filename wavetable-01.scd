(
~baby = Buffer.read(s, "/home/slee2/.BitwigStudio/installed-packages/1.0/samples/Bitwig/Percussion/Vocal Drums and Percussion/Vocal kick/Vocal Drum-Percussion Kick 09.wav");


~boop = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


~phase = Bus.audio(s, 1);
)

(
SynthDef(\out, {
	var out;
    out = BufRd.ar(
		numChannels: 1,
		bufnum: ~baby,
		phase: In.ar(~phase) * MouseX.kr(256, 10000, 1) ;
	);
	Out.ar(0, [out, out]);
}).play;


SynthDef(\wavetableTimeDisplacement, {
	var phase;
	phase = Phasor.ar(0, 1, 0, MouseX.kr(256, 10000, 1));
	phase = LinSelectX.ar(MouseY.kr(0, 1), [
		phase/MouseX.kr(256, 10000, 1),
		BufRd.ar(
		  numChannels: 1,
		  bufnum: ~baby,
		  phase: phase
	    )
	]);
	Out.ar(~phase, phase);
}).play;
)
