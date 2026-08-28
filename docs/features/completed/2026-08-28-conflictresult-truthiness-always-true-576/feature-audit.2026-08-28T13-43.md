# Feature Audit — Issue #576 (ConflictResult truthiness)

Timestamp: 2026-08-28T13-43

- Branch: `bug/conflictresult-truthiness-always-true-576-r2`
- Base: `origin/main` (merge-base `e546e814e246d814474d35067f0674590b0e41ff`)
- Work Mode: `full-bug`, read from the `- Work Mode: full-bug` marker at `issue.md` line 12
- AC source: the `## Acceptance Criteria` section of `spec.md` **only**, per the `full-bug` row of
  the acceptance-criteria-tracking skill. `user-story.md` is not an AC source in this mode and does
  not exist in this feature folder.
- AC count: 21, matching the executor's report

**Blocking findings: 0. All 21 criteria verified PASS independently of checkbox state.**

## Method

Each criterion was evaluated against the code and against evidence artifacts on disk. Checkbox state
in `spec.md` was treated as a claim to be tested, not as proof. Where a criterion asserted a test
passes, the reviewer executed the test rather than reading the recorded result. Where a criterion
asserted a coverage figure, the reviewer reproduced the command and independently parsed the
coverage artifact. Where a criterion asserted a file was unmodified, the reviewer ran the anchored
diff.

Reviewer-executed verification commands, all against the worktree at HEAD:

| Command | Result |
| --- | --- |
| `poetry run pytest <conflicts> <invariants> <parity>` | 185 passed |
| `poetry run pytest` on the 5 AC-named node IDs | 14 passed (4 unit + 10 parametrized) |
| `poetry run pytest <conflicts> <invariants> --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing` | 112 passed; module row `60 0 22 0 100%` |
| `poetry run pytest --cov-branch --cov-report=term-missing --cov` | `TOTAL ... 91%` |
| `poetry run pytest <push-down node ID>` | 1 passed |
| `poetry run black --check .` / `ruff check .` / `pyright` | exit 0 / `All checks passed!` / `0 errors` |
| `Invoke-PoshQCTest -Root <worktree>` | `Tests Passed: 3839, Failed: 0, Skipped: 9` |
| `Invoke-PoshQCAnalyze -Root <worktree>` | `PSScriptAnalyzer passed: no findings` |
| `Invoke-Pester` on `BlastRadius.Conflict.Tests.ps1` | 29 passed, 0 failed |
| `sha256sum` on the six source/bundle files | all three pairs match |
| `git diff --stat origin/main...HEAD -- <both parity suites>` | empty |

## Criterion-by-Criterion Evaluation

