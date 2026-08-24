# Policy Audit — cycle 4 exit re-audit (Issue #500)

**Authored:** 2026-08-23T04-45 by feature-review.
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `8db37795`
**Base:** `main` @ `bee15c0660d382ed74c642d2e028fd136051046f` (merge-base; branch 24 ahead, 0 behind)
**Work mode:** `full-bug` (from `issue.md` line 12) → AC source is `spec.md` only.
**Audit scope:** the full branch diff against the resolved base. 188 files, 13728 insertions, 131 deletions.

## Verdict

**blocking_count: 0**

Overall recommendation: **Go**.

## Rejected Scope Narrowing

None. The caller prompt named two commits (`71641d9c`, `8db37795`) as the cycle-4 subject but explicitly
stated "The full feature diff is the whole branch range against main," and the audit was performed
against `bee15c06...HEAD`. No narrowing was attempted and none was rejected.

## PR Context Artifact Refresh

The artifact pair at `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` was
**stale** on entry: it recorded head `0610037bdfa90a8d77ee75a0f5d7dbb2b985cdb7` and base
`fb30a9a58b8422e610a09b07361421e97367807a`, both predating the two cycle-4 commits and the current
merge-base. Regenerated with `poetry run dev.pr-context --base main` before proceeding, per
`.claude/skills/pr-context-artifacts/SKILL.md`.

## Evidence Location Compliance

**PASS.** No violations.

- `git diff --name-only bee15c06...HEAD | grep -E "^artifacts/"` returns nothing. The branch writes no
  file under `artifacts/` at all, so `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and
  `artifacts/coverage/` are all vacuously clean.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0, no output.
- Every evidence artifact this branch adds sits under
  `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/<kind>/`,
  matching `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Toolchain — independently re-executed, not accepted from evidence

All stages were run by the reviewer from the worktree root at `8db37795` with a clean tree.

| Stage | Command | Result | Matches reported? |
|---|---|---|---|
| Format (Py) | `poetry run black --check .` | exit 0, `440 files would be left unchanged` | yes |
| Lint (Py) | `poetry run ruff check .` | exit 0, `All checks passed!` | yes |
| Types (Py) | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | yes |
| Unit (Py) | `poetry run pytest --cov=scripts.dev_tools --cov-branch` | `4079 passed, 5 skipped` | yes |
| Parity module | `poetry run pytest -q --no-cov tests/scripts/dev_tools/test_blast_radius_config_parity.py` | `17 passed` | yes |
| Format (TS) | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | `All matched files use Prettier code style!` | n/a (cycle 4 touched no TS) |
| Lint (TS) | `npm run lint` | exit 0, no output | n/a |
| Types (TS) | `npm run typecheck` | exit 0 | n/a |
| Unit (TS) | `npm run test:coverage` | `195 suites, 2657 tests, all passed` | n/a |
| PoshQC full | `pwsh -File scripts/dev-tools/run-poshqc-suite.ps1 -WorkspaceRoot .` | exit 0; format clean, PSScriptAnalyzer no findings, `3362 passed, 0 failed, 9 skipped` (= 3371 total) | test counts yes; coverage figure see M5 |
| Pester (blast-radius dir) | `Invoke-Pester tests/scripts/claude-lib/blast-radius` | `384 passed, 0 failed` | yes |

The reported `tests=3371 errors=0 failures=0 disabled=9` and the `tests/scripts/claude-lib/blast-radius`
directory total of `384` both reproduce exactly. The 5 Python skips and 9 Pester skips are pre-existing
and unchanged from baseline.

**Note on `.claude/state/`.** A stale gitignored `.claude/state/python-batch-budget.default.json`
(mtime 2026-08-23 00:40) was present on entry — the known trigger of issue #510. It was removed before
the pytest run. It was **not** recreated by any stage of the reviewer's toolchain run, so pytest is not
its producer. Issue #510 is open and is not re-raised here.

## Coverage Verification (mandatory per language with changed files)

Languages with changed files in the branch diff: **TypeScript, Python, PowerShell**. C# has zero
changed files. Coverage artifacts were inspected; coverage generation was re-run only to obtain an
independent reading, as the recorded artifacts were the executor's own output.

### TypeScript — PASS

- Artifact: `extensions/drm-copilot/coverage/lcov.info` (present).
- Project-wide: **lines 96.66%** (43071/44558), **branches 90.04%** (6122/6799), functions 89.67%.
  Thresholds: lines >= 85% PASS, branches >= 75% PASS.
