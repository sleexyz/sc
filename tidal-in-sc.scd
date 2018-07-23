s.boot;

p = ProxySpace.push(s);


~out.play;
Scale.directory

~tempo = 160/60;

(
~clock = {Impulse.kr(~tempo*4)};
~count = {PulseCount.kr(~clock)};

)
(
~bass[0] = {SinOsc.ar(Demand.kr((~count / 2) % 1, 0, Dseq([0, 2, 3, 12] + 60, inf).midicps))};
~bass[1] = {SinOsc.ar(Demand.kr((~count / 4) % 1, 0, Dseq([0, 2, 3, 12] + 72, inf).midicps))};

~out2 = ~bass * 0.125;
~out1 = {FreeVerb.ar(~out2, 0.33, 0.5, 0.5).tanh.tanh};

~out = ~out1;
)

p.quant = 1;