| # | Criterion (abbreviated) | Verdict | Reviewer evidence |
| --- | --- | --- | --- |
| AC1 | `test_bool_is_false_for_a_disjoint_pair` exists and passes | **PASS** | Executed by node ID: `PASSED`. Asserts `result.conflict is False` and `bool(result) is False`. Red state captured at `evidence/regression-testing/fail-before...md` with `EXIT_CODE: 1`, `ExpectedExitCode: 1`. |
| AC2 | `test_bool_is_true_for_an_overlapping_pair` exists and passes | **PASS** | Executed by node ID: `PASSED`. Asserts both `conflict is True` and `bool(result) is True` for a radius against itself. |
| AC3 | `test_bool_matches_the_conflict_field_on_constructed_results` exists and passes | **PASS** | Executed by node ID: `PASSED`. Covers both directions on directly constructed records, independent of the `conflicts()` relation. |
| AC4 | `test_boolean_projection_agrees_with_the_conflict_field` passes for every `RADIUS_PAIRS` entry | **PASS** | Executed: 10 parametrized cases `left0-right0` through `left9-right9`, all `PASSED`. Parametrized directly over the existing `RADIUS_PAIRS` matrix; asserts `bool(result) is result.conflict`. |
| AC5 | `test_conflict_reason_defines_no_boolean_projection` exists and passes | **PASS** | Executed by node ID: `PASSED`. Asserts neither `__bool__` nor `__len__` is in `vars(ConflictReason)`. Confirmed the non-goal holds at HEAD. |
| AC6 | Single Pester `It` asserting both halves of the divergence, inside `Describe 'Test-BlastRadiusConflict result shape'` | **PASS** | `It 'is unconditionally truthy even when its conflict key is false'` exists in that `Describe`, asserts `$result['conflict'] \| Should -BeFalse` **and** `$coerced \| Should -BeTrue` in one test. Reviewer-executed: `[+] is unconditionally truthy even when its conflict key is false`. |
| AC7 | Pester `It` asserting the help contains `the conflict key of the returned hashtable` | **PASS** | `It 'documents the truthiness divergence in its comment-based help'` reads `Get-Help -Full \| Out-String -Width 500` and asserts the literal. Reviewer-executed: `[+] documents the truthiness divergence in its comment-based help`. Literal confirmed present at `BlastRadius.psm1:432`. |
| AC8 | Existing key-set assertion at `BlastRadius.Conflict.Tests.ps1:65` unmodified and still passing | **PASS** | The file diff has **zero** deleted or changed lines — a filter for `^-` returned nothing. Single additive hunk at line 83; the `It` spans lines 56–67, entirely above it. Line 65 reads `@($result.Keys \| Sort-Object) \| Should -Be @('conflict', 'reasons')`. Reviewer-executed: `[+] returns the conflict verdict and a reasons collection`. |
| AC9 | `parallel-add` literal in source and bundled copy, in the edge-derivation step | **PASS** | Present at line 67 of both copies, on a single line, inside the step that maps conflicting pairs onto `(int, int)` conflict edges. |
| AC10 | `parallel-plan` hashtable literal in the edge-seeding procedure and ConflictResult literal in the contention-contract section | **PASS** | Hashtable literal at line 308 of both copies (edge-seeding procedure); `the conflict field of the returned ConflictResult` at line 217 of both copies (contention contract). Each on a single line. |
| AC11 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes after the change | **PASS** | Reviewer-executed with `.claude/state/` absent: `1 passed`. See the note below on the issue #510 condition. |
| AC12 | Evidence artifact records matching SHA-256 digests for each of the three pairs | **PASS** | `evidence/other/bundle-parity-post-change...md` records six digests. Reviewer recomputed all six at HEAD; every value matches the artifact and all three pairs are equal. No stale-hash divergence. |
| AC13 | Scoped coverage command run once, captured, term-missing names the module with non-zero statements | **PASS** | Reviewer reproduced the exact command: module row `scripts\dev_tools\_blast_radius_conflicts.py 60 0 22 0 100%`, `112 passed`. Statement count 60 is non-zero. `No data was collected` absent. |
| AC14 | Line coverage >= 85% and branch coverage >= 75% for the module | **PASS** | Reviewer-reproduced: line 100%, branch 100%. Independently parsed from `artifacts/python/lcov.info`: `LF:60 LH:60` and `BRF:22 BRH:22`. |
| AC15 | `BlastRadius.psm1` line coverage >= 85% in Pester output, no branch assertion | **PASS** | Reviewer parsed the JaCoCo `sourcefile` element from a freshly regenerated `artifacts/pester/powershell-coverage.xml`: `LINE missed=0 covered=109` = 100%. No branch figure is asserted, correctly, since Pester does not measure branch coverage. |
| AC16 | Four-stage Python toolchain clean in a single pass | **PASS** | Reviewer-executed all four: black `455 files would be left unchanged`; ruff `All checks passed!`; pyright `0 errors, 0 warnings, 0 informations`; pytest `TOTAL ... 91%`. `final-qa-loop-outcome` records iteration count 1 with no file rewritten. |
| AC17 | Three-stage PowerShell toolchain clean in a single pass | **PASS** | Reviewer-executed analyze (`no findings`) and test (`Tests Passed: 3839, Failed: 0`). Format stage rewrote no tracked file — `git status --porcelain` shows no tracked modification after all runs. |
| AC18 | Diff lists only declared file-scope paths and none of six named exclusions | **PASS** | The ten non-documentation paths are exactly the declared File Scope. A filter for the extension TypeScript source tree, the policy-rule directory, the facade module, the drift-detection module, the blast-radius truth table, and the PoshQC run-settings file returned **no rows**. |
| AC19 | No `__len__` on `ConflictResult`; docstring and construction validation otherwise behaviorally unchanged | **PASS** | `git diff --numstat` on the module: `15 0` — purely additive, zero deletions, so `__post_init__` and the class docstring cannot have changed. Grep for `__len__` finds only the docstring sentence explaining its deliberate absence, not a definition. |
| AC20 | Neither parity suite modified; both pass unchanged | **PASS** | Anchored `git diff --stat` over both parity suites produced **empty output**. Reviewer-executed: 185 passed across conflicts, invariants, and the Python parity suite together; the PowerShell parity suite is inside the green 3839-passed run. Shared fixture corpus under `tests/fixtures/blast_radius` absent from the diff. |
| AC21 | Neither `BlastRadius.psm1` copy exceeds 500 lines | **PASS** | `wc -l`: 493 and 493. |

