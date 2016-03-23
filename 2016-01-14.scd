s.dumpOSC;

// /d_recv : receive synthdef definition

// Server Command Reference

// Select.kr

// Synth Definition File Format

// "http://doc.sccode.org/Overviews/JITLib.html"


(
SynthDef(\poop, {|freq = 440|
	var x = SinOsc.ar;
	Out.ar(0, x);
}).add;
)

x = Synth(\poop, [\freq, 440]); //9
x.free; //11
x.set(\freq, 330); //15

