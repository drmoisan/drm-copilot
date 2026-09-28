# Pinned behavioural decisions — remediation cycle 1, issue #596 ([P6-T2])

Timestamp: 2026-08-30T01-52
Task: [P6-T2]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: this task records two decisions already pinned in the plan. It runs no toolchain stage. The
implementing edits were verified live against the tree at
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5` by the [P4-T2]
literal gate and the [P5-T5], [P5-T6], and [P5-T11] final QA runs.

EXIT_CODE: 0
ExpectedExitCode: 0

---

## Decision D-1 — the containment comparison, and the exact-root candidate

### The comparison as written

The containment predicate in both batch-budget hooks now reads, verbatim:

```
return ([string]::Equals($normalizedPath, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $normalizedPath.StartsWith($normalizedRoot + '/', [System.StringComparison]::OrdinalIgnoreCase))
```

It replaced, in place and on a single line, the defective form:

```
return $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
```

The replaced line was `.claude/hooks/enforce-powershell-batch-budget.ps1:92` and
`.claude/hooks/enforce-python-batch-budget.ps1:89`, and the same line in each of the two bundle
mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.

The defect the change fixes is a prefix collision: without the `+ '/'` operand, a candidate in a
sibling directory whose name merely extends the root — `/repo-sibling/scripts/tool.ps1` against the
root `/repo` — satisfies `StartsWith` and is wrongly classified as in-root.

### The exact-root admission is retained, and the equality operand is how

`spec.md` lines 325-328 pin `StartsWith($root + '/', [System.StringComparison]::OrdinalIgnoreCase)`
and nothing else. That form **alone** would reject a candidate equal to the root, because the root
carries no trailing separator after `TrimEnd('/')`. The explicit `[string]::Equals` operand is what
keeps the exact-root candidate admitted.

**The three reasons this is the right reading of the spec rule rather than a departure from it:**

1. **The helper is shared with the rehydrate filter.** It is used by the decision path and by
   `ConvertTo-*BatchBudgetState`. The rehydrate filter applies no extension filter to persisted
   entries, so a persisted entry equal to the root is structurally representable in the state file
   even though the scope filter keeps it out of the decision path.
2. **The pre-fix behaviour admitted the exact-root candidate.** Narrowing it would be a behaviour
   change that no audit finding asks for. The remediation's mandate is to fix the prefix collision,
   not to tighten an unrelated case.
3. **The cost is one operand in one expression.** No structural change, no new function, no new
   line.

This decision is pinned by a dedicated regression test in each suite, titled
`admits a candidate path that is exactly the resolved root`, which calls
`Test-*BatchBudgetPathInRoot -Path '/repo' -Root '/repo'` and asserts the result is true. That test
passes both before and after the fix; its role is to prevent the D-1 edit from narrowing behaviour,
which is why it is not tagged `[expect-fail]`.

### The line-count constraint, and why it is load-bearing

The replacement was a single-line replacement of one existing line and **added no line and removed no
line**. This was binding rather than cosmetic: the B-3 fail-before evidence is a per-line coverage
record keyed on absolute line numbers 154 and 155 of the PowerShell hook and 151 and 152 of the
Python hook, and any line-count change in the same file would have silently moved those numbers
between the baseline capture and the final capture. Both files retained their baseline line counts
of 457 and 454, confirmed at [P1-T4], [P2-T4], and again at the end of Phase 5.

### What was preserved unchanged

The early return for a relative candidate, the empty-root guard, the null-or-whitespace path guard,
the function signature, the comment-based help, and `OrdinalIgnoreCase` throughout.

---

## Decision D-2 — the unterminated managed block

### The rule

**When no closing sentinel is found at or after the opening sentinel, the managed block is treated as
the opening sentinel line alone. Every line after the opening sentinel is preserved, in its original
order.** This is a single answer; no alternative was offered or considered at execution time.

### The edit as written

`extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:126` changed from:

```
const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;
```

to:

```
const endIndex = endOffset === -1 ? beginIndex : beginIndex + endOffset;
```

The adjacent comment above `endOffset` was updated to record both cases: a closer preceding the
opener belongs to an earlier malformed block, and an absent closer makes the managed block the
opening line alone, so every following line is preserved.

### Consequence 1 — the block's former body is retained as unmanaged content after the closed block

The former body of the unterminated block becomes ordinary unmanaged content sitting **after** the
newly closed managed block. On the reviewer's demonstrated input
`"a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"` the output retains `.old/`, `b/`, and
`c/` after the block.

Retaining `.old/` is correct under the module's line-26 invariant, which preserves content outside
the block rather than judging it. A stale ignore pattern is inert to git in the same way the module's
existing duplicate-entry decision already relies on. This consequence is accepted deliberately rather
than discovered later.

### Consequence 2 — the result is a fixed point, with each sentinel occurring exactly once

Applying the function to that output finds a well-formed block at `beginIndex = 1` with its closer
three lines later, replaces it in place, and returns the same document. **Each sentinel occurs
exactly once in the output.** The pinning test
`preserves content following an opening sentinel that has no closing sentinel` asserts both
properties directly: it checks `countOccurrences` reports exactly 1 occurrence of each sentinel, and
it asserts `mergeClaudeGitignore(merged)` equals `merged`.

### Consequence 3 — the well-formed path is untouched

`endOffset === -1` is false whenever a closer exists at or after the opener, so the well-formed path,
append-when-absent, and never-a-second-block are all unaffected. The seven pre-existing merge tests
each supply either no opening sentinel or a well-formed sentinel pair, so none of them can change
result. The closest case, `emits one managed block when a managed entry already appears outside it`,
is safe because its opener is immediately followed by its closer, giving `endOffset` of 1. All seven
passed unchanged, evidenced in
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/regression-testing/gitignore-merge-pass-after.2026-08-29T23-07.md`.

### What was preserved unchanged

`toLines`, `toDocument`, `appendManagedBlock`, `renderManagedBlock`, `normalizeLineEndings`, every
exported constant, and the module's zero-import property.

Output Summary: Decision D-1 is recorded in full — the containment comparison now combines an
`[string]::Equals` operand with a `StartsWith($normalizedRoot + '/', ...)` operand; the exact-root
admission is retained deliberately, for the three reasons stated (the helper is shared with the
rehydrate filter, the pre-fix behaviour admitted it, and the cost is one operand); and the
replacement added and removed no line, which is what keeps the B-3 per-line coverage numbers valid.
Decision D-2 is recorded in full — an unterminated managed block is treated as its opening line
alone, the block's former body is retained as unmanaged content after the closed block, and the
result is a fixed point in which each sentinel occurs exactly once.