- Changed production file (modified tier), `src/lib/push-down/claude-blast-radius-derive-core.ts`:
  **lines 468/468 = 100.00%**, **branches 46/48 = 95.83%**. Both above the 85%/75% uniform tier
  thresholds. No regression possible on changed lines at 100%.
- The other changed TypeScript files (`test/lib/push-down/blast-radius-derive-core.test.ts`,
  `blast-radius-derive.test.ts`, `claude-config-carriage.test.ts`, `config-carriage.test-helpers.ts`)
  are test files and test infrastructure, permitted exclusions under
  `.claude/rules/general-unit-test.md`.

### Python — PASS

- Artifact: `artifacts/python/lcov.info` (present, regenerated by the reviewer's run).
- Authoritative figures from `totals` in the coverage JSON:
  `percent_statements_covered = 92.6033%`, `percent_branches_covered = 85.1859%`,
  `percent_covered = 90.6105%`. Thresholds: line/statement >= 85% PASS, branch >= 75% PASS.
- No production Python file is changed anywhere on the branch
  (`git diff bee15c06...HEAD -- scripts/` is empty), so no changed-line regression is possible.
- The two changed Python files (`tests/scripts/dev_tools/test_blast_radius_config_parity.py`,
  `tests/scripts/dev_tools/blast_radius_parity_test_support.py`) are test files.

### PowerShell — PASS

- Artifact: `artifacts/pester/powershell-coverage.xml` (present).
- Independent reading from the JaCoCo root counters after the reviewer's own PoshQC run:
  **LINE 96.18%** (covered 6369, missed 253), INSTRUCTION 95.67%, METHOD 95.41%, CLASS 100%,
  79 source files. Threshold: line >= 85% PASS.
- No branch threshold applies. Pester measures command (instruction) and line coverage only; per
  `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md` the absence of a branch figure is
  a capability limit, not a FAIL.
- No production PowerShell file is changed on the branch; both changed `.ps1` files are Pester tests.
- The recorded figure differs from this independent reading — see finding **M5**. The threshold verdict
  is PASS under every measurement taken (96.18%, 96.21%, 96.47%).

### C# — not applicable

Zero changed C# files in the branch diff. `artifacts/csharp/coverage.xml` is not required and its
absence is not a finding.

### Coverage Exclusion Policy — PASS

No `exclude` entry was added anywhere on the branch. The diff contains no change to `jest.config.cjs`,
to `pyproject.toml` coverage configuration, or to any PoshQC scan configuration. No production source
path is excluded from measurement.

## Policy Compliance by Rule File

| Rule | Verdict | Evidence |
|---|---|---|
| `CLAUDE.md` tone policy | PASS | All added prose in the rule file, spec, tests, and evidence artifacts is neutral and literal. No humour, hyperbole, or decorative metaphor found in the diff. |
| `.claude/rules/general-code-change.md` — 500-line file limit | PASS | Every changed non-doc file measured: `claude-blast-radius-derive-core.ts` 468, `blast-radius-derive-core.test.ts` 482, `blast-radius-derive.test.ts` 472, `claude-config-carriage.test.ts` 460, `config-carriage.test-helpers.ts` 224, `BlastRadius.KeyPartition.Tests.ps1` 268, `BlastRadius.TruthTable.Tests.ps1` 325, `blast_radius_parity_test_support.py` 249, `test_blast_radius_config_parity.py` 499. See **I4** on the 499 headroom. |
| `.claude/rules/general-code-change.md` — seven-stage toolchain, single pass | PASS | Reproduced independently; table above. |
| `.claude/rules/general-code-change.md` — simplicity, separation of concerns | PASS | The key-to-assertion registry is inert data plus one pure helper (`unconsumed_class_keys`); no assertion lives in the support module, matching its stated contract. |
| `.claude/rules/general-unit-test.md` — no temporary files in tests | PASS | The new Python case uses `inspect.getsource`; the new Pester case uses `Get-Content -Raw` against a committed test file. No temporary file is created by either. |
| `.claude/rules/general-unit-test.md` — test file location mirrors source | PASS | All test files sit under `tests/` or `extensions/drm-copilot/test/`. No colocation in a production tree. |
| `.claude/rules/general-unit-test.md` — determinism | PASS | Python dict iteration order is insertion-ordered; the PowerShell `Hashtable.Keys` enumeration is unordered but is consumed only in an order-independent set union (`BlastRadius.KeyPartition.Tests.ps1:133`) and in an accumulate-all loop, so results are order-independent. No clock read, no RNG, no banned timing API added. |
| `.claude/rules/general-unit-test.md` — coverage thresholds | PASS | Section above. |
| `.claude/rules/quality-tiers.md` — uniform thresholds | PASS | 85%/75% applied uniformly; no tier-specific lower floor invoked anywhere in the evidence set. |
| `.claude/rules/python.md` | PASS | Black, Ruff, Pyright all clean on an independent run. |
| `.claude/rules/python-suppressions.md` | **PARTIAL** | One `# noqa: E501` added. See finding **M4**. |
| `.claude/rules/powershell.md` | PASS | PoshQC format and analyze clean; no branch-coverage gate asserted against Pester. |
| `.claude/rules/typescript.md` | PASS | Prettier, ESLint, tsc clean. |
| `.claude/rules/parallel-orchestration.md` | PASS | The rule file is amended, not weakened. Both copies byte-identical (`cmp` exit 0; sha256 `cd5d1a97…f8e4` on both). No JSON Schema was authored, imported, or read. No `depends_on` or `integration_branch` key introduced. |
| `.claude/rules/benchmark-baselines.md` | n/a | No diff under `scripts/benchmarks/**`. |
| `.claude/rules/ci-workflows.md` | n/a | No workflow file changed on the branch. |
| `.claude/rules/plan-acceptance-gates.md` | **PARTIAL** | P5-T12's acceptance condition cannot pass on this branch. See adjudication (a) and finding **I9**. |

## Adjudication (a) — P5-T12 left unchecked

**Question put to the reviewer:** is leaving P5-T12 unchecked with recorded evidence the right
disposition, and is the substantive property actually true?

**The substantive property is TRUE, independently verified.** The executor's verification used
`git diff HEAD` against an uncommitted working tree; that measurement is now trivially empty because
the work is committed, so it cannot be reproduced as stated. The reviewer used a different and
still-valid measurement:
`git diff eeadf582..HEAD --stat -- scripts/dev_tools/ extensions/drm-copilot/src/ tests/scripts/dev_tools/test_blast_radius_config.py`
(where `eeadf582` is the parent of the two cycle-4 commits) produces **no output**. Cycle 4 therefore
touched zero files under any of the three scoped paths. `git diff eeadf582..HEAD --name-only` lists 31
files: one rule document and its published copy, `spec.md`, two Pester/Python test files, and 26
documentation and evidence artifacts. Nothing production, nothing out of scope.

**The gate genuinely cannot pass.**
`git log --oneline bee15c06..HEAD -- extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`
names exactly one commit, `44b4551e` ("fix(500): correct the bundled blast-radius truth table"), a
cycle-1 commit. Because P5-T12 diffs the whole branch range, the `extensions/drm-copilot/src/` leg is
permanently non-empty for any cycle-4 executor. The condition is unfalsifiable in the opposite
direction from the usual defect: it can only ever fail.

**Disposition: CORRECT, and I agree with the orchestrator's reasoning.** Rewriting an acceptance
condition after watching it fail is the precise defect class this feature has produced four times
(AC9, AC10, AC4, R1). A gate retro-fitted to its own observed outcome is not a gate. Leaving the box
`- [ ]` with a signed evidence artifact naming the root cause, the offending commit, and a substitute
measurement is exactly what `acceptance-criteria-tracking` rule 4 prescribes: "If an AC item cannot be
fully delivered or verified, leave it as `- [ ]` and document the gap." The artifact at
`evidence/qa-gates/p5-t12-scope-verification.2026-08-23T02-59.md` does all three.

Two qualifications, recorded as **I9** rather than as a defect: P5-T12 is a *plan* task, not an
acceptance criterion, so it has no bearing on the AC roll-up; and the correct forward action is a
plan-authoring finding (the condition should have been scoped to the cycle's own commit range at
authoring time), not an edit to the landed plan.

## Adjudication (b) — the new `# noqa: E501`

**Question put to the reviewer:** acceptable convention-following deviation, or a finding?

**It is a finding, at Minor severity.** Two distinct issues, and the second is the more substantive.

**On the suppression itself.** `.claude/rules/python-suppressions.md` states that all `# noqa`
suppressions "must either match a pre-authorized pattern defined in this file, OR have explicit user
approval for that specific suppression." `E501` appears in neither the pre-authorized list (S603,
ARG002, B008, TCH002/TCH003, S310, S314, BLE001, S301, S108/S105) nor the explicitly-not-authorized
list. There is no user approval on record. The three prior `# noqa: E501` instances in
`tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py:86`,
`.../test_section_intent.py:76`, and `tests/scripts/dev_tools/test_potential_to_issue_content.py:65`
establish precedent, but precedent is not authorization under a rule that enumerates its authorized
patterns exhaustively. The rule's required escalation path — attempt resolution without a suppression,
then "at least five more distinct approaches," documented — is not evidenced anywhere in the plan or
the evidence set. The suppression also lacks the explanatory comment the rule mandates alongside every
authorized pattern.

