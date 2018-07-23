(
a = SynthDef(\help_beattrack, { |out, vol=1.0, beepvol=1.0, lock=0|
    var in, fft, resample;
    var trackb, trackh, trackq, tempo;
    var bsound, hsound, qsound, beep;

    in = SoundIn.ar(0);

    fft = FFT(LocalBuf(1024), in); // for sampling rates 44100 and 48000

    #trackb, trackh, trackq, tempo = BeatTrack.kr(fft, lock);

    beep = SinOsc.ar(1000, 0.0, Decay.kr(trackb, 0.1));

    Out.ar(out, Pan2.ar((vol * in) + (beepvol * beep), 0.0))

}).play
)

(
SynthDef(\help_beattrack2, { |out|
    var trackb, trackh, trackq, tempo;
    var source;
    var bsound, hsound, qsound;

    source = SoundIn.ar(0);

    #trackb, trackh, trackq, tempo = BeatTrack.kr(FFT(LocalBuf(1024), source));

    //bsound = Pan2.ar(LPF.ar(WhiteNoise.ar * Decay.kr(trackb, 0.05), 1000), 0.0);

    hsound = Pan2.ar(BPF.ar(WhiteNoise.ar * Decay.kr(trackh, 0.05), 3000, 0.66), -0.5);

    //qsound = Pan2.ar(HPF.ar(WhiteNoise.ar * Decay.kr(trackq, 0.05),5000), 0.5);

	    Out.ar(out, source + hsound);// + hsound + qsound);
}).play;
)

(
//favour higher tempi in own weighting scheme
c = Array.fill(120, { |i| 0.5 + (0.5 * (i / 120)) });
e = Buffer.sendCollection(s, c, 1);
)



(
SynthDef(\help_beattrack2_2, { |out|
    var trackb, trackh, trackq, tempo;
    var source, kbus;
    var bsound, hsound, qsound;

    source = SoundIn.ar(0);

    //downsampling automatic via kr from ar
    kbus = Out.kr(0, LPF.ar(source, 1000)); //([feature1, feature3]++feature2);

    #trackb, trackh, trackq, tempo = BeatTrack2.kr(0,1,weightingscheme: e.bufnum);

    bsound = Pan2.ar(LPF.ar(WhiteNoise.ar * (Decay.kr(trackb, 0.05)), 1000), 0.0);
    hsound = Pan2.ar(BPF.ar(WhiteNoise.ar * (Decay.kr(trackh, 0.05)), 3000, 0.66),-0.5);
    qsound = Pan2.ar(HPF.ar(WhiteNoise.ar * (Decay.kr(trackq, 0.05)), 5000), 0.5);

    Out.ar(out, source + bsound + hsound + qsound);
}).play;
)