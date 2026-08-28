# Policy Compliance Audit — Issue #576 (ConflictResult truthiness)

Timestamp: 2026-08-28T13-43

- Feature folder: `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576`
- Branch: `bug/conflictresult-truthiness-always-true-576-r2`
- Base: `origin/main` (merge-base `e546e814e246d814474d35067f0674590b0e41ff`)
- Work Mode: `full-bug` (marker read from `issue.md` line 12)
- Reviewer scope: full branch diff `origin/main...HEAD`, 47 files, 3748 insertions, 4 deletions

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Scope discipline | PASS |
| Policy-document immutability | PASS |
| Evidence location invariant | PASS |
| Evidence schema (timestamp conventions) | PASS |
| Python toolchain (7-stage, applicable stages) | PASS |
| PowerShell toolchain (3-stage) | PASS |
| Coverage — Python | PASS |
| Coverage — PowerShell | PASS |
| Coverage — TypeScript | N/A (zero changed files) |
| Coverage — C# | N/A (zero changed files) |
| File size limit (500 lines) | PASS |
| Unit-test policy | PASS |
| Cross-language parity preservation | PASS |
| Blast-radius formatting discipline | PASS |

**Blocking findings: 0. Advisory findings: 2.**

## Rejected Scope Narrowing

None. The delegating prompt directed a full-branch audit against `origin/main` and supplied
scrutiny points that expand rather than narrow the scope. No instruction attempted to limit the
audit to a plan, task, or phase subset, to mark a language out of scope, or to skip a toolchain or
coverage check. The audit was performed against the full branch diff.

## Language Coverage Determination

Changed files by extension across the full branch diff:

```
41 md   3 py   2 psm1   1 ps1
```

Languages with changed files: **Python** and **PowerShell**. TypeScript and C# have **zero** changed
files on this branch — verified by an explicit filter for `.ts`, `.tsx`, and `.cs` over
`git diff --name-only origin/main...HEAD`, which returned no rows. `N/A` is therefore an admissible
verdict for those two languages under the coverage rule, which reserves `N/A` for languages with no
changed files.

The three bundled push-down mirrors under `extensions/drm-copilot/resources/claude-customizations/`
are Markdown and PowerShell resource payloads, not TypeScript source; they do not place TypeScript
in scope.

## Scope Discipline

The ten non-documentation changed paths are exactly the plan's declared File Scope:

Production (7):

```
scripts/dev_tools/_blast_radius_conflicts.py
.claude/lib/blast-radius/BlastRadius.psm1
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
```

Tests (3):

```
tests/scripts/dev_tools/test_blast_radius_conflicts.py
tests/scripts/dev_tools/test_blast_radius_invariants.py
tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
```

All remaining changed paths are inside the feature folder (process and evidence artifacts).

A filter for the six paths the specification excludes returned no rows: the extension TypeScript
source tree, the policy-rule directory, the facade module, the drift-detection module, the
blast-radius truth table, and the PoshQC run-settings file are all absent from the diff.

## Policy-Document Immutability

No file under `.claude/rules/` or `.github/instructions/` appears in the branch diff. The reviewer
made no edit to any policy document, source file, plan, or specification. `git status --porcelain`
filtered for tracked modifications returned none after all review commands, confirming the review
was non-mutating with respect to tracked content.

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited **0**.

A filter over the branch diff for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`,
and `artifacts/evidence/` returned no rows. All 33 evidence artifacts are written under the
canonical `<FEATURE>/evidence/<kind>/` scheme, using four kinds:

| Kind | Artifacts |
| --- | --- |
| `baseline` | 11 |
| `qa-gates` | 19 |
| `regression-testing` | 2 |
| `other` | 1 |

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Evidence Schema Compliance

All 33 evidence artifacts were parsed programmatically for the four required fields and for the
conditional `ExpectedExitCode` field.

- `Timestamp:` present in **33 of 33**.
- `Command:` present in **33 of 33**.
- `EXIT_CODE:` present in **33 of 33**.
- `Output Summary:` present in **33 of 33**.
- Artifacts recording a deliberately non-zero exit: **2**, and both carry `ExpectedExitCode`:
  - `evidence/qa-gates/push-down-parity.2026-08-28T12-46.md` — `EXIT_CODE: 1`, `ExpectedExitCode: 1`
  - `evidence/regression-testing/fail-before.2026-08-28T12-46.md` — `EXIT_CODE: 1`, `ExpectedExitCode: 1`

Zero schema problems were detected. Every artifact carries the single ISO-8601 stamp
`2026-08-28T12-46`.

Two synthesis tasks (`final-qa-loop-outcome`, `acceptance-criteria-signoff`) record
`Command: n/a (synthesis task)` with `EXIT_CODE: 0`. This is a truthful declaration that the task
runs no shell command rather than a fabricated command, and is treated as compliant.

## Toolchain Verification (reviewer-executed, independent of recorded evidence)

### Python

| Stage | Command | Result |
| --- | --- | --- |
| Formatting | `poetry run black --check .` | exit 0 — `455 files would be left unchanged` |
| Linting | `poetry run ruff check .` | exit 0 — `All checks passed!` |
| Type checking | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` |
| Unit tests | `poetry run pytest --cov-branch --cov-report=term-missing --cov` | `TOTAL ... 91%` |

