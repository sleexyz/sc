s = Server("aServer", NetAddr("localhost", 57110));

s.freeAll


(
~buttons = Array.fill(9, {|i|
	Bus.new('control', i, 1, s).set(0.5);
});


~keys = Array.fill(128, {|i|
	Bus.new('control', i, 1, s).set(0);

});

~switch = Array.fill(9, {|i|
	{|val|
		~buttons[i].set(val/128);
	}
});


MIDIdef.cc(\test1, {|val, chan|
	~switch[chan].value(val)
});

MIDIdef.noteOn(\test2, {|val, chan|
	~keys[chan].set(val/128);
});
MIDIdef.noteOff(\test3, {|val, chan|
	~keys[chan].set(0);
});

)