A remedy exists and was not taken. The def line is 105 characters as committed and 91 without the
`# noqa`, against an 88-character limit. In the `-> (` continuation form the line measures
`len(name) + 11`, so any name at 77 characters or fewer fits; the name is 80. Shortening by three
characters — for example `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion`
(74) — removes the need for a suppression entirely at no cost in descriptiveness. The plan mandated the
80-character name at `remediation-plan.2026-08-22T18-05.md:271`, so the executor was following
instructions; the correct response was to flag the conflict, not to satisfy the name and suppress the
consequence.

**On the checked gate.** This is the sharper point. P5-T2's stated acceptance is
"`EXIT_CODE: 0`, zero new `noqa` present." A new `noqa` is present. The task is nonetheless marked
`- [x]`, and no deviation is recorded in the plan, in
`evidence/qa-gates/remediation-toolchain-single-pass.2026-08-23T02-59.md` (which records only
"EXIT_CODE 0 (all checks passed)" and silently omits the second half of the condition), or in any
other cycle-4 artifact. That is inconsistent with the same cycle's handling of P5-T12, where an
unsatisfied condition was correctly left unchecked and documented. A gate whose stated condition is
half-satisfied and checked anyway is weaker than no gate, because a later reader reasonably infers
from the `[x]` that no new suppression exists.

