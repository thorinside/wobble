# Wobble

A wobbly sine oscillator for the Expert Sleepers disting NT. Produces organic, slowly-drifting tones using smoothed random modulation of pitch and amplitude.

## Patching

### Inputs (Routing Page)

| Input | Description |
|-------|-------------|
| Pitch CV | 1V/octave pitch CV (0V = base freq) |
| Amp CV | Amplitude wobble modulation (±5V = ±250%) |
| Phase CV | Phase wobble modulation (±5V = ±150%) |
| Rate CV | Wobble rate modulation (±5V = ±100 Hz) |

### Output

**Out** → Audio destination (VCA, filter, mixer, etc.) at ±5V

### Suggested Patches

- **Sequenced melody**: Sequencer pitch → V/Oct input, base freq sets root note
- **Drone pad**: No V/Oct needed, amp wobble 10-20%, phase wobble 2-5%, rate 0.3-0.8 Hz
- **Evolving texture**: LFO → Amp CV or Rate CV for slowly changing character

## Parameters (Program Page)

| Parameter | Range | Description |
|-----------|-------|-------------|
| Base Freq | 20-4000 Hz | Fundamental frequency at 0V input |
| Amp Wobble | 0-500% | Amplitude modulation depth (>100% = chaotic) |
| Phase Wobble | 0-300% | Phase/pitch warping (>100% = extreme) |
| Wobble Rate | 0.01-200 Hz | Modulation speed (>20 Hz = audio-rate FM) |

## Building

Requires Faust compiler and ARM toolchain for hardware builds.

```bash
make test      # Build .dylib for VCV Rack nt_emu testing
make hardware  # Build .o for disting NT hardware
make clean     # Remove build artifacts
```

## License

MIT
