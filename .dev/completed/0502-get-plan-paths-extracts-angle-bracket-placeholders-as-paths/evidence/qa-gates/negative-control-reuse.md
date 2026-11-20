# QA Gate — Negative-Control Reuse — [P5-T7]

Timestamp: 2026-08-23T02-40

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T7]

Command: `git diff --exit-code main -- tests/fixtures/blast_radius/conflict-path-overlap.json`

EXIT_CODE: 0

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

## Result

Exit code 0: the reused negative control is byte-identical to its state on `main`. It was not
edited at any point during execution.

## Why `main` is named explicitly and the bare form is prohibited here

The bare `git diff --exit-code` form compares the worktree against the index only. It therefore
passes vacuously the moment the executor commits, which makes it a check that cannot fail. Comparing
against `main` spans every committed and uncommitted change this branch has made, so the gate stays
falsifiable across the whole execution regardless of commit state.

Recording the resolved SHA is what makes the anchor auditable. `main` is a moving local ref: if it
is fetched forward mid-execution without a rebase, this gate can fail for a change this branch never
made. That direction is fail-closed and therefore safe, but it is only diagnosable when the SHA is
on record.

## The AC-9 reuse rationale, from the plan of record

**Decision: reuse `tests/fixtures/blast_radius/conflict-path-overlap.json` unmodified. Do not create
a new near-duplicate.**

The existing fixture already encodes exactly the required control: two radii whose only shared entry
is a single concrete synthetic path under the Python dev-tools tree, with disjoint modules and
disjoint contracts, and an expected conflict verdict of true carrying a single `path_overlap` reason.
That synthetic path is fixture content, not a repository path, so it is named in prose here rather
than in an inline-code span; inline-coding it would inject a phantom entry into this item's own
derived radius. Its text contains no marker character, so the fix leaves its expected result
byte-identical.

Reuse is stronger than a new fixture, not merely cheaper. A control authored alongside the fix proves
only that the author expected it to pass. A pre-existing fixture that was written before the fix
existed and is committed unmodified proves the fix did not perturb an independently authored
assertion. Adding a near-duplicate would also inflate the parity corpus without adding
discriminating power, since both parity suites already assert this fixture across the radius,
findings, conflict-verdict, and conflict-reason channels.

## What this gate establishes

The real-path conflict channel is unperturbed by the placeholder guard. The guard removes
marker-bearing tokens from the harvest; it does not change how two genuinely shared concrete paths
contend. This fixture is the independent witness of that, and its zero-diff status against `main` is
what makes the witness credible.

This gate is also cited by the [P5-T3] blocker record
(`evidence/other/p5-t3-blocker-conflict-fixture-seam.md`) as one of the four completed observations
that cover the pair-level behaviour that task was reaching for.

## Output Summary

Exit code 0. The reused negative control `tests/fixtures/blast_radius/conflict-path-overlap.json` is
unmodified relative to `main` at `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`, proving the AC-9 reuse
decision holds on disk and that the independently authored real-path conflict assertion was not
touched during execution.
