# Research: UNC and extended-length path-leg spellings resolve to the session root (#937)

- Issue: #937 (follow-up to #732 code-review CR-1; #903 Operator Follow-up 8)
- Branch: `bug/exempt-operand-unc-path-leg-937`
- Work mode: full-bug
- Timestamp note: the research agent had no shell tool and could not read the host clock. The filename timestamp `2026-10-15T17-46` is one minute after the latest artifact timestamp in this folder (`plan.2026-10-15T17-45.md`), used as a lower bound. The orchestrator may rename the file if an exact clock value is required.
- Method: all behavior statements below are reasoned from source reading. No PowerShell was executed. Every "reasoned" claim is marked as such.

## 1. Current State Analysis (Q1)

### 1.1 The targets module

File: `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (425 lines; pure string logic per header lines 5-8).

| Element | Location | Behavior |
|---|---|---|
| `$script:OrchestrationTargetDirectoryChangeWords` | lines 25-27 | `cd`, `pushd`, `popd`, `chdir`, `Set-Location`, `sl`, `Push-Location`, `Pop-Location` |
| `$script:OrchestrationTargetRelocationPattern` | lines 30-33 | `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE` as standalone identifiers |
| `$script:OrchestrationTargetAbsolutePattern` | line 36 | `'^([A-Za-z]:/|/(?!/))'` - drive-lettered, or rooted but explicitly not `//` |
| `ConvertTo-OrchestrationTargetPath` | lines 41-60 | `Replace('\', '/')`, then removes one trailing `/` unless the value is a bare drive root |
| `Test-OrchestrationTargetDotSegment` | lines 92-100 | true when a `/`-split segment is `.` or `..` |
| `New-OrchestrationTargetResult` | lines 102-122 | unresolved result: `Resolved=$false`, `ReasonCode='target-unresolvable'`, `Detail="<rule>: <value>"` |
| `Get-OrchestrationGitSelectorTarget` | lines 124-196 | git global-option walk; `-C` values are judged as written (no normalization) |
| `Get-OrchestrationCommandTarget` | lines 198-273 | rules R0-R7 |
| `Resolve-OrchestrationEpicTargetVerdict` | lines 275-330 | verdict V1-V7 |
| `Get-OrchestrationEpicTargetDenyReason` | lines 332-373 | deny text per reason code |
| `Resolve-OrchestrationEpicTargetOutcome` | lines 375-424 | shared outcome |

The issue cites line 31 (pattern) and line 201 (path-leg loop). Both are stale: #903 inserted the relocation pattern (lines 31-33), so the pattern is now at line 36 and the path-leg loop is at lines 223-230 (line 201 is now the `.SYNOPSIS` of `Get-OrchestrationCommandTarget`).

### 1.2 Every leg that consumes the normalization or the absolute pattern

| Leg | Location | Input normalized? | UNC / `\\?\` outcome today (reasoned) |
|---|---|---|---|
| R0 session root | lines 217-220 | yes (`ConvertTo-OrchestrationTargetPath`) | `//...` fails line 36 -> `session-root-not-absolute` (fail closed) |
| R1 path leg (Write/Edit `file_path`; Codex `apply_patch` markers) | lines 223-230 | yes | `//...` fails line 36 -> **`$targets.Add($root)`** (line 225). This is the defect. |
| R2 unbalanced segment | line 237 | n/a | unaffected |
| R3 directory change (`cd`, `Set-Location`, ...) | lines 238-240 | n/a | denied as `directory-change` regardless of operand spelling |
| R4 wrapper / live substitution | lines 241-251 | n/a | denied as `wrapper-git` regardless of operand |
| R5 env relocation (`GIT_DIR=...`) | lines 252-254 | n/a | denied as `git-relocation` regardless of operand |
| R5 option relocation (`--git-dir`, `--work-tree`, `-c core.worktree=`) | lines 174-178, 184 | n/a | denied as `git-relocation` regardless of operand |
| R6 `-C` selector | lines 187-193 | **no** (judged as written) | backslash spelling (`\\?\C:\x`, `\\server\share`) -> `selector-backslash` (line 189); forward-slash spelling (`//?/C:/x`, `//server/share`) -> `selector-not-absolute` (line 190). Already fail closed; pinned for `//server/share` by test U14. |
| Verdict root key | line 296 | yes | cache key only; no resolution decision |

