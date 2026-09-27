# Phase 9 Scoped Pester Verification (issue #673, closing #672)

Timestamp: 2026-09-19T19-01

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-hooks,tests/scripts/claude-runtime`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-hooks,tests/scripts/claude-runtime -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1`.

EXIT_CODE: 0

## Report freshness

- JUnit report last write (UTC): `2026-09-19T19:02:55Z`, later than this artifact's `Timestamp:` of `2026-09-19T19-01`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 1905 |
| `failures` | 0 |
| `errors` | 0 |

Testcases carrying a `failure` child: none. The `[P0-T10]` baseline recorded no failing test, so no exclusion applies and the zero is unconditional.

## The five named testsuites

| Testsuite | tests | failures | passed |
| --- | --- | --- | --- |
| `enforce-prd-feature-before-planner.Tests.ps1` | 47 | 0 | 47 |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 0 | 25 |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 24 | 0 | 24 |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | 13 | 0 | 13 |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | 8 | 0 | 8 |

All four `enforce-prd-feature-before-planner*` testsuites are present. The identity suite has all 13 of its §7 rows passing, each appearing exactly once. `every production call to Get-PrdFeatureCheckpointFolder supplies CheckpointPath explicitly` is Passed, taking the runtime guard from seven rows to eight.

The TargetResolution suite fell from 28 rows to 24: five rows were deleted because their subject was removed, and one was added, which is a net of four.

## Line coverage of the two prd gate files

| File | Line coverage | `covered` | `missed` | `line` elements |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 90.32% | 84 | 9 | 93 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 96.61% | 57 | 2 | 59 |

Both are above the 85% floor.

One figure is flagged for `[P11-T5]` rather than left to be discovered there. The gate file's baseline was 90.72% (88 covered, 9 missed, 97 elements) and it now reads 90.32% (84 covered, 9 missed, 93 elements). The missed count is unchanged at 9; what moved is the denominator, because deleting the unreachable session-root guard removed four **covered** lines. A change that deletes covered code lowers the ratio while improving the file, which is the arithmetic `[P11-T5]`'s no-regression condition has to be read against. This figure is from a two-folder scoped run; `[P11-T4]` measures the whole configured path and is the number `[P11-T5]` consumes.

## Every testcase under the five testsuites

