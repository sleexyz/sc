// Here's my Supercollider learning
// 2015-03-08

s = Server.local;
s.boot;
s.freeAll;

// First I'm following
// https://github.com/s8/NY-SC3-Meetup/blob/master/04-02-2015-SC_intro/04-02-2015-intro.scd

"try me".postln
"try me"

4 + 4

// Ctrl+D searches the help index
SinOsc

{SinOsc.ar}.play

// Ctrl+. is a shorcut for sending the .freeAll message to the server
s.freeAll

{WhiteNoise.ar(MouseX.kr(0, 1))}.freqscope;

// we create two functions, which we assign to the variables a and b. Supercollider denotes functions with the curly braces
// This method of Synth definition and invocation is called "Convenience style"
a = {WhiteNoise.ar(0.1)}
b = {SinOsc.ar}

//The Supercollider interpreter returns "a Function", indicating that the object assignment is a function

//Notice that when you invoke "a.play", the statusbar of the ide indicates an increment in the number of Synth objects instantiated on the server
c = a.play
d = b.play


c.free
d.free

// Now this method of invocation is called "Object-Style"
// Here we create a SynthDef called \test_sine, which we add to the global directory of SynthDefs
// SynthDef: short for Synthesizer Definition

// Notice how the Statusbar indicates that we have "2g" (2 generators?)
SynthDef(\test_sine, {Out.ar(0, SinOsc.ar)}).add
SynthDef(\test_noise, {Out.ar(0, WhiteNoise.ar(0.1))}).add

a = Synth(\test_sine)
b = Synth(\test_noise)

a.free
b.free

// Now here we use "Messaging-style" instantiation and invocation
// We are communicating with Supercollider directly using OSC messages
// we send to the \s_new channel the parameters [\test_noise, a, 0, 1]
a = s.nextNodeID
b = s.nextNodeID

s.sendMsg(\s_new, \test_sine, a, 0, 1)
s.sendMsg(\s_new, \test_noise, b, 0, 1)

s.sendMsg(\n_free, a)
s.sendMsg(\n_free, b)

// Supercollider is able to seemingly completely disregard your volume control settings

// Compare this:
{HPF.ar(in: Saw.ar, freq: 10000)}.play

// with this:
{HPF.ar(in: Saw.ar, freq: -10000)}.play



//Here are some demos taken from https://github.com/s8/NY-SC3-Meetup/blob/master/04-02-2015-SC_intro/04-02-2015-demos.scd



//Everything in its right place
(
SynthDef(\everythingrhodes,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 4.85 lfowidth= 0.5 cutoff= 2000 rq=0.5 pan = 0.0|

	var pulse, filter, env;
	pulse = Pulse.ar(freq*[1,33.5.midiratio],[0.2,0.1],[0.7,0.3]);
	env = EnvGen.ar(Env.adsr(0.0,1.0,0.8,3.0),gate,doneAction:2);
	//keyboard tracking filter cutoff
	filter = BLowPass4.ar(pulse,(cutoff*(env.squared))+200+freq,rq);
	Out.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));

}).add;


//chorus and compression
SynthDef(\choruscompresseffect, {|out =0 gate= 1|
	var source = In.ar(out,2);
	var chorus;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Splay.ar(Array.fill(4,{
		var maxdelaytime= rrand(0.005,0.02);
		DelayC.ar(source[0], maxdelaytime,LFNoise1.kr(Rand(0.1,0.6),0.25*maxdelaytime,0.75*maxdelaytime) )
	}));

	chorus = Compander.ar(4*(source + chorus),source,0.4,1,4);

	XOut.ar(out,env,chorus);

}).add;

)


(
Pfx(
	Pbind(
		\instrument,\everythingrhodes,
		\midinote,Pseq([12,8,7,0,[-12,4,12],[-12,4,12],[-12,4,12],[-11,5,12],[-11,5,12],[-9,7,12],7]+48,inf),
		\dur,Pseq([0.5,0.5,0.5,0.5,1.5,1.0,1.0,1.0,1.0,2.0,0.5],inf),
		\cutoff,Pstutter(11,Pn(Pseries(500,500,4),inf))
	),
	\choruscompresseffect
).play
)

// Okay, I'm gonna figure out what this whole pbind thing is

//syntax example
(
a = Pbind(\x, Pseq([1,2,3]), \y, Prand([100, 300, 200], inf), \zzz, 99);
x = a.asStream;
)

