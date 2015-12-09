// taken from "http://doc.sccode.org/Guides/News-3_5.html#Bitwise ops"
// modified






(
play {
	var t, srate;
	srate = MouseX.kr(1, 22050, 1);
    t = PulseCount.ar(Impulse.ar(srate));
    HPF.ar(
        (
            ((t * 15) & (t >> 5)) |
            ((t * 5)  & (t >> [3, 4])) |
            ((t * 2)  & (t >> 9)) |
            ((t * 8)  & (t >> 11))
            - 3 % 256
        ) / 127-1 * 3
        , 20
    ).tanh
}
)





(
{
	var t, srate, out, atten, x, y;
	x = MouseX.kr;
	y = MouseY.kr;
	//srate = x.linexp(0, 1, 1000, 22050);
	srate = 8000;


	t = PulseCount.ar(Impulse.ar(srate));
	out = (
		((t * 30) & (t >> 5)) |
	    ((t >> 8 * 12) & (t >> 2)) |
		((t * 5) & (t >> [3, 4])) |
		((t * 4) & (t >> 9)) |
		((t * 16) & (t >> 11)) |
		0
		- 1 % 512
	) / 255-(1) * 3;

	out = out;
	out = HPF.ar(out, y.linexp(-1, 1, 1e1, 1e2));
	out = LPF.ar(out, y.linexp(-1, 1, 1e1, 1e3));
	out = (1- (out)).tanh;
}.play
)


(
{
	var t, srate, out, atten, x, y;
	x = MouseX.kr;
	y = MouseY.kr;
	srate = 8000;


	t = PulseCount.ar(Impulse.ar(srate));
	out = t*(((t>>12)|(t>>8))&(63&(t>>4)));
	out = out % (0 << 10)/ (0 << 10 -1);

	out = HPF.ar(out, 20).tanh;
}.scope
)
