# Acceptance Criteria Reconciliation (Issue #559)

Timestamp: 2026-08-26T01-12
Tasks: [P6-T12] (reconciliation) and [P6-T14] (follow-ups, recorded under `Follow-ups:` below)
AC source: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`
Work Mode: `full-bug` — `spec.md` is the sole acceptance-criteria source; `user-story.md` carries no
acceptance criteria and is not an AC source under this mode.

## Evidence Schema Classification (Remediation R3, Issue #559)

Timestamp: 2026-08-26T01-11

This artifact is a narrative reconciliation record: it maps acceptance criteria to prior
command-step evidence artifacts and records no command of its own. It therefore carries no
`Command:` or `EXIT_CODE:` field.

Output Summary: 38 acceptance criteria reconciled; 36 checked, 2 left unchecked (spec lines 623
and 644) for the reasons adjudicated below.

Of the 29 evidence artifacts this feature produced, 26 conform to the full four-field schema
(`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`). The remaining three are narrative
or derivation records that record no single command: this artifact,
`evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`, and
`evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`. This paragraph supersedes any
earlier statement in this feature's evidence claiming uniform four-field conformance across all
29 artifacts.

## Checkbox partition — 42 total, 38 acceptance criteria

`spec.md` carries 42 Markdown checkboxes. They partition as follows, and the reconciliation is
conducted on that basis.

| Group | Spec lines | Count | Treatment |
|---|---|---|---|
| Inherited severity markers | 56-59 | 4 | **Excluded — not acceptance criteria** |
| Acceptance criteria | 559-706 | **38** | Reconciled individually below |
| Total | — | 42 | — |

### The four excluded severity markers

Lines 56-59 are the inherited template severity selector, not acceptance criteria. They are a
single-select radio group describing the issue's severity, and checking or unchecking them delivers
nothing:

| Spec line | Marker | State | Note |
|---|---|---|---|
| 56 | `Blocker` | `[ ]` | Not selected |
| 57 | `High` | `[x]` | **Already checked** — the selected severity |
| 58 | `Medium` | `[ ]` | Not selected |
| 59 | `Low` | `[ ]` | Not selected |

Line 57 already carries the checked `High` marker; the other three are correctly unchecked because
the group is single-select. No task in this plan altered any of the four.

## Final tally

| Metric | Value |
|---|---|
| Acceptance criteria total | **38** |
| Checked (delivered and verified) | **36** |
| Unchecked | **2** |
| Unchecked at spec line 644 | Yes — BLOCKED, mandated to remain unchecked |
| Unchecked at spec line 623 | Yes — genuinely unsatisfied; see adjudication below |

**`[P6-T12]` expects exactly one of the 38 to end unchecked. Two do.** This is reported plainly
rather than resolved by forcing the count. The deviation, and the reasoning behind refusing to force
it, is set out in full under "Adjudication of the two criteria a prior phase left unchecked".

## Reconciliation by section

Every criterion below is mapped to the evidence artifact path that supports it, or to its blocking
reason. Evidence paths are relative to
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/`.

### F1 — startup protocol no longer instructs re-reading injected content (3 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 559 | `[x]` | `[P3-T3]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 1) |
| 562 | `[x]` | `[P3-T9]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 2) |
| 565 | `[x]` | `[P3-T9]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 2) |

### F2 — preloaded skill set reduced from six to three (3 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 571 | `[x]` | `[P3-T4]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 7) |
| 573 | `[x]` | `[P3-T4]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 7) |
| 576 | `[x]` | non-write assertion | `evidence/qa-gates/scope-containment.2026-08-26T00-00.md` (operand 6) |

### F3 — all nineteen rules files carry scoped frontmatter (7 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 581 | `[x]` | `[P2-T1]`..`[P2-T5]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 1) |
| 584 | `[x]` | `[P2-T1]`..`[P2-T5]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 2) |
| 587 | `[x]` | `[P2-T4]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 3) |
| 597 | `[x]` | `[P2-T3]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 4) |
| 601 | `[x]` | `[P2-T5]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 5) |
| 603 | `[x]` | `[P2-T7]` | `evidence/other/f3-glob-justification.2026-08-26T00-00.md` |
| 607 | `[x]` | `[P2-T6]` | `evidence/baseline/baseline-rules-frontmatter-inventory.2026-08-26T00-00.md` plus the `[P2-T6]` single-hunk diff inspection |

