# Remediation Inputs — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-29T23-07
- Branch: `feature/batch-budget-state-portability-596` at `9e41b9bf`
- Source artifacts:
  - `docs/features/active/2026-08-29-batch-budget-state-portability-596/audit/2026-08-29T23-07/policy-audit.md`
  - `docs/features/active/2026-08-29-batch-budget-state-portability-596/audit/2026-08-29T23-07/code-review.md`
  - `docs/features/active/2026-08-29-batch-budget-state-portability-596/audit/2026-08-29T23-07/feature-audit.md`

Two findings are remediation-required. Six are advisory and are listed separately; none of the six
needs to be addressed before merge.

Change-budget note for the executor: R-1 touches four production `.ps1` files (two hooks plus their
two bundle mirrors) and two test `.ps1` files. The per-batch cap in `.claude/rules/powershell.md` is
3 production and 3 test files, so R-1 must be split across two batches, or run with an approved
`CLAUDE_POWERSHELL_BUDGET_PROD` override. Every `.claude/**` edit must be mirrored byte-identically
in the same change, and mirror parity must be re-verified with `git hash-object` afterwards.

---

## R-1 (Major) — Containment comparison omits the trailing separator

### Files

- `.claude/hooks/enforce-powershell-batch-budget.ps1` (line 92)
- `.claude/hooks/enforce-python-batch-budget.ps1` (line 92)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` (mirror)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` (mirror)
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (473 lines; 27 headroom)
- `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` (463 lines; 37 headroom)

### Finding

`spec.md` lines 326-328 pin the containment rule:

> normalize both the candidate path and the root with `-replace '\\', '/'`, `TrimEnd('/')` the root,
> and compare with `StartsWith($root + '/', [System.StringComparison]::OrdinalIgnoreCase)`

Both hooks compare without the appended separator:

```powershell
return $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
```

### Evidence

Executed against the shipped function with `root = C:/repos/wt/agent-abc`:

```
C:/repos/wt/agent-abc/src/a.ps1       inRoot=True    correct
C:/repos/wt/agent-abc-r2/src/a.ps1    inRoot=True    INCORRECT — different worktree
C:/repos/wt/agent-abcdef/src/a.ps1    inRoot=True    INCORRECT — different worktree
C:/synthetic-out-of-root/x.ps1        inRoot=False   correct
```

### Impact

Defect 3 in `issue.md` — "a path belonging to a different worktree is counted against the current
worktree's budget" — remains open for any sibling worktree whose directory name extends the current
root's name. Retry worktrees in this repository are named by suffixing the original (`-r2`, `-r3`),
so the collision is realistic. The helper is shared by the decision path and the rehydrate filter, so
a poisoned entry from a prefix-sharing sibling also survives rehydration and continues to consume a
slot.

### Required change

Compare against the root with a trailing separator appended, while continuing to admit a candidate
that is exactly the root. Preserve the existing early returns for a relative candidate and for an
empty root, and preserve `OrdinalIgnoreCase`.

### Required tests

One test per suite asserting that an absolute path under a sibling directory whose name extends the
root (for example root `/repo`, candidate `/repo-sibling/scripts/tool.ps1`, and the `.py` equivalent
for the Python suite) yields `permissionDecision = 'allow'`, `shouldWriteState` false, and unchanged
recorded-file lists.

Use a `.ps1` candidate in the PowerShell suite and a `.py` candidate in the Python suite. A candidate
that does not match the suite's scope filter returns the same assertion values at the scope filter
before the containment check runs, and the test would pass for the wrong reason.

### Verification

- Both suites pass.
- The new tests fail against the current implementation (confirm before fixing).
- `git hash-object` yields identical ids for both edited pairs.
- `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"` passes.
- Per-file line coverage for both hooks stays at or above 85 percent.

---

## R-2 (Major) — `mergeClaudeGitignore` deletes content following an unclosed managed block

### Files

- `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` (line 126; 164 lines)
- `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` (145 lines)

### Finding

```ts
const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;
```

When an opening sentinel is present but the closing sentinel is absent, `endIndex` becomes the file's
last line and `lines.slice(endIndex + 1)` is empty, so every line after the opening sentinel is
discarded.

### Evidence

Executed against the shipped function:

```
input:  "a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"
output: "a/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
```

`b/` and `c/` are lost.

### Impact

