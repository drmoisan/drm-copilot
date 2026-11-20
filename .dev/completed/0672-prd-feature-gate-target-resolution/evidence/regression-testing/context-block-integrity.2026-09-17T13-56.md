# Context-block integrity of the FolderResolution suite after the Phase 1 amendment

Timestamp: 2026-09-17T13-56

Task: `[P1-T5]` of `remediation-plan.2026-09-17T12-29.md`
Criterion this protects: criterion 20 (`spec.md` line 639), the #518 depth-insensitivity criterion, which
requires the truncation `Context` block and the preserved-gate-behaviour `Context` block in
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` to pass
byte-unmodified.

Command:

- `git merge-base --is-ancestor 1b150689c2d6bbda848ae10ec92e4ccc018a5560 HEAD`
- `git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
- `Select-String -SimpleMatch -Pattern 'Resolve-WorktreeCallTarget' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'`

EXIT_CODE: 0

- `git merge-base --is-ancestor` exit code: **0**.
- `git diff` exit code: 0.
- `Select-String` exit code: 0.

Anchor precondition: `<baselineHead>` is bound to `1b150689c2d6bbda848ae10ec92e4ccc018a5560`, the commit
recorded by `[P0-T2]`. The ancestry check exits **0**, so the branch was not re-anchored after `[P0-T2]` and
the diff below spans this remediation's change set only. The halt branch stated in `[P1-T5]` is therefore not
taken.

Output Summary:

## `Resolve-WorktreeCallTarget` occurrence count

**1**, at line 28 — the statement this task added, inside the Describe-level `BeforeAll`. The acceptance
requires exactly one match, so the file carries no second reference to the derivation.

The alternative placement permitted by `[P1-T4]` and `[P1-T5]` — a Describe-level `BeforeEach` immediately
after the `BeforeAll` — was **not** required. The `BeforeAll`-level mock is observed by the contained cases on
this Pester version (5.6.1), as `[P1-T6]` confirms by result.

## Anchored diff — verbatim

```
diff --git a/tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 b/tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
index c087c7f0..991a64ab 100644
--- a/tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
+++ b/tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
@@ -25,6 +25,7 @@ Describe 'enforce-prd-feature-before-planner.ps1 folder resolution' {
         $script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
         . $script:UnderTest
         . $script:Helpers
+        Mock -CommandName Resolve-WorktreeCallTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot '/synthetic-worktrees/session-root' -Detail 'modelled no-target for the delivered cases' }
     }

     Context 'folder resolution by four-segment truncation' {
```

The diff is a single hunk with a single `+` line and no `-` line. The added line sits inside the
`BeforeAll` block, between the `. $script:Helpers` dot-source and the block's closing brace. No line whose
content belongs to any `Context` appears as an added or removed line; the three unchanged trailing context
lines that git prints for readability — the closing brace, the blank line, and the `Context` opening line —
are unmodified lines shown for position, each prefixed with a space rather than a `+` or `-`.

## Context-block start lines after the amendment

| `Context` | line after amendment | line before amendment |
| --- | --- | --- |
| `folder resolution by four-segment truncation` | 31 | 30 |
| `deterministic selection among two feature folders` | 88 | 87 |
| `decision equivalence and the reproduction differential` | 149 | 148 |
| `preserved gate behavior` | 238 | 237 |
| `indeterminate work-mode marker` | 319 | 318 |
| `block message` | 409 | 408 |

Every block shifted down by exactly one line, which is the arithmetic consequence of one line being inserted
above all six of them. A uniform one-line shift with an empty added-and-removed set inside the blocks is the
positive evidence that no block's content changed: had any line inside a block been edited, that line would
appear in the diff as a `+`/`-` pair.

The two blocks criterion 20 names are `folder resolution by four-segment truncation`, which the plan cites as
beginning at line 30 pre-amendment and which measures 30 pre-amendment, and `preserved gate behavior`, which
the plan cites as beginning at line 237 pre-amendment and which measures 237 pre-amendment. Both citations are
confirmed against the tree, and both blocks are byte-unmodified.

Acceptance for the diff clause of `[P1-T5]`: the anchored diff shows added lines only inside the `BeforeAll`
block and no line whose content belongs to either named `Context`. Satisfied. The suite's node and pass counts
are recorded separately by `[P1-T6]`.
