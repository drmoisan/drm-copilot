# Remediation reconciliation — cycle 1, issue #596 ([P6-T1])

Timestamp: 2026-08-30T01-51
Task: [P6-T1]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: this task runs no toolchain stage. It reconciles the three in-scope findings against the
evidence artifacts already on disk, all rooted at
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. One live
verification command was run to confirm the acceptance-criteria checkbox state reported below:

```
awk '/^## Acceptance Criteria/{f=1;next} f&&/^## /{exit} f' docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md | grep -c -E '^- \[[ x]\]'
```

EXIT_CODE: 0
ExpectedExitCode: 0

## Finding-by-finding reconciliation

### B-1 — Major — prefix-collision in the batch-budget containment predicate

**Verdict: PASS.**

| | |
| --- | --- |
| Implementing tasks | [P1-T4] (`.claude/hooks/enforce-powershell-batch-budget.ps1:92`), [P1-T5] (bundle mirror), [P2-T4] (`.claude/hooks/enforce-python-batch-budget.ps1:89`), [P2-T5] (bundle mirror) |
| Pinning tests | `discards an absolute candidate path in a sibling directory whose name extends the root` in each of `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` and `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`; plus the regression guard `admits a candidate path that is exactly the resolved root` in each suite, which pins the retained exact-root admission of decision D-1 |
| Fail-before evidence | `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/regression-testing/powershell-containment-fail-before.2026-08-29T23-07.md`, `.../python-containment-fail-before.2026-08-29T23-07.md` |
| Pass-after evidence | `.../evidence/regression-testing/powershell-containment-pass-after.2026-08-29T23-07.md`, `.../python-containment-pass-after.2026-08-29T23-07.md` |
| Literal gate | `.../evidence/qa-gates/containment-literal-after.2026-08-29T23-07.md`, against the before-state in `.../evidence/remediation-baseline/containment-literal-before.2026-08-29T23-07.md` |
| Mirror parity | `.../evidence/qa-gates/mirror-hash-parity-after.2026-08-29T23-07.md`, against `.../evidence/remediation-baseline/mirror-hash-parity-before.2026-08-29T23-07.md` |
| Final QA confirmation | `.../evidence/qa-gates/powershell-suite-final.2026-08-29T23-07.md`, `.../python-suite-final.2026-08-29T23-07.md` |

All four production files carry the corrected literal; the defective literal is absent from all four.
Both hook/mirror pairs are byte-identical and both differ from their baseline hashes.

### B-2 — Major — `mergeClaudeGitignore` deletes every line following an unterminated managed block

**Verdict: PASS.**

| | |
| --- | --- |
| Implementing task | [P3-T3] (`extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:126`, decision D-2) |
| Pinning test | `preserves content following an opening sentinel that has no closing sentinel` in `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts`, which additionally asserts one occurrence of each sentinel and the fixed-point property `mergeClaudeGitignore(merged) === merged` |
| Fail-before evidence | `.../evidence/regression-testing/gitignore-merge-fail-before.2026-08-29T23-07.md` (`1 failed, 7 passed, 8 total`) |
| Pass-after evidence | `.../evidence/regression-testing/gitignore-merge-pass-after.2026-08-29T23-07.md` (`8 passed, 8 total`) |
| Regression guard | `.../evidence/regression-testing/gitignore-pushdown-regression.2026-08-29T23-07.md` |
| Final QA confirmation | `.../evidence/qa-gates/typescript-test-coverage-final.2026-08-29T23-07.md` — branch coverage of the module rose from 90 to 95 because the line-126 arm became exercised |

### B-3 — Minor, folded in — the unreadable-session-id catch block is untested in both hook suites

**Verdict: PASS.**

| | |
| --- | --- |
| Implementing tasks | [P1-T2] and [P2-T2] (test additions only; **no production line changes for B-3**) |
| Pinning tests | `falls through to the worktree-derived id when the session-id file is unreadable` in each of the two hook suites, each driving `Get-*BatchBudgetSessionId` directly with a throwing `-ReadSessionIdFile` seam |
| Fail-before disposition | A failing run is structurally impossible, because the catch block already exists and already behaves correctly. The fail-before requirement is satisfied by the exception dossier `.../evidence/regression-testing/fail-before-exception.2026-08-29T23-07.md` together with the per-line alternative proof below |
| Alternative proof, before | Form D rows in `.../evidence/remediation-baseline/powershell-suite-baseline.2026-08-29T23-07.md` (lines 154, 155: `ci=0`) and `.../python-suite-baseline.2026-08-29T23-07.md` (lines 151, 152: `ci=0`) |
| Alternative proof, after | Form D rows in `.../evidence/regression-testing/powershell-containment-pass-after.2026-08-29T23-07.md` and `.../python-containment-pass-after.2026-08-29T23-07.md`, re-confirmed at final QA in `.../evidence/qa-gates/powershell-suite-final.2026-08-29T23-07.md` and `.../python-suite-final.2026-08-29T23-07.md` (all four lines `mi=0`) |
| Coverage effect | `.../evidence/qa-gates/coverage-delta.2026-08-29T23-07.md` — both hooks moved from 93.8 to 95.3 percent scoped per-file LINE coverage |

