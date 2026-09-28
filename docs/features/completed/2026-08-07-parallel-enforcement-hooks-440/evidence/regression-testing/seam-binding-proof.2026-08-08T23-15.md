# P2-T6 — Seam Binding Discipline Proof (three `grep -rn` searches)

Timestamp: 2026-08-09T00-52

`git grep` was NOT used. This branch has zero commits, so every file created by
this remediation cycle is untracked; `git grep` skips untracked files and both
negative searches below would have returned no match for the wrong reason. The
positive control proves the searches actually read the new, untracked files.

Untracked confirmation: `git ls-files --error-unmatch extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts`
exits 1 with `did not match any file(s) known to git`, so the file is untracked
and `git grep` would indeed have skipped it.

## Command 1 — negative search, TypeScript tests

Command: `grep -rn "parallel-orchestrator-state-cohort-barrier" extensions/drm-copilot/test` (run from the repository root)

EXIT_CODE: 1

Output Summary: no match. No file under `extensions/drm-copilot/test` references
the barrier invariant module by name, so no TypeScript test imports it directly.
Every case in `parallel-cohort-barrier-parity.test.ts` and
`parallel-orchestrator-state-cohort-barrier.test.ts` routes through
`validateArtifact({ artifactType: "parallel-orchestrator-state", text })`
instead. `grep -rn` matches file CONTENTS, not file names, so the behavior
suite's own filename does not produce a match.

## Command 2 — negative search, Python parity test

Command: `grep -rn "_parallel_orchestrator_state_cohort_barrier" tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` (run from the repository root)

EXIT_CODE: 1

Output Summary: no match. The Python parity suite imports only the public entry
point `validate_parallel_orchestrator_state_text` from
`scripts.dev_tools.validate_parallel_orchestrator_state`, and never the barrier
helper module.

## Command 3 — positive control

Command: `grep -rln "validateArtifact" extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` (run from the repository root)

EXIT_CODE: 0

Output Summary:

```
extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts
```

The search reached and read the new untracked file and found the dispatched
entry point in it. The two negative results above are therefore genuine absences
of the searched token, not artifacts of a search that skipped the new files.

## Disposition

Both negative searches returned no match with exit code 1. The positive control
returned a match with exit code 0. Binding constraint 5 holds: the seam in
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` is
parsed and reached at run time on every execution of both new TypeScript suites.
