# exempt-operand-unc-path-leg-937 (Spec)

- **Issue:** #937
- **Parent (optional):** none (follow-up to #732 code-review CR-1; #903 Operator Follow-up 8)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T17-50
- **Status:** Draft
- **Version:** 0.2

## Context

- Summary: in the orchestration preimplementation gate, `Get-OrchestrationCommandTarget` maps a path-leg input (Claude Write/Edit `file_path`; Codex `apply_patch` marker path) to the session root when the input is spelled as UNC (`\\server\share\...`), extended-length (`\\?\C:\...`, `\\?\UNC\...`), or device (`\\.\...`). The epic-scope decision can therefore evaluate the coordinator's checkpoint instead of the worktree the path names, or deny nothing at all. Source: #732 `code-review.2026-10-09T05-42.md` CR-1 (Medium, Non-blocking), recorded as FU-6 and carried forward as #903 Operator Follow-up 8.
- Observed environment(s): any OS; the defect is in pure string logic and is platform-independent. Baseline: `main` at f6915d42.
- Customer impact and severity: Medium. Affects agents operating under an epic-scope session whose Write/Edit or `apply_patch` path uses a non-local spelling. Wrong-checkpoint evaluation weakens the gate's fail-closed guarantee; no data loss is directly caused.
- First observed date and version(s) impacted: reported 2026-10-09 in the #732 review; behavior equals the pre-#732 base, so it is not a regression.
- Technical source: `docs/features/active/exempt-operand-unc-path-leg-937/research/research.2026-10-15T17-46.md` (section 4.3 recommendation adopted).

## Repro & Evidence

- Steps to reproduce (reasoned in research section 1.3; reproduced by the reviewer probe in #732 CR-1):
  1. Call `Get-OrchestrationCommandTarget -FilePath @('\\?\C:\wt\other\a.ps1') -SessionRoot 'C:\wt\coordinator'`.
  2. Line 224 normalizes the path to `//?/C:/wt/other/a.ps1`.
  3. Line 225 tests it against `$script:OrchestrationTargetAbsolutePattern` (`'^([A-Za-z]:/|/(?!/))'`, line 36); the match fails, so the session root is added as the target.
- Expected vs actual behavior:
  - Expected: a non-local path-leg spelling is denied as unresolvable.
  - Actual: `Resolved=$true`, `Targets=@('C:/wt/coordinator')`.
- Logs/screenshots/error snippets: #732 code-review line 24 (`extended-length Write path | Resolved=True | Targets=C:/wt/coordinator`).
- Frequency / determinism: deterministic for every UNC, extended-length, and device spelling in either separator style.
- Correction to the issue text: the issue's reproduction names `git -C`. The R6 `-C` selector leg already denies these spellings (`selector-backslash` for backslash forms, `selector-not-absolute` for forward-slash forms; pinned by U14 and U16). Only the R1 path-leg loop misresolves. The issue's line references (31, 201) are stale; the current pattern is at line 36 and the path-leg loop at lines 223-230.
- Related spelling (in scope by orchestrator decision): a drive-relative path-leg input such as `C:wt\a.ps1` normalizes to `C:wt/a.ps1`, fails the same pattern, and also resolves to the session root through the same loop (research Risk 2).

## Scope & Non-Goals

### In scope

- R1 path-leg loop of `Get-OrchestrationCommandTarget` in every byte-identical copy of `enforce-orchestration-preimplementation-gate-targets.ps1`.
- Fail-closed denial of UNC, extended-length, device, and NT-object spellings in either separator style, and of drive-relative spellings.
- Unit rows on both surfaces and end-to-end gate rows on the Claude (Write) and Codex (`apply_patch`) surfaces.

### Non-Goals

- Normalizing non-local spellings to a local form and resolving them (research option (a), rejected).
- The single-feature fallback in `Resolve-WorktreeOperandTarget` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`), which treats `//...` as absolute and falls back to the session worktree when no `.git` marker is found. It is a separate code path with documented fallback semantics and is not changed.
- `ConvertTo-OrchestrationTargetPath`, `$script:OrchestrationTargetAbsolutePattern`, the R0 session-root rule, the R6 `-C` selector leg, and the verdict cache key.
- The epic-scope callers (`enforce-orchestration-preimplementation-gate-epic-scope.ps1`, every copy) and the `pack-manifests/core.json` files.
- Parser files (`hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-payload*.ps1`, `hook-command-heredoc.ps1`).
- The #927 parser test files `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` and `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` are not touched.
- Changing the non-epic-scope verdict (`none`) for an unresolved result; that is the documented #732 D3 contract and applies to every unresolvable rule.

### Explicitly excluded systems

- No network, UNC share, or real Windows device path is used in verification; all inputs are string literals and every filesystem seam in the gate suites is mocked.

## Root Cause Analysis

- Confirmed root cause (source reading, research sections 1.2-1.3): the R1 loop treats any normalized input that fails `$script:OrchestrationTargetAbsolutePattern` as relative and contributes the session root (`$targets.Add($root); continue`). The pattern deliberately rejects a leading `//`, so every UNC, extended-length, and device spelling, and every drive-relative spelling, is classified as relative.
- Signals: #732 reviewer probe output; per-spelling trace table in research section 1.3.
- Affected components:
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`

## Proposed Fix

### Design summary (what changes where):

Fail closed (research option (b)). In the R1 path-leg loop, test the raw input before normalization. When the raw input begins with a non-local prefix or is a drive-relative spelling, return an unresolved result with rule token `path-not-local`. All other path-leg inputs behave exactly as today.

### Boundaries and invariants to preserve:

- `ConvertTo-OrchestrationTargetPath` and `$script:OrchestrationTargetAbsolutePattern` are unchanged.
- R0 (session root), R2-R7 (command loop), and the R6 `-C` selector leg are unchanged.
- Existing unit rows U01-U05, U14, and U16 keep passing unchanged.
- A bare drive root (`C:\`, `C:/`) keeps today's behavior: it normalizes to `C:/`, matches the absolute pattern, and is contributed as its own target.
- A relative path such as `scripts/a.ps1` keeps contributing the session root (U02).
- The targets copies stay byte-identical (SHA-256), use LF line endings, have every line at or below 120 characters, and stay at or below 500 lines.

### Dependencies or blocked work:

- None. The change does not depend on #927.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- Production (identical edit, then copied byte-for-byte): the targets copies listed under Root Cause Analysis.
- Tests:
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`

#### Functions/classes/CLI commands impacted:

- `Get-OrchestrationCommandTarget` (R1 path-leg loop only).
- New module-scope pattern variable(s) adjacent to `$script:OrchestrationTargetAbsolutePattern`, for example:
  - `$script:OrchestrationTargetNonLocalPattern = '^(?:[\\/]{2}|[\\/]\?\?[\\/])'` (UNC, `\\?\`, `\\?\UNC\`, `\\.\`, `\??\`, either separator style, including mixed separators).
  - A drive-relative alternative matching a drive letter and colon not followed by a separator (for example `^[A-Za-z]:(?![\\/])`), which matches `C:wt\a.ps1` and bare `C:` but not `C:\` or `C:/`.
  - The planner may combine these into one pattern; the observable contract below is binding, not the exact regex text.

#### Data flow and validation changes:

- Inside `foreach ($rawPath in ...)`, the first statement tests `$rawPath` (not the normalized value) against the non-local/drive-relative pattern. Testing the raw value prevents the trailing-slash trim from collapsing a bare `\\` or `//` to `/`.
- On match: `return (New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath)`.
- The new check precedes the dot-segment check, so `\\server\share\..\x` reports `path-not-local`.
- R1 runs before the command loop; a non-local path denies even when another path in the same call is valid (first failing rule wins).

#### Error handling and logging updates:

- No new reason code. The result uses the existing `target-unresolvable` reason code and the existing deny text in `Get-OrchestrationEpicTargetDenyReason`. No logging change.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the targets copies and the test rows.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: `-FilePath` element whose raw value begins with `\\`, `//`, `\/`, `/\`, `\??\`, or `/??/`, or begins with a drive letter and colon not followed by `\` or `/`.
- Output: `Resolved=$false`, `Targets` empty, `ReasonCode='target-unresolvable'`, `Detail` beginning with `path-not-local` followed by `: ` and the raw input.
- Input (remediation cycle 1, issue #937 RI-2, RI-4, RI-5): a `-FilePath` element whose raw value begins or ends with whitespace, begins with `file:` (any case) or `~`, or begins with a single `\` not followed by `\` or `/`. Output: the same unresolved `path-not-local` result.
- Input (remediation cycle 2, issue #937 RI-7): a `-FilePath` element whose raw value begins with a URI scheme of two or more characters (a letter followed by one or more letters, digits, `+`, `.`, or `-`) and a colon, such as `http:`, `smb:`, `vscode-remote:`, or `git+ssh:`. Output: the same unresolved `path-not-local` result. A single drive letter and colon keeps the drive-relative and drive-root handling above.

#### Required configuration keys and defaults:

- None.

#### Backward-compatibility expectations:

- The function signature and result shape are unchanged. Callers in the epic-scope copies require no change.
- With an epic-scope session root, a non-local or drive-relative Write/Edit or `apply_patch` path now yields verdict `deny` with `target-unresolvable` where it previously yielded `evaluate`/`allow` against the session root. With a non-epic session root, the verdict remains `none` (D3 contract).

#### Performance constraints (latency/throughput/memory):

- One additional regex match per path-leg input; no measurable impact.

## Assumptions, Constraints, Dependencies

- Assumptions: the Write tool supplies absolute paths by contract, so legitimate callers are unaffected by denying drive-relative spellings.
- Constraints: Linux CI runs the hook suites, so tests must not pass UNC strings through `Join-Path`, `Resolve-Path`, `Test-Path`, `Split-Path`, or `[System.IO.Path]`; tests must not create temporary files; Pester row labels must not contain unbalanced `<` or `>`.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: new deny outcome for the spellings above under epic scope; deny text unchanged.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: no rule file, skill, or `CHANGELOG.md` documents the rule tokens (research section 9.3); no documentation edit is required.

## Test Strategy

- Regression tests to add:
  - Unit (both surfaces via the existing `-ForEach` over `.claude/hooks` and `.codex/hooks`) in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`: a data-driven `path-not-local` row family covering backslash and forward-slash UNC, `\\?\C:\`, `//?/C:/`, `\\?\UNC\`, `\\.\`, `\??\`, mixed separators, bare `\\` and `//`, drive-relative `C:wt\a.ps1`, and bare `C:`; a row asserting a non-local path denies alongside a valid sibling path; a row asserting `\\server\share\..\x` reports `path-not-local` rather than `path-dot-segment`; a row passing a non-local `apply_patch` marker through `Get-OrchestrationPatchMarkerPath`; and keep-behavior rows for `C:\` and `C:/`.
  - Gate (Claude) in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`: Write deny rows for a UNC path, an extended-length path, and a drive-relative path, each with `Code = 'target-unresolvable'`.
  - Gate (Codex) in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`: `apply_patch` marker deny rows for a UNC path, an extended-length path, and a drive-relative path, each with `Code = 'target-unresolvable'`.
- Fail-before evidence: run the new rows against the unfixed code and record the failures (unit rows: `Resolved=$true` with the session root; gate rows: outcome `allow`) under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/`.
- Edge cases: mixed separators; bare `\\`/`//`; `..` inside a UNC path; bare drive root; bare drive-relative `C:`.
- Test file split (remediation cycle 2, issue #937 RI-8): rows U27 to U31, named in AC-1 to AC-6 and AC-16 to AC-18, moved unchanged and with unchanged testcase names from `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1`, which runs them on the same two surfaces.
- Coverage: the new branch executes on both surfaces; changed-line coverage is expected to be complete and must not reduce coverage on changed lines. Thresholds follow `.claude/rules/general-unit-test.md`.
- Toolchain: PoshQC format, analyze (PSScriptAnalyzer), and Pester via MCP; Python push-down contract tests via `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; CI jobs `poshqc / PowerShell QC` (windows-latest, coverage) and `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest, hook suites, no coverage).
- Manual validation: none required.

## Acceptance Criteria

- [x] AC-1: In every production copy of `enforce-orchestration-preimplementation-gate-targets.ps1` checked by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`, the R1 path-leg loop of `Get-OrchestrationCommandTarget` tests the raw input before normalization and returns `Resolved=$false`, empty `Targets`, `ReasonCode='target-unresolvable'`, and `Detail` starting with `path-not-local` for UNC (`\\server\share`, `//server/share`) and mixed-separator spellings, including bare `\\` and `//`. Proven by the new `path-not-local` rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` passing on both the `.claude/hooks` and `.codex/hooks` surfaces.
- [x] AC-2: The same unresolved `path-not-local` result is returned for extended-length (`\\?\C:\`, `//?/C:/`, `\\?\UNC\`), device (`\\.\`, `//./`), and NT-object (`\??\`, `/??/`) path-leg spellings. Proven by the corresponding rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` on both surfaces.
- [x] AC-3: A drive-relative path-leg spelling (a drive letter and colon not followed by a separator, such as `C:wt\a.ps1` and bare `C:`) returns the unresolved `path-not-local` result instead of the session root. Proven by drive-relative rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` on both surfaces.
- [x] AC-4: A bare drive root path-leg input (`C:\` and `C:/`) keeps today's behavior (`Resolved=$true`, target `C:/`). Proven by keep-behavior rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` on both surfaces.
- [x] AC-5: Ordering is preserved: a non-local path denies with `path-not-local` even when another path in the same call is valid, and `\\server\share\..\x` reports `path-not-local` rather than `path-dot-segment`. Proven by dedicated rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`.
- [x] AC-6: A non-local `apply_patch` marker path extracted by `Get-OrchestrationPatchMarkerPath` and passed to `Get-OrchestrationCommandTarget` yields the `path-not-local` unresolved result. Proven by a marker row in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`.
- [x] AC-7: Under an epic-scope session root, a Claude Write whose `file_path` is a UNC, extended-length, or drive-relative spelling is denied with `target-unresolvable`. Proven by new Write rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`.
- [x] AC-8: Under an epic-scope session root, a Codex `apply_patch` whose marker path is a UNC, extended-length, or drive-relative spelling is denied with `target-unresolvable`. Proven by new rows in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`.
- [x] AC-9: Fail-before evidence shows the new unit rows (`Resolved` returned `$true`) and the new gate rows (outcome `allow`) failing against the unfixed code, recorded under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/`.
- [x] AC-10: Existing rows U01-U05, U14, and U16 in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` pass without modification, and `ConvertTo-OrchestrationTargetPath`, `$script:OrchestrationTargetAbsolutePattern`, the R0 session-root rule, and the R6 `-C` selector leg are unchanged (verified by `git diff main` on each targets copy and by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` passing unmodified).
- [x] AC-11: Every copy of the targets file checked by the Parity suite is byte-identical to the canonical `.claude/hooks` copy with LF endings, every line is at or below 120 characters, and each file is at or below 500 lines. Proven by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` passing.
- [x] AC-12: The push-down resource contract tests pass: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.
- [x] AC-13: No out-of-scope file is modified: no copy of `enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, parser files, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, and `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` are absent from `git diff --name-only main`.
- [x] AC-14: PoshQC format, analyze, and test (via MCP) complete with no formatting diff, zero analyzer findings, and all Pester tests in `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` passing; changed lines in the targets file are covered.
- [x] AC-15: CI jobs `poshqc / PowerShell QC` (windows-latest, coverage) and `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest) conclude `success` on the PR head. (CI-dependent; checked off at S9.)
- [x] AC-16: In every production copy of `enforce-orchestration-preimplementation-gate-targets.ps1` checked by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`, a path-leg input with leading or trailing whitespace returns `Resolved=$false`, empty `Targets`, `ReasonCode='target-unresolvable'`, and `Detail` equal to `path-not-local: ` followed by the raw input, for a leading-space UNC spelling (`' \\server\share\a.ps1'`), a leading-space absolute spelling (`' /synthetic-worktrees/other/a.ps1'`), and a trailing-space absolute spelling (`'/synthetic-worktrees/other/a.ps1 '`). Proven by the U27 rows `leading-space-unc`, `leading-space-absolute`, and `trailing-space-absolute` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` passing on both the `.claude/hooks` and `.codex/hooks` surfaces in CI job `poshqc / PowerShell hook suites (Linux)` (issue #937 remediation RI-2).
- [x] AC-17: The same unresolved `path-not-local` result is returned for `file:` URI path-leg spellings (`file:///C:/wt/a.ps1`, `file://server/share/a.ps1`) and `~`-prefixed path-leg spellings (`~/wt/a.ps1`, `~\wt\a.ps1`). Proven by the U27 rows `file-uri-drive`, `file-uri-unc`, `tilde-forward`, and `tilde-backslash` on both surfaces, and, under an epic-scope session root, by the Claude Write rows and the Codex `apply_patch` rows whose names end in `(issue #937 RI-4)` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` denying with `target-unresolvable`, all passing in CI job `poshqc / PowerShell hook suites (Linux)` (issue #937 remediation RI-4).
- [x] AC-18: A single-backslash root-relative path-leg spelling (`\wt\a.ps1`) returns the unresolved `path-not-local` result, while `$script:OrchestrationTargetAbsolutePattern` stays unchanged and a single forward-slash POSIX absolute path-leg input keeps resolving to itself. Proven by the U27 row `root-relative-backslash` on both surfaces, by the Claude Write and Codex `apply_patch` rows whose names end in `(issue #937 RI-5)` denying with `target-unresolvable` under an epic-scope session root, and by U01 passing unmodified, all in CI job `poshqc / PowerShell hook suites (Linux)`, and by an additions-only diff of each targets copy against the merge base with `origin/main` (issue #937 remediation RI-5).
- [x] AC-19: Fail-before evidence shows the 16 new U27 testcases of AC-16 to AC-18 (`Resolved` returned `$true`) and the 6 new `(issue #937 RI-4)` and `(issue #937 RI-5)` gate testcases (outcome `allow`) failing in CI job `poshqc / PowerShell hook suites (Linux)` against the code before the remediation cycle 1 fix, recorded under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/`.
- [x] AC-20: In every production copy of `enforce-orchestration-preimplementation-gate-targets.ps1` checked by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`, a path-leg input whose raw value begins with a URI scheme of two or more characters and a colon returns `Resolved=$false`, empty `Targets`, `ReasonCode='target-unresolvable'`, and `Detail` equal to `path-not-local: ` followed by the raw input, for `http://server/share/a.ps1`, `smb://server/share/a.ps1`, `vscode-remote://wsl/wt/a.ps1`, and `git+ssh://server/repo/a.ps1`, while a relative path with a later colon (`scripts/a:b.ps1`) keeps resolving to the session root and the drive-relative and drive-root rows keep their results. Proven by the U27 rows `http-uri`, `smb-uri`, `vscode-remote-uri`, and `scheme-plus-uri` and by U32 in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1` on both the `.claude/hooks` and `.codex/hooks` surfaces, by the Claude Write rows and the Codex `apply_patch` rows whose names end in `(issue #937 RI-7)` denying with `target-unresolvable` under an epic-scope session root, and by fail-before evidence of those 14 testcases (8 U27 and 6 gate) failing against the code before the remediation cycle 2 fix, all in CI job `poshqc / PowerShell hook suites (Linux)` (issue #937 remediation RI-7).

## Risks & Mitigations

- Technical or operational risks:
  - A legitimate caller supplying a drive-relative path would now be denied under epic scope. Mitigation: the Write tool supplies absolute paths by contract; the deny text is diagnosable because `Detail` carries the raw value.
  - Linux CI behavior differs for path APIs. Mitigation: the code under test uses only string operations and `-match`; tests use single-quoted literals and no path APIs.
  - Mirror drift (BOM or CRLF). Mitigation: produce the mirrors by copying the edited canonical file with LF endings; the Parity suite is the authoritative check.
  - The single-feature path may still resolve these spellings via its own fallback. Mitigation: recorded as a non-goal and a candidate follow-up.
- Mitigations and rollbacks: revert the targets copies and the added test rows.

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; the bundled mirrors ship with the next extension build.
- Post-fix monitoring or clean-up tasks: optional follow-up for `Resolve-WorktreeOperandTarget` single-feature handling of the same spellings, if the operator wants single-feature mode to deny them.
- Links: #937; #732 code-review CR-1 (`docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/code-review.2026-10-09T05-42.md`); #903 Operator Follow-up 8; research `docs/features/active/exempt-operand-unc-path-leg-937/research/research.2026-10-15T17-46.md`.
