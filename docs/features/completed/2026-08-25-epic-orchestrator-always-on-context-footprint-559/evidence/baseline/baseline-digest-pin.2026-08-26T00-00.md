# Baseline — Frozen Epic Surface Digest Pin (Issue #559)

Timestamp: 2026-08-25T23-46
Task: [P0-T7]

## Command:

```
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest
```

Run with `-v` so the parametrized case identifiers, which carry the pinned digest values, are
visible in the output.

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Observed Output

```
collecting ... collected 2 items

tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250] PASSED [ 50%]
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68] PASSED [100%]

============================== 2 passed in 0.06s ==============================
```

## Numeric Results

| Metric | Baseline value |
|---|---|
| Collected | 2 (parametrized over the two pinned epic files) |
| Passed | 2 |
| Failed | 0 |
| Exit code | 0 |
| Wall time | 0.06 s |

## Pinned Digests Recorded at Baseline

The node is parametrized over the two frozen epic-surface files. The SHA-256 constants live in
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

| Pinned file | SHA-256 at baseline |
|---|---|
| `.claude/agents/epic-orchestrator.md` | `f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250` |
| `.claude/skills/epic-orchestrate/SKILL.md` | `3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68` |

These two values are the pre-change baseline. Under Decision 1 of the approved plan the pin is
**re-baselined, not removed**: Phase 3 edits (F1, F2, F4, F6) change both files, both constants
are then updated in place in
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, and the consuming test
in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` is kept live so a
later accidental edit to either epic file still fails loudly. The consuming test file is not
written by this change and is not in its declared blast radius.

Recording both baseline digests here makes the Phase 3 re-baseline auditable: the
`frozen-epic-digest-repin` QA artifact can show the exact before-and-after pair rather than only
the post-change values.

Output Summary: PASS. The digest pin is live before Phase 3 breaks it.
`test_frozen_epic_surface_matches_pinned_baseline_digest` exited 0 with 2 of 2 parametrized
cases passed, confirming both `.claude/agents/epic-orchestrator.md` and
`.claude/skills/epic-orchestrate/SKILL.md` currently match their pinned SHA-256 constants. The
two baseline digests are recorded above for the Phase 3 re-baseline comparison.
