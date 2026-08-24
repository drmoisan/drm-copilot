# 2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path (Spec)

- **Issue:** #516
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-24T10-35
- **Status:** Ready for Planning
- **Version:** 0.1

Work mode is `full-bug`; this file is the sole acceptance-criteria source. Authoritative technical input: `research/research.2026-08-24T09-50.md` in this folder.

## Context and Defect Statement

`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` classifies a tool `file_path` as an implementation write unless it matches one of two exemptions. Both exemptions compare against repo-relative forms, but the incoming path is only separator-normalized — the workspace root is never stripped. The `Write` tool supplies absolute paths by contract, so every exempt path spelled absolutely is misclassified.

The defect sites, with line references to the working-tree file at research time (340 lines):

1. `Invoke-OrchestrationPreimplementationGateDecision`, lines 258–260 — the only normalization applied before classification:

   ```powershell
   if ($filePath) {
       $normalized = ([string]$filePath) -replace '\\', '/'
       $requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
   ```

2. `Test-ImplementationPath`, lines 65–77 — exempts via `Test-FeatureDocumentationOrEvidencePath` (lines 70–72), then checkpoint-literal membership `$script:CheckpointPaths -contains $NormalizedPath` (lines 73–75), then classifies by the extension pattern `-match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'` (line 76). An absolute spelling fails both exemptions and matches `\.json$`.

3. `Test-FeatureDocumentationOrEvidencePath`, lines 57–63 — `$NormalizedPath.StartsWith('docs/features/active/')`. An absolute path to a feature document does not carry that prefix, so feature-documentation and evidence writes with gated extensions (`.json`, `.yml`, `.ps1` fixtures) are also misclassified.

Observed consequence: with no checkpoint present — the state at the start of any orchestration — a `Write` of the checkpoint's absolute path is denied with the generalized `PREIMPLEMENTATION_GATE_BLOCKED` message about missing checkpoint fields. The checkpoint is required to exist before it may be created, and the block message misdirects the reader toward a content problem.

