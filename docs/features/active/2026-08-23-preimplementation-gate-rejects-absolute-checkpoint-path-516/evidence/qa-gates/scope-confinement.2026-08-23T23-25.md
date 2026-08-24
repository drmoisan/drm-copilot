# Scope Confinement — Only Two Predicate Bodies Changed (issue #516)

Timestamp: 2026-08-24T16-47
Command: `git diff --stat` and `git diff -U0` against `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` for all four hook copies, plus a function-body extraction and byte comparison of every protected symbol against its baseline text
EXIT_CODE: 0

Baseline substitution applies; see `evidence/baseline/baseline-branch-and-fileset.2026-08-23T23-25.md`.

## Diff Stat — all four copies

```text
 .claude/hooks/enforce-orchestration-preimplementation-gate.ps1                                                  | 33 +++++++++++++++++--
 extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1             | 33 +++++++++++++++++--
 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1                                                   | 37 ++++++++++++++++++++--
 extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1    | 37 ++++++++++++++++++++--
 4 files changed, 128 insertions(+), 12 deletions(-)
```

All four copies are modified, as required. Each family's two copies show identical stats, consistent with their byte-identity.

## Hunk Locations — exactly two per copy, both inside the two target functions

```text
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
@@ -62   +62,7   function Test-FeatureDocumentationOrEvidencePath
@@ -73,2 +79,23  function Test-ImplementationPath
+++ b/extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
@@ -62   +62,7   function Test-FeatureDocumentationOrEvidencePath
@@ -73,2 +79,23  function Test-ImplementationPath
+++ b/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
@@ -65   +65,7   function Test-FeatureDocumentationOrEvidencePath
@@ -76,2 +82,27  function Test-ImplementationPath
+++ b/extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
@@ -65   +65,7   function Test-FeatureDocumentationOrEvidencePath
@@ -76,2 +82,27  function Test-ImplementationPath
```

Every hunk's `@@` context marker names one of the two target functions, and every hunk falls inside that function's baseline line range:

| Copy | Function | Baseline line range | Hunk baseline lines | Contained |
| --- | --- | --- | --- | --- |
| Claude | `Test-FeatureDocumentationOrEvidencePath` | 57–63 | 62 | yes |
| Claude | `Test-ImplementationPath` | 65–77 | 73–74 | yes |
| Codex | `Test-FeatureDocumentationOrEvidencePath` | 60–66 | 65 | yes |
| Codex | `Test-ImplementationPath` | 68–80 | 76–77 | yes |

A diff shows exactly what changed, so text outside these four hunks is byte-unchanged by construction.

## Direct Byte Comparison of Every Protected Symbol

Rather than rely on hunk containment alone, each protected function was extracted from the baseline blob (`git show fb3e1f33:<path>`) and from the current working-tree file by brace-balanced parsing, and the two texts compared:

```text
=== .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
  Test-OrchestrationReady                              BYTE-UNCHANGED
  Test-ImplementationCommand                           BYTE-UNCHANGED
  Test-PreparationModeDelegation                       BYTE-UNCHANGED
  Test-ImplementationDelegation                        BYTE-UNCHANGED
  Get-CheckpointContent                                BYTE-UNCHANGED
  Invoke-OrchestrationPreimplementationGateDecision    BYTE-UNCHANGED
  Get-OrchestrationPreimplementationGateBlockDecision  BYTE-UNCHANGED
  Get-OrchestrationPreimplementationGateAllowDecision  BYTE-UNCHANGED
=== .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  Test-OrchestrationReady                              BYTE-UNCHANGED
  Test-ImplementationCommand                           BYTE-UNCHANGED
  Test-PreparationModeDelegation                       BYTE-UNCHANGED
  Test-ImplementationDelegation                        BYTE-UNCHANGED
  Get-CheckpointContent                                BYTE-UNCHANGED
  Invoke-OrchestrationPreimplementationGateDecision    BYTE-UNCHANGED
  Get-OrchestrationPreimplementationGateBlockDecision  BYTE-UNCHANGED
  Get-OrchestrationPreimplementationGateAllowDecision  BYTE-UNCHANGED
```

The two bundle mirrors inherit these verdicts through SHA256 equality with their canonical counterparts, confirmed at [P4-T9].

## Acceptance Conditions, Item by Item

| Symbol required byte-unchanged | Verdict | Basis |
| --- | --- | --- |
| `Test-OrchestrationReady` (including its `StartsWith('docs/features/active/')` on the checkpoint's own `feature-folder` field) | **BYTE-UNCHANGED** | direct body comparison |
| `Test-ImplementationCommand` | **BYTE-UNCHANGED** | direct body comparison |
| `Test-PreparationModeDelegation` | **BYTE-UNCHANGED** | direct body comparison |
| `Test-ImplementationDelegation` | **BYTE-UNCHANGED** | direct body comparison |
| `Get-CheckpointContent` | **BYTE-UNCHANGED** | direct body comparison |
| Payload-anomaly branch | **BYTE-UNCHANGED** | inside `Invoke-OrchestrationPreimplementationGateDecision`, compared as a whole |
| Block-reason text (`PREIMPLEMENTATION_GATE_BLOCKED: ...`) | **BYTE-UNCHANGED** | inside `Invoke-OrchestrationPreimplementationGateDecision` and `Get-OrchestrationPreimplementationGateBlockDecision`, both compared as a whole |
| Both entry points | **BYTE-UNCHANGED** | outside all four hunks; the Claude `Invoke-...EntryPoint` and dot-source guard sit below line 289 and the Codex entry block below line 302, both far past the last changed line |

`Test-OrchestrationReady` deserves separate mention because the spec names conflating it with the defective predicate as the most likely over-reach in this item. Its `StartsWith('docs/features/active/')` reads the checkpoint's own `feature-folder` value, which is repo-relative by the checkpoint contract rather than a tool-supplied path. It was not touched, and the comparison above confirms it byte-for-byte.

## One Protected Name Appears in the Diff, as Prose Only

A scan of every added and removed line for the protected symbol names returned exactly one distinct match, present in the Codex copy and its mirror:

```text
+    # repo-relative path harvested from a file marker by Test-ImplementationCommand
```

This is an **added comment inside `Test-ImplementationPath`**, recording why the segment anchor preserves idempotence for the `apply_patch` call site. It mentions `Test-ImplementationCommand` in prose; it does not modify it. The direct body comparison above independently confirms `Test-ImplementationCommand` is byte-unchanged in both canonical copies, and the two `apply_patch` idempotence cases in the new Codex suite pass, exercising that function's behavior directly.

Output Summary: Each of the four hook copies carries exactly two diff hunks, both confined to `Test-FeatureDocumentationOrEvidencePath` and `Test-ImplementationPath`, which are the only two function bodies this change modifies. A direct brace-balanced extraction and byte comparison against the baseline blob confirms `Test-OrchestrationReady`, `Test-ImplementationCommand`, `Test-PreparationModeDelegation`, `Test-ImplementationDelegation`, `Get-CheckpointContent`, the decision function containing the payload-anomaly branch and the block-reason text, and both decision-builder functions are all BYTE-UNCHANGED in both canonical copies; the two mirrors inherit the verdict through SHA256 equality. The single occurrence of a protected name in the diff is an added explanatory comment inside `Test-ImplementationPath`, not a modification.