### F4 — no unqualified section citation remains under `.claude/` (4 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 613 | `[x]` | `[P3-T1]`, `[P3-T2]`, `[P3-T6]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 8) |
| 616 | `[x]` | `[P3-T1]` | `[P3-T19]` two-node run; `evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md` |
| 619 | `[x]` | `[P3-T2]` | `[P3-T19]` two-node run; `evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md` |
| 623 | **`[ ]`** | — | **UNSATISFIED.** See adjudication below. |

### F5 — mechanical half (6 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 629 | `[x]` | `[P4-T2]` | `evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md` |
| 631 | `[x]` | `[P4-T1]` | `evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md` |
| 633 | `[x]` | `[P4-T5]` | `evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md` |
| 635 | `[x]` | `[P4-T3]` | `evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md` |
| 637 | `[x]` | `[P4-T5]` | `evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md` |
| 639 | `[x]` | `[P4-T5]` | `evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md` |

### F5 — decision half (2 criteria, recorded separately)

The heading `### F5 — decision half` carries **two** criteria, not one. They have different
dispositions and are recorded separately, exactly as `[P6-T12]` requires.

| Spec line | State | Disposition | Evidence / blocking reason |
|---|---|---|---|
| **644** | **`[ ]`** | **BLOCKED — DO NOT CHECK** | **Blocked on the reserved human decision.** No coverage floor and no toolchain stage count was selected, inferred, or narrowed by this change. Reasoning recorded without recommendation at `evidence/other/f5-reserved-human-decision.2026-08-26T00-00.md`. Remaining unchecked is the **expected and correct** outcome, not a delivery failure. |
| 652 | `[x]` | **DELIVERED** by `[P4-T7]` | A `human_interaction.requirements[]` entry with `response: "halt"` was recorded in `artifacts/orchestration/orchestrator-state.json` and the checkpoint validates. Per the human-interaction invariants in `.claude/rules/orchestrator-state.md`, a `halt` requirement carries no `runbook_path`. Supporting text at `evidence/other/f5-reserved-human-decision.2026-08-26T00-00.md`. |

