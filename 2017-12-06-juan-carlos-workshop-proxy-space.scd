s.boot;

p = ProxySpace.push(s);

~out.play;

(
~tempo = {Impulse.kr(80)};
~clock = {PulseCount.kr(~tempo)};
~notes = {Dseq([0, 12] + 60, inf)};
~bass[0] = {RHPF.ar(Impulse.ar(1), MouseX.kr(60, 12000, 1), MouseY.kr(0.1, 1, 1))};
~bass[1] = {SinOsc.ar(Demand.kr(~tempo, 0, ~notes).midicps)};

~out2 = ~bass;
~out1 = {FreeVerb.ar(~out2, 0.33, 0.5, 0.5)};

~out = ~out1;
)

p.quant = 1;


