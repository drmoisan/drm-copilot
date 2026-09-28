<!-- markdownlint-disable-file -->

# Task Research Notes: Preimplementation Gate Record Resolution (Issue #606)

## Research Executed

### File Analysis

- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
  - `Find-OrchestrationDelegationIssueNumber` at lines 253-275 uses `issue[_-]?num(?:ber)?`, which accepts `issue_num` and `issue-number` but does not accept a space in `Issue number: 644`.
  - `Find-OrchestrationModeRecord` at lines 331-360 performs the folder and issue comparisons in one pass. An earlier record that matches only `issue_num` is therefore returned before a later record whose normalized `feature_folder` exactly matches the target.
  - Both epic and parallel readiness predicates call that shared resolver (lines 400 and 455), then reject only the returned record when its `merge_status` is terminal (lines 402 and 457).
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  - The decision function resolves the prompt folder and issue number at lines 412-417. `Get-OrchestrationModeDenyReason` at lines 315-330 preserves the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and reports only the mode, canonical checkpoint, and failed predicate.
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
  - SHA-256 equals the live hook SHA-256 before any change: `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4`.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
  - The deterministic Pester suite dot-sources both gate files (lines 34-44) and supplies literal JSON fixtures without filesystem, clock, network, process, or temporary-file dependencies (lines 21-31).
  - Existing target-resolution tests cover `issue_num: 301` and bare `issue #301` (lines 220-243), and existing readiness tests cover issue fallback only when the folder does not match (lines 298-302). They do not cover a prior issue-only record followed by a later exact-folder record.
  - Decision-level matrices assert deny reasons by stable fragments, including the prefix and failed predicate, rather than full equality (lines 385-403 and 422-478).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - The contract test compares each non-memory `.claude` resource as raw bytes between the repository root and bundled payload (lines 106-143). Any hook edit must update both copies identically.

### Code Search Results

- `Find-OrchestrationDelegationIssueNumber`, `Find-OrchestrationModeRecord`, and `merge_status`
  - The target hook is the only Claude-side implementation of the affected helper names. The two readiness predicates share `Find-OrchestrationModeRecord`; no duplicate resolver needs independent repair.
- `PREIMPLEMENTATION_GATE_BLOCKED` and `permissionDecisionReason`
  - The gate implementation documents the unchanged prefix as consumed by downstream reason matching. The focused Pester suite uses `Should -BeLike`/`Should -Match` fragments, but this search does not prove that every external consumer avoids full-string matching.
- Claude resource parity
  - Repository contract tests enforce byte parity for root `.claude` resources and their bundled mirror. The initial raw hashes match.

### External Research

- #githubRepo:"drmoisan/drm-copilot enforce-orchestration-preimplementation-gate-modes Find-OrchestrationModeRecord"
  - The checked-out tracked repository provides the authoritative implementation and focused Pester conventions described above; the shared resolver is the sole target for both epic and parallel records.
- #fetch:https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex.match?view=net-9.0
  - Microsoft documents that `Regex.Match` returns the first matching substring and exposes its capture groups through the returned `Match`. The gate's keyed parser therefore needs a pattern whose first successful match includes the required space-separated key form and preserves capture group 1 as the digits-only issue value.

### Project Conventions