**Severity: Minor, not Blocking.** The suppression has no behavioural consequence, the underlying
formatting state is compliant with Black and Ruff as configured, and the deviation is now recorded
here. It does not warrant blocking a merge, but it should not be recorded as compliant either, which
is why `python-suppressions.md` carries a PARTIAL verdict above.

## Findings

Severity definitions: **Blocking** prevents merge; **Major** should be fixed before merge absent a
recorded acceptance; **Minor** should be fixed but does not gate; **Info** is an observation with no
required action.

### Blocking — none

### Major — none

### Minor

**M1 — Cycle 4 renamed the `Describe` and left an in-file pointer to the old arrangement.**
`tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1:22-24` reads:

```
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root. Mirrors the file-level BeforeAll of
    # BlastRadius.TruthTable.Tests.ps1, whose Describe this file received.
```

R5 renamed this file's `Describe` from `'Committed blast-radius truth table shape'` to
`'Committed blast-radius truth table cross-copy key partition'` in commit `71641d9c`. The file
therefore no longer carries `BlastRadius.TruthTable.Tests.ps1`'s `Describe`; it has its own. The clause
"whose Describe this file received" is now false. This is the same stale-pointer class as R2/R3 — a
rename landing without its in-file references updated — reproduced inside the commit that was fixing
R2/R3. The same commit rewrote the `.DESCRIPTION` block six lines above and the `Describe` line 29
lines below without touching this line. Remedy: replace the clause with a statement that this file
resolves its own `RepoRoot` and `ConfigPath` the same way `BlastRadius.TruthTable.Tests.ps1` does,
dropping the received-`Describe` claim.

**M2 — The rewritten `.DESCRIPTION` read-inventory was not updated alongside its case inventory.**
`BlastRadius.KeyPartition.Tests.ps1:16-18` still closes with "The tests read the two committed
configurations read-only, invoke no external process, and create no temporary files." The fifth case
added in cycle 4 (`requires every Class 2 and Class 3 key to be indexed by name in its registered
consumer file`, line 235) additionally reads a third file — `BlastRadius.TruthTable.Tests.ps1`, via
`Get-Content -Raw` at line 249 — which is a test source file, not a committed configuration. Commit
`71641d9c` extended the sentence immediately before this one to announce the fifth case but left this
sentence unchanged. Same class as M1. Remedy: name the consumer-file read in the inventory.

