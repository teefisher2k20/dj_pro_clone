# 🎹 Pitch Play Mode - User Guide

## What is Pitch Play?

Pitch Play transforms your sampler pads into a **chromatic keyboard**, allowing you to play melodic patterns from any point in your track. It's perfect for creating live remixes, mashups, and creative performances.

## How to Use

### 1. **Activate Pitch Play**

- Load a track on Deck A or B
- Navigate to the **Sampler Panel** (bottom of the screen)
- Click the **"PITCH A"** or **"PITCH B"** button (purple accent)
- The current playback position becomes your "root note"

### 2. **Play Notes**

When Pitch Play is active, the sampler pads transform:

- **Pads 1-8**: Deck A chromatic scale
- **Pads 9-16**: Deck B chromatic scale

Each pad represents a musical note:

```text
Pad 1: C  (Root)
Pad 2: C# (+1 semitone)
Pad 3: D  (+2 semitones)
Pad 4: D# (+3 semitones)
Pad 5: E  (+4 semitones)
Pad 6: F  (+5 semitones)
Pad 7: F# (+6 semitones)
Pad 8: G  (+7 semitones)
```

### 3. **Visual Feedback**

- Pads show a **purple gradient** background
- **Music note icon** appears on each pad
- **Note name** (C, D, E, etc.) is displayed
- Pads **glow brighter** when pressed

### 4. **Performance Tips**

- **Set your cue point**: Pause at a vocal phrase, drum hit, or melody
- **Activate Pitch Play**: Lock in that moment
- **Play the pads**: Create melodies, basslines, or rhythmic patterns
- **Combine with Slip Mode**: Keep the track playing while you perform

### 5. **Deactivate**

- Click the **"PITCH A/B"** button again to return to normal sampler mode

## Technical Details

- Uses **equal temperament tuning** (standard Western music scale)
- Pitch multipliers calculated as: `2^(semitones/12)`
- Temporarily disables Key Lock to allow pitch shifting
- Jumps to the saved cue point on each pad press

## Creative Ideas

- **Vocal Chops**: Set cue on a vocal and play it melodically
- **Drum Hits**: Turn a kick or snare into a pitched instrument
- **Melody Loops**: Create new melodies from existing musical phrases
- **Live Remixing**: Perform alongside the main track

---

**Note**: In this version:

- Polyphonic playback (multiple notes at once) is **implemented**.
- Separate audio instances per pad are **implemented**.
- Auto-restore original pitch after note release is **implemented**.
- MIDI controller support (via connected MIDI device) is **implemented** (Channel 1=Deck A, Channel 2=Deck B, Notes 60-67).
