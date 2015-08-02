(
{
}
)



b = Buffer.read(s, thisProcess.platform.recordingsDir +/+ "SC_150731_175403_01.aiff");
(
{
	var mix, noise, hum, numHarms, humFreq, tuning;
	mix = BufRd.ar(2, b, Phasor.ar(0, BufRateScale.kr(c), 0, BufFrames.kr(b)))!2;


	numHarms = 7;
	humFreq = 100;
	hum = Array.fill(numHarms, {|i| SinOsc.ar( (i+1) * humFreq, 0, 1/numHarms)});
	hum = hum.sum;
	noise = hum*Dust.ar(LFNoise1.ar(0.5).range(1000, 8000))*LFNoise1.ar(1).range(0.5, 2);

	tuning = HPF.ar(Latch.ar(SinOsc.ar(LFNoise2.kr(1).range(0, 100000)), Impulse.ar(8000)), 2000) * 0.1;
	tuning = LPF.ar(tuning, 1000);
	noise = LPF.ar(noise, 1000);
	mix = mix + (noise* 0.5);
	mix = SelectX.ar(MouseX.kr(0, 1), [mix, noise]);
	mix = SelectX.ar(MouseX.kr(0, 0.5), [mix, tuning]);
}.play
)









// copied from da internet

(
SynthDef("radiostatic", {arg out=0;
	var hum, sineSweep, tuning, dustNoise, staticNoise, humFreq, numHarms;

	numHarms = 7;
	humFreq = 100;
	hum = Array.fill(numHarms, {|i| SinOsc.ar( (i+1) * humFreq, 0, 1/numHarms)});
	hum = hum.sum;
	dustNoise = Dust.ar(LFNoise1.ar(0.5).range(1000,8000));
	staticNoise = hum * dustNoise * LFNoise1.ar(1).range(0.5, 2);

	sineSweep = SinOsc.ar(LFNoise2.ar(1).range(20, 11000));
	tuning = SinOsc.ar(10000).ring4(sineSweep) * LFNoise2.ar(1.1).range(0.05, 0.1);

	Out.ar(out,  Pan2.ar(staticNoise + tuning, 0));
}).add;
)

a = Synth("radiostatic");