**M3 — Recorded Python coverage figure is correct but mislabelled, with arithmetic that does not
produce it.** `evidence/qa-gates/final-python-pytest-coverage.2026-08-23T02-59.md` and
`evidence/qa-gates/coverage-delta-verification.2026-08-23T02-59.md` state
"Statement coverage (TOTAL row): (14939 - 1105) / 14939 = 90.61%". The stated arithmetic yields
**92.60%**, not 90.61%. The figure 90.61% is coverage.py's `totals.percent_covered`, the *combined*
statement-and-branch figure, which under `--cov-branch` is what the `TOTAL` row reports. Statement
coverage is `totals.percent_statements_covered = 92.6033%`. Independently confirmed from the JSON:
`percent_covered = 90.61046653938415`, `percent_statements_covered = 92.6032532298012`,
`percent_branches_covered = 85.18586005830903`. Every threshold is met under either label, so the
verdict is unaffected, but the recorded provenance is wrong and a later reader recomputing the stated
expression will get a different number and conclude the artifact is unreliable. Remedy: label 90.61%
as combined coverage and record 92.60% as statement coverage, or drop the expression.

**M4 — Unauthorized `# noqa: E501`, and P5-T2 checked against a half-unsatisfied condition.** Full
adjudication in section (b) above. Files:
`tests/scripts/dev_tools/test_blast_radius_config_parity.py:358` (the suppression);
`2026-08-22T17-20-remediation/remediation-plan.2026-08-22T18-05.md:500-501` (the checked gate whose
stated acceptance is "zero new `noqa` present"). Remedy, in order of preference: shorten the test name
to 77 characters or fewer so no suppression is needed; or, if the name is to be kept, record the
deviation explicitly (as a numbered plan deviation, the way PD-1 was recorded), add the rule-mandated
explanatory comment, and uncheck or annotate P5-T2.

**M5 — Recorded PowerShell line-coverage figure is not reproducible; the denominator is unstable
across measurement sessions.** The cycle-4 evidence records line coverage 96.47% from
`missed=211, covered=5758` (denominator 5969). The reviewer's independent run of the repository's own
local entrypoint, `pwsh -File scripts/dev-tools/run-poshqc-suite.ps1 -WorkspaceRoot .` with the
default `config/poshqc-scan.json` scan folders, produced `LINE missed=253, covered=6369` (denominator
6622) → **96.18%**, over the same 79 source files and with an identical test result
(`3362 passed, 9 skipped`). Cycles 1-3 recorded a third denominator: `missed=228, covered=5792`
(6020) → 96.21%. No production PowerShell file changed at any point on this branch, so a moving
denominator is a property of the measurement path, not of the code. Consequence: the cycle-4 claim
"identical to the P0-T18 baseline; no regression" is internally consistent because both figures come
from the same session and the same tool (`mcp__drm-copilot__run_poshqc_test`), but a cross-session
percentage comparison against cycles 1-3 is not meaningful. The threshold verdict is PASS under all
three measurements (96.18%, 96.21%, 96.47%, all >= 85%). Remedy: record the scan-folder set and the
denominator alongside the percentage in future PowerShell coverage evidence so the figure is
reproducible, and keep baseline and final on one tool path within a cycle (which cycle 4 did).

### Info

**I1 — R1's consumption check is a textual-mention check, so a narrower instance of the same gap
survives.** Registering a key to an existing assertion and writing the key's name in a comment inside
that assertion passes all 17 Python tests; the PowerShell analogue passes all 384 Pester tests
(perturbation B below). The gap is narrowed from "append a name to a tuple" to "write the key's name
inside an existing assertion", which is a deliberate act rather than an oversight, so this is an
accepted residual and not a defect. Recorded so a later reader does not over-read the guarantee.

**I2 — The PowerShell mirror is strictly weaker than the Python original.** `unconsumed_class_keys`
resolves each registered name to a *callable* and searches *that function's* source
(`inspect.getsource`). The Pester mirror maps each key to a *file* and searches the whole file text for
the `['key']` indexer substring. A key whose indexer literal appears anywhere in
`BlastRadius.TruthTable.Tests.ps1` — including the header comment block — resolves. Structurally
different strength for the same stated invariant. Not a defect: PowerShell has no `inspect.getsource`
equivalent for a Pester `It` body, and the file-scoped form still closes the practical gap.

