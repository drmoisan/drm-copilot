# Gap 3 Fail-Before — Edit-Tool Bypass (Issue #253, P4-T3)

- Timestamp: 2026-06-26T15-50
- Scope: `.claude/hooks/enforce-completion-consistency.ps1` Edit-tool path.

## WhyFailingRunImpossible

A clean red Pester run cannot be produced before the Gap-3 change because the read-then-validate path and its `CheckpointReader` seam parameter do not yet exist. A test exercising the new seam (`-CheckpointReader`) would fail with a parameter-binding error rather than a meaningful assertion failure, and a test using only the current public surface cannot fail because the current hook unconditionally allows any Edit-style call. The gap is therefore proved by code inspection.

## Absence-of-Enforcement Proof

In `Invoke-CompletionConsistencyDecision`, after confirming the path is the checkpoint path, the hook reads `$toolInput.content`:

- Lines 251-254 (pre-change): `$content = $toolInput.content; if (-not $content) { return [ordered]@{ decision = 'allow' } }`.

An Edit tool call supplies only `old_string`/`new_string` and no `content`, so `-not $content` is true and the hook returns `allow` immediately. There is no read of the on-disk checkpoint and no application of the `old_string` -> `new_string` patch. Consequently an Edit that flips `next_step` to `complete` (asserting completion) without any `issue-num`/`feature-folder`/`ci_gate` evidence is ALLOWED before the change, bypassing the Write-path completion-evidence checks.

SearchScope: `.claude/hooks/enforce-completion-consistency.ps1` (full file).
SearchPatterns: `CheckpointReader`, `old_string`, `Get-CheckpointFileContent`, on-disk checkpoint read in the decision path.
SearchResult: none — no read-then-validate path present before the change; the Edit branch is the unconditional allow at lines 251-254.

## Pass-After

P4-T3 adds an injectable `CheckpointReader` seam and a read-then-validate path: when `content` is absent but `old_string` is present on the checkpoint path, the hook reads the on-disk checkpoint, applies the patch in memory, and runs the existing completion checks; it blocks when the patched result asserts completion without evidence and allows on missing file or non-matching patch. The five P4-T3 Pester contexts assert these behaviors (pass-after), including that an Edit producing a completion assertion without evidence is now blocked.