### F6 — bounded child return contract (6 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 659 | `[x]` | `[P3-T7]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 3) |
| 662 | `[x]` | `[P3-T7]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 4) |
| 665 | `[x]` | `[P3-T7]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 5) |
| 668 | `[x]` | `[P3-T8]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 6) |
| 670 | `[x]` | `[P3-T10]` | `evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md` (test 7) |
| 672 | `[x]` | `[P3-T5]` | `[P3-T5]` single-node kickoff-discovery run; `evidence/qa-gates/push-down-mirror-parity.2026-08-26T00-00.md` |

Criterion 662 names six required fields; the delivered shape carries eight, adding `branch_name` and
`worktree_path` per Decision 3. A superset satisfies a "names every required field" criterion.

### Cross-cutting (7 criteria)

| Spec line | State | Delivered by | Evidence |
|---|---|---|---|
| 678 | `[x]` | `[P3-T19]` | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 6) |
| **681** | **`[x]`** | `[P2-T8]`..`[P2-T12]`, `[P3-T15]`..`[P3-T17]` | **Adjudicated — see below.** `evidence/qa-gates/push-down-mirror-parity.2026-08-26T00-00.md` plus the direct eight-pair byte comparison recorded below. |
| 686 | `[x]` | `[P3-T11]`..`[P3-T14]` | `evidence/qa-gates/frozen-epic-digest-repin.2026-08-26T00-00.md` |
| 693 | `[x]` | `[P0-T9]`, `[P5-T1]`..`[P5-T3]` | `evidence/baseline/always-on-line-count-before.2026-08-26T00-00.md`, `...-after...`, `...-comparison...` |
| 699 | `[x]` | `[P1-T3]`, `[P1-T4]`, `[P6-T10]`, `[P6-T11]` | All four artifacts under `evidence/regression-testing/` |
| **702** | **`[x]`** | `[P6-T1]`..`[P6-T5]` | **Adjudicated — see below.** Five artifacts under `evidence/qa-gates/` |
| 706 | `[x]` | `[P6-T8]` | `evidence/qa-gates/scope-containment.2026-08-26T00-00.md` |

## Adjudication of the two criteria a prior phase left unchecked

Two criteria were deliberately left unchecked by an earlier phase and are adjudicated here. They are
resolved in **opposite directions**, and the asymmetry is the point: one has a true substantive claim
whose stated verification instrument is broken for an unrelated reason, and the other has a
substantive claim that is simply false.

### Spec line 681 — the eight bundled mirrors — RESOLVED AS SATISFIED, checked

**Criterion.** "Each of the eight files under
`extensions/drm-copilot/resources/claude-customizations/.claude/` listed in 'Files to Change' is
byte-identical to its repository original, verified by
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passing."

**The problem.** The named command exits 1, solely because of the tolerated environmental failure
recorded at `[P6-T4]`.

**Direct verification of the substantive claim.** Rather than rely on the earlier Phase 3 record, all
eight pairs were re-compared byte-for-byte at reconciliation time, with SHA-256 computed from the
working-tree bytes:

```
IDENTICAL crlf=False 5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec .claude/agents/epic-orchestrator.md
IDENTICAL crlf=False d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b .claude/skills/epic-orchestrate/SKILL.md
IDENTICAL crlf=False df0be165f88b09a43fb5ec6e803a0fa336571622b88511cec1b46a2d452e2be1 .claude/skills/orchestrate/SKILL.md
IDENTICAL crlf=False 20d0e12ba4916b8a5383236b40b835ed4531031617e7c5995a748ceac6acafa0 .claude/rules/parallel-orchestration.md
IDENTICAL crlf=False 888138b265d5e4b83622a3e71b8c1bc11e66d7061d7d6ed8e03b700e4b2b3b2a .claude/rules/plan-acceptance-gates.md
IDENTICAL crlf=False 08a82f2f710fddde7e6ea42b39c1f3911a462c58efd47e384bf3e0cb7c67da12 .claude/rules/orchestrator-state.md
IDENTICAL crlf=False f64cecee524bfa122c1bc624a04a16bc2845b30e34e9d2e02f8db90dd8716918 .claude/rules/ci-workflows.md
IDENTICAL crlf=False c3d711744e7d9334cbaa2ef9e057865fd65913a6b3067193e4fa36b104256a6a .claude/rules/benchmark-baselines.md
MISMATCHES=0
```

All eight pairs are byte-identical and all eight originals are LF-only, so no line-ending flip
occurred. The first two digests were additionally cross-checked against the pinned constants at
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` lines 126 and 130 and match
exactly, confirming the re-baselined pin is live and consistent rather than stale.

**Why the command's failure does not bear on this criterion.** The single failing assertion names
`.claude/state/python-batch-budget.default.json`. That path:

1. is **not one of the eight files** the criterion is about;
2. is not a bundled-payload file at all;
3. is gitignored (`.gitignore:68`, `.claude/state/`) and untracked;
4. is machine-local, written by this repository's own `Write|Edit` PreToolUse hook
   `.claude/hooks/enforce-python-batch-budget.ps1`;
5. did not exist during Phase 0, when the same command **passed** — which demonstrates directly that
   the command exits 0 in an environment without the local hook artifact, such as a CI runner where
   Claude Code PreToolUse hooks do not run.

**Decision: SATISFIED, checked.** The substantive claim is true and was verified by a strictly
stronger method than the one the criterion names — direct byte comparison plus SHA-256 over all
eight pairs, rather than a test that asserts the same thing. The named instrument's failure is
provably disjoint from the criterion's subject matter. Checking it does not paper over a defect; the
defect is real, is recorded, is out of scope, and appears as follow-up 6 below.

### Spec line 623 — path-like token resolution — REMAINS UNCHECKED

**Criterion.** "Every path-like token in `.claude/agents/epic-orchestrator.md` and
`.claude/skills/epic-orchestrate/SKILL.md` that is not a template placeholder resolves to an existing
file in the repository."

