# 2026-09-27-exempt-operand-bypass-brace-and-dot-segments (Spec)

- **Issue:** #732 (primary); bundled #738, #745, #735
- **Parent (optional):** epic #852 (`enforcement-hook-precision`), child C1b
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the authoritative acceptance-criteria source; no `user-story.md`)
- **Branch:** `bug/exempt-operand-bypass-brace-and-dot-segments-732`, based on `epic/enforcement-hook-precision-integration`
- **Primary design input:** `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/research/research.2026-10-08T14-00.md`

## Problem Statement

### #732 (primary): exempt-operand bypass

The preimplementation gate's exempt-path check, `Test-ExemptOrchestrationOperand` in
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its byte-identical
copies, can be bypassed. Two confirmed operand shapes resolve outside the exempt trees but are
treated as exempt:

1. Brace expansion (CR-2, #713 review): `docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts`.
   A POSIX shell expands the word to `docs/features/active/../../../src/prod.ts`, which git
   normalizes to `src/prod.ts`. The gate evaluates the literal string, finds no segment equal to
   `..`, matches the `docs/features/active/` prefix, and returns exempt.
2. Dot segments (#710 decision D7): `docs/features/active/.\./.\./.\./src/x.ps1`. The operand check
   rewrites `\` to `/` (the PowerShell reading), producing only `.` segments, and returns exempt. A
   POSIX shell removes the escapes and produces `docs/features/active/../../../src/x.ps1`, which
   resolves to `src/x.ps1`.

Expected: an operand is exempt only when its fully resolved path, after shell expansion and
normalization, lies inside an exempt tree. Otherwise the check fails closed.

Actual: both shapes are exempt, so a production-file change can bypass the preimplementation
readiness gate. Severity: High. Both defects predate the pull requests that found them.

Root cause (research Q2): the operand check prefix-matches the raw string after a PowerShell-style
`\` to `/` rewrite, while the command splitter adopts the POSIX reading of `\`. The check has no
model of brace expansion and rejects only a segment exactly equal to `..`. The defect applies to all
five exempt trees, not only `docs/features/active/`.

### #738: epic-scope resolution reads only the first `git -C` of the first segment

`Get-OrchestrationEpicScopeSelector` on both surfaces tokenizes only the first command segment and
returns the token at index 2 only when the segment starts `git -C`. A second `-C`, a selector in a
later segment, a `cd` segment, a wrapper-led segment, and `--git-dir`/`--work-tree` are not read. An
unresolvable selector (for example a relative `-C`) yields "not epic scope" and silently falls to
the single-feature path. On Claude, a Write/Edit `file_path` into another worktree is evaluated
against the session root's HEAD. On Codex, `apply_patch` file-marker paths are never used for
target resolution.

### #745: trailer-form documentation and missing trailer tests

`.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror do not document the Integration
Commit Form or the trailer commit forms that the gate admits. No test pins `--trailer` taking a
following `--` as its value (CR-4). The typographic quote code points U+201A, U+201B, and U+201E
have no deny row. Helpers line 131 is 140 characters.

### #735: which shell Codex uses on Windows (research precondition)

Before any Codex-surface parsing change, the executing shell had to be determined. The research
artifact (Q1) records the finding: on native Windows, Codex defaults to PowerShell (`pwsh`, then
Windows PowerShell 5.1, then `cmd.exe`), the model may choose another shell per call (`bash`, `sh`,
`zsh`, `cmd`, `pwsh`, `powershell`), and the PreToolUse payload carries only the raw command string,
with neither the shell nor `workdir`. The executing shell is therefore undetermined per command.

## Scope

In scope:

- `Test-OrchestrationCommandTextUnresolvable`, `Test-ExemptOrchestrationOperand`, and the
  outside-quote character constant in all copies of
  `enforce-orchestration-preimplementation-gate-helpers.ps1` (#732, #735, #745 item 4).
- A new pure, byte-identical shared file `enforce-orchestration-preimplementation-gate-targets.ps1`
  in each hook root (`.claude/hooks/`, `.codex/hooks/`, and their bundled mirrors) that implements
  per-segment target resolution by consuming the C1a (#824) API (#738).
- Epic-scope decision changes in `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
  and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and their bundled
  mirrors (#738).
- Header comments recording the #735 finding in the helpers file and in
  `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (and their bundled mirrors).
- Skill documentation: `.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror (#745); the
  quoting-rule paragraph in `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`,
  `.agents/skills/epic-plan/SKILL.md`, and their bundled mirrors (consequence of D2).
- Pack-manifest and parity-test registration of the new shared file.
- New Pester suites and in-place row changes listed under Test Strategy.

## Non-Goals

- No edits to any copy of `enforce-orchestration-preimplementation-gate-modes.ps1`. C2 (#565) owns
  the folder-resolution region (`Find-OrchestrationDelegationTargetFolder`).
- No edits to any copy of `hook-command-invocation.ps1` or `hook-command-scanner.ps1`. C1a (#824)
  owns them; C1b consumes their API only.
- No change to the single-feature target resolution path (`Resolve-OrchestrationGateTarget`).
- No modeling of heredoc-fed commit messages (D5, deferred).
- No `cmd.exe`-specific parsing (D6).
- No new `.claude/rules/` file for the #735 finding (D1).
- No edits to `.github/instructions/*`, `issue.md`, the plan file, or the research artifact by this
  preparation run.
- No bash or Python port of any hook.

### Unfiled follow-up candidates

The following are recorded as follow-up candidates only. **No GitHub issue is created for any of
them in this run.**

| ID | Candidate | Source |
|---|---|---|
| FU-1 | Path-leg `..` gap: `Test-FeatureDocumentationOrEvidencePath` (`-cmatch '(^|/)docs/features/active/'`) admits a Write/Edit `file_path` or Codex `apply_patch` marker such as `docs/features/active/../../src/x.ps1` as non-implementation on both gates. | Research Q2 scope note, Risk 5, Open Question 3 |
| FU-2 | `cmd.exe` divergence: `cmd.exe` does not treat `'` as a quote and interprets `%VAR%` and `^`; a single-quoted message containing a path can become a pathspec. | Research Q1, Risk 3, Open Question 2 |
| FU-3 | Other prefix-match idiom sites: `Test-OrchestrationReady`, `.codex/hooks/enforce-epic-planning-only.ps1`, `enforce-completion-helpers.ps1`, `validate-task-researcher-output.ps1`, `enforce-feature-folder-order.ps1`, and the `docs/features/epics/` checkpoint-field checks. | Research Q2 scope-note table |
| FU-4 | Codex `workdir`: request upstream payload support for `workdir` (and the selected shell), or add a Codex strict mode in epic scope that denies an implementation-classified git segment without an absolute `-C`. | Research Q3, Open Question 1, D4 |
| FU-5 | Single-feature `Resolve-OrchestrationGateTarget` still resolves only the first selector. | Research Open Question 6 |

## Decisions

| ID | Issue | Decision | Rationale |
|---|---|---|---|
| D1 | #735 | The executing shell is treated as undetermined on both surfaces. The shared helpers adopt shell-agnostic, fail-closed parsing: any command or operand shape whose meaning differs between a POSIX shell and PowerShell denies. The finding is recorded in hook header comments (helpers file and Codex gate) and in the research artifact. No new `.claude/rules/` file is added. | Codex on native Windows defaults to PowerShell, but the model can select the shell per call and the hook payload carries only the raw command string (research Q1, E1-E12). The hook cannot select a parse. The helpers file is byte-identical across surfaces, so one fail-closed rule serves both. A rules file would need frontmatter, a bundle mirror, and a decision on `.github/instructions/*` canonicity (research Open Question 4); header comments keep the finding next to the code that depends on it. |
| D2 | #732 | Adopt the research Q2 normalization design: (1) deny a backslash anywhere in the command text; (2) extend the outside-quote deny set from `> < #` to `> < # { } , ( ) @`; (3) an operand is exempt only when it matches `^[A-Za-z0-9._/-]+$` (case-sensitive match); (4) a leading `/` (including `//`) denies; (5) any segment equal to `..` denies; (6) the operand must start with one of the five exempt-tree prefixes exactly; (7) remove the `\` to `/` rewrite and the wildcard literal-prefix logic from the operand check. The exemption stays allow-side only; every parse ambiguity denies. | With backslash and `..` denied, a path that starts with an exempt prefix cannot leave it lexically, so a dot-segment collapse step adds code without changing any decision. The allowlist subsumes the leading-colon, drive-letter, UNC, `~`, `%`, `^`, `!`, `=`, `+`, whitespace, non-ASCII look-alike, brace, comma, and glob/bracket checks. No tracked file under `docs/features/` uses a character outside the allowlist (research Q2 character-set check). The change reduces net helper lines. |
| D2a | #732 | The following allow-to-deny reversals are intended behavior changes: (a) D4 row 18 backslash-operand allow in the Claude CommandExemption suite and the Codex command-exemption suite; (b) LACS allow 3 (backslash selector) in both suites; (c) the ChainEscape escaped-semicolon row (`git commit -m fix\;done -- docs/features/active/x/spec.md`) changes from exempt to not exempt. A glob operand under an exempt tree (for example `docs/features/active/x/*.md`), currently admitted by the literal-prefix logic but untested, also changes to deny. | Under PowerShell `fix\;done` runs `git commit -m fix\` (a pathless commit of the index) followed by `done`. Backslash readings diverge between shells (D1). Glob expansion differs between shells and no tested allow row or skill document uses a glob operand under an exempt tree (research Q2 glob note). |
| D3 | #738 | Adopt the research Q3 per-segment target contract. Every segment's effective target is resolved. A relative `-C` value, or one containing a `.` or `..` segment, is unresolved. When any candidate (the session root or any resolved target) is epic scope, an unresolved, mixed, or ambiguous target set denies, and every resolved target must satisfy the epic readiness conditions. When no candidate is epic scope, the decision returns no epic-scope verdict and the single-feature path runs unchanged. Segment and invocation parsing is consumed from the C1a (#824) API in `.claude/hooks/hook-command-invocation.ps1` (and its scanner); it is not re-implemented. The C1a function names are not fixed at spec time, so the plan must verify the merged API before editing. Deny reasons keep the `PREIMPLEMENTATION_GATE_BLOCKED:` leading token and carry stable reason codes for new denies. | Fail-closed is the repository norm for an unresolvable or ambiguous target (epic Shared Design). The epic assigns `hook-command-invocation.ps1` to C1a and requires later children to consume its matching API. Keeping the leading token preserves consumers that match on it. Leaving the single-feature path unchanged keeps #738 within its stated scope (epic-scope resolution). |
| D4 | #738 | Codex `workdir` is unobservable to the hook. The session root (the hook process working directory) is the target for any Codex segment without an explicit `-C`. The residual is recorded as follow-up candidate FU-4. | The Codex PreToolUse payload carries `tool_input.command` only; `workdir` and the selected shell are absent, and the payload `cwd` is the session cwd (research Q1 E9, E11). A Codex strict mode would change Codex epic-orchestrator command forms outside this child's scope. |
| D5 | #745 item 5 | Heredoc-fed commit messages are deferred. They remain documented as not admitted. | Heredoc syntax is shell-specific (POSIX `<<'EOF'`; PowerShell `@' '@` here-strings; none in cmd), and the executing shell is undetermined (D1), so a byte-identical shared helper cannot select a parse. `<` is already in the outside-quote deny set. The two admitted forms (`--trailer` and the single-paragraph multi-`-m` form) already carry both attribution trailers. The helpers file has little line headroom. |
| D6 | #735 residual | The `cmd.exe` single-quote divergence is accepted as a recorded residual risk (FU-2). | Closing it on all surfaces would require denying any single-quoted span containing whitespace, which removes the #713 single-quoted trailer forms. `cmd.exe` is reached only as the last fallback or by an explicit model choice. |
| D7 | #745 item 4 | The line-length target is 120 characters. No analyzer rule enforces it: `PSAvoidLongLines` is not enabled in `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and no repository rule file states a PowerShell line-length limit. | 120 is the `PSAvoidLongLines` default maximum (research Q5; quoted from general knowledge of the rule, not verified). D2 shortens the line at 131 to about 107 characters. Wrapping helpers line 78 (144 characters) is optional and outside the AC. |
| D8 | ordering | This plan executes after C1a (#824) and C2 (#565) merge into `epic/enforcement-hook-precision-integration`. C1b makes no edits to any `enforce-orchestration-preimplementation-gate-modes.ps1` copy and no edits to `hook-command-invocation.ps1` or `hook-command-scanner.ps1` (any copy). | Epic Dependency Rationale: C1b consumes C1a's segment and wrapper matching and edits the gate family whose folder resolution C2 changes. Line numbers cited in this spec and the research may move after the rebase. |

## Functional Requirements

### FR-1 (#732, #735): command-text level

1. `Test-OrchestrationCommandTextUnresolvable` returns true when the command text contains a
   backslash anywhere, inside or outside quotes. The double-quote backslash branch and the
   escaped-quote checks that this rule subsumes are removed.
2. `$script:OutsideQuoteCommandCharacters` is `> < # { } , ( ) @`. Each of these characters outside
   any quote makes the command text unresolvable.
3. Existing rules are preserved: `$` and backtick outside single quotes, and typographic quotes
   U+2018 to U+201E anywhere, make the text unresolvable.

### FR-2 (#732): operand level

`Test-ExemptOrchestrationOperand` returns true only when all of the following hold; otherwise false:

1. The operand matches `^[A-Za-z0-9._/-]+$` with a case-sensitive match.
2. The operand does not start with `/`.
3. No `/`-separated segment equals `..`.
4. The operand starts with one of the five exempt-tree prefixes exactly: `docs/features/epics/`,
   `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`,
   `artifacts/orchestration/`.

The `\` to `/` rewrite and the wildcard literal-prefix logic are removed from the operand check.
`$script:PathspecWildcardCharacters` remains because `Test-ExemptOrchestrationSelector` uses it.

### FR-3 (#738): per-segment target resolution

A new shared file `enforce-orchestration-preimplementation-gate-targets.ps1` (pure string and path
logic; no process, network, or environment access beyond what C1a's API performs) exposes a target
resolver. Proposed contract (the name may be adjusted by the plan; the return shape is normative):

```
Get-OrchestrationCommandTarget -Command <string> -FilePath <string> -SessionRoot <absolute path>
  -> [pscustomobject] @{ Resolved = [bool]; Targets = [string[]]; ReasonCode = [string]; Detail = [string] }
```

Rules (any rule that yields unresolved sets `Resolved = $false` with a reason code):

1. Path leg: an absolute `file_path` contributes its own path; a relative one contributes the
   session root. On Codex, each `apply_patch` file-marker path is treated the same way.
2. Command leg: segments are obtained from the C1a API (`Read-CommandLineSegment` or its merged
   successor). An unbalanced segment is unresolved.
3. A segment whose command word changes the working directory (`cd`, `pushd`, `popd`, `chdir`,
   `Set-Location`, `sl`, `Push-Location`, `Pop-Location`) is unresolved.
4. A wrapper-led or live-substitution segment that the C1a matcher reports as invoking `git` is
   unresolved.
5. A `GIT_DIR=`, `GIT_WORK_TREE=`, `GIT_COMMON_DIR=`, or `GIT_INDEX_FILE=` prefix, or a `--git-dir`
   or `--work-tree` option, is unresolved.
6. For each `git` segment, every `-C` value is collected by walking the global options with the C1a
   git option table (`Get-CommandLineGlobalOption` or its merged successor). A relative value, or a
   value containing a `.` or `..` segment, is unresolved. A segment with no `-C` contributes the
   session root (D4).
7. `Targets` is the distinct set of normalized absolute targets.

### FR-4 (#738): epic-scope decision, both surfaces

`Get-OrchestrationEpicScopeDecision` on Claude and Codex:

1. Evaluates epic scope for the session root and for every resolved target.
2. Returns no epic-scope verdict when no candidate is epic scope; the single-feature path runs
   unchanged.
3. Denies when any candidate is epic scope and the target set is unresolved, mixed (some targets not
   epic scope), or ambiguous, or any target fails the epic command-leg readiness check.
4. Allows only when every target is epic scope and passes readiness.
5. On Claude, `target-worktree-ambiguous` for any target becomes a deny (previously "not epic
   scope").
6. Deny reasons begin with `PREIMPLEMENTATION_GATE_BLOCKED:` and contain one stable reason code:
   `target-unresolvable`, `target-mixed`, `target-ambiguous`, or `target-not-ready`. Existing deny
   reasons are unchanged.

### FR-5 (#735): recorded finding

The header comment of the helpers file (all copies) and of
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (and its bundled mirror) states that
the executing shell is undetermined per command, cites #735 and the research artifact, and states
the shell-agnostic fail-closed rule. The Codex gate header also states that `workdir` is not in the
payload and that the session root is the default target (D4).

### FR-6 (#745): documentation

1. `.agents/skills/epic-plan/SKILL.md` and
   `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`
   document the Integration Commit Form and the trailer commit forms the gate admits: single-quoted
   `$`, single-quoted backtick, and `--trailer` (separate-value and `=` forms). Recommended
   placement: after `## Integration Branch`, in Codex wording.
2. The quoting-rule paragraph in `.claude/skills/epic-plan/SKILL.md`,
   `.claude/skills/parallel-plan/SKILL.md`, `.agents/skills/epic-plan/SKILL.md`, and each of their
   bundled mirrors states: a backslash anywhere is denied; `{ } , ( ) @` are denied outside quotes;
   staging operands must be plain forward-slash repo-relative paths using only
   `A-Z a-z 0-9 . _ / -`.
3. Heredoc-fed commit messages remain documented as not admitted (D5).

## Constraints

- **Mirrors.** Every changed hook file updates its Codex copy where one exists and its bundled
  mirror under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/...` and
  `codex-and-agents-customizations/.codex/...` or `.agents/...`). Every changed skill document
  updates its bundled mirror.
- **Byte identity.** `enforce-orchestration-preimplementation-gate-helpers.ps1` has four
  byte-identical copies: `.claude/hooks/`, `.codex/hooks/`,
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (count confirmed
  by research Numeric Derivation Evidence N1 and re-checked during spec authoring by filename glob
  and by a search for `function Test-ExemptOrchestrationOperand`; both returned the same four
  paths). The new targets file follows the same four-root, byte-identical pattern and is registered
  in both `pack-manifests/core.json` files, in `SharedModuleNames` in
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and in a parity test.
- **Parity tests stay green.** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`,
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`,
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
  `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`,
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`,
  `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and
  `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`.
- **No Python in hooks.** No hook gains a Python file or a Python invocation.
- **500-line cap** on every production and test file. Current budgets (research Q2, Q3, Q6; may
  move after the D8 rebase): helpers 497; `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  466; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 487; Claude epic-scope 279;
  Codex epic-scope 189; Codex epic-resolution 493 (no edits planned); Claude CommandExemption suite
  493 and Codex command-exemption suite 496 (in-place row changes only); AttributionTrailer suite
  103; ChainEscape suite 198. New logic and new tests go in new files.
- **Coverage.** PowerShell line coverage >= 85% for every changed or added file under
  `.claude/hooks`, `.claude/lib`, and `.codex/hooks`. Coverage evidence is produced by invoking the
  in-repo PoshQC module directly (the MCP runner rewrites the coverage artifact with installed
  extension settings).
- **Toolchain.** PowerShell format, analyze, and test per `.claude/rules/powershell.md`, repeated
  until a single clean pass.
- **Upstream ordering.** D8. Before editing, the plan records the merged C1a API (function names,
  signatures, return shapes, and scanner record fields) from
  `epic/enforcement-hook-precision-integration`.
- **Evidence location.** All evidence is written under this feature folder's `evidence/<kind>/`.

## Test Strategy

All new or changed rows are fail-before: each new deny row is run against the pre-change code and
its failure is recorded under `evidence/regression-testing/` before the fix is applied.

1. **Helper-level operand normalization (#732, #735), both surfaces.** New suite
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1`,
   run against the Claude and Codex helpers copies (ChainEscape precedent). Rows:
   - Deny: both #732 shapes; `\;`, `\&`, `\|` inside a command; `.\.` operands;
     `docs\features\active\x\a.md`; brace `{a,b}` and `{a..b}` in an operand and in an unquoted
     message; unquoted comma; unquoted `@name`; unquoted `(` and `)`; glob operands `*`, `?`, `[`
     under an exempt tree; leading `/` and `//`; a `..` segment; a drive-letter operand; `~`, `%`,
     `^`, `!`, `=`, `+` in an operand; a non-ASCII look-alike character.
   - Allow: an ordinary operand under each of the five exempt trees; an operand containing a `.`
     segment within an exempt tree; a single-quoted message containing `{`, `,`, `(`, or `@`.
2. **Gate-level #732 rows, both surfaces.** New suites
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1`
   and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1`
   invoke the gate script with a staging command carrying each #732 shape, without an authorizing
   checkpoint, and assert a deny decision with the `PREIMPLEMENTATION_GATE_BLOCKED:` token.
3. **Intended reversals (D2a).** In-place row changes in
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`,
   `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`,
   and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`.
4. **Targets unit suite (#738).** New suite
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`
   covering each FR-3 rule and reason code, run against the Claude and Codex copies.
5. **Gate-level #738 suites, both surfaces.** New suites
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`
   and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`.
   Rows: a two-segment command whose second segment targets a different worktree; a repeated `-C`;
   a relative `-C`; an unresolvable `-C`; a `cd` segment; a wrapper-led git segment; all targets
   epic scope and ready (allow); no candidate epic scope (single-feature path unchanged); on Claude,
   a Write/Edit `file_path` into another worktree; on Codex, an `apply_patch` absolute file marker
   into another worktree and a segment without `-C` resolving to the session root (D4). Fixtures
   construct worktree topologies in memory or through the existing test seams; no temporary files.
6. **#745 trailer rows.** In-place additions to
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`:
   admit `git commit -m x --trailer -- docs/features/active/x/a.md`; deny
   `git commit -m x --trailer -- src/x.ts`; deny rows for U+201A, U+201B, and U+201E (research N2).
7. **Regression of existing suites.** All existing preimplementation-gate, epic-scope, operand
   resolution, worktree resolution, and `claude-lib/worktree-resolution` suites pass. Assertion
   changes to existing rows are limited to the D2a reversals and to rows the plan lists in
   `evidence/other/` as D3 intended changes (for example a relative `-C` in an epic-scope session,
   which previously fell to the single-feature path).
8. **Parity and manifest suites** listed under Constraints.

## Acceptance Criteria

### #732

- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1` asserts that `Test-ExemptOrchestrationStagingCommand` returns `$false` for `git add docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts` and for `git add docs/features/active/.\./.\./.\./src/x.ps1` against both the Claude and Codex helpers copies, and a fail-before run of both rows against the pre-change helpers is recorded under `evidence/regression-testing/`.
- [ ] The same suite asserts `$false` for every deny row listed in Test Strategy item 1 (backslash forms, brace forms, unquoted comma, `@name`, parentheses, glob operands, leading `/` and `//`, `..` segment, drive letter, `~ % ^ ! = +`, non-ASCII look-alike) on both surfaces, and the suite passes.
- [ ] The same suite asserts `$true` for an ordinary operand under each of `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, and `artifacts/orchestration/`, for an operand with a `.` segment inside an exempt tree, and for a single-quoted message containing `{`, `,`, `(`, or `@`, on both surfaces.
- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1` pass and assert a deny decision containing `PREIMPLEMENTATION_GATE_BLOCKED:` for both #732 shapes when no authorizing checkpoint exists.
- [ ] The D4 row 18 backslash-operand row and the LACS allow 3 row assert deny in both `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and both suites pass.
- [ ] The escaped-semicolon row (`git commit -m fix\;done -- docs/features/active/x/spec.md`) in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` asserts not exempt on both surfaces, and the suite passes.
- [ ] `Test-ExemptOrchestrationOperand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` contains no `\` to `/` rewrite and no wildcard literal-prefix branch, and `$script:OutsideQuoteCommandCharacters` lists exactly `> < # { } , ( ) @` (verified by reading the file).
- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, asserting SHA256 identity of all four helpers copies and that each is at most 500 lines.

### #738

- [ ] `evidence/other/` contains a C1a API verification record, written before any edit to an epic-scope or targets file, that lists the function names, signatures, and return shapes consumed from `hook-command-invocation.ps1` and `hook-command-scanner.ps1` as merged on `epic/enforcement-hook-precision-integration`; and `enforce-orchestration-preimplementation-gate-targets.ps1` calls only those functions for segment and option parsing and does not call `Split-OrchestrationCommandLine`.
- [ ] `enforce-orchestration-preimplementation-gate-targets.ps1` exists in `.claude/hooks/`, `.codex/hooks/`, and both bundled hook roots; a Pester parity test asserts the four copies are SHA256-identical and at most 500 lines; the file is listed in both `pack-manifests/core.json` files and in `SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` passes and covers each FR-3 rule (path leg, unbalanced, directory-changing command, wrapper-led or substitution git, `GIT_*` prefix and `--git-dir`/`--work-tree`, repeated `-C`, relative and dot-segment `-C`, no `-C` resolving to the session root) on both copies.
- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` passes and asserts, at gate level on the Claude surface: deny for a two-segment command whose second segment targets a different, not-ready worktree; correct handling of a repeated `-C` (every value evaluated); deny for a relative `-C`; deny for an unresolvable `-C`; deny for a `cd` segment and a wrapper-led git segment; deny for a Write/Edit `file_path` into a not-ready epic worktree; allow when every target is epic scope and ready; unchanged single-feature behavior when no candidate is epic scope.
- [ ] `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` passes and asserts the same command-leg rows on the Codex surface, plus deny for an `apply_patch` absolute file marker into a not-ready epic worktree and session-root resolution for a segment without `-C`.
- [ ] Every new epic-scope deny asserted in the two gate-level #738 suites begins with `PREIMPLEMENTATION_GATE_BLOCKED:` and contains one of the reason codes `target-unresolvable`, `target-mixed`, `target-ambiguous`, or `target-not-ready`.
- [ ] The existing suites `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `.OperandResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1` (Claude), `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` and `-epic-resolution.Tests.ps1` (Codex), and `tests/scripts/claude-lib/worktree-resolution/*.Tests.ps1` pass, and any changed assertion in them is listed in an `evidence/other/` record of D3 intended changes.

### #745

- [ ] `.agents/skills/epic-plan/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md` contain an Integration Commit Form section documenting the single-quoted `$`, single-quoted backtick, and `--trailer` commit forms, and the two files are identical (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passes).
- [ ] The quoting-rule text in `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`, `.agents/skills/epic-plan/SKILL.md`, and each bundled mirror states that a backslash anywhere is denied, that `{ } , ( ) @` are denied outside quotes, and that operands use only `A-Z a-z 0-9 . _ / -`.
- [ ] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` contains an admit row for `git commit -m x --trailer -- docs/features/active/x/a.md` and a deny row for `git commit -m x --trailer -- src/x.ts`, and the suite passes.
- [ ] The same suite contains deny rows whose command text includes U+201A, U+201B, and U+201E respectively, and the suite passes.
- [ ] In all four helpers copies, the backslash test formerly at line 131 and every line added or changed by this child is at most 120 characters, verified by a line-length scan recorded under `evidence/qa-gates/`.
- [ ] This spec records the D5 adopt-or-defer decision for heredoc-fed commit messages with its rationale (Decisions table, row D5).

### #735

- [ ] `research/research.2026-10-08T14-00.md` in this feature folder contains section Q1 recording the Codex Windows shell finding and its evidence table.
- [ ] The commit that added `research/research.2026-10-08T14-00.md` precedes, in `git log` on this branch, the first commit that modifies any file under `.codex/hooks/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- [ ] The header comment of all four helpers copies and of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundled mirror cites #735 and states that the executing shell is undetermined and that shell-divergent shapes deny; the Codex gate header also states that `workdir` is not in the payload and the session root is the default target.

### Cross-cutting constraints

- [ ] `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD` lists no copy of `enforce-orchestration-preimplementation-gate-modes.ps1`, `hook-command-invocation.ps1`, or `hook-command-scanner.ps1`.
- [ ] `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` pass.
- [ ] No file added or changed under `.claude/hooks/`, `.codex/hooks/`, or their bundled mirrors is a Python file or invokes `python`, `python3`, `py`, or `poetry` (verified by content search recorded under `evidence/qa-gates/`).
- [ ] Every production and test file added or changed by this child is at most 500 lines (line counts recorded under `evidence/qa-gates/`).
- [ ] A direct in-repo PoshQC module run records PowerShell line coverage >= 85% for every added or changed file under `.claude/hooks/`, `.claude/lib/`, and `.codex/hooks/`, with the artifact under `evidence/qa-gates/` and a baseline under `evidence/baseline/`.
- [ ] The PowerShell toolchain (format, analyze, test) completes a single clean pass, recorded under `evidence/qa-gates/`.

## Risks & Mitigations

- **Agent habits narrowed.** Backslash operands, `-C C:\...` selectors, unquoted commas or
  parentheses in messages, and glob operands become denials. Mitigation: FR-6 documents the
  accepted forms; the deny prefix is unchanged.
- **C1a API drift.** The resolver depends on an API not fixed at spec time. Mitigation: the D3 and
  constraint verification step before editing; consumption isolated in the targets file.
- **`cmd.exe` residual** (D6, FU-2) and **Codex `workdir` residual** (D4, FU-4) remain open.
- **Path-leg `..` gap** (FU-1) remains open; it is outside the bundled acceptance conditions.
- **Line caps.** Several files have little or no headroom; new logic and tests go in new files.
- **Stale evidence.** The research read branch state without a fetch and did not read issue
  comments. The plan re-reads `gh issue view <n> --json body,comments` for #732, #738, #745, and #735
  before editing and records any overriding decision.

## Rollout & Follow-up

- Delivered as one pull request into `epic/enforcement-hook-precision-integration`; closes #732,
  #738, #745, and #735.
- Follow-up candidates FU-1 to FU-5 are recorded above and are not filed in this run.
- Downstream: C4 (#786) enumerates hook imports after this child merges (the targets file adds a
  dot-source); C5b (#737) adds Claude/Codex parity coverage of the gate pair this child changes.