### Note on AC11 and the issue #510 condition

AC11's substantive claim is that every edited file under `.claude` matches its bundled counterpart.
The reviewer established this by two independent routes: a direct run of the node ID with
`.claude/state/` absent (`1 passed`), and a recomputation of all six SHA-256 digests at HEAD (all
three pairs equal).

The reviewer also independently reproduced the failure mode the executor disclosed. During this
review the batch-budget hooks recreated `.claude/state/` as a side effect of the reviewer's own
tool invocations, after which the same full-suite run reported
`FAILED ...::test_bundled_claude_payload_contains_all_repo_runtime_contracts` with `1 failed, 4208
passed`. `git ls-files .claude/state/` remained empty and no tracked file was modified. The failure
is a function of untracked, hook-generated session state and is independent of the branch content.
This confirms the executor's diagnosis by reproduction rather than by assertion.

## Regression Coverage of the Reported Defect

The issue reports that `bool(ConflictResult)` is `True` whether or not a conflict was found, so a
caller writing `if conflicts(a, b, config):` treats every item pair as conflicting.

The reviewer confirmed the defect exists on `main` and is fixed on the branch. An import of the
module from the main repository checkout showed `has __bool__: False` and
`ConflictResult(conflict=False, reasons=())` evaluating to `bool: True`. The same construction
against the branch module shows `has __bool__: True` and `bool: False`.

| Expected behavior from `issue.md` | Delivered |
| --- | --- |
| `bool(result)` equals whether a conflict exists | Yes — `__bool__` returns the `conflict` field; verified in both directions and across the 10-pair matrix |
| Mirrored in the PowerShell port | Divergence documented in comment-based help and pinned by a test; parity is provably unattainable because PowerShell exposes no hook to change hashtable boolean coercion |
| Mirrored in the TypeScript parity surface | Out of scope by the specification's own Non-Goals; no TypeScript surface for this relation is in the branch diff |

The issue's four "Proposed Fix / Validation Ideas" are addressed as follows: the unit test for both
directions is delivered (AC1, AC2); the agreement test over the radius matrix is delivered as a
parametrized table test over `RADIUS_PAIRS` rather than a `hypothesis` property (AC4 — noted in the
code review as observation O3, not a finding); the in-repo boolean-context check is addressed by the
skill prose that instructs correct reading at both call sites (AC9, AC10); and cross-runtime
behavior is addressed by documenting the divergence rather than forcing a false parity (AC6, AC7).

## Scope Fidelity Relative to Baseline

The delivered scope matches the plan's declared File Scope exactly — seven production files and
three test files — with no additions and no omissions. No out-of-scope remediation was attempted,
including for the issue #510 condition the change legitimately encountered.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/spec.md
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: none
```

All 21 criteria were evaluated **PASS**. Per the acceptance-criteria-tracking skill, a reviewer
checks off any PASS item not already checked and leaves PARTIAL, FAIL, or UNVERIFIED items
unchecked. All 21 were already checked by the executor and all 21 are independently confirmed, so
**no checkbox was changed by this review** and no item required unchecking. No phantom criteria were
added.

## Conclusion

**Blocking findings: 0.**

The delivered change satisfies all 21 acceptance criteria, verified independently of the executor's
checkbox state and, for every criterion asserting a test result or a coverage figure, by
reviewer-executed commands rather than by reading recorded output. The reported defect is
demonstrably fixed: the boolean projection now agrees with the verdict in both directions and across
the full radius matrix, while the PowerShell divergence that cannot be fixed is documented and
pinned so it cannot drift unnoticed.
