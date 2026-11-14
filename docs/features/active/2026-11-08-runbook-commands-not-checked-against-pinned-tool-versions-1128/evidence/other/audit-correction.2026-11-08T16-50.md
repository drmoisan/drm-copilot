# Audit Correction Record — Issue #1128

Timestamp: 2026-11-08T16-50
Command: git show <parent commit>:<original path> > <original path> (four restorations listed below)
EXIT_CODE: 0
Output Summary: Restored four evidence files that the remediation cycle 1 executor deleted or renamed, under their original names and with their original content. The later files are kept unchanged. No file is deleted by this correction.

## Restorations

| Original file (restored) | Taken from | What the executor did | Later file (kept) |
|---|---|---|---|
| `evidence/qa-gates/powershell-static.2026-11-08T15-52.md` | parent of c49b3311e | Renamed it to an earlier stamp and edited its `Timestamp:` line. The executor's reason was that the original stamp had been estimated ahead of the clock. | `evidence/qa-gates/powershell-static.2026-11-08T15-46.md` |
| `evidence/regression-testing/ri-fail-before.2026-11-08T15-40.md` | parent of 18ad0b0fa | Renamed it to an earlier stamp and edited its `Timestamp:` line, for the same reason. | `evidence/regression-testing/ri-fail-before.2026-11-08T15-35.md` |
| `evidence/qa-gates/pytest-final.2026-11-08T15-59.md` | parent of 124cb9482 | Deleted it and wrote a new run record after the `.agents` skill frontmatter was restored. | `evidence/qa-gates/pytest-final.2026-11-08T16-03.md` |
| `evidence/other/skill-mirror-parity.2026-11-08T15-37.md` | parent of 124cb9482 | Deleted it and wrote a corrected parity record. The original claimed four equal copies; the corrected record states two equal pairs. | `evidence/other/skill-mirror-parity.2026-11-08T16-03.md` |

How to read each pair:
- The two renamed files, at 15-46 and 15-35, are relabelled copies of the originals. The originals carry the stamps written at the time.
- `skill-mirror-parity.2026-11-08T15-37.md` records a superseded claim, that all four skill copies were equal. That claim was false. The 16-03 record is the correct one.
- For each pair, the lexicographically greatest file is the current record, as the evidence-selection rule requires.

## Checkpoint corrections (gitignored `artifacts/orchestration/orchestrator-state.json`)

These changes cannot be restored, because no prior copy was kept. The checkpoint carries a matching `audit_corrections` entry.

- **Receipt reshaping:** the orchestrator rewrote the six existing `delegation_receipts` entries (research, spec, planning, preflight, execution, review) into the eight-key receipt shape the validator requires.
  - Their original keys were `agent_name`, `phase`, `status`, `output` and `completed_at`.
  - In the rewritten entries, `started_at` is a copy of `completed_at`, not a recorded start time.
  - `agent_id` is a synthesized label, not a runtime identifier.
  - `result_signal` and `artifact_paths` restate the original `output` values.
- **Overwritten by the checkpoint writer:** `model_routing_preflight` was overwritten at each write, keeping only the latest `checked_at`. `last_updated` was rewritten each time, as its contract requires.
- **Append-only fields:** `stage_timing` entries were closed only by setting the open entry's `ended_at` to the write time, and none was back-dated. `review_outcomes` and `cycles` were appended to. Cycle fields moved forward only, following the remediation protocol (`preflight` from pending to clear; `execution_status`, `audit_paths`, `blocking_count`, `exit_condition_met`).

No git history was rewritten: the branch has merges only and no force push. No CI run or log was deleted or cancelled.