- Standards referenced: `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.github/agents/task-researcher.agent.md`, and the focused suite header.
- Instructions followed: research output is feature-associated and timestamped under `docs/features/active/2026-08-30-preimplementation-gate-bare-hash-record-resolution-606/research/`; no evidence, source, test, configuration, or checkpoint files were changed.
- Validation status: `pwsh -NoProfile -Command "Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1' -CI -Output Detailed"` was denied before launch by the current preimplementation gate: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.` It is not a passing or failing Pester result.

## Key Discoveries

### Project Structure

The production behavior is concentrated in the pure Claude mode helper. The main gate owns payload parsing and deny transport, while the helper owns prompt token parsing and record readiness. The bundled file is a required byte-identical publication copy. One Pester suite already exercises the helper and decision-level epic and parallel paths, so the fix should stay within those three file paths.

### Implementation Patterns

The prompt parser is case-insensitive and returns strings, while checkpoint matching normalizes `feature_folder` to a basename. The readiness predicates use a shared resolver before testing terminal `merge_status`; consequently, target selection must be correct before any merge-status decision is trustworthy.

`Get-OrchestrationModeDenyReason` has a narrow, stable output contract: `PREIMPLEMENTATION_GATE_BLOCKED` prefix, mode, canonical checkpoint path, and quoted readiness predicate. The current failure signal for this defect is already the stable predicate name `merge_status`; adding resolved issue or status text would require passing additional context from the readiness predicate through the main gate and would change an externally observable diagnostic. The repository tests permit appended text, but the source comment identifies downstream matching and the workspace search cannot verify every consumer. Diagnostics should therefore remain unchanged for Issue #606.

### Complete Examples

The current single-pass selection implementation, from `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:331`, permits the defect because issue fallback happens before all folder candidates are inspected.

```powershell
foreach ($record in @($Records)) {
    if ($null -eq $record) { continue }
    if ($TargetFolder) {
        $folder = Get-OrchestrationModeString -Value $record -Name 'feature_folder'
        $basename = Get-OrchestrationModeFolderBasename -Path $folder
        if ($basename -and $basename -eq $TargetFolder) { return $record }
    }
    if ($IssueNumber) {
        $issue = Get-OrchestrationModeString -Value $record -Name 'issue_num'
        if ($issue -and $issue -eq $IssueNumber) { return $record }
    }
}
return $null
```

### API and Schema Documentation

The helper interface remains `Find-OrchestrationModeRecord -Records -TargetFolder -IssueNumber` and returns either a checkpoint record or `$null`. No checkpoint schema change is necessary. `issue_num`, `feature_folder`, and optional `merge_status` remain the consumed record keys. `merged` and `worktree_removed` remain terminal; absent status remains non-terminal.

### Configuration Examples

No configuration format or dependency is involved. The live hook and bundle resource must contain identical bytes after the implementation change.

### Technical Requirements

- The keyed issue parser must return `'644'` for `Issue number: 644`, while retaining case-insensitive matching, optional `#`, colon/equal separators, existing underscore/hyphen forms, and bare-hash fallback.
- Folder matching must search the complete record collection before issue-number fallback. If no folder matches, return the first issue-number match in collection order; if neither key matches, return `$null`.
- The multi-record regression must prove that an earlier issue-only terminal record cannot mask a later exact-folder non-terminal record for both epic `features` and parallel `items` readiness paths.
- Deny diagnostics must retain their current reason contract for this issue.
- Both hook copies must be raw-byte identical, and the existing root-to-bundle parity test must pass.

**Mandatory unachievable objective callout**:
- **No objective was proven unachievable.** The focused Pester baseline was not executable in the current session because the repository gate denied the command before launch; this does not prevent implementing or later validating the narrowly scoped fix in a checkpoint-ready execution session.

## Recommended Approach

Make the minimal shared-helper change and retain the existing deny text.

1. Widen only the separator position in the keyed issue pattern so it accepts whitespace in addition to the existing underscore and hyphen forms, preserving the existing digits capture as group 1. A suitable pattern shape is `issue[\s_-]?num(?:ber)?\s*[:=]\s*#?(\d+)` with the existing `IgnoreCase` option.
2. Split `Find-OrchestrationModeRecord` into ordered searches: first iterate all non-null records for normalized `feature_folder`; only after that search has no match, iterate records for `issue_num`. This implements the documented folder-first rule independent of record order.
3. Apply the same bytes to the bundled hook copy. Do not modify `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` or its deny reason helper.
4. Extend the focused Pester suite with parser coverage for `Issue number: 644` and deterministic multi-record epic and parallel readiness cases. Each case should place an earlier record with the prompt issue number and terminal status before the later exact folder record with a non-terminal status, then assert readiness/allow. This fails under the current resolver and passes only after the two-pass search.

Rejected alternatives: append the resolved issue and `merge_status` to the deny diagnostic, or create a new diagnostic transport object. Both enlarge an externally observable error contract without being needed to correct resolution; preserve the documented prefix and current predicate-only behavior. A folder-only resolver was also rejected because the existing issue fallback for renamed/missing folder paths is covered by the focused suite and must remain available after all folder candidates are checked.

## Implementation Guidance

- **Objectives**: Resolve human-readable keyed issue tokens and ensure exact feature-folder identity wins over issue fallback across the full checkpoint collection.
- **Key Tasks**: Update the live helper, copy the exact bytes to the bundle mirror, add the focused parser and multi-record readiness regressions, run focused Pester and Claude resource parity validation once the checkpoint permits commands.
- **Dependencies**: PowerShell 7 with Pester 5 for the focused suite; Python test environment for `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. No new package dependency is required.
- **Success Criteria**:
  - `Find-OrchestrationDelegationIssueNumber -Prompt 'Issue number: 644'` returns `'644'`.
  - A later exact-folder record is selected over an earlier issue-only record in both epic and parallel readiness paths.
  - Existing issue fallback remains valid when no folder matches.
  - Terminal merge statuses continue to deny only for the correctly resolved record, and existing deny reason wording remains unchanged.
  - The two hook copies have equal raw bytes and both focused validation commands pass.

## Terminal Result Contract

Handoff to `prd-feature` and atomic planning may proceed from this artifact. The implementation plan must limit production edits to the live mode helper and its bundled mirror, limit tests to the focused Claude Pester suite, preserve the current deny diagnostic contract, and require recorded passing Pester and resource-parity results before completion. The unavailable baseline command must be rerun after the orchestration checkpoint is ready.