**I3 — Pre-existing cannot-fail non-vacuity idiom survives in a file this branch edits.**
`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` lines 72, 171, and 172 use
`@($script:CommittedConfig['<key>']).Count | Should -BeGreaterThan 0`. Verified empirically in pwsh:
`@($h['nope']).Count` is `1` and `@($null).Count` is `1`, so the assertion cannot fail for an absent
key or a null value; it fails only for an explicitly empty array (`@(@()).Count` is `0`). This is the
exact idiom cycle 3 identified and repaired, and its correction is documented at length inside
`BlastRadius.KeyPartition.Tests.ps1:170-182`. **These three lines are pre-existing:** at merge-base
`bee15c06` they are lines 72, 139, and 140 of the same file, and the branch diff does not touch them
(`git diff bee15c06...HEAD` adds only one `-BeGreaterThan 0` line, `$separatorFree.Count`, which is
sound because `@($x | Where-Object …)` on a null input yields a genuinely empty array — verified). They
are also now **compensated**: the four-state floor at `BlastRadius.KeyPartition.Tests.ps1:167` covers
exactly the four (copy, key) combinations these lines were meant to guard, correctly rejecting absent,
null, and empty. Out of scope for this branch. Recommend a separate cleanup issue to delete the
redundant weaker duplicates.

**I4 — `test_blast_radius_config_parity.py` is at 499 of the 500-line limit.** One line of headroom.
The next addition to this module forces another split. That pressure already produced plan deviation
PD-1 (the `blast_radius_parity_test_support.py` sibling) and cycle 3's Pester split, and the Pester
split in turn produced the R2/R3 stale pointers this cycle repaired. Worth pre-empting in whatever
touches this module next.

**I5 — The directional invariant's non-vacuity floor guards a wider set than the invariant compares.**
`test_the_gate_compares_non_empty_collections` asserts the full `shared_surfaces` list is non-empty in
both copies, not the *separator-free subset* that
`test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` actually compares. A
self-hosted copy with zero separator-free entries would satisfy the invariant vacuously. Compensating
control: the `bundled <= self_hosted` assertion in
`test_class_two_bundled_shared_surfaces_are_the_portable_set` fails if the self-hosted copy loses a
separator-free entry the bundle carries, and the bundle carries three (`package-lock.json`,
`poetry.lock`, `quality-tiers.yml`). Confirmed by perturbation C. No action required.

**I6 — AC11's uncheck and re-check are not observable in commit history.** The plan has P2-T2 set AC11
to `- [ ]` and P5-T14 restore it to `- [x]`. Both landed in commit `71641d9c`, so the net diff for that
line is `[x]` → `[x]` with only the text changed. The procedure was followed in the working tree; it
simply leaves no trace. Noted so a later reader does not read the unchanged checkbox as evidence that
the uncheck step was skipped.

**I7 — R6's requested numeric specificity was not delivered.** The remediation input asked the floor
docstring to state that "six of those [states are caught] at module import" and that "only the seven
remaining states reach this assertion." The delivered text names the two upstream functions
(`require_string_list`, `load_module_globs`) and their `TypeError`, satisfying the input's own stated
purpose — "naming the upstream functions makes the coverage claim checkable" — but replaces the counts
with "Most tested cells" and "only the remaining states". Defensible (prose counts go stale), and the
sixteen-cell table the input pointed at remains in
`evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md` Group B.

**I8 — Finding numbering differs between the task brief and the remediation inputs; no item was
dropped.** `remediation-inputs.2026-08-22T17-20.md` enumerates R1 through R6. The task brief describes
"R1-R5". The mapping is: brief R1 = inputs R1 (CR-3 consumption); brief R2 = inputs R2 (AC11 text) plus
inputs R3 (the four stale pointers); brief R3 = inputs R6 (floor docstring); brief R4 = inputs R4
(header `verbatim` claim) plus inputs R5 (`Describe` name); brief R5 = the inputs' "do not restore with
`git checkout --`" instruction. All six enumerated items were addressed. Verified item by item in the
feature audit.

**I9 — P5-T12's acceptance condition was defective at plan-authoring time.** See adjudication (a). The
condition diffs the full branch range where it needed the cycle's own commit range, so it can only ever
fail once any prior cycle has touched `extensions/drm-copilot/src/`. This is a plan-authoring finding,
not an executor finding, and the correct remedy is at the planner, not in the landed plan. Recommend
recording it as a plan-gate authoring note: a scope-containment gate must be scoped to the range whose
containment it asserts.

