# Follow-ups (P4-T9)

Timestamp: 2026-10-01T23:59:30-04:00

Three deferred items, recorded and not part of this change:

1. Newline truncation in `.claude/lib/bash/compute-cohorts.sh` through `pcoh_split_words` in `.claude/lib/bash/parallel-cohorts.sh`. That helper has its own Python authority and parity suite (`tests/shell/parallel_cohorts_parity.bats`) and is not edited here.
2. Python-only whitespace characters in `--edges` (`\x1c` to `\x1f`, `\x85`, `\xa0`, other Unicode spaces), to be fixed or declared as a divergence class later. After this fix the two lanes still differ on those characters.
3. The completed #599 spec, `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/spec.md`, is not edited by this change.