x.next(());

//Sound example
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, 0.1).play;
Pbind(\freq, Prand([36, 43, 60, 71, 64].midicps, inf), \dur, Prand([0.1, 0.3], inf)).play;


// Following "http://ecmc.rochester.edu/ecmc/docs/supercollider/scbook/Ch21_Interface_Investigations/ixi SC tutorial/ixi_SC_tutorial_05.html"

//whitenoise
{WhiteNoise.ar(1)}.plot(1)
{WhiteNoise.ar(1)}.play()
{WhiteNoise.ar(mul: MouseY.kr(0, 1))}.freqscope();

//pinknoise
{PinkNoise.ar(1)}.plot(10)
{PinkNoise.ar(1)}.play
{PinkNoise.ar(1)}.freqscope

//brownnoise
{BrownNoise.ar(1)}.plot(1)
{BrownNoise.ar(1)}.play
{BrownNoise.ar(1)}.freqscope

//Crackle
{Crackle.ar(chaosParam: XLine.kr( 0.9, 2.0, 10),mul: 1)}.play

// ooh what's XLine?
// Exponential curve from 200 to 17000 in 10 seconds
play({ SinOsc.ar(XLine.kr(200,17000,10),0,0.1) });

{SinOsc.ar{Crackle.ar(chaosParam: MouseX.kr(0, 1),mul: 440)}}.play

//LFDNoise0 (Dynamic Step Noise)
// Generates Random values at a rate given by freq
//LFDNoise doesn't quantize
// {LFDNoise0.ar(MouseX.kr(0, 20000), 0.1)}.freqscope

//LFNoise0 (Step Noise)
//LFNoise quantizes, but is more efficient
{LFNoise0.ar(MouseX.kr(0, 20000), 0.1)}.freqscope

//LFDNoise1 Linear Interpolation
// You can see in the oscilloscope the linear interpolation between one value and the next
{ LFDNoise1.ar(MouseX.kr(0, 20000), 0.1) }.play;

//LFNoise2 Quadratic Interpolation
// You can see in the oscilloscope the Quadratic interpolation between one value and the next
{ LFNoise2.ar(MouseX.kr(0, 20000), 0.1) }.play;

//LFDNoise3: Cubic Interpolation
// You can see in the oscilloscope the Cubic interpolation between one value and the next
{ LFDNoise3.ar(MouseX.kr(0, 20000), 0.1) }.play;

//LFClipNoise: Random stream of +1 or -1 at a rate given by freq
{ LFDClipNoise.ar(MouseX.kr(0, 2000), 0.1) }.play;

{ Saw.ar(LFDClipNoise.ar(MouseX.kr(1, 10), 220, 440), 0.4)}.play

//impulse: 0 punctuated by blips of signal at a rate controlled by freq
{Impulse.ar(freq:MouseX.kr(0, 1000), phase: 0.7)}.play

g = 1.asWarp;
g.map(0.5);
//Blip: Band Limited ImPulse generator
// Animal Crossing
{Blip.ar(freq: g.map(MouseX.kr(0, 1)) * 440, numharm: MouseY.kr(1, 10),mul: 0.2)!2}.play;

//Dust
{ Dust.ar(80)}.play
{ Dust.ar(4) }.play
{ Dust2.ar(MouseX.kr(0, 100, -4)) }.play

// what's this?
{WhiteNoise.ar(1) * EnvGen.ar(Env.perc(0.001,0.5), doneAction:2)}.play

// is this better?
{LPF.ar(WhiteNoise.ar(1), 3300) * EnvGen.ar(Env.perc(0.001,0.5), doneAction:2)}.play

// ???
(
fork{
	100.do({
		{LPF.ar(WhiteNoise.ar(1), MouseX.kr(200,20000, 1))
			* EnvGen.ar(Env.perc(0.001,0.5), doneAction:2)}.play;
		1.wait;
	});
}
)

(
fork{
	100.do({
		{LPF.ar(Saw.ar(440), MouseX.kr(200,20000, 1))
			* EnvGen.ar(Env.perc(0.001,0.5), doneAction:2)}.play;
		1.wait;
	});
}
)
// <> is the Function Composition operator
({|a|SinOsc.ar(freq: a)} <> {|d|Dust.ar(d, 220, 220)} <> {MouseX.kr(0, 10000)}).play
// ! is the duplication operator. Duplicates objects into array, if function, invokes function
15 ! 5 == [15, 15, 15, 15, 15] //true
{ 10.rand} ! 5 // [ 4, 4, 3, 8, 0 ]



