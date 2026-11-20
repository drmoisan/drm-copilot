# Fail-Before Exception Dossier (P1-T5)

Timestamp: 2026-08-25T23-46

Filename-stamp substitution: the plan fixes the evidence filename suffix at
`.2026-08-24T13-10.md`. This execution ran on 2026-08-25 at 23:46, so the executor
substituted its own `yyyy-MM-ddTHH-mm` stamp `2026-08-25T23-46` into that position,
as the plan's "Evidence filename timestamps" clause directs. The path prefix and the
base name `fail-before-exception` — the preferred name prefix defined by
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — are unchanged.

## Scope of this dossier

Phase 1 of the plan produces genuine failing runs for the two defects where a failing
run is structurally possible, recorded in:

- `fail-before-push-order.2026-08-25T23-46.md` (tag push order, supports AC4)
- `fail-before-workflow-invariants.2026-08-25T23-46.md` (`publish-mcp-npm.yml`
  trigger set and publish-step guard, supports AC13 and AC14)

This dossier covers the remaining criteria for which a genuine failing run is
structurally impossible: **AC18**, **AC25**, **AC27**, and **AC28**, plus the Phase 0
read-only probes. For each, it records why no failing run can exist and what proof
stands in its place.

## Negative-claim fields

SearchScope:

- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/regression-testing/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/other/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/baseline/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/issue-updates/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/` searched
  recursively, to cover the feature root as well as the kind-specific subdirectories.

Version-scope note: this feature is single-version. A recursive listing of the feature
folder returns exactly three subdirectories — `evidence/`, `research/`, and `runbooks/` —
and no `v1/`, `v2/`, or any other version directory, so the current-version scope and the
feature root are the same location and no version-scoped fallback search applies. There is
no enclosing epic folder for this feature, so no epic-rollup scope was searched.

SearchPatterns:

- `fail-before-exception.*.md` (the preferred name prefix)
- `fail-before-exception*` (recursive, extension-agnostic, to catch a differently
  suffixed variant)
- Directory listings of `evidence/` and of every kind-specific subdirectory present.

SearchResult: none. Before this task ran, no `fail-before-exception` artifact existed
anywhere under the feature folder. The only artifacts present under
`evidence/regression-testing/` were the two genuine failing-run records written by P1-T2
and P1-T4 in this same phase. The `evidence/qa-gates/`, `evidence/issue-updates/`, and
`evidence/remediation-baseline/` subdirectories do not yet exist; `evidence/baseline/` and
`evidence/other/` hold only the Phase 0 artifacts, none of which matches the patterns above.
This file is therefore the first exception dossier for this feature.

---

## AC18 — green branch-head run of `publish-mcp-npm.yml` with a `skipped` publish step

Criterion text: a green run of `publish-mcp-npm.yml` against the branch head exists,
produced by the new `pull_request` trigger, and the run's publish-step conclusion is
`skipped`.

WhyFailingRunImpossible: the run this criterion asserts cannot be made to fail, because
it cannot be made to exist. `.github/workflows/publish-mcp-npm.yml` currently declares
only `push` (tags `mcp-server-v*`) and `workflow_dispatch` triggers — confirmed by the
P1-T4 failing test `declares a pull_request trigger scoped to the mcp-server package and
the workflow file`, whose message quotes the entire unmodified trigger block. No trigger
in that set fires on a branch head, so GitHub Actions produces no branch-head run to
observe, whether passing or failing. The `pull_request` trigger that would create one is
added by P4-T1, which is a later phase. Producing the run additionally requires a branch
push and an open pull request, both of which this plan's hard prohibitions forbid to the
executor, and neither of which any Phase 1 task performs.

Alternative proof:

- The absence of the trigger is proved positively rather than asserted: the P1-T4 test
  named above fails against the unmodified workflow with the trigger block quoted
  verbatim in its failure message, recorded in
  `fail-before-workflow-invariants.2026-08-25T23-46.md`.
- The criterion is carried forward rather than dropped. The plan assigns P7-T12 to record
  the deferral in
  `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.<stamp>.md`
  with a `DEFERRED_TO: pr-author` line, a per-workflow section for each workflow file,
  and the exact read-only invocation the deferral owner runs once the pull request exists.
- The AC18 checkbox in `spec.md` stays unchecked until an observed green run with a
  `skipped` publish-step conclusion is recorded. Phase 1 checks off no acceptance
  criterion at all.

## AC25 — `run-actionlint.ps1` exits 0 against the changed and added workflow files

Criterion text: `scripts/dev-tools/run-actionlint.ps1` completes with exit code 0 against
the changed and added workflow files.

WhyFailingRunImpossible: this criterion asserts the continued absence of a defect, not
the correction of one. Phase 0 task P0-T6 already ran
`pwsh ./scripts/dev-tools/run-actionlint.ps1` against the unmodified tree and recorded
`EXIT_CODE: 0` in `evidence/baseline/actionlint-baseline.2026-08-25T23-33.md`. A
fail-before run would require actionlint to fail before the change, which it does not, and
the only way to manufacture such a failure would be to commit deliberately invalid
workflow YAML — a defect introduced solely to be removed. A criterion whose pre-change
state is already green has no failing prior state to record.

Alternative proof:

- Baseline-establishes-attribution proof: the P0-T6 artifact records a green actionlint
  run against the unmodified tree, so any non-zero actionlint result observed later in
  this execution is attributable to this change and to nothing pre-existing. That
  attribution is what the fail-before evidence would otherwise have supplied.
- The criterion is verified forward, not backward: P4-T6, P5-T6, and P7-T5 each re-run
  the same command after the workflow edits land and record the exit code. AC25 is
  satisfied by those pass-after records against the P0-T6 baseline.
- Phase 1 modifies no workflow file, so the actionlint result is unchanged by this phase.

## AC27 — operator runbook at `docs/engineering/missed-npm-publish.runbook.md`

Criterion text: an operator runbook exists documenting, for each state in the failure-state
table, the corresponding recovery; the two preconditions that must both hold before any tag
delete-and-re-push is considered; and the statement that the disposition of an
already-consumed version number is a human decision.

WhyFailingRunImpossible: the criterion is documentation-only. Its subject,
`docs/engineering/missed-npm-publish.runbook.md`, does not exist in the tracked tree and is
created by P6-T1. No executable behaviour is asserted, so there is no test that can be run
against the current state and observed to fail. A test asserting the file's absence would
pass, not fail, and would assert the opposite of the criterion; a test asserting its
presence would fail only because the file has not been written yet, which records the
scheduling of P6-T1 rather than any defect in the production surface. Neither is
fail-before evidence in the sense the convention intends.

Alternative proof:

- Absence-of-artifact proof: `docs/engineering/missed-npm-publish.runbook.md` is absent
  from the tracked tree at the Phase 1 commit. The plan's
  "Literals This Plan Instructs the Executor to Create" section lists the file path and
  the three section headings among the literals that do not yet exist, which is the
  authoring-side record of that absence.
- The criterion is verified by enumeration rather than by a failing run: P6-T2 records the
  line number at which each of the six state tokens and each of the three heading literals
  appears in the created runbook, in
  `evidence/qa-gates/runbook-state-coverage.<stamp>.md`. A missing item cannot be
  enumerated with a line number, so the enumeration is capable of failing and is the gate
  that carries AC27.

## AC28 — scope boundary: no `README.md` line modified, no `quality-tiers.yml` added

Criterion text: the diff modifies no line of `README.md` (owned by issue #528) and adds no
`quality-tiers.yml`, confirming both remain out of scope.

WhyFailingRunImpossible: this is a scope-boundary assertion over the change's own diff, so
it has no pre-change state at all. Before the change there is no diff, hence nothing that
could touch `README.md` or add `quality-tiers.yml`, and the assertion is vacuously true.
Manufacturing a failing prior state would mean deliberately modifying `README.md` in order
to observe the boundary check reject it — an out-of-scope edit made solely to be reverted,
which is precisely what the criterion exists to forbid.

Alternative proof:

- Clean-tree proof for the pre-change state: `git status --porcelain` returned empty
  output at the start of Phase 1, so no file was modified before this phase began and the
  boundary held trivially.
- Phase 1's own diff is inside the boundary: this phase modifies exactly one tracked file
  (`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`) and adds one test file plus
  three evidence artifacts. It touches no line of `README.md` and creates no
  `quality-tiers.yml`. Phase 1 modifies no production file whatsoever.
- The criterion is verified forward by P7-T10, which records the union of
  `git status --porcelain` and `git diff --name-only main...HEAD` and asserts that union
  contains neither `README.md` nor `quality-tiers.yml`. That check is capable of failing,
  because the union is non-empty by the time it runs and either name appearing in it fails
  the task. The porcelain status is included there because a newly added untracked file is
  invisible to a tracked-file diff.

## Phase 0 read-only probes (P0-T7 through P0-T11)

WhyFailingRunImpossible: the five Phase 0 probes are observations of external systems —
the npm registry and the GitHub Actions run history — not assertions about this
repository's production surface. Each records what a read-only query returned together with
a determination line derived from it. A probe has no pre-change failing state, because the
external fact it observes is not changed by this work: the same query returns the same
answer before and after. Manufacturing a failing probe run would require publishing a
version or dispatching a workflow, both of which the plan's hard prohibitions forbid and
neither of which any task performs.

Alternative proof:

- Recorded-observation proof: each probe is recorded as its own artifact under
  `evidence/other/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` —
  `npm-absent-version-probe.2026-08-25T23-33.md`,
  `npm-present-version-probe.2026-08-25T23-33.md`,
  `registry-check-decisiveness.2026-08-25T23-33.md`,
  `gh-run-list-headbranch-probe.2026-08-25T23-33.md`, and
  `gh-publish-step-name-probe.2026-08-25T23-33.md`.
- Discriminating-control proof: the probes are not single observations but paired ones.
  P0-T7 queries a version known absent from the registry and P0-T8 queries a version known
  present; P0-T9 compares the two observed exit codes and emits
  `REGISTRY_CHECK_DECISIVE` accordingly. A check that returned the same result for both
  operands would be recorded as non-decisive and would mark its nine dependent tasks
  INCOMPLETE. That comparison is capable of failing, which is what the probes supply in
  place of a failing run: they establish that the registry check the design rests on can
  itself distinguish the two cases, rather than being a gate that cannot fail.
- Each probe carries exactly one determination line, so its result is decidable from the
  artifact alone without re-running the external query.

---

## Statement of coverage

This dossier covers **AC18**, **AC25**, **AC27**, and **AC28**, plus the Phase 0 read-only
probes. It does not cover, and does not substitute for, the genuine failing runs recorded
for AC4, AC13, and AC14 in `fail-before-push-order.2026-08-25T23-46.md` and
`fail-before-workflow-invariants.2026-08-25T23-46.md`. It checks off no acceptance
criterion: Phase 1 delivers none, and every AC checkbox in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`
remains unchecked at the end of this phase.
