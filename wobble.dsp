import("stdfaust.lib");

// Slow, smoothed random sources for organic movement
wobble(seed, rate) = no.lfnoise(rate) : si.smooth(ba.tau2pole(1.0/rate));

// V/Oct to Hz conversion (0V = base frequency)
voct2hz(base, voct) = base * pow(2, voct);

// Wobble oscillator (normalized -1 to +1)
wobbleOsc(freq, ampWobble, phaseWobble, wobbleRate) =
    sin(phasor * 2 * ma.PI) * ampMod
with {
    phasor = os.phasor(1, freq) + phaseOffset;
    phaseOffset = wobble(1, wobbleRate) * phaseWobble;
    ampMod = 1.0 + wobble(2, wobbleRate * 1.13) * ampWobble;
};

// Parameters (Program page)
baseFreq = 130.81;  // C3 fixed base frequency
octave = hslider("[0]Octave", 0, -2, 4, 1);  // -2 to +4 octaves
tune = hslider("[1]Tune[unit:semitones]", 0, -7, 7, 1);  // ±7 semitones
// FM Depth with log-like curve: more resolution at low values
fmDepthRaw = hslider("[2]FM Depth", 0, 0, 8, 0.01) / 8.0;  // normalize to 0-1, displays 0.00-8.00
fmDepth = (fmDepthRaw * fmDepthRaw * 8.0) : si.smoo;  // squared curve, 0-8 range
ampWobbleAmt = hslider("[3]Amp Wobble[unit:%]", 5, 0, 500, 1) / 100.0 : si.smoo;  // displays 0-500%, actual 0-5.0
phaseWobbleAmt = hslider("[4]Phase Wobble[unit:%]", 2, 0, 300, 1) / 100.0 : si.smoo;  // displays 0-300%, actual 0-3.0
wobbleRate = hslider("[5]Wobble Rate[unit:hz]", 0.5, 0.1, 200, 0.1) : si.smoo;  // displays 0.1-200.0 Hz

// Eurorack output level
EURORACK_LEVEL = 5.0;

// Tube-style soft saturation (keeps output within ±5V)
// Transparent up to ~3V, gentle compression 3-5V, soft limit at ±5V
soft_saturate(x) = ma.tanh(x * 0.2) * 5.0;

// Main process with CV inputs
// voct_cv: 1V/octave pitch CV input
// fm_in: audio-rate FM input (linear FM)
// fm_depth_cv: FM depth CV (±5V = ±4 added to panel value)
// amp_cv: amplitude wobble CV (±5V = ±250% added to panel value)
// phase_cv: phase wobble CV (±5V = ±150% added to panel value)
// rate_cv: wobble rate CV (±5V = ±100Hz added to panel value)
process(voct_cv, fm_in, fm_depth_cv, amp_cv, phase_cv, rate_cv) = out
with {
    // Combine panel + CV, clamp to valid ranges
    total_fm_depth = max(0, fmDepth + fm_depth_cv * 0.8);            // ±5V = ±4 depth
    total_amp = max(0, min(6.0, ampWobbleAmt + amp_cv * 0.5));       // 0-600%
    total_phase = max(0, min(4.0, phaseWobbleAmt + phase_cv * 0.3)); // 0-400%
    total_rate = max(0.01, min(300, wobbleRate + rate_cv * 20));     // 0.01-300 Hz

    // Base pitch from octave + tune + V/Oct CV
    baseHz = voct2hz(baseFreq, octave + tune/12.0 + voct_cv);
    // Linear FM: freq = baseHz * (1 + fm_in * depth)
    // fm_in is ±5V, normalized to ±1 by hardware
    freq = max(20, baseHz * (1.0 + fm_in * total_fm_depth));
    raw = wobbleOsc(freq, total_amp, total_phase, total_rate) * EURORACK_LEVEL;
    out = soft_saturate(raw);
};

// Plugin metadata
declare name "Wobble";
declare version "1.0";
declare description "Wobbly oscillator with organic movement";
declare guid "ThWb";

// Input names (0-based)
declare input0 "Pitch CV";
declare input1 "FM In";
declare input2 "FM Depth CV";
declare input3 "Amp CV";
declare input4 "Phase CV";
declare input5 "Rate CV";

// Output names (0-based)
declare output0 "Out";