//Filters, yay!!!

//Low pass filter
{LPF.ar(in:WhiteNoise.ar(0.4), freq: MouseX.kr(40, 20000, 1))}.play;

//doneAction: 2 frees the enclosing Synth after the XLine is over
{LPF.ar(in: WhiteNoise.ar(0.4), freq: XLine.kr(40, 20000, doneAction: 2))}.play;

//High pass filter
{HPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40, 20000, 1))}.play

//Band pass filter
{BPF.ar(WhiteNoise.ar(1), MouseX.kr(40, 20000,1), MouseY.kr(0.01,1))}.play;

//Mid EQ filter
(
{MidEQ.ar(
	in: WhiteNoise.ar(0.024),
	freq: MouseX.kr(40, 20000, 1),
	rq: MouseY.kr(0.01, 1),
	db: 24)
}.play;
)

//We plug Whitenoise into MidEQ into BPF
(
{
	var signal = MidEQ.ar(WhiteNoise.ar(0.4), MouseX.kr(40, 20000, 1), MouseY.kr(0.01, 1), 24);
	BPF.ar(signal, MouseX.kr(40, 20000, 1), MouseY.kr(0.01, 1));
}.play;
)
//Resonant Filter
{Resonz.ar(WhiteNoise.ar(0.5), MouseX.kr(40, 20000 , 1), MouseY.kr(0.01, 1), 24)}.play;
//A short impulse won't resonate
{Resonz.ar(Dust.ar(0.5), 2000, 0.1)}.play

//For that we use Ringz
{Ringz.ar(in: Dust.ar(10, 0.3),freq: MouseX.kr(200, 6000, 1),decaytime: MouseY.kr(0.04, 6, 1))}.play;

//resonant filter
//Dust sends random impulses, while Impulse generates them at a frequency
{Ringz.ar(in: Impulse.ar(4, 0, 0.3), freq: MouseX.kr(200, 6000, 1), decaytime: MouseY.kr(0.04, 6, 1))}.play

//What if we want to "resonate" multiple frequencies?
{Ringz.ar( Dust.ar(3, 0.3), 440, 2) + Ringz.ar(Dust.ar(3, 0.3), 880, 2)}.play
//...or?
(
{
	var trigger, freq;
	trigger = Dust.ar(3, 0.3);
	freq = 440;
	Ringz.ar(trigger, freq, 2, 0.3) +
	Ringz.ar(trigger, freq * 2, 2, 0.3)+
	Ringz.ar(trigger, freq * 3, 2, 0.3)
}.play
)
// there is a better way!
// Klank is a bank of resonators like Ringz, but with fixed frequencies

{ Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Dust.ar(2, 0.3))}.play;
// whitenoise input
{ Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], WhiteNoise.ar(0.005))}.play;
{SoundIn.ar(1)}.play
{ Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], SoundIn.ar(1, 0.01))}.play;

//Formlet
{Formlet.ar(Impulse.ar(4, 0.9) + WhiteNoise.ar(0.02), MouseX.kr(200, 2000, 1), 0.005, 0.5)}.play

{Formlet.ar(LFNoise0.ar(4, 0.1), MouseX.kr(200, 2000, 1), 0.005, 0.1)}.play
{RHPF.ar(in: WhiteNoise.ar(0.04), freq: MouseX.kr(40, 20000, 1), rq: MouseY.kr(0.01, 1, 1))}.play
{RLPF.ar(in: WhiteNoise.ar(0.04), freq: MouseX.kr(40, 20000, 1), rq: MouseY.kr(0.01, 1, 1))}.play
{RLPF.ar(in: SinOsc.ar(100, 0 ,0.1), freq: MouseX.kr(40, 20000, 1), rq: MouseY.kr(0.01, 1, 1))}.play
{RLPF.ar(in: LFSaw.ar(100,0, 0.1), freq: MouseX.kr(40, 20000, 1), rq: MouseY.kr(0.01, 1, 1))}.play
{RLPF.ar(in: LFPulse.ar(100,0,0.5,  0.1), freq: MouseX.kr(40, 20000, 1), rq: MouseY.kr(0.01, 1, 1))}.play

//Let's make a bell with subtractive synthesis!