**I10 — Reviewer side effect on gitignored artifacts.** Running the PoshQC suite overwrote
`artifacts/pester/powershell-coverage.xml` and wrote `powershell-coverage.koverage.xml` and
`pester-junit.xml`. The path is gitignored (`.gitignore:6` `/artifacts`), so no tracked file changed and
the branch diff is unaffected. The executor's cycle-4 XML is consequently no longer available for
byte-level comparison, which is why M5 is stated as a non-reproduction rather than a contradiction.
`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were also regenerated, as
required.

## Perturbation Battery (reviewer-executed)

Every perturbation was applied by a script *file* (never multi-line `poetry run python -c`, per the
recorded silent-no-op hazard), confirmed to have landed with `git diff --stat` before the gate was run,
and restored against sha256 hashes recorded **outside the repository** at `/tmp/rev500/pre-hashes.txt`
*before* any perturbation. Final state: `sha256sum -c` reports `OK` for all six files, exit 0, and
`git status --porcelain` is empty.

| # | Perturbation | Gate response | Conclusion |
|---|---|---|---|
| A | `"invented_key": []` added to **both** committed configs; `"invented_key"` registered in `CLASS_TWO_KEY_ASSERTIONS` against the real assertion `test_class_two_bundled_shared_surfaces_are_the_portable_set`; mirrored in `$script:ClassTwoKeyConsumerFile` against `BlastRadius.TruthTable.Tests.ps1` | Python **1 failed, 16 passed** — `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`, message `unresolved pairs (('invented_key', 'test_class_two_bundled_shared_surfaces_are_the_portable_set'),)`. Pester **383 passed, 1 failed** — `requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file`, `Expected $null or empty, but got 'invented_key -> BlastRadius.TruthTable.Tests.ps1'` | **R1 is closed by construction, in both languages.** The exhaustiveness gate passed (the key is classified) exactly as predicted, and only the new consumption gate fired. Baseline for comparison: 17 passed / 384 passed, both re-verified immediately before. |
| B | On top of A, a comment `# invented_key is mentioned here but never read.` added inside the registered Python assertion, and a comment containing `$config['invented_key']` added to `BlastRadius.TruthTable.Tests.ps1` | Python **17 passed**. Pester **384 passed** | Boundary of the guarantee: the check is a textual mention, not a real read (**I1**, **I2**). |
| C | Bundled config only: dropped `poetry.lock` from `shared_surfaces`, dropped `.agents/skills/**` from `mandate_reads`, reinstated `"claude-runtime": [".claude/**"]` in `modules` | Python **6 failed, 11 passed**: `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`, `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]`, `test_class_two_bundled_shared_surfaces_are_the_portable_set`, `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle`, `test_class_three_bundled_modules_are_payload_modules_only`, `test_no_committed_copy_declares_an_umbrella_module[…bundled…]`. Pester **380 passed, 4 failed**: `declares equal values for the runtime-describing keys in both copies` (KeyPartition), `requires every separator-free self-hosted shared surface to reach the bundled copy` (KeyPartition), `declares no removed umbrella module in either committed copy` (TruthTable), `declares only payload modules in the bundled copy` (TruthTable) | AC4, AC6, AC10, AC13 and all four of AC11's file attributions are falsifiable against the exact defect each asserts. Notably the fail-closed regression test fires the moment `claude-runtime` is reinstated. |
| D | Bundled config only: dropped `package-lock.json` from `shared_surfaces` | Python **3 failed, 14 passed**, including `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` | AC14's fail-open regression test is falsifiable against the separator-free root surface it depends on. |

## Assumptions Documented

1. `gh` is unavailable in this environment (the PR context summary records "GitHub CLI unavailable"), so
   no GitHub-side check status, PR metadata, or issue state was consulted. The seven filed follow-up
   issues (#505-#511) are accepted as filed on the caller's statement and were not verified against
   GitHub.
2. `mcp__drm-copilot__run_poshqc_test` is not available to this reviewer, so the PowerShell stages were
   run through the repository's local entrypoint `scripts/dev-tools/run-poshqc-suite.ps1`. This is the
   source of the coverage-denominator difference in M5.
3. No CI run against the branch head was inspected. No workflow file is changed on the branch, so the
   `modified-workflow-needs-green-run` policy rule does not apply.