The same defect exists in the Codex variant `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (identical `Test-ImplementationPath` at lines 68–79; separator-only normalization at lines 272–273; the same classifier also receives apply-patch hunk paths at lines 92–103 and mapped Edit/Write paths at lines 321–327).

The hook ships in four copies that must stay consistent:

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

Copies 1 and 3 are byte-identical to each other, as are copies 2 and 4; push-down parity tests enforce both relations. The fix must land in all four and preserve both parity relations.

Severity: High. The gate fails closed, so this is not a safety hole, but it blocks the documented orchestration path at its first step and the only workaround (shell write with a relative path) is discoverable only by reading the hook source.

## Goal

Make both path exemptions and the extension classifier see the same repo-relative form for any spelling of a path that can be confidently resolved to a location under the workspace root — repo-relative, absolute with either separator style, either drive-letter case, duplicated separators, or identity `.` segments — while leaving every unresolvable form classified exactly as it is today.

## Non-Goals

- **This change must not widen the gate's exemption surface.** The gate is fail-closed by design. Every path form the hook cannot confidently resolve to an exempted location must remain classified as an implementation write. Specifically excluded from ever becoming exempt: paths outside the workspace root, `..`-bearing paths, UNC paths under a non-UNC root, drive-relative paths, and segment-misaligned root prefixes.
- No change to which paths are exempt in repo-relative form: the seven-literal checkpoint set, the `docs/features/active/` prefix, and the extension pattern are consumed unchanged.
- No change to the case semantics applied to the stripped tail (`-contains` case-insensitive, `StartsWith` case-sensitive, `-match` case-insensitive). Only the root-prefix comparison is case-insensitive.
- No change to the command classifier's classification logic or its command-pattern list in either variant, and no change of any kind to the Claude copy of `Test-ImplementationCommand`. The Codex copy receives only the optional `-WorkspaceRoot` parameter and the hunk-path normalization described under invariant 5, because its apply-patch hunk-path loop passes harvested paths to the same exemption classifier this fix corrects. No change to the block-message text, the delegation classifiers, the readiness logic, or the entry point contract (always exit 0).
- No changes to `enforce-evidence-locations.ps1` or `enforce-feature-folder-order.ps1` — verified in research section 1.5 not to share the defect (their `(^|/)` idiom is safe because it drives deny decisions).
- No centralization of the helper into `.claude/lib/hook-payload/HookPayload.psm1` (research section 2.3; the Codex variant does not import that module). Centralization is a possible follow-up, not part of #516.
- The undocumented `lifecycle_ready` requirement on the checkpoint exemption (issue.md, Suspected Cause, final bullet) is a separate observation and is not addressed here.

## Behavioural Specification

### Design shape

Per research sections 2.3, 3.2, and 8:

1. Add a pure helper function `ConvertTo-WorkspaceRelativePath -FilePath <string> -WorkspaceRoot <string>` to each hook variant. Pure string operations only: no filesystem access, no subprocess, no environment read.
2. Add an optional parameter `[string] $WorkspaceRoot = (Get-Location).Path` to `Invoke-OrchestrationPreimplementationGateDecision` (Claude variant) and its Codex equivalent. This is the injection seam; the default relies on the existing runtime guarantee that hook processes start in the workspace root (proven by the relative `-File` registration in `.claude/settings.json`).
3. Replace the two-line separator-only normalization (Claude lines 258–260; Codex lines 272–273) with one call to the helper. In the Codex variant only, thread the same root into the apply-patch hunk-path loop (Codex lines 92–103) via the optional `-WorkspaceRoot` parameter on `Test-ImplementationCommand`. The mapped Edit/Write loop (Codex lines 321–331) needs no edit: it calls the decision function, whose `-WorkspaceRoot` parameter default supplies the workspace root on that path. The root must not be sourced from the payload `cwd` field.
4. `Test-ImplementationPath`, `Test-FeatureDocumentationOrEvidencePath`, `$script:CheckpointPaths`, readiness logic, message text, and the entry point are not modified. Normalization happens once, upstream of both exemptions and the extension pattern, so all three checks stay consistent.

Rejected alternatives (research sections 3.1 and 9, binding on the planner): segment-anchored suffix matching (`(^|/)` idiom) widens the exemption to same-shaped paths outside the workspace; absolute literals in `$script:CheckpointPaths` are machine-dependent and forbidden by the list's own contract comment (hook lines 13–17); filesystem canonicalization (`Resolve-Path`, `[IO.Path]::GetFullPath`) requires existence or consults ambient cwd.

### Normalization contract

Inputs: raw `file_path` string `P`, workspace root string `R`. All steps are ordinal string operations (research section 4.1):

1. Normalize separators in both `P` and `R`: `\` becomes `/`.
2. Collapse duplicate separators (`(?<!^)/{2,}` → `/`) in both, preserving a leading `//` (UNC server prefix).
3. Remove identity dot segments from `P`: leading `./` (repeatedly), interior `/./`, trailing `/.`.
4. Fail-closed guard: if `P` still contains a `..` segment (`^\.\./`, `/\.\./`, or `/\.\.$`), skip stripping entirely and return `P` as-is. Textual `..` resolution is never attempted.
5. Trim all trailing `/` from `R`.
6. Segment-aligned prefix test: if `R` is non-empty and `P` starts with `R + '/'` under `[System.StringComparison]::OrdinalIgnoreCase`, the tail is `P.Substring(R.Length + 1)`. Return the tail when non-empty; return `P` unchanged when the tail is empty (path equals the root; carries no extension, so the classifier allows it).
7. Otherwise return `P` unchanged (relative paths, absolute paths outside the root, UNC paths under a non-UNC root, drive-relative forms).