(
{
	var chime, freqSpecs, burst, harmonics = 10;
	var burstEnv, burstLength = 0.001;

	freqSpecs = `[
		{rrand(100, 1200)}.dup(harmonics),
		{rrand(0.3, 1.0)}.dup(harmonics).normalizeSum,
		{rrand(2.0, 4.0)}.dup(harmonics)];
	burstEnv = Env.perc(0, burstLength);
	burst = PinkNoise.ar(EnvGen.kr(burstEnv, gate: Impulse.kr(1))*0.3);

	Klank.ar(freqSpecs, burst)
}.play
)
//The famous minimoog is a subtractive synthesis machine
{MoogFF.ar(Saw.ar(333), MouseX.kr(400, 16000), MouseY.kr(0.01, 4))}.freqscope




// Now i'm exploring Sound synthesis
// From https://github.com/s8/NY-SC3-Meetup/blob/master/04-03-2015-SC_intro-sound_synthesis/sound_synthesis_intro.scd
{Out.ar([0,1],
	RLPF.ar(
		Saw.ar(200, 0.1),
		MouseX.kr(20, 20000,1),
		MouseY.kr(0.01, 1)
))}.play;


Filter.dumpSubclassList
SynthDescLib.global.browse;
{ Pan2.ar(Klank.ar(`[[1, 2.2, 3.5, 4.9], nil, Array.series(4, 1, -0.2)], PinkNoise.ar(EnvGen.ar(Env.perc(0.001,0.01), Impulse.ar(4))), 1), 0); }.play;

//LFO
{
	var env,vco,  lfo, rlpf;
	vco = SinOsc.ar(50, 0.0, 0.5);
	lfo = SinOsc.ar(MouseX.kr(0,01, 30), 0.0, 100, 50);
	rlpf = RLPF.ar(in: vco, freq: lfo,rq: MouseY.kr(0.01, 1.0, 1));
	Out.ar([0,1], rlpf);
}.play;

//filter noise into sinewave
{BPF.ar(
	WhiteNoise.ar(0.1), 440, MouseX.kr(0, 1.0)
)}.play

{Ringz.ar(WhiteNoise.ar(0.01), MouseX.kr(20, 2000,1), 1, 0.1)}.play
{Resonz.ar(PinkNoise.ar(1), MouseX.kr(20, 2000), MouseY.kr(0.001, 1), 1)}.play

{DynKlank.ar(
	`[
		([48, 59, 52].midicps *MouseY.kr(1, 2, 1 )),
		1.dup(3).normalizeSum,
		pi.dup(3)
], WhiteNoise.ar(0.01) + Impulse.ar(2, 0, 1) + Impulse.ar(3,0 , 1))}.play
(
{
	DynKlank.ar(
	`[
		([48, 59, 52].midicps * Pulse.kr(0.20, 0.1, 1, 1)),
		1.dup(3).normalizeSum,
		pi.dup(3)
], Resonz.ar(
		WhiteNoise.ar(0.01) + Impulse.ar(2, 0, 1) + Impulse.ar(5,0 , 1),
			MouseX.kr(20, 20000,1), MouseY.kr(0.01, 1),0.5)
)
}.play
)

(
{
	SoundIn.ar([0,1])
}.scope
)