| Testsuite | Testcase | Status |
| --- | --- | --- |
| `enforce-prd-feature-before-planner.Tests.ps1` | `tool input parsing.denies an empty payload as an envelope anomaly (fail closed)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `tool input parsing.allows when subagent_type is not atomic-planner` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `tool input parsing.allows when subagent_type is missing from a well-formed tool_input` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `tool input parsing.denies the legacy flat root shape as a missing-tool_input anomaly` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `tool input parsing.denies unparseable JSON instead of throwing (exit 1 is non-blocking)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.allows when both spec.md and user-story.md exist in the target folder (prompt path)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.blocks when spec.md is missing` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.blocks when user-story.md is missing` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.blocks when no feature folder is found in prompt and no checkpoint exists` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.allows the session-root fallback when the derived target is the session root` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.prefers the prompt-derived folder over the checkpoint folder` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.treats a path ending in .md as a file and uses its parent directory` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `atomic-planner delegation.accepts backslash separators inside the prompt path` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Entrypoint transport.reads the payload through the shared reader` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Entrypoint transport.emits a block decision JSON when prerequisites are missing (AC-7)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Entrypoint transport.real Test-Path wrapper returns $false for a nonexistent path` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Entrypoint transport.Get-PrdFeatureCheckpointFolder returns $null when checkpoint is absent` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Find-PrdFeatureFolderFromPrompt.returns $null for empty prompt` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Find-PrdFeatureFolderFromPrompt.returns $null when no docs/features/active path is present` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Find-PrdFeatureFolderFromPrompt.returns the folder when one is present` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Find-PrdFeatureFolderFromPrompt.strips .md suffix to a folder parent` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns full-feature for an exact full-feature marker` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns full-bug for an exact full-bug marker` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns minor-audit for an exact minor-audit marker` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.normalizes the legacy full marker to full-feature` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.is case-insensitive on the marker label` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns $null when no marker line is present` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns $null for an unrecognized marker value` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns $null for empty content` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Resolve-PrdFeatureWorkMode.returns $null for $null content` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureRequiredFile.requires spec.md and user-story.md for full-feature` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureRequiredFile.requires spec.md only for full-bug` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureRequiredFile.requires neither file for minor-audit` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureRequiredFile.returns spec.md alone for a $null mode so no reachable path can demand user-story.md` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureRequiredFile.returns spec.md alone for an unrecognized mode string so no reachable path can demand user-story.md` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureIssueContent.returns $null when issue.md does not exist` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `Get-PrdFeatureIssueContent.returns $null when issue.md exists but Get-Content throws (unreadable)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `allows full-feature mode when spec.md and user-story.md are both present` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `blocks full-feature mode when spec.md is missing, naming the work mode` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `allows full-bug mode when only spec.md is present (user-story.md absent)` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `blocks full-bug mode when spec.md is missing and does not demand user-story.md` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `allows minor-audit mode even when spec.md and user-story.md are both absent` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `treats the legacy full marker as the full-feature requirement set` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `fail-closed prerequisite resolution (AC: unable to determine work mode).fails closed when the work-mode marker line is absent from issue.md` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `fail-closed prerequisite resolution (AC: unable to determine work mode).fails closed when issue.md exists but is unreadable` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `fail-closed prerequisite resolution (AC: unable to determine work mode).fails closed when the marker value is unrecognized` | Passed |
| `enforce-prd-feature-before-planner.Tests.ps1` | `fail-closed prerequisite resolution (AC: unable to determine work mode).fails closed when issue.md itself does not exist` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.resolves the same folder when the prompt cites the feature folder alone` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.resolves the same folder when the prompt cites a research artifact path` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.resolves the same folder when the prompt cites an evidence artifact path` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.resolves the folder from a nested artifact path with no folder citation` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.rejects a token that truncates to fewer than four segments` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `folder resolution by four-segment truncation.yields one distinct candidate when one folder is cited at three depths` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `deterministic selection among two feature folders.prefers the derived target when it occurs later in the prompt` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `deterministic selection among two feature folders.denies when the checkpoint is absent and the tie cannot be resolved against the derived target` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `deterministic selection among two feature folders.denies when the checkpoint names a folder that is not a candidate` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `decision equivalence and the reproduction differential.returns the same decision for all four prompt forms` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `decision equivalence and the reproduction differential.returns the same decision for folder-relative and repo-relative research paths` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `decision equivalence and the reproduction differential.allows full-bug with spec present and user-story absent citing a nested research artifact` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `preserved gate behavior.denies full-feature when spec.md is missing` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `preserved gate behavior.denies full-bug when spec.md is missing` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `preserved gate behavior.denies full-feature when user-story.md is missing and names it` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `preserved gate behavior.allows minor-audit when neither prerequisite file is present` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `preserved gate behavior.normalizes the legacy full marker to the full-feature prerequisite set` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.denies with the indeterminate-marker reason when the marker line is absent` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.denies with the indeterminate-marker reason when issue.md is unreadable` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.denies with the indeterminate-marker reason when the marker value is unrecognized` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.names the resolved folder and the issue.md path in the indeterminate reason` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.omits spec.md and user-story.md from the indeterminate reason` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `indeterminate work-mode marker.does not invoke the file-existence probe in the indeterminate branch` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `block message.names the resolved folder ahead of the prd-feature remedy phrase` | Passed |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `block message.retains the PRD_FEATURE_BLOCKED prefix on every deny reason` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `cross-file mock resolution smoke.observes a test-scope mock across the dot-source boundary` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `call-target resolution seam.resolves no target from a call whose text is empty` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `call-target resolution seam.hands the assembled prompt and description text to the identity resolver` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `call-target resolution seam.hands a branch label to the identity resolver` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `call-target resolution seam.supplies the process location as the session root and reads no envelope cwd` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.allows when the target root holds the required document` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.allows when the modelled cwd is the item worktree` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.allows a repo-relative citation placed in the item worktree` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.denies with the no-target code when the identity places in no live worktree` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.allows an absolute path to the target feature folder` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.allows an absolute path to the target feature folder` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.denies with the missing-document reason when the document is absent under the target root` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.denies with the ambiguity code when the target cannot be resolved` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.emits an ambiguity code distinct from the missing-document and marker reasons` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.runs no existence probe on the ambiguity branch` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.reads the checkpoint of the resolved worktree rather than the session root's` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.denies rather than selecting the earliest candidate on an unresolved tie` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.probes once on a full-bug allow row` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.probes twice on a full-feature allow row` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.resolves the required document set for each work mode` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.resolves the required document set for each work mode` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.resolves the required document set for each work mode` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.resolves the required document set for each work mode` | Passed |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | `target resolution matrix.denies with the ambiguity reason when the folder is absent from the target root` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R1 allows a coordinating-session delegation whose item is identified by issue number while the folder exists in twelve worktrees` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R2 denies with the no-target code when the prompt carries neither an issue number nor a branch` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R3 denies with the ambiguity code when two live worktrees record the issue` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R4 resolves by branch when a stale attempt records the same issue` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R5 reads the feature folder from the checkpoint of the resolved worktree when the prompt names none` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R5 never composes a checkpoint path under the coordinating session root` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R6 denies with the missing-document reason when a prerequisite is absent beneath the resolved worktree` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R7 ignores a feature-folder path when choosing the worktree` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R8 selects among two cited folders with the checkpoint of the resolved worktree` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R8 denies with the ambiguity code when the resolved checkpoint names neither cited folder` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd R9 denies with the work-mode reason when the marker is absent from the resolved folder` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd resolution-family and document-family reasons never appear in each other's decisions` | Passed |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | `prd lets no feature-folder path and no file path select the worktree` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Invoke-OrchestratorStatePreflight supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Get-PrAuthorCheckpointContent supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Get-ModelRoutingCheckpoint supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Test-EpicBaseBranchOverride supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Test-PrAuthorReceiptVerification supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Get-PrdFeatureCheckpointFolder supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `the in-scope hook files carry the checkpoint path literal in no string expression` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `the orchestrator-state module keeps its four hundred ninety-nine line count` | Passed |

Rows: 117. Failed: 0.

Output Summary: All acceptance conditions hold. The report post-dates this artifact's timestamp; the root records `failures 0` and `errors 0`; all four prd testsuites are present; all 13 identity-suite rows appear exactly once with status Passed; the widened `Get-PrdFeatureCheckpointFolder` row is Passed; and both prd gate files exceed the 85% line-coverage floor at 90.32% and 96.61%. All 117 rows across the five testsuites pass. The gate file's coverage ratio is 0.40 points below its baseline with an unchanged miss count, because the deleted guard was covered code; this is recorded for `[P11-T5]` rather than deferred to it.
