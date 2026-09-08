# Decision B — DISPOSABLE_SESSION_ARTIFACT is retained and inert in drm-copilot

Timestamp: 2026-09-08T05-47

Task: [P1-T2] of `remediation-plan.2026-09-08T05-00.md`
Finding: R6b (code review F6; policy audit P22)

Decision: RETAIN

## Re-derived ignore state

Command:

```
git check-ignore -v artifacts/pr_context.summary.txt artifacts/pr_context.appendix.txt artifacts/orchestration/orchestrator-state.json
```

EXIT_CODE: 0

Output, verbatim:

```
.gitignore:6:/artifacts	artifacts/pr_context.summary.txt
.gitignore:6:/artifacts	artifacts/pr_context.appendix.txt
.gitignore:6:/artifacts	artifacts/orchestration/orchestrator-state.json
```

All three hard-coded session-artifact paths are ignored by `.gitignore:6`, whose pattern is
`/artifacts`. The classifier reads status without `--ignored`
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:29-33` states the prohibition; `:341` is the
read itself), so an ignored file never becomes a status entry and rung 2 cannot fire in a
drm-copilot worktree.

## Provenance of the 2026-09-06 observation

The three paths were named as observed dirt in the original report. That observation was
produced against the TaskMaster checkout, not against drm-copilot:

- `issue.md:27` records the data source as "the TaskMaster checkout as observed on
  2026-09-06".
- `spec.md:21` repeats the same environment line in the spec's Context block.
- `spec.md:132-134` records the observation in the Repro and Evidence section.

In that checkout the three paths were reported by `git status --porcelain`, so they are not
ignored there. The TaskMaster checkout is not present in this worktree, so this provenance
rests on the issue's own run record rather than on a re-execution. No claim is made here
that the observation was re-run; what was re-run is the drm-copilot ignore state above.

## Decision and mechanism

The verdict is retained. It is not dead code and is not removed.

**How it is reachable:** through the inspected checkout's own `.gitignore`, with no change
to the status read. The tool is repository-agnostic; in a consumer checkout that does not
ignore `artifacts/`, the paths appear as status entries and rung 2 fires. Delivery to such
a checkout is by the extension push-down of `claude-customizations`, recorded in the
`## Rollout & Follow-up` step of `spec.md` that begins "Consumer checkouts pick the change
up through the normal extension push-down of", so the rung is live exactly where the tool
is used.

**What that costs elsewhere:** nothing, because `--ignored` is not added.

## The prohibition on `--ignored`

Adding `--ignored` to the status read is prohibited. It would pull every ignored build
output into the classified set and, for any entry matching a disposable rung, into the
cleared set. The prohibition is already stated at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:29-33` and is reinforced by a new test in
Phase 7 asserting that no status read the library issues carries `--ignored`, with a
positive control so the assertion cannot pass vacuously.

## Coverage consequence

Retaining the rung is coverage-neutral.

`dirt_is_session_artifact` at `scripts/bash/cleanup_worktrees_dirt_lib.sh:126-129` and its
emission site at `:244-245` are already exercised by the `dirt_session_artifact` scenario,
and neither appears in the 29-entry uncovered set recorded in
`evidence/remediation-baseline/shell-qc-test-coverage.2026-09-08T05-30.md`.

Lines 74-77 are reported uncovered because they are the interior of the multi-line
`CLEANUP_WT_SESSION_ARTIFACT_PATHS=(` array assignment, whose statement kcov attributes to
its closing line 78 — and 78 is not in the uncovered set. That is an instrumentation
property, the same one that reports lines 95, 148, 151 and 305 uncovered while the
statements they open do execute. It is unrelated to this decision, and removing the rung
would not close those four lines: the array literal would go away with the rung, but so
would its already-covered matcher and emission site, leaving the file's covered-line count
lower rather than higher.

## Work items this decision entails

1. A `SKILL.md` sentence in the `DIRTFILE|` bullet of `## Report Line Contract` recording
   the retention, the inertness, and the prohibition (plan tasks P7-T2 and P7-T3).
2. A new acceptance criterion in `spec.md`, AC-44 (plan task P1-T6).
3. A test asserting no status read carries `--ignored`, with `status --porcelain` in the
   argv log as the positive control (plan task P7-T5).

No code change is made.