Contradicts the module's own documented invariant at line 26 ("Content outside the block is preserved
exactly, including its ordering") and the spec's at line 310 ("Content outside the block is preserved
byte-for-byte including its ordering"). The write lands in a **consumer** repository's `.gitignore`,
and the delivered file is deliberately omitted from `PushDownSummary.files`, so the loss is silent at
both ends. A consumer who removes the END line while editing, or who resolves a merge conflict across
the block, loses every subsequent ignore rule on the next push-down.

The branch is untested and is part of the 10 percent of branches the module does not cover.

### Required change

When no closing sentinel is found at or after the opening sentinel, treat the malformed block as the
opening line alone and preserve every line after it. The managed block replaces only the opening
line; the remainder of the document is retained in order.

The existing correct behaviors must be preserved: in-place replacement of a well-formed block, append
when no opening sentinel is present, no second block ever appended, and the fixed-point property
`f(f(x)) === f(x)`.

### Required tests

Add a case for input carrying an opening sentinel with no closing sentinel and content after it,
asserting that the trailing content survives, that each sentinel appears exactly once in the output,
and that the result is a fixed point.

### Verification

- `npx jest test/lib/push-down/` passes (currently 234 tests).
- The new test fails against the current implementation (confirm before fixing).
- `claude-gitignore-merge.ts` holds line coverage at or above 85 percent and branch coverage at or
  above 75 percent under its `coverageThreshold` entry. Branch coverage is expected to rise from 90
  percent, since the currently uncovered arm becomes exercised.

---

## Advisory — not remediation-required

Listed for the record. None needs to be addressed before merge.

| Id | Finding | Suggested disposition |
| --- | --- | --- |
| N-1 | Four newly added lines uncovered. The notable one is the unreadable-session-id catch block, which `spec.md:623` enumerates in its own Test Strategy edge-case list and which no test drives. The empty-root guard is an untested fail-open branch. | Optional: add a throwing `ReadSessionIdFile` seam test to each suite (about 12 lines each; both suites have cap headroom). Would also reverse the two per-file coverage declines. |
| N-2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state, contravening the Deterministic Test Requirements in `.claude/rules/powershell.md`. It is one of the two failures preventing a clean unscoped Pester run for every feature in this epic. | File as a separate issue. Not owned by this feature and out of its authorized scope. |
| N-3 | Duplicated `EnsureDirectory` + `WriteStateFile` sequence in both branches of the `persist-session-id.ps1` switch (lines 110-114 and 117-121). | Optional: hoist the write above the `switch` for any decision carrying a session id, matching the spec's stated "combined action" approach at `spec.md:436`. |
| N-4 | Three Test Strategy checkboxes in `spec.md` (lines 591-593) remain unchecked although the work is delivered. Outside `## Acceptance Criteria`, so the AC count is unaffected. | Optional documentation hygiene: check them off, or annotate them as non-AC template items. |
| N-5 | The `!`-negation case enumerated at `spec.md:630` is untested. | Optional: add one merge-module case. Behavior is correct by inspection. |
| N-6 | `appendManagedBlock` trailing-blank-removal loop uncovered (lines 151-152, the module's only uncovered lines). | Optional. Low risk. |

## Explicitly Not Remediation Triggers

**The two per-file PowerShell coverage declines (95.6 to 93.8 percent) are not a remediation
trigger.** The plan classified any negative per-file delta as blocking; that classification is
stricter than repository policy and does not create a merge gate. The policy gate in
`.claude/rules/general-unit-test.md` and `.claude/rules/powershell.md` is a **changed-lines** gate,
and it is met: covered lines rose 86 to 121 in each file, so no previously covered line regressed. The
four additional missed lines are newly added lines, not lost coverage. Both files clear the 85 percent
floor with 8.8 points of margin and repository-wide PowerShell coverage is unchanged at 94.7 percent.
Full reasoning in the policy audit, Adjudication 1.

**Acceptance criterion 17 (the unscoped PoshQC run) is not a remediation trigger.** The two failures
were independently verified pre-existing: reproduced at HEAD with names byte-identical to the Phase 0
baseline, absent from the branch diff in both suite and subject, and constant at 2 while discovery
rose from 3851 to 3904. One of the two is caused by `enforce-epic-wave-barrier.ps1` reading the
ambient epic checkpoint, which currently records issue 596 itself as having unmerged `depends_on`
edges — a condition that resolves on merge. Leaving the criterion unchecked is correct; no feature
work can satisfy it from inside this worktree. Full reasoning in the policy audit, Adjudication 2.