Architecture-boundary, contract/schema, and integration stages have no applicable target in this
change: it adds one dunder method to an existing frozen dataclass, adds prose to Markdown skills and
to PowerShell comment-based help, and adds tests. No module boundary, published contract, or
external adapter is touched.

### PowerShell

| Stage | Command | Result |
| --- | --- | --- |
| Formatting | covered by the PoshQC run below; no tracked file was rewritten | PASS |
| Linting | `Invoke-PoshQCAnalyze -Root <worktree>` | exit 0 — `PSScriptAnalyzer passed: no findings` |
| Unit tests | `Invoke-PoshQCTest -Root <worktree>` | `Tests Passed: 3839, Failed: 0, Skipped: 9` |

The self-hosted PoshQC module was invoked directly rather than through the MCP tool, because the
MCP runner reads the installed extension's settings and its result payload carries no pass, fail, or
coverage counts. The executor's evidence records the same two-surface approach. Reviewer-reproduced
counts match the recorded evidence exactly (3839 passed, 0 failed).

Type checking is not applicable to PowerShell per the mandatory toolchain loop.

## Coverage Verification

Coverage was verified by inspecting pre-existing artifacts and by reproducing the scoped and
repo-wide commands. Coverage generation was not authored by the reviewer.

### Python — `artifacts/python/lcov.info` (present)

New/modified file in scope: `scripts/dev_tools/_blast_radius_conflicts.py` (modified; 15 insertions,
0 deletions).

```
SF:scripts\dev_tools\_blast_radius_conflicts.py
LF:60   LH:60    -> line coverage 100%
BRF:22  BRH:22   -> branch coverage 100%
```

Reviewer-reproduced term-missing table:

```
scripts\dev_tools\_blast_radius_conflicts.py      60      0     22      0   100%
```

| Threshold | Required | Observed | Verdict |
| --- | --- | --- | --- |
| Changed-file line coverage | >= 85% | 100% | PASS |
| Changed-file branch coverage | >= 75% | 100% | PASS |
| No regression on changed lines | required | baseline 100% -> 100%, `Miss` 0, `Missing` empty | PASS |
| Repo-wide line coverage | >= 85% | 91% (`TOTAL 15182 1109 5576 567 91%`) | PASS |

The output contains no `No data was collected` string; the module row carries a non-zero statement
count of 60, so the coverage argument provably collected data. This satisfies the G1-class concern
that a coverage argument can be stated as an acceptance condition yet measure nothing.

### PowerShell — `artifacts/pester/powershell-coverage.xml` (present)

Modified file in scope: `.claude/lib/blast-radius/BlastRadius.psm1` (11 insertions, comment-based
help only).

Reviewer-parsed JaCoCo counters for the `sourcefile` element named `BlastRadius.psm1`, taken from an
XML regenerated by the reviewer's own PoshQC run:

```
INSTRUCTION missed=0 covered=165  -> 100.00%
LINE        missed=0 covered=109  -> 100.00%
METHOD      missed=0 covered=8    -> 100.00%
CLASS       missed=0 covered=1    -> 100.00%
```

| Threshold | Required | Observed | Verdict |
| --- | --- | --- | --- |
| Changed-file line coverage | >= 85% | 100% | PASS |
| No regression on changed lines | required | baseline 100% -> 100% | PASS |
| Branch coverage | not applicable | Pester measures command and line coverage only | correctly omitted |

