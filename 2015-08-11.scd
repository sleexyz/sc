//Lag exploration

(
{
	var signal, density;
	signal = LFPulse.kr(0.5).range(0, 10000);
	density = Lag.kr(signal, MouseX.kr(0, 5));
	Ringz.ar(Dust2.ar(density), 500)!2;
}.play
)