**Direct verification.** Inline-code tokens were extracted from both files and each was classified
and tested for resolution. Of the tokens carrying a path separator: 14 resolve, 8 are template
placeholders (excluded by the criterion's own clause), and **one does not resolve**:

```
UNRESOLVED   artifacts/orchestration/epic-orchestrator-state.json
             cited_in=['.claude/agents/epic-orchestrator.md', '.claude/skills/epic-orchestrate/SKILL.md']
```

The 8 excluded placeholders are `docs/features/active/<basename>`,
`docs/features/completed/<basename>`, `docs/features/epics/<epic-slug>/epic-kickoff.md`,
`docs/features/epics/<epic-slug>/epic-status.md`, `docs/features/epics/<epic-slug>/epic.md`,
`epic/<epic-slug>-integration`, `origin/<integration_branch>`, and
`remediation-inputs.<timestamp>.md`.

**Facts about the one unresolved token.**

| Property | Finding |
|---|---|
| Is it a template placeholder? | **No.** It contains no placeholder marker; it is a concrete literal path. |
| Does the file exist? | **No.** `artifacts/orchestration/` exists and contains `orchestrator-state.json`, but not `epic-orchestrator-state.json`. |
| Is the path gitignored? | **Yes** — `.gitignore:6`, `/artifacts`. It can never be a committed repository file. |
| Introduced by this change? | **No.** It is present in the pre-change file at merge base `b36179b2` (3 matching lines in the agent file alone). |
| Is the citation *correct*? | **Yes.** It names the canonical location the epic orchestrator writes its checkpoint to at run time. |

**Decision: REMAINS UNCHECKED.** The criterion as written is false. The token is path-like, it is
not a template placeholder, and it does not resolve to an existing file. The criterion grants exactly
one exclusion — template placeholders — and this token is not covered by it.

There is a tempting reading under which a gitignored runtime-artifact path is outside the criterion's
intended scope, on the grounds that a run-state checkpoint is not repository content and could never
resolve by construction. That reading may well match the author's intent. **It is nonetheless
declined**, because adopting it would silently widen the criterion's single explicit exclusion clause
at check-off time rather than at authoring time. Checking a criterion by reinterpreting its exclusion
is the failure mode that acceptance-criteria tracking exists to prevent, and it would make the
checkbox a weaker signal for every future reader.

The honest disposition is: the citation is **correct and pre-existing**, the criterion is **too
strict as written**, and the correct remedy is to amend the criterion — which is an authoring action
outside this executor's mandate — not to check it.

**Consequence, stated plainly.** This leaves **two** of the 38 criteria unchecked (lines 623 and
644), where `[P6-T12]` expects exactly one. The count is **not** forced to one. Forcing it would
require either checking 623 on a basis this artifact has just rejected, or touching line 644, which
must remain unchecked at delivery. The deviation is reported rather than concealed, and it is
recorded as follow-up 7 below.

### Spec line 702 — toolchain single pass — checked, with the tolerated failure disclosed

Recorded here because it is the other criterion whose check-off depends on the tolerated failure.

The QA loop completed in **one iteration with zero restarts**: `black --check` exit 0, `ruff check`
exit 0 with zero diagnostics, `pyright` exit 0 with 0 errors and 0 warnings, and
`generate_codex_agent_variants --check` exit 0. `pytest` exited **1**, for the single tolerated
out-of-scope failure named at `[P6-T4]` and analysed under line 681 above; no failure is attributable
to this change. PoshQC is correctly not run because no PowerShell file was added or edited, which the
criterion's own conditional clause ("PoshQC additionally if a PowerShell file was added or edited")
provides for. Gate output for all five stages is recorded under `evidence/qa-gates/`.

The criterion is checked on that basis, with the non-zero pytest exit code disclosed here rather than
elided, so a reviewer can reach a different conclusion on full information.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md
- Total AC items: 38
- Checked off (delivered): 36
- Remaining (unchecked): 2
- Items remaining:
  1. [spec line 644] BLOCKED — DO NOT CHECK. Human selection of the authoritative coverage floor and
     toolchain stage count. Reserved human decision; mandated to remain unchecked at delivery. This
     is the expected and correct outcome.
  2. [spec line 623] Every path-like token in the two epic files that is not a template placeholder
     resolves to an existing file. Unsatisfied: `artifacts/orchestration/epic-orchestrator-state.json`
     is a non-placeholder, gitignored, runtime-generated checkpoint path that does not resolve. The
     citation is correct and pre-existing; the criterion is too strict as written.
```

---

## Follow-ups:

Task: [P6-T14]

Six follow-ups are recorded below, plus the count deviation from `[P6-T12]` as a seventh entry.
**None is acted on by this change.** Each is recorded as an observation for a future issue.

### 1. Regenerate the `.agents/` converted copies and mirror them

The `.claude/` originals changed by this issue have converted counterparts under `.agents/` and a
bundled mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. Neither was
regenerated. `[P6-T8]` asserts both paths are untouched (exit code 0), so the staleness is deliberate
and recorded, not accidental. **Not acted on.**

### 2. Add a converter-parity test so `.claude/` to `.agents/` staleness fails loudly

Follow-up 1 was possible only because nothing enforces the relationship. The `.claude/` to
`extensions/drm-copilot/resources/claude-customizations/.claude/` mirror is guarded by a byte-identity
test, but the `.claude/` to `.agents/` conversion has no equivalent guard, so drift is silent. A
converter-parity test would make it fail loudly. **Not acted on.**

### 3. Reconcile the stale embedded rule copies in `AGENTS.md`

`AGENTS.md` embeds copies of rule content that have diverged from `.claude/rules/`. This is
**blocked on the same reserved human decision as F5**: reconciling the embedded copies would require
selecting an authoritative coverage floor and toolchain stage count, which this change must not do.
`[P4-T5]` and `[P6-T8]` both assert `AGENTS.md` is unmodified. **Not acted on, and blocked.**

### 4. Scope the six other skills carrying the same `## Prerequisites` re-read defect

`[P3-T9]` removed the `## Prerequisites` re-read block from
`.claude/skills/epic-orchestrate/SKILL.md`. Six other skills carry the same defect — a block
instructing the agent to re-read content the runtime already injects. They were deliberately left
out of scope to keep this change's blast radius bounded. **Not acted on.**

### 5. Possible split of `.claude/rules/parallel-orchestration.md`

That file now carries two distinct concerns: the parallel-artifact schema invariants and the
blast-radius contention doctrine. The `paths:` frontmatter added by `[P2-T5]` has to cover both,
which is why its glob list is the longest of the five. Splitting it into a schema rule and a
blast-radius rule would let each carry a tighter `paths:` scope and reduce always-on context further.
This is a design question, not a defect. **Not acted on.**

### 6. The bundled-payload parity defect observed at baseline by `[P0-T11]`

`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, fails because
`list_scoped_files` **enumerates the filesystem rather than consulting git**. A gitignored, untracked,
machine-local file such as `.claude/state/python-batch-budget.default.json` therefore enters the
repo-side set and is reported as missing from the bundle.

**The correct fix is for the scan to consult git rather than for a developer to delete a machine-local
file.** The file is created by the repository's own `Write|Edit` PreToolUse hook
`.claude/hooks/enforce-python-batch-budget.ps1`, so deleting it is both a mutation of the developer's
environment and futile — the hook regenerates it on the next Write or Edit. Consulting git would make
the scan agree with the repository's own definition of what is in the repository.

**This change does not widen its scope to fix it, and deletes no gitignored file.** The defect was
recorded, not remediated; it is tolerated at `[P2-T13]`, `[P3-T18]`, and `[P6-T4]` under the
one-permitted-failure exception branch, and it is named explicitly in each of those artifacts.
Recorded here as an observation for a future issue. **Not acted on.**

### 7. Amend spec line 623 to exclude runtime-generated artifact paths

Recorded as a consequence of the adjudication above. The criterion at spec line 623 excludes only
template placeholders, so a gitignored runtime-artifact path such as
`artifacts/orchestration/epic-orchestrator-state.json` cannot satisfy it even though the citation is
correct and pre-existing. Amending the criterion to exclude paths under gitignored runtime-artifact
roots — an authoring action, outside this executor's mandate — would let it be satisfied honestly.
**Not acted on.**

## issue.md checkbox reconciliation

Task: [P6-T13]

`[P6-T13]` updates only the checkboxes under `## Proposed Fix / Validation Ideas` and `## Next Step`
in `issue.md`, and its acceptance condition is that no checkbox is checked without a corresponding
evidence artifact path recorded in **this** artifact. Each check-off below therefore names its
evidence path here. Paths are relative to the feature folder.

`issue.md` is not an acceptance-criteria source under `full-bug` work mode — `spec.md` is the sole AC
source — so these checkboxes are progress markers on the original bug report, not acceptance
criteria, and they are not counted in the 38.

### `## Proposed Fix / Validation Ideas`

| issue.md line | Item | State | Evidence artifact path / reason |
|---|---|---|---|
| 68 | Every `.claude/rules/*.md` frontmatter block parses as valid YAML | **`[x]`** | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 1, `test_every_claude_rule_carries_parseable_paths_and_description`). Corresponds to spec line 581. |
| 69 | `epic-orchestrator.md` frontmatter parses and every `skills:` entry resolves | **`[x]`** | `evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md` (test 6 `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`, test 7 `test_epic_orchestrator_preloads_exactly_three_skills`). Corresponds to spec lines 571 and 678. |
| 70 | No cross-reference in the two epic files points at a non-existent path | **`[ ]`** | **LEFT UNCHECKED — not delivered.** This is the `issue.md` counterpart of spec line 623, which remains unchecked for the reason adjudicated above: `artifacts/orchestration/epic-orchestrator-state.json` is a non-placeholder, gitignored, runtime-generated checkpoint path that does not resolve to an existing file. Leaving this unchecked keeps `issue.md` consistent with `spec.md`. |
| 71 | Markdown and PowerShell gates run for the files actually changed | **`[ ]`** | **LEFT UNCHECKED — cannot be delivered as written.** `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` establishes that **no Markdown lint or format gate exists in this repository**, so no Markdown gate could be run for the changed files; and PoshQC is not applicable because no PowerShell file was added or edited. Checking this would assert two gate runs that did not and could not occur. |
| 72 | Measured before-and-after always-on line count recorded under the canonical evidence path | **`[x]`** | `evidence/baseline/always-on-line-count-before.2026-08-26T00-00.md`, `evidence/baseline/always-on-line-count-after.2026-08-26T00-00.md`, `evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md`. Corresponds to spec line 693. |