Tokenization detail supporting the R6 row: `ConvertTo-CommandLineToken` (`.claude/hooks/hook-command-scanner.ps1` lines 53-101) strips only quote characters and keeps every backslash, so a `\\?\C:\x` operand reaches line 189 with its backslashes intact.

Conclusion: the issue's reproduction step "`git -C \\?\C:\...` ... resolves to the session root" is inaccurate for the `-C` leg; that leg already denies. Only the R1 path leg misresolves. This narrows the fix to one loop.

### 1.3 Reasoned reproduction of the misresolution (not executed)

`Get-OrchestrationCommandTarget -FilePath @('\\?\C:\wt\other\a.ps1') -SessionRoot 'C:\wt\coordinator'`:

1. Line 217: root -> `C:/wt/coordinator`; matches line 36.
2. Line 224: path -> `//?/C:/wt/other/a.ps1`.
3. Line 225: `^([A-Za-z]:/|/(?!/))` fails (first alternative: no drive letter; second: `/` followed by `/`), so `$targets.Add('C:/wt/coordinator')` and `continue`.
4. Result: `Resolved=$true`, `Targets=@('C:/wt/coordinator')`.

This matches the #732 reviewer probe output quoted in `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/code-review.2026-10-09T05-42.md` line 24 (`extended-length Write path | Resolved=True | Targets=C:/wt/coordinator`).

Per-spelling trace through lines 55-58 and 225 (reasoned):

| Raw path-leg input | After line 55-58 | Line 36 match | Contributes |
|---|---|---|---|
| `\\server\share\wt\a.ps1` | `//server/share/wt/a.ps1` | no | session root (defect) |
| `//server/share/wt/a.ps1` | unchanged | no | session root (defect) |
| `\\?\C:\wt\a.ps1` | `//?/C:/wt/a.ps1` | no | session root (defect) |
| `//?/C:/wt/a.ps1` | unchanged | no | session root (defect) |
| `\\?\UNC\server\share\a.ps1` | `//?/UNC/server/share/a.ps1` | no | session root (defect) |
| `\\.\C:\wt\a.ps1` | `//./C:/wt/a.ps1` | no | session root (defect) |
| `\??\C:\wt\a.ps1` | `/??/C:/wt/a.ps1` | yes (`/` then `?`) | the literal string `/??/C:/wt/a.ps1` (see 4.3) |
| bare `\\` or `//` | `/` (trailing-slash trim, line 56) | yes | target `/` |

### 1.4 How a resolved target is matched to a worktree

