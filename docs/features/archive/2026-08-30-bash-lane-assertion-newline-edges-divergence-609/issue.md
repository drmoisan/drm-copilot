# Bug: bash-lane-assertion-newline-edges-divergence

- Issue: #609
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/609
- Type: bug
- Work Mode: full-bug

## Summary
The bash lane-assertion `--edges` parser silently discards every token after the first newline, which diverges from the Python authority and is not declared in the feature's own exhaustive divergence list. Follow-up to #599, finding R-1 of `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/remediation-inputs.2026-08-30T17-17.md`.

## Environment
- OS/version: Windows 11 Pro 10.0.26200; bash lane executed under the repository shell toolchain
- Python version: repository Poetry environment (Python authority lane)
- Command/flags used: `--edges` with a value containing an embedded newline, against both the bash and Python lane-assertion entry points
- Data source or fixture: `tests/fixtures/parallel_manifest_payload/parallel.md`

## Steps to Reproduce
1. Run the bash lane against `tests/fixtures/parallel_manifest_payload/parallel.md` with `--edges 999:998\n101:202'`.
2. Run the Python authority (`scripts/dev_tools/parallel_lane_assertion.py`) against the same manifest with the same `--edges` value.
3. Compare the reported derived conflict component counts.

## Expected Behavior
Both lanes tokenize the `--edges` value identically, or the difference is declared as a numbered divergence class in `spec.md` and pinned by a test. `spec.md:328-366` presents the divergence set as exhaustive, and `spec.md:484-485` states that without such a declaration a deliberate behavior difference "would be indistinguishable from a porting defect."

## Actual Behavior
The two lanes disagree, and the difference is undeclared and untested:

```
--edges 999:998\n101:202'
  bash   -> Lane assertion: 2 derived conflict component(s); 0 disagreement(s).
  python -> Lane assertion: 1 derived conflict component(s); 0 disagreement(s).
```

The class-3 whitespace justification at `spec.md:352-358` is factually incomplete: it holds for space and tab, not for newline. Neither parity lane nor the unit suite covers the newline input in any direction.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: see the two-lane reproduction output under **Actual Behavior**.

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Severity Major. This does not block merge of `feature/remove-remaining-python-invocations-599-r2` on its own: the defect is in documentation completeness and test coverage, not in a shipped capability, and the diagnostic is advisory-only. None of the 33 acceptance criteria on that branch fail.

Bounding context (do not over-scope):

- The diagnostic is advisory-only, always exits 0, feeds nothing, and never influences scheduling.
- Both documented invocation forms - `parallel-plan/SKILL.md:321` and `parallel-planner.md:189` - pass single-line, space-separated strings.
- Pre-existing precedent: `.claude/lib/bash/compute-cohorts.sh` with `--keys "101 202 303" --edges 101:202\n202:303'` yields `[[101,303],[202]]`, not a valid partition.
- This feature does not introduce a regression.

## Source
From: docs/features/potential/2026-08-30-bash-lane-assertion-newline-edges-divergence.md (record not present on `origin/main` at 43c9e95e; this file mirrors the GitHub issue #609 body, which has no comments as of 2026-09-29).
