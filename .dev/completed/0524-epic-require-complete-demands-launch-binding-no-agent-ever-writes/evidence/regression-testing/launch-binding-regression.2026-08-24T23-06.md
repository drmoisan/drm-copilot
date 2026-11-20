# Launch-Binding Regression — Consolidated Before/After Record [P5-T3]

Timestamp: 2026-08-24T23-06

Task: [P5-T3]
Issue: #524
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)

This artifact consolidates the four per-run records into the single before/after comparison required
by the regression acceptance criterion in `spec.md`.

## Comparison Table

| Checkpoint fixture | Measure | Before the change | After the change |
| --- | --- | --- | --- |
| Four-feature, no launch paths | EXIT_CODE | 1 | 0 |
| Four-feature, no launch paths | Launch-binding errors | 20 | 0 |
| Four-feature, no launch paths | Total errors | 20 | 0 |
| One-unmerged variant | EXIT_CODE | 1 | 1 |
| One-unmerged variant | Launch-binding errors | 20 | 0 |
| One-unmerged variant | Completion errors (`merge_status is not merged/worktree_removed`) | 1 | 1 |
| One-unmerged variant | Total errors | 21 | 1 |

The one-unmerged variant records **exactly 1 completion error in both the before run and the after
run**. That invariance is the discrimination guarantee: the correction removed the Codex-only
launch-binding requirement without weakening the completion gate.

## Cited Per-Run Artifacts

| Task | Run | Artifact path |
| --- | --- | --- |
| [P1-T3] | Before, no launch paths | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/before-no-launch-paths.2026-08-24T22-31.md` |
| [P1-T4] | Before, one unmerged | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/before-one-unmerged.2026-08-24T22-32.md` |
| [P5-T1] | After, no launch paths | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/after-no-launch-paths.2026-08-24T23-04.md` |
| [P5-T2] | After, one unmerged | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/after-one-unmerged.2026-08-24T23-05.md` |

## Fixtures

| Fixture | Path |
| --- | --- |
| Four-feature, no launch paths | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json` |
| One-unmerged variant | `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json` |

Both fixtures model the Claude-shape epic checkpoint that reproduced the destination failure: four
features `child-a` through `child-d` with `issue_num` 101 through 104, all in `wave_number` 0, all
with empty `depends_on`, a top-level `epic_merge_pr.merge_commit_sha` that is a non-empty string,
and none of the four launch-evidence keys present. The one-unmerged variant differs only in
`child-d`'s `merge_status`.

## Command Used for Every Run

```
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state <fixture-path> --require-complete
```

The command is identical across all four runs; only the fixture path and the state of the
production code differ.

## Unit-Level Corroboration

The fixture-level result above is corroborated at unit level by the tests added in Phases 2 and 4
and by the preserved-test runs recorded in
`docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`
and
`docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`.

- `test_require_complete_skips_feature_without_launch_paths` (Python) and
  `skips launch binding for a feature with no launch paths under requireComplete` (Jest) pin the
  skip.
- `test_require_complete_rejects_partial_launch_binding` (Python) and
  `rejects a partial launch binding under requireComplete` (Jest) pin the either-key semantics, so
  the fix cannot be mistaken for a deletion of the gate.
