// Trigger Exploration:



// Latch example:
//
// Updates input signal every time trigger changes from non-positive to positive
// Essentially down sampling: induces aliasing
(
{
	var mix;

	mix = SinOsc.ar(MouseY.kr(1, 22050, 1));
	mix = Latch.ar(mix, Impulse.ar(MouseX.kr(1, 22050, 0)));
	mix = Out.ar(0, mix);
}.play
)

//Impulse and SinOsc have the same period for a given freq...
(
{[SinOsc.ar(200), Impulse.ar(200)]}.plot
)


// But for some reason they behave differently under Latch
(
{
	var mix, latchfreq;

	mix = SinOsc.ar(MouseY.kr(1, 22050, 1));
	latchfreq = MouseX.kr(1, 22050, 0);
	mix = Latch.ar(mix, [
		Impulse.ar(latchfreq),
		SinOsc.ar(latchfreq)
	]);
	mix = Out.ar(0, mix);
}.play
)












// Gate example
//
// Passes input signal when trigger is positive, holds otherwise
(
{
	var freq, mix;

	freq = 400;

	mix = SinOsc.ar(freq);
	mix = Gate.ar(mix, LFPulse.ar(freq/[1,2]));
	mix = Out.ar(0, mix);
}.scope
)