Repo-wide PowerShell command coverage from the reviewer's run: `Covered 94.19% / 0%. 10,563 analyzed
Commands in 88 Files.` The trailing `0%` is the branch figure Pester does not measure; per
`.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md` no branch gate applies and the
absent figure is **not** recorded as a failure.

### TypeScript / C#

Zero changed files on the branch. `coverage/lcov.info` and `artifacts/csharp/coverage.xml` are
absent, which is consistent and not a finding.

## Unit-Test Policy Compliance

| Requirement | Evidence | Verdict |
| --- | --- | --- |
| Test files mirror production structure | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`; `tests/scripts/claude-lib/blast-radius/` mirrors `.claude/lib/blast-radius/` | PASS |
| No colocation in the production tree | No test file added under `src/`, `scripts/`, or `.claude/lib/` | PASS |
| No temporary files in tests | No `tempfile`, `New-TemporaryFile`, or `TestDrive` write introduced by the added tests | PASS |
| No external dependencies | Added tests construct in-memory radii and call pure functions | PASS |
| Determinism | No clock, RNG, sleep, or timer use in the added tests | PASS |
| Arrange–Act–Assert | PowerShell tests carry explicit `# Arrange` / `# Act` / `# Assert` comments; Python tests follow the structure implicitly, consistent with the existing convention of both files | PASS |
| Positive and negative flows | Both boolean directions covered, plus a directly-constructed-result case and a non-goal pin | PASS |
| Coverage exclusion policy | No `exclude` entry added; no production path excluded from measurement | PASS |

## File Size Limit

| File | Lines | Limit | Verdict |
| --- | --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 493 | 500 | PASS |
| bundled `BlastRadius.psm1` mirror | 493 | 500 | PASS |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 241 | 500 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | 435 | 500 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | 371 | 500 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_invariants.py` | 278 | 500 | PASS |

The PowerShell module has 7 lines of headroom. This is noted as Advisory Finding A2.

## Cross-Language Parity Preservation (scrutiny point 1)

**Verdict: PASS.**

- `git diff --stat origin/main...HEAD -- tests/scripts/dev_tools/test_blast_radius_parity.py
  tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` produced **empty output**.
  Neither parity suite is modified.
- A filter for `parity` over the branch diff's changed-path list returns only evidence artifacts
  inside the feature folder, never a parity suite.
- The diff of `BlastRadius.Conflict.Tests.ps1` contains **zero deleted or changed lines** — a filter
  for lines beginning `-` returned nothing. The change is a single additive hunk of 33 lines
  beginning at line 83.
- The pre-existing `It 'returns the conflict verdict and a reasons collection'` spans lines 56–67,
  entirely above the hunk start. Its key-set assertion at line 65 is
  `@($result.Keys | Sort-Object) | Should -Be @('conflict', 'reasons')`, unchanged.
- Reviewer-executed Pester run of that file: **29 passed, 0 failed**, with the pre-existing `It` and
  both new `It` blocks individually reported green.
- Reviewer-executed Python run of the conflicts, invariants, and parity suites together:
  **185 passed**.

The shared JSON fixture corpus under `tests/fixtures/blast_radius` does not appear in the diff, so
the corpus was not extended with a truthiness assertion the two runtimes cannot both satisfy. The
design decision to document the divergence rather than force parity is correct: the two runtimes
provably cannot agree on this property, so a parity assertion would encode a falsehood.

## Issue #510 Branch (b) at [P5-T8] (scrutiny point 2)

**Verdict: PASS — the authorization was used exactly as written, and independently reproduced.**

The plan authorizes branch (b) for exactly one named path. Reviewer verification of each condition:

| Condition | Reviewer evidence |
| --- | --- |
| The assertion names that path and no other | The captured message names `.claude\state\powershell-batch-budget.default.json` and no second path |
| The path is gitignored | `git check-ignore -v` exits 0 and reports `.gitignore:68:.claude/state/`; line 68 of `.gitignore` reads `.claude/state/` |
| The path is untracked | `git ls-files .claude/state/` returns empty output |
| The path is outside the declared file scope | Absent from the ten-path File Scope; absent from the branch diff |
| No remediation was attempted | No file under `.claude/state/` appears in the diff; the bundled payload is unchanged between the failing and confirming runs |

**Independent reproduction.** During this review the reviewer's own PowerShell and Python tool
invocations caused the batch-budget hooks to recreate `.claude/state/`. The reviewer then observed
the identical failure:

- With `.claude/state/` absent, the reviewer ran the node ID and obtained `1 passed`.
- After the hooks recreated the directory (timestamp 13:40, containing
  `python-batch-budget.default.json`), the same full-suite run reported
  `FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  and `1 failed, 4208 passed`.
