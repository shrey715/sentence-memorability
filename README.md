# Sentence Memorability Study

## Research Overview

This project investigates how sentence memorability is affected by the
imageability of constituent nouns and grammatical voice (active vs. passive).
Sentences follow a Subject–Verb–Object structure with nouns drawn from
established memorability norms, producing four noun-pair conditions:

| Code | Subject noun | Object noun |
|------|-------------|-------------|
| HH   | High        | High        |
| HL   | High        | Low         |
| LH   | Low         | High        |
| LL   | Low         | Low         |

Each condition has both active and passive forms, giving **8 conditions total
(400 sentences)**. Participants completed a **continuous recognition task**
where they saw 222 sentences per session across 3 blocks, 48 of which were
target sentences that appeared twice (encoding → probe).

### Key responses per trial
- **IR (Immediate Recognition):** Spacebar press when the participant
  recognises a sentence meaning as previously seen.
- **WR (Wording Recognition):** Yes/No judgment on whether the exact wording
  (voice) matches the original.

### References
- Begg (1971) — Recognition Memory for Sentence Meaning and Wording
- Bregman & Strasberg (1968) — Memory for the Syntactic Form of Sentences
- James, Thompson & Baldwin (1973) — The Reconstructive Process in Sentence Memory

---

## Structure

```
data/processed/
├── combined_data.csv   # Raw logs merged
├── cleaned_data.csv    # Practice removed, block_id assigned
├── pruned_data.csv     # Validation flags added
└── final_data.csv      # Use this for analysis

src/preliminary/
├── data.R              # Merge logs
├── events.R            # Validate events, assign blocks
├── flagging.R          # Apply validation formula
└── final_cleaning.R    # Rename columns, drop failed blocks
```

## Analysis File: `final_data.csv`

Use this file only. All rows have passed validation.

**Dimensions:** 72,627 rows × 15 columns | 112 participants | 329/342 blocks (96.2%)

### Column Reference

| Column | Type | Description |
|--------|------|-------------|
| `participant_id` | int | Experiment-assigned participant number |
| `event_timestamp_ms` | int | Unix timestamp in milliseconds |
| `event_type` | chr | Type of logged event (see Event Types below) |
| `stimulus_id` | chr | Sentence identifier, encodes condition e.g. `HH_155_A` |
| `is_target_sentence` | bool | TRUE = one of the 48 experimental target sentences |
| `is_validation_sentence` | bool | TRUE = validation filler sentence |
| `is_probe_repeat` | bool | TRUE = second showing of sentence (recognition test moment) |
| `response_button` | chr | Spacebar / Yes / No / GapTime_x |
| `ir_accuracy` | int | 1 = correct IR hit, 0 = false alarm, NA = miss |
| `wr_accuracy` | int | 1 = correct wording judgment, 0 = incorrect, NA = no IR |
| `ir_reaction_time_ms` | int | RT in ms for IR spacebar press |
| `wr_reaction_time_ms` | int | RT in ms for WR Yes/No press |
| `ir_corrected_recognition` | num | Corrected recognition: P(hit) − P(false alarm) |
| `wr_corrected_recognition` | num | Corrected recognition: P(hit) − P(false alarm) |
| `block_id` | int | Block number: 1, 2, or 3 |

Parse: `HH_155_A` = noun condition (HH/HL/LH/LL) + sentence number + voice (A=active, P=passive).

---

## Event Types

| `event_type` | Description |
|---|---|
| `Sentence shown` | Trial onset (encoding vs. probe) |
| `IR pressed` | Immediate recognition response |
| `WR pressed` | Wording recognition response |
| `gap_time` | ISI marker |
| `Validation *` | Validation sentences (used in exclusion) |

**For analysis:** Filter to target probe sentences only: `event_type == "Sentence shown"`, `is_target_sentence == TRUE`, `is_probe_repeat == TRUE`.

## Data Quality

**Exclusions:**
- Participants: 2 excluded (271, 299)
- Blocks: 13 failed / 342 total (96.2% pass)
  - Block 1: 108/114 passed | Block 2: 109/114 passed | Block 3: 112/114 passed

**Validation rule:** `correct_val > (wrong_ir / 2) + missed_val` (strict inequality)

---

## Status

Preliminary analysis only — 112 participants collected (334 required for full power).