# Evidence-Location Validation

Timestamp: 2026-08-08T20-10

Command: `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

EXIT_CODE: 0

Output Summary:
- Finding count: **0**. The validator produced no output and exited 0, so no artifact resolves to a
  non-canonical evidence location anywhere in the repository.
- Total artifact count under the feature's canonical evidence root
  (`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/`): **53**.

The command was run twice: once at task time and once at end state after the last three `other/`
artifacts were written. Both runs exited 0 with zero findings. The counts below are the end-state
counts.

Per-kind breakdown of that root:

| Evidence kind | Artifacts | Of which written by this cycle |
| --- | --- | --- |
| `baseline/` | 7 | 0 (original cycle only) |
| `other/` | 13 | 8 |
| `qa-gates/` | 13 | 9 |
| `regression-testing/` | 8 | 6 |
| `remediation-baseline/` | 12 | 12 |
| **Total** | **53** | **35** |

Every kind is a canonical sub-path under
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. The 35 artifacts this remediation cycle
produced use exactly the four kinds the plan authorizes — `remediation-baseline/`,
`regression-testing/`, `qa-gates/`, and `other/`. The 18 artifacts from the original cycle are
unchanged except for `qa-gates/coverage-delta.2026-08-08T17-58.md`, which `[P5-T1]` corrected in place
as the plan directs.

**No artifact of this cycle resolves under `artifacts/`.** No non-canonical evidence path was supplied
by the caller, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies to this cycle. The only paths
this cycle wrote under `artifacts/` are the coverage build outputs that the test toolchain itself emits
(`artifacts/python/lcov.info` and the `.coverage` data file), which are gitignored build artifacts
rather than evidence.