- `git ls-files .claude/state/` remained empty and no tracked file was modified throughout.

The failure is therefore demonstrably a function of untracked, hook-generated session state and is
entirely independent of the branch content. The executor's diagnosis is confirmed by direct
reproduction rather than accepted on assertion.

## [P6-T4] Environment-Parity Reconciliation (scrutiny point 3)

**Verdict: PASS — a legitimate environment restoration, not a gate weakened after the fact.**

The question is whether removing untracked state mid-run to restore the baseline environment is
legitimate. Five considerations, each independently checked:

1. **The removed content is not repository content.** It is untracked and gitignored, confirmed
   above by `git ls-files` and `git check-ignore`. Removing it changes nothing the branch delivers.
2. **The artifact under test was never touched.** The bundled payload is byte-identical between the
   two runs; the reviewer confirmed all three source/bundle SHA-256 pairs match at HEAD.
3. **The direction of the change is toward the baseline, not away from it.** The baseline was
   captured before the directory existed. Removing it restores that condition rather than
   constructing a novel, more favourable one.
4. **The failure was reproduced by the reviewer without any code change**, establishing that the
   removal addressed an environmental variable rather than masking a defect in the delivery.
5. **Nothing was concealed.** Both runs are recorded in full. Run 1 is reported with its exit code,
   its counts, and its failing node ID; the micro-action is described with the three git commands
   that classified the directory; run 2 is reported with its counts and with a post-run check that
   the directory was not recreated. `[P5-T8]` independently retains the unremediated failure record
   with `EXIT_CODE: 1`, and the `final-qa-loop-outcome` artifact restates the condition a third time.

A gate weakened after the fact would show a relaxed assertion, a narrowed command, or a suppressed
record. None is present: the command string is identical between the two runs, the assertion is
untouched, and the failing run remains on the record in three separate artifacts.

**Reviewer-independent confirmation of the substantive claim.** With `.claude/state/` absent, the
reviewer ran the node ID directly and obtained `1 passed`. The acceptance criterion's substantive
content — that every edited file under `.claude` matches its bundled counterpart — is therefore
established by the reviewer's own run, not solely by the executor's second run.

## Empty-Baseline Consequence (scrutiny point 4)

**Verdict: PASS — the stricter condition was carried forward, not dropped.**

The plan's Verified Facts items 12 and 13 each asserted a pre-existing failure. Both baselines came
back green:

- Item 12 (Python push-down failure): `evidence/baseline/python-full-test.2026-08-28T12-46.md`
  records `EXIT_CODE: 0`, `4195 passed, 5 skipped`, `failed: 0`, and states the fact "no longer
  reproducing". The baseline failing node-ID set is **empty**.
- Item 13 (Pester Codex PreToolUse failure): `evidence/baseline/powershell-test.2026-08-28T12-46.md`
  records `ok: true`, and `powershell-test-observable` captures the observable counts with
  `Failed: 0`. The baseline failing set is **empty**.

An empty baseline failing set is the stricter condition, because a non-empty set would have excused
any member of it. The three dependent gates were each judged against the empty set:

| Gate | Baseline failing set | Applied condition | Outcome |
| --- | --- | --- | --- |
| `[P6-T4]` | empty | "empty is a subset of empty"; any failing node ID would fail the gate | Run 1 exited 1 and was **not** excused — the artifact does not claim the failure was pre-existing and permitted. The gate was only satisfied after the environment was restored and the failing set became genuinely empty. |
| `[P4-T5]` | empty | Pester conflict suite required green | 29 of 29 `Passed`; reviewer reproduced 29 passed, 0 failed |
| `[P6-T8]` | empty (`Failed: 0` at 3837 passed) | failed count not higher than 0, i.e. exactly 0 | `Failed: 0` at 3839 passed; reviewer reproduced 3839 passed, 0 failed |