(
//illucid
// Original run @ 44100hz
//2015-03-10
//https://soundcloud.com/freshdried/illucid
{
	var out, imp;
	imp = Impulse.ar(2, 0, 1) + Impulse.ar(5, 0, 1);
	out = {DynKlank.ar(
	`[
		([48, 59, 52].midicps * Pulse.kr(0.2, 0.1, 1, 1)),
		1.dup(3).normalizeSum,
		pi.dup(3)
		], Resonz.ar(
			WhiteNoise.ar(0.01)  +  imp * MouseX.kr(0, 6),
			MouseX.kr(20, 20000,1), MouseY.kr(0.01, 1),0.5)
	)};
	 0.2*out + Resonz.ar(
		PinkNoise.ar(MouseY.kr(0.1, 0.2)) +
		Pan2.ar(Dust.ar(2, 2, 1)*out * 4,  TRand.ar(0, 1, imp * 2 -1), 0.3),
		MouseX.kr(20, 20000,1), MouseY.kr(0.01, 1),0.5);
}.freqscope
)

{LPF.ar(Saw.ar(80, 1), MouseX.kr(20, 100, 1))}.play;



{Pulse.ar(0, 0.5)}.play

b = Buffer.read(s, "/usr/share/SuperCollider/sounds/a11wlk01-44_1.aiff");
b = Buffer.read(s, "/home/slee2/composition/doga.wav");


(
x = SynthDef(\help_Buffer, { arg out = 0, bufnum;
	Out.ar(out,
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
	)
}).play(s, [\bufnum, b.bufnum]);
)
{ Impulse.ar(800, 0.0, 0.5, 0) }.play
{ Impulse.ar(XLine.kr(800,100,5), 0.0,  0.5, 0) }.play

// 2015-03-29
(
{
    var trate, dur, clk, pos, pan,imp, out;
    trate = MouseY.kr(8, 120, 1);
	dur = 0.1 / trate;
	clk = Impulse.kr(trate);
	pos = MouseX.kr(0, BufDur.kr(b)) + TRand.kr(0, 0.05,clk);
    pan = WhiteNoise.kr(0.6);
	imp = Impulse.ar(2, 0, 1) + Impulse.ar(5, 0, 1);

	out = {DynKlank.ar(
	`[
			([48, 51, 54, 57, 60]).midicps,
		1.dup(3).normalizeSum,
		pi.dup(3)
		], TGrains.ar(2, clk, b, 1, pos, dur, pan, 2);
	)};
	0.001*out + Resonz.ar(
	PinkNoise.ar(MouseY.kr(0.1, 0.2)) +
	Pan2.ar(Dust.ar(2, 2, 1)*out * 4,  TRand.ar(0, 1, imp * 2 -1), 0.3),
	MouseX.kr(20, 20000,1), MouseY.kr(0.01, 1),0.5)/2;
}.play();
)

(
{
	var in;
	in=SoundIn.ar(1);
}.scope
)
(
{ var in, chain;
	    in = SoundIn.ar(1) * 10;
    chain = FFT(LocalBuf(2048), in);
    chain = PV_RandComb(chain, 0.95, Impulse.kr(0.4));
    IFFT(chain);
}.play;
);


// find scales
(

a = Scale.directory;
)

(
// modal space
// mouse x controls discrete pitch in dorian mode
var scale, buffer;
//scale = FloatArray[0, 2, 3.2, 5, 7, 9, 10]; // dorian scale
scale = Scale.indian.degrees;
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });

play({
    var mix, freq;

	freq = (DegreeToKey.kr(buffer.bufnum, MouseX.kr(0, 15),12, 1, 72)
		+ LFNoise1.kr([3,3], 0.04)).midicps;

    mix = LPF.ar(LFPulse.ar(freq,
		0,
		0.5,
		0.1), freq);

    // drone 5ths

    //+ RLPF.ar(LFPulse.ar([48,55].midicps, 0.15),
    //    SinOsc.kr(0.1, 0, 10, 72).midicps, 0.1, 0.1);


    // add some 70's euro-space-rock echo
    CombN.ar(mix, 0.31, 0.31, 2, 1, mix);
})
)






/* 2015-03-30 */


//echo!
(
{

	var in, mix;
	in = SoundIn.ar(1);
	mix = in;
	//mix = CombN.ar(in, 0.31, 0.31, 2, 1, in);
	Out.ar([0,1], mix );
}.play
)

// Binaural?
// We simulate a width with a delay
(
{
	var in, mix, left, right, width, pos, delay;
	in = SoundIn.ar(1);
	//mix = CombN.ar(in, 0.31, 0.31, 2, 1, in);
	mix = in;
	pos = MouseX.kr(-1, 1) * 0.8;
	delay = (0.5 * (pos + 1));
	width = 0.0001; //16 cm head, 1500m/s
	left = DelayN.ar(mix, 1, delay * width);
	right = DelayN.ar(mix, 1, (1 - delay) * width);
	Balance2.ar(left, right, pos, 5);
}.play
)

a = {Hilbert.ar(SinOsc.ar(200)) * -20.dbamp}.play;
a.release;



p = "/home/slee2/downloads/kaoru akimoto dress down (remastered).mp3";
b = MP3.readToBuffer(s, p);
/* 2015-03-30 */
(
//MP3 playback
// gettin used to synthdef syntax...

SynthDef(\playmp3, {|out=0, bufnum = 0|
	var source;
	// source = SoundIn.ar(1) * 10;
	source = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * MouseY.kr(-1, 1), loop: 1);
	Out.ar(out, source);
}).play(s, [\out, 0, \bufnum, b]);
)
thisProcess.platform.recordingsDir;




