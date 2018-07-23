(
MIDIIn.connectAll;
b = NetAddr.new("127.0.0.1", 57121);
)
MIDIClient.init;

// akai LPD8
(
~min = 1; // inclusive
~max = 9; // exclusive
MIDIdef.cc(\cc, {|val, chan|
	val.postln;
	if ((chan >= ~min) && (chan < ~max)) {
		b.sendMsg("/" ++ (chan - ~min), val/127);
	} {}
});
)

// midifighter twister
(
~min = 0; // inclusive
~max = 8; // exclusive
MIDIdef.cc(\cc, {|val, chan|
	val.postln;
	if ((chan >= ~min) && (chan < ~max)) {
		b.sendMsg("/" ++ (chan - ~min), val/127);
	} {}
});
)

// midifighter
(
~min = 36; // inclusive
~max = 52; // exclusive
MIDIdef.noteOn(\on, {|val, chan|
	if ((chan >= ~min) && (chan < ~max)) {
		b.sendMsg("/" ++ (chan - ~min), 1);
	} {}
});
MIDIdef.noteOff(\off, {|val, chan|
	if ((chan >= ~min) && (chan < ~max)) {
		b.sendMsg("/" ++ (chan - ~min), 0);
	} {}
});
)

s.dumpOSC(1);
s.dumpOSC(0);