(
o = Server.local.options;
o.maxNodes = 2**16;
o.memSize = 2 ** 21;
o.numOutputBusChannels = 16;
s.boot;

p=ProxySpace.push(s);
p.fadeTime = 2;
p.makeTempoClock;
p.clock.tempo = 140/60;
p.quant = 1.0;

c = Array.fill(16, { Bus.audio(s, 2); });

MIDIClient.init;

MIDIClient.sources.do({|x|
	if (x.name == "VirMIDI 4-0", {
		MIDIIn.connectByUID(0, x.uid);
	});
})
)