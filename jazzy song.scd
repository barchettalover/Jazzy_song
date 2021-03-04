(
s.waitForBoot{



SynthDef(\FMRhodes1, {
    arg
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1, att = 0.001, rel = 1, lfoSpeed = 4.8, inputLevel = 0.2,
    modIndex = 0.2, mix = 0.2, lfoDepth = 0.1;

    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    env1 = Env.perc(att, rel * 1.25, inputLevel, curve: \lin).kr;
    env2 = Env.perc(att, rel, inputLevel, curve: \lin).kr;
    env3 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;
    env4 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;

    osc4 = SinOsc.ar(freq) * 6.7341546494171 * modIndex * env4;
    osc3 = SinOsc.ar(freq * 2, osc4) * env3;
    osc2 = SinOsc.ar(freq * 30) * 0.683729941 * env2;
    osc1 = SinOsc.ar(freq * 2, osc2) * env1;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
  	snd = snd * (SinOsc.ar(lfoSpeed).range((1 - lfoDepth), 1));

    snd = snd * Env.asr(0, 1, 0.1).kr(gate: gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
},
)
).add;


/*
=========== HAT SYNTHDEF ==========
*/

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.3, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

~metronome = TempoClock.new(60/60).permanent_(true);
~gdom7 =  [67, 71, 74, 77];
~fmaj7 = [65, 69, 72, 76];

~chord1 = [60, 64, 67, 71]; // Cmaj7
~chord6 = [ 57, 60, 64, 67 ];// Amin7
~chord2 = [ 62, 65, 69, 72 ];// Dmin7
~chord5 = [50,67, 71, 74, 77]; // Gdom7


Pbindef(\jazz,
	\instrument, \FMRhodes1,
	\dur, Prand([
			Pseq([Rest(1/2), 2/2], inf),
	]),
	\midinote, Pseq([
		~chord1, ~chord1, ~chord1, ~chord1,
		~chord6, ~chord6, ~chord6, ~chord6,
		~chord2, ~chord2, ~chord2, ~chord2,
		~chord5, ~chord5, ~chord5, ~chord5

	], inf),
	\rel, 0.5,
	\mix, 0.2,
    \modIndex, 0.2,
    \lfoSpeed, 0.5,
    \lfoDepth, 0.4,
    \inputLevel, Pgauss(0.8, 0.1, inf),
    \amp, 0.2,
	\legato, Pseq([1/2], inf),
	\strum, Pwhite(0, 0.1),
	\ctranspose, 0,
);


	Pbindef(\jazz).quant_(30/60 * 4);

Pbindef(\drums,
	\instrument, "hihat",
	\dur, Pseq([1/12*2, Rest(1/6*2), 1/12*2, Rest(1/12*2), 1/12*2], inf),
	\att, 0.01,
	\rel, -0.005*~metronome.tempo + 1,
	\ffreq, 11500,
	\pan, 0,
	\amp, 0.2
);

	Pbindef(\drums).quant_(30/60 * 4);

}
)

Pbindef(\jazz).play;
Pbindef(\drums).play;
Pbindef(\jazz).stop;
Pbindef(\drums).stop;