The scope resolver closes over `Resolve-EpicScopeCheckpoint` (Claude `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 251-254 with `-MatchWorktreeHead`; Codex `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 194-197). `Resolve-EpicScopeCheckpoint` (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1` lines 278-381) calls `Find-WorktreeResolutionRoot -Path $WorktreeSelector` (line 340), which ascends the filesystem looking for a `.git` marker (`.claude/lib/worktree-resolution/WorktreeResolution.psm1` lines 258-293), then reads that worktree's HEAD and locates the epic checkpoint by branch via `Resolve-WorktreeEpicTarget`. Worktree roots are therefore not enumerated by `git worktree list` text; they are found by filesystem ascent from the target string, and compared by string to the session root only in `Resolve-OrchestrationEpicTargetVerdict` (line 303, ordinal case-insensitive).

The worktree-resolution library uses a different normalizer, `ConvertTo-WorktreeResolutionNormalizedPath` (`WorktreeResolution.psm1` lines 118-153), which preserves a leading `//` (line 141) and an absolute pattern `^([A-Za-z]:(/|$)|/)` (line 160) that accepts `//`. The two layers therefore disagree on UNC spellings; the targets module is the stricter one by design (D3 / R1 in #732).

## 2. Surface Copies and Parity Enforcement (Q2)

### 2.1 The four copies

| Copy | Role |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | canonical, Claude surface |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | Codex surface |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | bundled Claude mirror |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | bundled Codex mirror |

Header line 13 states "the four copies are byte-identical"; the `.claude` and `.codex` copies are intentionally identical (not surface-specific). Verification performed here: identical non-empty-line counts (396 each, Grep count of `.`), and identical line numbers for every grep hit on `OrchestrationTargetAbsolutePattern`, `ConvertTo-OrchestrationTargetPath`, and `Get-OrchestrationCommandTarget` across all four. A SHA-256 hash was not computed in this session (no shell). The #732 feature audit recorded matching `sha256sum` values at that time (`feature-audit.2026-10-09T05-42.md` AC-10).

### 2.2 Tests that enforce parity

| Test | What it enforces |
|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` lines 30-41 | SHA-256 equality across all four copies (detects BOM and EOL drift) |
| same file, lines 43-52 | each copy <= 500 lines |
| same file, lines 54-63 | each line <= 120 characters (#903, #732 CR-4) |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` lines 89-110 (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) | UTF-8 text equality of every distributable `.claude/**` file with its bundle copy |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` lines 215-228 (`test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`) | text equality of every repo `.codex/**` and `.agents/**` file with its bundle copy |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lines 137-142 | the targets file stays listed in the Codex `core.json` pack manifest (membership only; no edit needed) |

No TypeScript test compares hook content. `.gitattributes` line 1 (`* text=auto eol=lf`) means all four copies must be written with LF endings to keep the SHA-256 test green.

## 3. Existing Tests (Q3)

### 3.1 Unit suite

`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (399 lines):

- One `Describe` with `-ForEach @(@{ Surface = '.claude/hooks' }, @{ Surface = '.codex/hooks' })` (lines 10-13). `BeforeAll` dot-sources `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, and the targets file from that surface (lines 15-19). Every row therefore runs once per surface; there is no separate codex-hooks unit suite for this module.
- Session root is the synthetic literal `/synthetic-worktrees/session` (line 20). No worktree is faked at all: the functions under test are pure strings, so no filesystem state exists to fake.
- Rows are a mix of single `It` blocks (U01-U06) and data-driven `It ... -ForEach @(...)` rows (U07, U11, U11b, U12, U22, U25, U26). Assertions follow the established shape: `Resolved`, `ReasonCode -Be 'target-unresolvable'`, `Detail.StartsWith('<rule>')`.
- Path-leg rows are U01-U05; U14 already pins `//server/share` on the `-C` leg.

Placement for the new rows: a new data-driven row family after U05 (path-leg group) or appended as U27, covering each spelling in section 1.3 on both surfaces automatically.

`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` (61 lines) exercises `ConvertTo-OrchestrationTargetPath` directly. It needs no change because the recommended design does not change that function.

### 3.2 Gate-level suites (end-to-end through the decision function)

- Claude: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` (149 lines). Worktrees are faked by Pester mocks inside the `EpicScopeResolution` module (`Set-TargetSeam`, lines 32-52): `Find-WorktreeResolutionRoot` returns `/synthetic-worktrees/epic-coordinator` for any path not under `/outside/` or `/synthetic-worktrees/<name>/`. Data-driven deny rows at lines 71-91 take `Command`, `FilePath`, `Code`. A Write row is already present (line 77).
- Codex: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` (154 lines). Same mock model by name (lines 32-51); rows take only `Command` (line 55), and the path leg is reached through an `apply_patch` body (row at line 69). The Codex gate classifies marker paths after `-replace '\\', '/'` (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 146-157), so a `.ps1` marker spelled `\\?\C:\...` is classified as implementation and reaches the epic decision.

Placement: one Write row per spelling in the Claude deny table (lines 71-79) and one `apply_patch` row per spelling in the Codex deny table (lines 62-70), each with `Code = 'target-unresolvable'`.

Reasoned fail-before for those gate rows: before the fix the UNC Write contributes the session root, which the mocks make epic scope with a merge in progress (`Test-EpicScopeMergeInProgress` returns true for the coordinator), so the verdict is `evaluate` and the outcome is `allow`. After the fix the target result is unresolved and the session root is epic scope, so the verdict is `deny` with `target-unresolvable`. The row therefore fails before and passes after.

## 4. Candidate Approaches (Q4)

### 4.1 Option (a): normalize to a local spelling and resolve

Map `\\?\C:\` and `\\.\C:\` to `C:/`, and `\\?\UNC\server\share` to `//server/share`, then accept `//server/share` as absolute and let the scope resolver match it.

- Advantages: a Write via `\\?\C:\wt\x` is evaluated against the worktree it names, including when the session root is not epic scope.
- Limitations:
  - `\\?\` disables Win32 path normalization. The .NET source comment for `IsExtended` (dotnet/runtime `src/libraries/Common/src/System/IO/PathInternal.Windows.cs`, fetched in this session) states that skipping normalization "will *only* occur if back slashes ('\') are used". A `\\?\` path therefore names literal segments (trailing dots and spaces are significant, `..` is not collapsed), so `\\?\C:\x\a.` and `C:\x\a.` can name different files. A string rewrite to `C:/` is not semantically exact.
  - UNC targets cannot be matched to a session root: the R0 rule (line 218) already rejects a `//` session root, and the gate's scope-resolver and checkpoint seams assume local roots. Accepting `//server/share` would add a new root family that no other leg supports.
  - Changing `ConvertTo-OrchestrationTargetPath` also changes R0 (line 217) and the verdict cache key (line 296), which widens the blast radius beyond the defective loop.
  - Device paths (`\\.\pipe\x`, `\\.\PhysicalDrive0`) still need a deny branch, so (a) requires (b) anyway.

### 4.2 Option (b): fail closed for UNC, extended-length, and device spellings (recommended)

In the R1 path-leg loop, before the absolute test, return an unresolved result with a new rule token when the input begins with a UNC, extended-length, or device prefix.

- Advantages:
  - One added condition in one loop; R0, R6, and the normalizer are unchanged.
  - Matches the gate's fail-closed norm (spec D3 of #732; CR-1 recommendation text, code-review line 24) and the existing `-C` leg, which already denies the same spellings (U14, U16).
  - Uses the existing reason code `target-unresolvable` and the existing deny text in `Get-OrchestrationEpicTargetDenyReason` (lines 370-372). No new reason code; `target-ambiguous` is not appropriate because no worktree claim is involved.
  - Rule token is reported with the raw value, keeping the deny diagnosable.
- Limitations: in a session whose root is not epic scope, an unresolved result yields verdict `none` (lines 310-314) and the single-feature path decides. This is the documented D3 contract (#732 CR-8) and applies identically to every other unresolvable rule, so (b) introduces no new gap.

### 4.3 Recommendation

Adopt option (b).

Proposed change (all four byte-identical copies):

1. Add a module-scope pattern next to line 36, for example:
   `$script:OrchestrationTargetNonLocalPattern = '^(?:[\\/]{2}|[\\/]\?\?[\\/])'`
   with a comment naming UNC, extended-length (`\\?\`, `\\?\UNC\`), device (`\\.\`), and NT object (`\??\`) spellings in either separator style.
2. In `Get-OrchestrationCommandTarget`, first statement inside the path loop (before line 224's normalization result is tested at line 225):
   `if ($rawPath -match $script:OrchestrationTargetNonLocalPattern) { return (New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath) }`
   Testing the raw input (separator-agnostic) rather than the normalized value avoids the trailing-slash trim at line 56 collapsing a bare `\\` or `//` to `/`.
3. Update the module `.DESCRIPTION` only if it enumerates rules (it does not today; the rules are defined in the #732 plan), so no header change is strictly required. Keep every new line <= 120 characters (Parity test, lines 54-63) and the file under 500 lines (425 today).

Rule token choice: `path-not-local`. CR-1 suggested `path-not-absolute`; that token reads as incorrect for `\\?\C:\x`, which is absolute. Either token satisfies the deny contract; the planner may choose CR-1's wording for symmetry with `selector-not-absolute`.

Coverage of the spelling family by the recommended pattern (reasoned):

| Spelling | Matched by `^(?:[\\/]{2}|[\\/]\?\?[\\/])` |
|---|---|
| `\\server\share\...`, `//server/share/...` | yes |
| `\\?\C:\...`, `//?/C:/...` | yes |
| `\\?\UNC\server\share\...`, `//?/UNC/...` | yes |
| `\\.\C:\...`, `//./C:/...`, `\\.\pipe\...` | yes |
| `\??\C:\...` (and `/??/C:/...`) | yes |
| mixed `\/server/share` | yes |
| `C:\wt\a.ps1`, `C:/wt/a.ps1` | no (unchanged, U04) |
| `/synthetic-worktrees/other/a.ps1` | no (unchanged, U01) |
| `scripts/a.ps1` | no (unchanged, U02) |

`\\.\` device paths: they need the same treatment and are covered by the `//` alternative. `\??\`: per the same .NET source, `IsExtended` treats `\??\` as equivalent to `\\?\` (backslash form only; the source comment states "\??\ is recognized and handled, /??/ is not"). Today it does not resolve to the session root (it becomes the literal target `/??/C:/...`, which the scope resolver most likely fails to ascend, giving `selector-unresolved`), so it is not part of the reported defect. Including it in the pattern makes the deny local and deterministic instead of depending on a filesystem probe; this is the recommended default. If the planner prefers the minimum issue scope, drop the second alternative; the `//` alternative alone closes #937.

`-C` leg: no change. Backslash spellings are already `selector-backslash`; forward-slash `//` spellings are already `selector-not-absolute`; a forward-slash `/??/` selector is not a device alias per the .NET comment above.

### Rejected alternatives

- Option (a) normalization: not semantically exact for `\\?\`, cannot resolve UNC roots, widens the change to R0 and the verdict key, and still needs (b) for device paths.
- Tightening `$script:OrchestrationTargetAbsolutePattern` alone: `//` already fails it; the defect is that R1 maps a non-absolute input to the session root. Changing the pattern does not alter that mapping.

## 5. Behavior Semantics

- Success: an R1 input with no UNC/device prefix behaves exactly as today (U01-U05 unchanged).
- Failure: an R1 input with the prefix yields `Resolved=$false`, `Targets=@()`, `ReasonCode='target-unresolvable'`, `Detail='path-not-local: <raw input>'`.
- Ordering: R1 runs before the command loop (line 232), so a UNC path in a multi-path call denies even if another path is valid; first failing rule wins, consistent with `path-dot-segment` (lines 226-228). Within R1, the new check precedes the dot-segment check, so `\\server\share\..\x` reports `path-not-local`.
- Epic-scope decision: with an epic-scope session root, the verdict is `deny` / `target-unresolvable` and the reason text is the existing fall-through string (lines 370-372). With a non-epic session root, the verdict is `none` (D3 contract, unchanged).
- Single-feature path: untouched. `Resolve-OrchestrationGateTarget` (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 134-136) uses `Resolve-WorktreeOperandTarget` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` lines 450-488), whose normalizer preserves `//` and which falls back to the session worktree when no `.git` marker is found (lines 482-485). That is a separate code path with its own fallback semantics; see Risks.

## 6. Consumers (Q5)

Production callers of `Get-OrchestrationCommandTarget` (and transitively of the normalizer):

| Caller | Location |
|---|---|
| Claude epic-scope gate | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 250 |
| Codex epic-scope gate | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 193 |
| Claude bundled mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 250 |
| Codex bundled mirror | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 193 |

`ConvertTo-OrchestrationTargetPath` has no caller outside the targets file except the C1bCoverage test. None of the epic-scope callers need to change.

Test consumers: `enforce-orchestration-preimplementation-gate-targets.Tests.ps1`, `enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1`, and (through the gate) the two EpicScopeTargets suites.

Parser involvement: the targets module calls `Read-CommandLineSegment`, `Get-CommandLineGlobalOption`, and `Get-CommandLineInvocation` only in the command loop (lines 233, 138, 248). The R1 path loop does not touch the parser. No parser file (`hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-payload*.ps1`, `hook-command-heredoc.ps1`) needs to change.

#927 overlap: this fix does not need to touch `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` or `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`. Neither file references `Get-OrchestrationCommandTarget` or the targets file (repository Grep for `enforce-orchestration-preimplementation-gate-targets|Get-OrchestrationCommandTarget|epic-scope` under `tests/` returned neither file), and the change is confined to the path leg, which the parser does not process.

## 7. Prior Work (Q6)

- #732 (folder `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/`, bundling #738, #745, #735) replaced the exempt-operand checks with an allowlist, added shell-divergence denies, and introduced the targets module so the epic-scope decision resolves every command segment and path instead of only the first segment (code-review lines 10-14, 45-50).
- CR-1 (code-review line 24, Medium, Non-blocking): UNC and extended-length path-leg spellings normalize to `//...`, fail the absolute pattern, and contribute the session root. Recommended fix: treat a `//`-prefixed path-leg input as unresolved with reason `target-unresolvable` and add rows to the targets suite and `EpicScopeTargets.Tests.ps1`; otherwise record as FU-6.
- Why deferred: the reviewer classified it as an incomplete closure rather than a regression ("The current behavior equals the pre-change behavior for every path leg"), and no acceptance criterion named UNC spellings (feature audit AC-12, Gap G-A). It was recorded as FU-6 in `evidence/other/follow-ups.md` line 14 ("candidate fix is to deny them as `target-unresolvable`"), not filed.
- #903 (`docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md` line 231, Operator Follow-up 8): "#732 CR-1 (UNC path leg, Medium). Not in #903 scope and still open in the current tree." #903 did land CR-2, CR-3, CR-4, and CR-6 from the same review (visible in the current file at lines 31-33, 375-424, the 120-character parity row, and lines 140-142).

The recommended design is the fix CR-1 and FU-6 proposed.

## 8. Verification Environment (Q7)

- `.github/workflows/_poshqc.yml`: job `PowerShell QC` (line 9, `windows-latest`, line 10) runs format (lines 22-30, fails on any reformat diff across the repo, mirrors included), analyze (lines 32-36), and tests with coverage (lines 38-42). Job `PowerShell hook suites (Linux)` (line 55, `ubuntu-latest`) runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled (lines 76-78).
- Linux versus Windows for the new rows:
  - Unit rows: the code under test uses only `String.Replace`, `-match`, and `-split`; no path API is called. Single-quoted PowerShell literals such as `'\\?\C:\wt\a.ps1'` contain literal backslashes on both platforms. Rows will behave identically. Do not pass the UNC strings through `Join-Path`, `Resolve-Path`, `Test-Path`, `[System.IO.Path]`, or `Split-Path`; those behave differently on Linux (backslash is not a separator there).
  - Gate rows: the Write payload is built with `ConvertTo-Json` (Claude suite line 57), which escapes and round-trips backslashes on both platforms. The session root is `(Get-Location).Path` (Linux `/home/runner/...`, Windows `D:\a\...`); the mocked `Find-WorktreeResolutionRoot` maps either to `/synthetic-worktrees/epic-coordinator`, so the outcome does not depend on the runner. With the fix, the UNC target is never passed to the resolver.
  - Use Pester row labels without unbalanced `<` `>` so template expansion is unaffected.

## 9. Requirements Mapping and File List (Q8)

### 9.1 Production (edit, byte-identical)

1. `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`

### 9.2 Tests (edit)

5. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` - new data-driven path-leg deny rows (each spelling in section 4.3), one row asserting the deny wins over a valid sibling path, and one `Get-OrchestrationPatchMarkerPath` + UNC marker row. Runs on both surfaces via the existing `-ForEach`.
6. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` - Write rows (UNC and `\\?\`) with `Code = 'target-unresolvable'`.
7. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` - `apply_patch` marker rows (UNC and `\\?\`) with `Code = 'target-unresolvable'`.

### 9.3 Not edited (verified unnecessary)

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (enforces the result; no change).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` (normalizer unchanged).
- All four `enforce-orchestration-preimplementation-gate-epic-scope.ps1` copies (call signature unchanged).
- Both `pack-manifests/core.json` files (file already listed).
- Parser files and the two #927 test files (section 6).
- Rule files, skills, and `CHANGELOG.md`: a repository Grep for `path-dot-segment|selector-not-absolute|target-unresolvable` outside `docs/features/` matched only the four targets copies and three test suites, so no documentation describes the rule tokens. No doc edit is required.
- Feature-folder artifacts (`spec.md`, `plan.*.md`, evidence) are authored by the workflow, not part of the code fix.

## 10. Testing Implications

- Fail-before: the new unit rows fail before the fix (current result is `Resolved=$true`, `Targets=@($script:Root)`); the gate rows fail before the fix (outcome `allow`; see 3.2). Capture both under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/`.
- Regression scope: run `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` entirely (matches the Linux CI job) plus the two Python push-down contract tests named in 2.2.
- Coverage: the new branch is one line in a file already measured on the Windows job; the new rows execute it on both surfaces. Line coverage on changed lines should be 100%.
- Toolchain: PoshQC format, analyze (PSScriptAnalyzer), Pester; Python contract tests via `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.

## Numeric Derivation Evidence

### Claim N1: the targets module has exactly 4 production copies

- Complete Family: every non-test file in the repository named `enforce-orchestration-preimplementation-gate-targets.ps1`.
- Exhaustive Search Scope: entire worktree, all directories.
- Inclusion Rules: file name equals `enforce-orchestration-preimplementation-gate-targets.ps1`.
- Exclusion Rules: files under `tests/` (they are named `*.Tests.ps1` / `*.Parity.Tests.ps1`, not the module name).
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate-targets*.ps1`, then drop `tests/` entries.
- Primary Member Set: `.claude/hooks/...-targets.ps1`; `.codex/hooks/...-targets.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...-targets.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...-targets.ps1`.
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: content Grep for the definition line `\$script:OrchestrationTargetAbsolutePattern = ` across the whole worktree (files_with_matches).
- Cross-check Member Set: the same four paths.
- Cross-check Count: 4
- Member-set Comparison: identical normalized sets; no member present in one set and absent from the other.

### Claim N2: the target resolver has exactly 4 production call sites (one per epic-scope copy)

- Complete Family: every non-test invocation of `Get-OrchestrationCommandTarget`.
- Exhaustive Search Scope: entire worktree excluding `docs/`.
- Inclusion Rules: a line that invokes the function with arguments.
- Exclusion Rules: the function definition lines in the four targets copies; `tests/` files; comment-only mentions (`.claude` epic-scope line 224 and its mirror, which are inside a comment block).
- Primary Search Strategy or Query Expression: Grep `Get-OrchestrationCommandTarget|ConvertTo-OrchestrationTargetPath|OrchestrationTargetAbsolutePattern|Resolve-OrchestrationEpicTargetVerdict` (content mode, `!docs/**`), filtered to invocation lines outside `tests/` and outside the targets files.
- Primary Member Set: `.claude/hooks/...-epic-scope.ps1:250`; `.codex/hooks/...-epic-scope.ps1:193`; `extensions/.../claude-customizations/.claude/hooks/...-epic-scope.ps1:250`; `extensions/.../codex-and-agents-customizations/.codex/hooks/...-epic-scope.ps1:193`.
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (each epic-scope file is the only dot-sourcer of the targets module per header line 12 and epic-scope line 49).
- Cross-check Member Set: the same four files.
- Cross-check Count: 4
- Member-set Comparison: identical normalized file sets.

## Automation Feasibility

Fully automatable; no human interaction is required. The change is a pure-string edit to one file copied to three mirrors, and every verification step (Pester on both surfaces, PSScriptAnalyzer, PoshQC format, the SHA-256 parity suite, the two Python push-down contract tests, and the two CI jobs in `_poshqc.yml`) runs non-interactively. No UNC share, network, or real Windows device path is needed because the rows are string inputs and the gate rows mock every filesystem seam.

## Risks and Open Items

1. Single-feature path (out of scope, recorded for the planner): `Resolve-WorktreeOperandTarget` (`WorktreeRunResolution.psm1` lines 477-487) treats `//...` as absolute and ascends the filesystem. On Windows a `//?/C:/...` probe is likely to succeed because .NET treats it as a device path (reasoned from the .NET source comment; not executed). If the probe fails (for example a real UNC share that is unreachable, or any Linux host), the call falls back to the session worktree (lines 482-485). That fallback is the documented "operand inside no worktree" behavior, not part of #937, and a candidate follow-up only if the operator wants single-feature mode to deny the same spellings.
2. Drive-relative spelling `C:wt\a.ps1` normalizes to `C:wt/a.ps1`, fails line 36, and contributes the session root. It is a separate spelling not named in #937; the Write tool supplies absolute paths by contract (gate line 81-83 comment). Recorded as an observation, not addressed.
3. `\??\` inclusion is a judgment call (section 4.3). Dropping it leaves today's behavior for that spelling unchanged (not a session-root misresolution).
4. Rule-token naming (`path-not-local` versus CR-1's `path-not-absolute`) is cosmetic; tests assert `Detail.StartsWith(<token>)`, so the planner must fix one token before the regression rows are written.
5. SHA-256 parity across the four copies was not recomputed in this session; the mirrors must be produced by copying the edited canonical file with LF endings, and the Parity suite is the authoritative check.