The strictest available reading was applied. Notably, the executor did **not** use the disappearance
of the predicted item-12 failure as licence to excuse the run-1 failure at `[P6-T4]`: it re-ran to a
genuinely clean state instead. That is the correct handling of a baseline that turned out empty.

## Blast-Radius Formatting Discipline (scrutiny point 5)

**Verdict: PASS.**

The plan states that out-of-scope path citations are written as plain prose without inline-code
formatting, and that three PoshQC commands sit in fenced blocks, so those tokens are not harvested
into the declared radius.

- **The executor changed no prose in either document.** Diffing `spec.md` and
  `plan.2026-08-28T09-31.md` from the planner-authored commit `d6149e0b` to `HEAD`, then filtering
  out checkbox lines, yields **empty output for both files**. Every executor edit to the plan and
  the specification is a `- [ ]` to `- [x]` checkbox flip. No inline-code formatting was restored,
  and no prose, heading, or fenced block was altered.
- **The evidence artifacts observe the same discipline.** A search of the 33 evidence artifacts for
  inline-code-wrapped occurrences of the six out-of-scope tokens found **none** for the extension
  TypeScript source tree, the facade module, the drift-detection module, the blast-radius truth
  table, or the PoshQC run-settings file. Where the artifacts must refer to these, they use plain
  prose — for example `the PowerShell parity suite BlastRadius.Parity.Tests.ps1 under
  tests/scripts/claude-lib/blast-radius` and `the blast-radius truth table config/blast-radius.json`.
- **The only inline-code out-of-scope citations are mandate-read paths.** Two artifacts cite
  `.claude/rules/*.md` and `.claude/skills/policy-compliance-order/SKILL.md` in inline code, in the
  phase-0 policy-read record and in a scope-exclusion confirmation. Both are members of the
  `mandate_reads` exclusion set in `config/blast-radius.json`, verified by the reviewer:

```
.claude/rules/**
.claude/skills/policy-compliance-order/SKILL.md
```

  Under the read-by-mandate classification in `.claude/rules/parallel-orchestration.md`, matching
  citations are removed from the harvest before module and shared-surface resolution, so these
  tokens cannot produce a false conflict edge. The trailing-separator form `.claude/rules/`
  additionally fails the extractor's shape rule for a wildcard-free token whose final component
  names a directory. No contention is introduced.

## Advisory Findings

**A1 — `ConflictResult.__bool__` raises `TypeError` for a non-`bool` `conflict` field.**
Severity: Advisory. Not blocking; arguably an improvement over the prior behavior.

`__post_init__` validates `self.conflict != bool(self.reasons)`. Because Python evaluates
`0 != False` as `False`, a construction such as `ConflictResult(conflict=0, reasons=())` passes
validation and stores an `int`. `__bool__` then returns that `int`, and CPython rejects it:

```
__bool__ should return bool, returned int
```

Before this change the same construction returned `True` silently. The change therefore converts a
silently-wrong value into a loud failure, which is consistent with the fail-fast principle in
`.claude/rules/general-code-change.md`. The path is unreachable from in-repo production code — the
only constructor is `conflicts()`, which always passes `bool(reasons)` — and a non-`bool` argument
is a Pyright type error against the declared `conflict: bool` annotation.

This is the same boolean/integer equality class already documented in
`.claude/rules/parallel-orchestration.md` as a known Python/TypeScript divergence. Optional
hardening, if a later feature wants the invariant closed: assert `isinstance(self.conflict, bool)`
in `__post_init__`, or compare with `is not` against the normalized value.

**A2 — `BlastRadius.psm1` is 7 lines below the 500-line limit.**
Severity: Advisory. Both copies stand at 493 lines. The limit is not breached and this change is
compliant. Recorded only so that the next feature adding comment-based help to this module plans for
extraction rather than discovering the ceiling mid-execution.

## Conclusion

**Blocking findings: 0.**

The change is compliant with the repository policy set. Scope is exactly as declared, both parity
suites and the frozen key-set assertion survived untouched, coverage exceeds every applicable
threshold in both coverage languages, all 33 evidence artifacts satisfy the timestamp-convention
schema, and the two disclosed exceptions were each verified against evidence rather than accepted on
disclosure. Issue #510's condition was reproduced independently by the reviewer, confirming it is
environmental and unrelated to the delivery.