(
// sheeet....
// 2015.03.31
///
SynthDef(\rt, { |out=0, timeDispersion = 0.004, pitchDispersion = 0, pitchRatio = 1|
	var in, grainSize,  mix, arr;
	in = SoundIn.ar(0);
	grainSize = 0.1;
	arr = 2**([-1,0,1] * pitchRatio);
	mix = in;
	5.do({

		mix = mix + Mix.new(arr.collect({|pitchRatio|
			PitchShift.ar(mix, grainSize, pitchRatio, pitchDispersion, timeDispersion, 0.5);
		}));
	});
	Out.ar(out, Pan2.ar(Limiter.ar(Mix.new(mix), 0.5), LFNoise1.ar(0.2, 0.4), 4));
}).send(s);


SynthDef(\Mousex, {|out = 0, mult= 1, add = 0|
	Out.kr(out, MouseX.kr(0 + add, mult + add, 1));
}).send(s);

SynthDef(\Mousey, {|out = 0, mult= 1, add = 0|
	Out.kr(out, MouseY.kr(0 + add, mult + add));
}).send(s);

SynthDef(\delay, {|delay=0.25|
	var y;
	y = In.ar(0, 2);
	1.do(y = AllpassN.ar(In.ar(0, 2),delay, delay,3, 1));
	Out.ar(0, y);
}).send(s);
)

(
~busx = Bus.control(s);
~busy = Bus.control(s);

Synth("Mousex", [\out, ~busx.index, \add, 0.0001]);
Synth("Mousey", [\out, ~busy.index, \mult, 1, \add, 0]);

~rt = Synth(\rt, [\out,0]);
~rt.map(\timeDispersion, ~busx.index);
~rt.map(\pitchRatio, ~busy.index);

//Synth.tail(s, \aDelay, [\delay, 0.9]);
)

// 2015-04-08

//transfer functions
// input function -(transfer function)-> output function
// Signal: FloatArray: [a0, a1, a2, a3...]
// Wavetable: FloatArray: [2*a0-a1, a1-a0 , 2*a1-a2, a2-a1]

Signal
Shaper
DWGPlucked

//chebyshev polynomials are an orthonormal basis to [0,1]
// From what I can gather in 5 minutes, they are useful for approimating signals

//Chebyshev polynomials!
(
var mix;
b = Buffer.alloc(s, 1024, 1);

//make map, figure out this cheby sheet
t = Signal.chebyFill(513, 0.25.dup(50));

b.sendCollection(t.asWavetableNoWrap);
{
	mix = Shaper.ar(b, AudioIn.ar(1, 1));
	Out.ar(0, mix!2);

}.freqscope;
)
(
t = Signal.chebyFill(513, (0.25).dup(10).collect({|num| num.rand2}));

b.sendCollection(t.asWavetableNoWrap);
)
b.free;
//envelopes
(
{
	var env;

	env  = Env([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]);
	SinOsc.ar(470)*EnvGen.kr(env, doneAction:2);
}.play
);
Signal.chebyFill(513,1.0.dup(2).collect({|input| input.rand2})).plot

// 2015-04-19
//Blip: Band Limited ImPulse generator
// TODO make functional
// Animal Crossing
// otamatone
(
g = 1.asWarp;
g.map(0.5);

{
	var mouth, k, scale;
	k = 1;
	scale = 5;
	mouth = Select.ar(LFNoise0.kr(k * (scale**0)) > 0,[
		Silent.ar,
		Select.ar(LFNoise0.kr(k * (scale**1)) > 0, [
			Silent.ar,
			Select.ar( LFNoise0.kr(k * (scale**2)) > 0, [
				Silent.ar;
				LFNoise0.ar(k * (scale **3), 0.1);
			]);
		]);
	])!2;
}.play;
)
// 2015-04-19
// I guess it's a fractal noise generator

(
SynthDef(\selfsimilar, {|out = 0, k = 0.1, scale = 5|
	var mix, func, accumulator, iterations;
	iterations = 5;
	func = {|exp, output|
		Select.ar(LFNoise0.kr(k * (scale**exp)) < 0.5, [
			Silent.ar,
			output //CombL.ar(output, 0.2, 0.2, 1, 1);
		]);
	};
	accumulator = func.value(0, _);

	for(1, iterations - 1,{|i|
		accumulator = accumulator <> func.value(i, _);
	});

	mix = accumulator <> LFNoise0.ar(k* (scale**iterations));
	Out.ar(out, mix);
}).add;
SynthDef(\resonator, {|out = 0|
	var mix;
	mix = FreeVerb.ar(RLPF.ar(In.ar,
		[0, 4, 8, 12].collect(_ + 50).choose.midicps,
		0
	));
	Out.ar(out, mix!2);
}).add;

Synth(\selfsimilar);
Synth.tail(s, \resonator, [\resonator, 0.9]);
)