Appending `/` to the root before the prefix test makes the match segment-aligned: root `C:/repo` tests prefix `C:/repo/`, which `C:/repository/...` does not carry. The root-prefix comparison is `OrdinalIgnoreCase` because Windows paths are case-insensitive and the Pester gate runs on `windows-latest` only; tail comparisons keep their existing semantics.

### Decision table

Root for all rows: `C:/wt/repo` (seam value `C:\wt\repo`). ALLOW means exempt or non-implementation; DENY means classified as an implementation write and therefore blocked whenever the checkpoint is not ready. Rows are derived from research section 4.2.

| # | Incoming `file_path` | Handling | Decision |
| --- | --- | --- | --- |
| 1 | `artifacts/orchestration/orchestrator-state.json` (repo-relative) | steps 6–7 no-op; existing literal match | ALLOW (existing) |
| 2 | `artifacts\orchestration\orchestrator-state.json` (repo-relative, backslashes) | separator normalization only | ALLOW (existing) |
| 3 | `C:\wt\repo\artifacts\orchestration\orchestrator-state.json` (Windows absolute, backslashes) | strip root → literal | ALLOW (the fix) |
| 4 | `C:/wt/repo/artifacts/orchestration/orchestrator-state.json` (absolute, forward slashes) | strip root → literal | ALLOW (the fix) |
| 5 | `c:\wt\repo\artifacts\orchestration\orchestrator-state.json` (drive-letter case difference) | OrdinalIgnoreCase prefix → literal | ALLOW |
| 6 | `C:/WT/REPO/artifacts/orchestration/orchestrator-state.json` (root-segment case difference) | OrdinalIgnoreCase prefix → literal | ALLOW (Windows filesystem is case-insensitive; same file) |
| 7 | row 3 path with root supplied as `C:/wt/repo/` (trailing separator) | step 5 trims; same as row 3 | ALLOW |
| 8 | `C:/wt/repository/artifacts/orchestration/orchestrator-state.json` (segment-misaligned root prefix) | prefix `C:/wt/repo/` absent → no strip → absolute string reaches classifier | DENY (fails closed) |
| 9 | `C:/wt/repo//artifacts//orchestration/orchestrator-state.json` (duplicated separators) | duplicates collapse → literal | ALLOW (same file) |
| 10 | `C:/wt/repo/./artifacts/orchestration/orchestrator-state.json` (`.` segments) | identity segments removed → literal | ALLOW (same file) |
| 11 | `C:/wt/repo/x/../artifacts/orchestration/orchestrator-state.json` (`..` segment) | step 4 guard → no strip | DENY (fails closed; `..` never resolved textually) |
| 12 | `//server/share/artifacts/orchestration/orchestrator-state.json` (UNC path, non-UNC root) | leading `//` preserved; prefix fails → no strip | DENY (fails closed) |
| 13 | UNC path under a UNC root (`//server/share/repo` seam + same-root path) | same segment-aligned logic | ALLOW (only when the seam root is that UNC root) |
| 14 | `C:/other/artifacts/orchestration/orchestrator-state.json` (absolute, outside workspace root) | prefix fails → no strip | DENY (fails closed; identical to current behaviour) |
| 15 | `./artifacts/orchestration/orchestrator-state.json` (leading `./`) | leading `./` removed → literal | ALLOW (behaviour change from today's DENY; `./` is identity, resolution is confident) |
| 16 | `C:/wt/repo/docs/features/active/2026-08-23-...-516/evidence/x.json` (absolute feature-evidence path, gated extension) | strip root → `StartsWith('docs/features/active/')` | ALLOW (fixes exemption 2) |
| 17 | `C:/wt/repo/scripts/dev_tools/x.py` (absolute production source) | strip root → extension match | DENY (critical negative: absolute implementation writes stay gated) |
| 18 | `C:/wt/repo/artifacts/orchestration/some-other-file.json` | strip root → not in literal set | DENY (literal set, not directory prefix; absolute twin of Tests.ps1:290-298) |
| 19 | `C:/wt/repo/scripts/parallel-planner-state.json` (tail matches an exempted literal's basename but lives elsewhere) | strip root → not a literal | DENY (full-path equality, not basename; absolute twin of Tests.ps1:300-308) |
| 20 | `C:artifacts/orchestration/orchestrator-state.json` (drive-relative, no slash) | no root prefix → no strip; contains `:` so equals no literal | DENY (fails closed) |
| 21 | `C:\wt\repo/artifacts\orchestration/orchestrator-state.json` (mixed separators) | step 1 unifies → literal | ALLOW |
| 22 | `C:/wt/repo/ARTIFACTS/orchestration/orchestrator-state.json` (tail case variant, checkpoint) | strip → `-contains` is case-insensitive | ALLOW (identical to today's relative-tail semantics; not a widening) |
| 23 | `C:/wt/repo/DOCS/features/active/x/file.json` (tail case variant, prefix exemption) | strip → `StartsWith` is case-sensitive → falls to extension match | DENY (identical to today's relative-tail semantics) |
| 24 | `C:/wt/repo` exactly (path equals root) | empty tail → pass-through; no extension | ALLOW (no extension → not an implementation path, same as today) |

Non-widening invariant: every ALLOW row either (a) already allows today for the equivalent relative spelling, or (b) is a confidently-resolved spelling of the same file as an already-exempt relative form. Every form the algorithm cannot confidently resolve (rows 8, 11, 12, 14, 20) passes through unchanged and is denied by the unchanged classifier.

## Invariants Preserved

A reviewer must be able to check each of the following against the diff:

1. **Seven-literal checkpoint exemption set** — `$script:CheckpointPaths` (Claude hook lines 18–26) keeps exactly its seven repo-relative literals; no entry added, removed, or made absolute; the contract comment (lines 13–17) stands.
2. **`docs/features/active/` prefix exemption** — `Test-FeatureDocumentationOrEvidencePath` (lines 57–63) is textually unchanged, including its case-sensitive `StartsWith`.
3. **Implementation-extension pattern** — the regex `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$` (line 76) is unchanged.
4. **Preparation-mode delegation exemption (issue #535)** — `Test-PreparationModeDelegation` (lines 105–138), the marker constants (lines 31–34), and the probe in `Test-ImplementationDelegation` (lines 149–158) are unchanged; all issue #535 test contexts pass unmodified.
5. **Command classifier** — `Test-ImplementationCommand` (lines 79–103) is unchanged; command payloads are not path-based and take no normalization.
   - Clarification (Codex variant only): the Codex copy of `Test-ImplementationCommand` gains an optional `-WorkspaceRoot` parameter with a backward-compatible default of `(Get-Location).Path`, because the same defect reaches the exemption classifier through that function's apply-patch hunk-path loop (Codex lines 92–103); the harvested hunk paths are normalized with `ConvertTo-WorkspaceRelativePath` before classification. The Claude copy of `Test-ImplementationCommand` parses no hunk paths and is unmodified.
6. **Fail-closed payload-anomaly handling** — the anomaly deny path (lines 246–252) and the always-exit-0 entry-point contract are unchanged.
7. **Source-scan contracts** — the hook text contains no `$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT` literals (scanned including comments by `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`) and no Python invocation (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
8. **Mirror parity** — copies 1/3 byte-identical, copies 2/4 byte-identical, enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and the codex pack manifest test `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`.

## Testability

Every decision-table row is driven deterministically with no filesystem access and no dependence on the current working directory, per `.claude/rules/general-unit-test.md` (temporary files in tests are prohibited) and the Deterministic Test Requirements in `.claude/rules/powershell.md`:

- **End-to-end decision cases** — build the nested envelope with the existing helper pattern (`ConvertTo-ImplementationWriteToolInput`, Tests.ps1:9-19) and call `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $notReady -WorkspaceRoot 'C:\synthetic\root'`. Supplying `-CheckpointRaw` means `Get-CheckpointContent` — the only filesystem read on this path — never executes (the isolation the #535 tests already use, Tests.ps1:260-263). Supplying `-WorkspaceRoot` removes any cwd dependence, giving Terminal / Test Explorer parity.
- **Helper unit cases** — call `ConvertTo-WorkspaceRelativePath -FilePath ... -WorkspaceRoot ...` directly and assert the returned string, one behaviour per `It`. This pins the algorithm rows that are awkward end-to-end (rows 5, 9, 10, 13, 20, 22, 24, including the UNC-root positive and the path-equals-root degenerate).
- **Default-root line coverage** — the existing relative-path tests call the decision function without `-WorkspaceRoot`, so the `(Get-Location).Path` default expression executes under coverage; no assertion depends on its value because relative inputs never consult the root.
- **Placement** — the existing Claude test file is at 461 lines and cannot absorb the case matrix under the 500-line cap. New facet file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1`, dot-sourcing the hook as the existing file does. Codex twin cases go to a sibling facet file under `tests/scripts/codex-hooks/` (the existing contract file is at 494 lines).
- **Regression** — every existing relative-path test is kept unchanged. Absolute twins are added, not substituted; replacing the relative cases would relocate the blind spot rather than close it.

## Execution Constraints

- Four production files exceeds the PowerShell per-batch cap of 3 (`.claude/rules/powershell.md`, Change Budget). Execution must batch as #535 did: Claude pair plus Claude tests, then Codex pair plus Codex tests, with the batch-budget state reset between batches.
- Toolchain per batch: `run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, restarting from format on any change, until all stages pass in a single pass.
- Line budget: Claude hook 340 → approximately 395 lines; Codex hook 336 → approximately 395 lines; both must stay under 500. New facet test files sized under 500.

## Out of Scope

- Any file other than the four hook copies and new/updated test files. In particular: `.claude/lib/hook-payload/HookPayload.psm1`, `enforce-evidence-locations.ps1`, `enforce-feature-folder-order.ps1`, `.claude/settings.json` registrations, and every file under `.claude/rules/` and `.github/instructions/`.
- The block-message wording. The issue notes the message misdirects toward checkpoint content; distinguishing the two failure reasons is a possible follow-up, not part of this fix.
- The undocumented `lifecycle_ready` requirement on the checkpoint exemption.
- Centralizing the normalization helper for adoption by other hooks.
- Any change to checkpoint-content validation (`Test-OrchestrationReady`), which checks checkpoint fields, not tool paths.

## Risks and Mitigations

- **Risk: the fix widens the exemption surface.** Mitigated by the fail-closed pass-through (algorithm steps 4 and 7), the negative half of the test matrix (decision-table rows 8, 11, 12, 14, 17–20, 23), and the retained existing negative tests.
- **Risk: mirror drift across the four copies.** Mitigated by the existing byte-parity push-down tests, which fail on any divergence within a pair.
- **Risk: relocating rather than closing the test blind spot.** Mitigated by keeping every existing relative-path test unchanged and adding absolute twins alongside them.

## Acceptance Criteria

- [x] With an explicitly not-ready checkpoint injected via `-CheckpointRaw` and a synthetic root injected via `-WorkspaceRoot`, a `Write` payload whose `file_path` is the absolute Windows-backslash spelling of `artifacts/orchestration/orchestrator-state.json` under that root produces an allow decision (decision-table row 3, the reported defect). Verified by a named test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1`.
- [x] The absolute backslash and absolute forward-slash twins of each of the seven `$script:CheckpointPaths` literals produce allow decisions against a not-ready checkpoint (rows 3–4 generalized), asserted by iterating the literal list as Tests.ps1:259-274 does for relative forms. Verified by named tests in the new Claude facet test file.
- [x] Confident-resolution variants of the checkpoint path produce allow decisions: lower-case drive letter (row 5), upper-cased root segments (row 6), root supplied with a trailing separator (row 7), duplicated separators (row 9), `/./` segment (row 10), leading `./` (row 15), and mixed separators (row 21). Verified by one named test per row.
- [x] An absolute path to a gated-extension file under `docs/features/active/` (row 16) and the absolute twin of the existing `spec.md` case produce allow decisions against a not-ready checkpoint. Verified by named tests in the new Claude facet test file.
- [x] An absolute production-source write under the synthetic root (`...\scripts\dev_tools\x.py`, row 17) produces a deny decision against a not-ready checkpoint. Verified by a named test in the new Claude facet test file.
- [x] The absolute spelling of `artifacts/orchestration/some-other-file.json` under the synthetic root (row 18) produces a deny decision, preserving the literal-set (not directory-prefix) semantics of Tests.ps1:290-298 in absolute form. Verified by a named test.
- [x] The absolute spelling of `scripts/parallel-planner-state.json` under the synthetic root (row 19) produces a deny decision, preserving the full-path-equality (not basename) semantics of Tests.ps1:300-308 in absolute form. Verified by a named test.
- [x] Each remaining fail-closed form produces a deny decision: checkpoint-shaped path under a different root (row 14), segment-misaligned root prefix (row 8), `..`-bearing path (row 11), UNC path under a non-UNC root (row 12), drive-relative path (row 20), and the `DOCS/` tail case variant (row 23). Verified by one named test per row in the new Claude facet test file.
- [x] `ConvertTo-WorkspaceRelativePath` unit tests assert the returned string for rows 5, 9, 10, 13 (UNC root), 20, 22, and 24 (path equals root, empty tail) by direct call with injected `-FilePath` and `-WorkspaceRoot`. Verified by named helper-unit tests.
- [x] The Codex variant carries equivalent positive and negative coverage in a new facet file under `tests/scripts/codex-hooks/`, including the absolute checkpoint allow and the absolute production-source deny. Verified by named tests in that file.
- [x] The pre-existing test files `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` are unmodified (`git diff --stat main -- <path>` shows no change to either) and every assertion in both passes.
- [x] All four hook copies carry the fix: `git grep -l 'ConvertTo-WorkspaceRelativePath' -- '*.ps1'` lists exactly the four hook paths named in the Context section (plus test files); no other production file matches.
- [x] Both push-down parity relations hold: copies 1 and 3 have identical SHA-256 hashes, and copies 2 and 4 have identical SHA-256 hashes (verified by `sha256sum` over the four paths), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` pass.
- [x] `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` pass against the changed hooks (no forbidden environment literals, no Python invocation introduced).
- [x] The full PowerShell toolchain passes clean in a single pass: `run_poshqc_format` reports no file changes, `run_poshqc_analyze` reports zero findings, and `run_poshqc_test` reports zero failures.
- [x] PowerShell line coverage for the changed hook files is at or above the uniform 85% threshold with no coverage regression on changed lines, as reported by the `run_poshqc_test` coverage output. (Per `.claude/rules/quality-tiers.md`, Pester does not measure branch coverage, so no branch-coverage criterion applies to PowerShell.)
- [x] Every changed or added `.ps1` file remains under 500 lines: `Get-Content <file> | Measure-Object -Line` reports fewer than 500 lines for each of the four hook copies and each new facet test file.

## Rollout & Follow-up

- Delivery is a standard feature branch and pull request; no configuration, flag, or migration is involved. Rollback is a revert of the single PR.
- Follow-up candidates (out of scope here): distinguish the two `PREIMPLEMENTATION_GATE_BLOCKED` failure reasons in the message text; document the `lifecycle_ready` requirement in the orchestrate skill; consider centralizing the normalization helper for adoption by other path-classifying hooks.
- Links: issue #516 (https://github.com/drmoisan/drm-copilot/issues/516), `issue.md` and `research/research.2026-08-24T09-50.md` in this folder; related prior work: issue #535 / PR #536 (checkpoint-literal and preparation-mode exemptions), issue #501 (payload-envelope test-shape blind spot).