No verdict on this page is PARTIAL or BLOCKED, so no missing-evidence entry is required. Every
artifact path named above was confirmed present on disk.

## Advisory findings N-2 through N-6 — out of scope, not addressed

The following five advisory findings were **out of scope for this remediation cycle and were not
addressed**. No task in the plan touched any of them, and none should be read as delivered.

| Id | Subject | Disposition |
| --- | --- | --- |
| N-2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state | Out of scope. Not owned by this feature. It remains one of the two failures preventing a clean unscoped Pester run. |
| N-3 | Duplicated `EnsureDirectory` + `WriteStateFile` sequence in both branches of the `persist-session-id.ps1` switch | Out of scope. `.claude/hooks/persist-session-id.ps1` and its bundle mirror were not edited in this cycle. |
| N-4 | Three unchecked Test Strategy checkboxes in `spec.md` lines 591-593 | Out of scope. These sit outside `## Acceptance Criteria` and were left as found. |
| N-5 | The `!`-negation case at `spec.md:629-630` is untested | Out of scope. No merge-module case was added for it. |
| N-6 | `appendManagedBlock` trailing-blank-removal loop uncovered | Out of scope. Those two statements remain the module's only uncovered lines; they appear in the final coverage table as the range `153-154`, the same statements the baseline reported as `151-152`, displaced by the two comment lines the D-2 edit added above them. |

## Advisory finding N-1 — addressed IN PART ONLY

N-1 names more than one uncovered region. It is **partly** addressed and must not be reported as
either unaddressed or fully addressed.

**Addressed:** the unreadable-session-id catch block. This is exactly the B-3 subject. The catch
bodies at `.claude/hooks/enforce-powershell-batch-budget.ps1:154-155` and
`.claude/hooks/enforce-python-batch-budget.ps1:151-152` moved from uncovered (`ci=0`) to covered
(`mi=0`) in both hooks, evidenced by the Form D before-and-after pairs cited under B-3 above. N-1
also predicted that closing this gap would reverse the two per-file coverage declines recorded during
the original cycle; the observed rise from 93.8 to 95.3 percent in each hook is consistent with that.

**Not addressed, and out of scope:** the other regions N-1 names remain uncovered.

- The **empty-root guard** in `Test-*BatchBudgetPathInRoot` — N-1 describes it as an untested
  fail-open branch. It is still untested.
- The **null-or-whitespace path guard** in the same function. Still untested.

Both are siblings of the D-1 edit line. The plan's sibling-invalidation review recorded that they
stay uncovered, that no task asserts on them, and that the D-1 replacement adds no line so neither
the file's line count nor the Form D line numbers move. That prediction held: both hook files
retained their baseline line counts of 457 and 454.

**N-1 is therefore reported as PARTIAL, not as unaddressed and not as complete.**

## Acceptance-criteria checkbox state

**No `## Acceptance Criteria` checkbox in `spec.md` changed state in this cycle.**

Verified live against
`docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md` at the time of writing:

- Total checkbox items under `## Acceptance Criteria`: **17**
- Checked (`- [x]`): **16**
- Unchecked (`- [ ]`): **1**

These three counts are identical to the state [P0-T2] recorded before any edit in this remediation,
so no checkbox was checked and none was unchecked.

The single unchecked item is at `spec.md:773`. It requires
`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
`mcp__drm-copilot__run_poshqc_test` to all pass in a single consecutive run with no file
modifications. It **remains unchecked, deliberately**. A consecutively clean unscoped PoshQC test run
is unsatisfiable in this worktree for two independently verified pre-existing reasons outside this
remediation's scope: one failure in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`,
and one in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (advisory N-2), the
latter produced by `enforce-epic-wave-barrier.ps1` reading the ambient epic checkpoint, which
currently records issue 596 itself as carrying unmerged `depends_on` edges. This plan deliberately
runs no unscoped Pester invocation and states no acceptance condition over one, so this criterion was
neither attempted nor satisfied in this cycle.

The two Major findings are conformance defects against criteria already recorded as satisfied, and
B-3 closes a `## Test Strategy` edge case that carries no acceptance criterion. That is why the
checkbox state is expected to be unchanged rather than merely observed to be.

Output Summary: B-1 **PASS**, B-2 **PASS**, B-3 **PASS**, each mapped to its implementing task, its
pinning test, and its named evidence artifact paths, all confirmed present on disk. No verdict is
PARTIAL or BLOCKED, so no missing-evidence entry is required. Advisory findings N-2 through N-6 were
out of scope and were **not** addressed. Advisory finding N-1 was addressed **in part only** — the
unreadable-session-id catch block that B-3 covers is now covered in both hooks, while the empty-root
guard and the null-or-whitespace path guard that N-1 also names remain uncovered and out of scope.
No `## Acceptance Criteria` checkbox in `spec.md` changed state: 17 items, 16 checked, 1 unchecked,
identical to the [P0-T2] baseline, with the single unchecked item at line 773 left unchecked
deliberately because a consecutively clean unscoped PoshQC run is blocked by two pre-existing
out-of-scope failures.