### `## Next Step`

| issue.md line | Item | State | Evidence artifact path / reason |
|---|---|---|---|
| 76 | Promote to GitHub issue (bug-report template) | `[x]` | Already checked before this task; not altered. Issue #559 exists and the promoted lifecycle record is committed at `docs/features/potential/promoted/2026-08-25-epic-orchestrator-always-on-context-footprint.md`. |
| 77 | Move to active fix folder / branch | **`[x]`** | `evidence/baseline/baseline-git-state.2026-08-26T00-00.md`, which records the branch `bug/epic-orchestrator-always-on-context-footprint-559` and the working-tree state. The active feature folder `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/` is committed on that branch. |

### Checkboxes deliberately not touched

`[P6-T13]` scopes the update to the two sections above. The following were left exactly as found:

| issue.md line | Item | State | Why untouched |
|---|---|---|---|
| 48 | Attached minimal logs or screenshot | `[ ]` | Under `## Logs / Screenshots`, outside the two named sections. Also not delivered — this is a text-and-measurement bug with no screenshot. |
| 53-56 | `Blocker` / `High` / `Medium` / `Low` | `[ ]` / `[x]` / `[ ]` / `[ ]` | Under `## Impact / Severity`, outside the two named sections. Inherited single-select severity markers, mirroring spec lines 56-59; `High` is the selected value. |

## Scope containment of the reconciliation itself

This reconciliation modified exactly two files, both inside the declared blast radius: `spec.md`
(four checkbox flips at lines 681, 699, 702, 706) and this artifact. Both were verified LF-only after
editing, since a silent LF-to-CRLF rewrite is not revealed by `git diff --stat` and would invalidate
the pinned SHA-256 digests. No gitignored file was created, deleted, moved, or mutated at any point.
