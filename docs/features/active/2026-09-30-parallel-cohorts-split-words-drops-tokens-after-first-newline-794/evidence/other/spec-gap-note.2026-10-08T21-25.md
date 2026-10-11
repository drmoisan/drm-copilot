# Spec gap note (P2-T4)

Timestamp: 2026-10-09T07-09

The spec's scope statement that a fix inside `pcoh_split_words` covers every call site is incomplete.

Source locations:
- `.claude/lib/bash/parallel-cohorts.sh` lines 145 and 149 (original line numbers of the two `pc_contains_word` calls on the raw `$keys` string in `pcoh_build_adjacency`).
- `.claude/lib/bash/parallel-common.sh` lines 223-230 (`pc_contains_word`, which matches the pattern space, word, space).

Evidence:
- `repro-before-combined.2026-10-08T21-25.md` (P1-T5): multi-line --keys with multi-line --edges exits 1 with a false "not a member of item_keys" error.
- `repro-companion-needed-b.2026-10-08T21-25.md` (P2-T2 observation b): after the `pcoh_split_words` fix alone the same call still exits 1 with `Conflict edge (1, 2) names item key 1`.
- `repro-companion-needed-a.2026-10-08T21-25.md` (P2-T2 observation a): multi-line --keys alone works after the tokenizer fix.

Companion fix: P2-T3 rebuilds the membership haystack from the split tokens in `pcoh_build_adjacency`. After it, the same call exits 0 with `[[2],[1,3]]` (repro-after-combined).

The orchestrator accepted this companion fix and this note (accepted by the orchestrator).