//maybe I'm better off not decomposing my synths...
(
{|k = 0.1, scale = 5|
	var signal, mix, func, accumulator, iterations, tone;
	iterations = 5;
	func = {|exp, output|
		Select.ar(LFNoise0.kr(k * (scale**exp)) < 0, [
			Silent.ar,
			CombL.ar(output, 0.2, 0.2, 1, 1);
		]);
	};
	accumulator = func.value(0, _);

	for(1, iterations - 1,{|i|
		accumulator = accumulator <> func.value(i, _);
	});
	tone = [0, 3, 4, 8, 20, 23, 24, 25].collect(_ + 30).choose.midicps;
	signal =  SinOsc.ar(tone, 0, 0.1);
	mix = accumulator <> signal;
	mix = FreeVerb.ar(mix);
	Out.ar(0, (mix * 0.2)!2);
}.play
)



//This is a pure ugen approach, which might not be the most efficient.
//If I'm just triggering, I can just write this probably in patterns...

(


10.do{{|k = 0.01, scale = 5|
	var signal, mix, func, accumulator, iterations, tone;
	iterations = 8;
	func = {|exp, output|
		Select.ar(LFNoise0.kr(k * (scale**exp)) < 0, [
			Silent.ar,
			CombC.ar(output, 0.1, 0.1, 0.1, 1);
		]);
	};
	accumulator =   func.value(0, _);

	for(1, iterations - 1,{|i|
		accumulator = accumulator <> func.value(i, _);
	});
	tone = Array.fill(48, _ * 1).collect(_ + 20).choose.midicps;
	signal =  LFNoise0.ar(k * (scale**iterations), 0.1);
	mix = accumulator <> signal;
	mix = RHPF.ar(RLPF.ar(mix, tone, 0, 0.1), tone, 0, 0.05);
	mix = Pan2.ar(FreeVerb.ar(mix, mul: 0.2), (1 - 1.0.rand**9)*(2.rand * 2 - 1));
	Out.ar(0, (mix * 0.2)!2);
}.scope
}

)

//Testing buttcheek double parabola distribution
{Pan2.ar(SinOsc.ar(400.rand + 20, 1.0.rand, 0.1), (1 - 1.0.rand**10)*(2.rand * 2 - 1), 1)}.play



{CombN.ar(LFNoise0.ar(1, 0.1), )!2}.play

{Select.ar(LFNoise0.kr(0.5) > 0.4, [Silent.ar, SinOsc.ar])}.play
{Blip.ar(400, MouseY.kr(0, 200))}.play
{Ringz.ar(LFNoise0.ar(1, 0.1), 100, 0.1, 0.5)!2}.play

//partial function bind test
(
f = {|a, b|10*a + b};
a = f.value(_, 1);
a.value(2);
)
Quarks.gui;





//2015-05-13
//mirror redux
(
4.do({{
	var scale, buffer, degree;
	scale = Scale.iraq.degrees;
	buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });
	degree = Logistic.kr(MouseX.kr(2, 3.99), MouseY.kr(1, 20), 0.25, 50).floor;
	Limiter.ar(BPF.ar(PinkNoise.ar(0.1), DegreeToKey.kr(buffer.bufnum, degree).midicps,  0.01), 0.01)!2;
}.play;});
)
//Pfsm...

// 2015-06-03
{SinOsc.ar(SinOsc.kr(1, 0, 100, 300))}.play



//out of phase sound near
//in phase sounds out
//
{[SinOsc.kr(MouseY.kr(0, 30), -1*pi, pi), SinOsc.kr(MouseY.kr(0, 30), 0, pi)].collect{|phase| SinOsc.ar(30, phase)}}.play
{Dust2.ar(10000)}.scope

//use trigger as gate
// Envgen

//2015-06-08
{ [0, 6].collect{|offset| SinOsc.ar(200+offset, 0)}}.play




















{SinOsc.ar(440, 0, 1, 0)}.play
