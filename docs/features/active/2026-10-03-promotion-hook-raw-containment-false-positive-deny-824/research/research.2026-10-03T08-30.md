# Research: promotion-hook raw-containment false-positive deny (Issue #824)

- **Issue:** #824
- **Branch:** bug/promotion-hook-raw-containment-false-positive-deny-824
- **Baseline:** main at 93725814
- **Date:** 2026-10-03
- **Scope:** read-only research. All citations are `path:line` against the worktree `drm-copilot-wt-824` at the baseline commit.

## 1. Summary of findings

1. The defect is in the shared helper, not in the promotion hook. `Resolve-CommandLineInvocation` (`.claude/hooks/hook-command-invocation.ps1:202-205`) returns a match for any wrapper-led or live-substitution segment when `Test-CommandLineRawContainment` (`:92-117`) reports that the raw segment text contains the command word and every subcommand element as ordinal, case-insensitive substrings (`:111-116`). Word boundaries, order, and adjacency are not checked. The `.codex` copy is line-for-line the same (`.codex/hooks/hook-command-invocation.ps1:92-117`, `:202-205`).
2. The reproduction command is denied by the promotion hook's structural leg (`.claude/hooks/enforce-promotion-mcp-only.ps1:126-129`). It is not denied by the hook's own adjacency regex (`:116-120`): that regex is already token-aware and does not match the reproduction.
3. Every "must still deny" case in the acceptance criteria is caught today by a leg that does not use raw containment: the adjacency regex `(?i)\bgh\s+issue\s+(?:create|new)\b` evaluated per segment against `ScanText`, which is the raw text for wrapper-led segments (`.claude/hooks/enforce-promotion-mcp-only.ps1:116-120`, `.claude/hooks/hook-command-scanner.ps1:150-151`), the structural token match (`hook-command-invocation.ps1:207-234`), or the `gh api` lookahead regex (`enforce-promotion-mcp-only.ps1:136-141`). Replacing raw containment with a token-aware sequence match therefore removes the false positive without removing any acceptance-criteria deny.
4. The raw-containment rule feeds 34 call expressions in 13 hook files across both runtimes (see section 3 and the Numeric Derivation Evidence). At least four call families convert a raw-containment false positive into a hard deny: the promotion hook, the pr-author `gh pr create` Case B, both worktree-removal gates (a false positive resolves no operand and no checkpoint record can match a null path), and the `validate-bash` structural leg when a `-f`, `--force`, or `--hard` token is present outside the quoted argument. Fixing the shared helper corrects all of them at once.
5. `hook-command-invocation.ps1` is 483 lines on both surfaces. A token-aware matcher with documentation does not fit under the 500-line cap in place. The recommended design places it in a new shared module.

## 2. Current behaviour of the shared parser

### 2.1 Segment classification (`.claude/hooks/hook-command-scanner.ps1`)

- `Read-CommandLineSegment` (`:303-483`) scans once, left to right. Outside quotes and heredoc bodies, segments end at `;`, `&`, `|`, newline, `(`, `)`, `{`, `}`, backtick (`:31`), and at the two-character `$(` opener (`:434-455`).
- Each record carries `RawText`, `MaskedText`, `Tokens`, `CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`, `Unbalanced`, `ScanText` (`:153-162`).
- `IsWrapperLed` is true when the first non-`VAR=value` token is in `sh, bash, zsh, dash, ksh, pwsh, powershell, xargs, env, command, eval, nohup, time, timeout` (`:21-24`, `:144-148`).
- `HasLiveSubstitution` is true when `$(` or a backtick occurs inside a double-quoted span (`:382`).
- `Unbalanced` is true when a quote or heredoc does not close, or a heredoc delimiter is not literal (`:423-429`, `:447`, `:475`).
- `ScanText` is `RawText` when `Unbalanced`, `HasLiveSubstitution`, or `IsWrapperLed`; otherwise `MaskedText` (`:150-151`).
- Tokens collapse a balanced quoted span into one token (`ConvertTo-CommandLineToken`, `:49-97`), so the contents of `pwsh -Command '...'` or `bash -c "..."` are one token and are invisible to the structural matcher.

### 2.2 Invocation resolution (`.claude/hooks/hook-command-invocation.ps1:166-238`)

Per segment, in order:

| Rule | Condition | Result | Citation |
|---|---|---|---|
| R1 Unbalanced | `$segment.Unbalanced` | match, `OperandIndex = -1` | `:198-200` |
| R2 Raw containment | `IsWrapperLed -or HasLiveSubstitution` and `Test-CommandLineRawContainment` true | match, `OperandIndex = -1` | `:202-205` |
| R3 Structural | skip `VAR=value` and transparent wrappers `command, env, nohup, time, timeout` (`:23`, `:207-213`); token equals `CommandWord` (PowerShell `-ne`, case-insensitive) (`:215`); before each subcommand element, absorb modeled options (`Skip-CommandLineOption`, `:119-164`) | match with `OperandIndex` past the path (`:232-233`) | `:207-234` |
| R3a Unmodeled option | a dash token in neither option list between the command word and a subcommand element | match, `OperandIndex = -1` | `:220-223` |
| none | no segment matched | `$null` | `:237` |

Result shape: `$null`, or `[pscustomobject]@{ Segment; OperandIndex }`. `OperandIndex = -1` marks a non-structural match; `Get-CommandLineOperand` then returns an empty array (`:309-312`), while `Get-CommandLineFlagValue` and `Test-CommandLineFlag` still read the matched segment's tokens (`:397-419`, `:445-454`).

Only R2 reaches `Test-CommandLineRawContainment`. Its second caller, `Test-CommandLineMention` (`:457-483`), is documented as informational and no hook calls it (verified: no production match for `Test-CommandLineMention` outside `hook-command-invocation.ps1`).

### 2.3 The documented contract versus caller behaviour

`Test-CommandLineRawContainment` states that "a false positive only forces a checkpoint check" (`:98-99`); the option-table comment repeats the claim (`:29`). Section 3 shows this is true for two call families and false for four.

### 2.4 Reproduction trace

`pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`

- One segment: the single-quoted span contains `;`, `(`, `{`, but they are inside quotes and do not split.
- `CommandWord = pwsh`, so `IsWrapperLed = $true` and `ScanText = RawText`.
- Adjacency regex (`enforce-promotion-mcp-only.ps1:117`): no `gh\s+issue\s+(create|new)` sequence, so no match.
- R2 for `@('issue','new')`: `gh` is a substring of `through`; `issue` occurs literally; `new` is a substring of `New-Object`. Containment is true, so `Test-CommandLineInvocation` returns true and the hook returns the gh-issue deny reason (`:126-129`).

## 3. Call graph and false-positive consequence per caller

Production callers of the resolver family (`Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`). All reach `Resolve-CommandLineInvocation`, so all inherit R2.

| Hook (runtime) | Call sites | Command / path | Effect of an R2 false positive | Hard deny? |
|---|---|---|---|---|
| `enforce-promotion-mcp-only.ps1` (Claude) | `:126-127` | `gh issue create`, `gh issue new` | returns `Get-PromotionMcpOnlyGhIssueBlockedReason` (`:128`) | Yes, unconditional |
| `enforce-promotion-mcp-only.ps1` (Codex) | `:123-124` | same | same (`:125`) | Yes, unconditional |
| `enforce-pr-author-skill-helpers.ps1` (Claude) | `:279-280`, `:290-291` | `gh pr create`, `gh pr edit` | for `pr create` with no `--body`/`--body-file` in tokens or raw text: Case B `PR_AUTHOR_SKILL_BLOCKED` (`:319-323`); for `pr edit` with no body flags: allow (`:326-330`); with a `--body` substring in raw text: Case A deny (`:299-317`) | Yes for `pr create` (Case B), and Case A when `--body` text is present |
| `enforce-pr-author-skill.epic-base-branch.ps1` (Claude) | `:92`, `:100`, `:138` | `gh pr create --base` | only reached after the helpers' checks; checkpoint `epic_mode` conditional (`:107-121`) | Conditional on checkpoint |
| `enforce-epic-worktree-removal-gate.ps1` (Claude) | `:140-141`, `:355` | `git worktree remove` | in scope; operand list is empty for `OperandIndex = -1`, so path is `$null` or `--force` (`:143-149`); every allow predicate rejects a null/blank path (`:172-174`, `:214-216`, `:250-252`); deny at `:403` | Yes, effectively unconditional |
| `enforce-epic-worktree-removal-gate.ps1` (Codex) | `:58-59`, `:126` | same | same structure | Yes, effectively unconditional |
| `enforce-parallel-worktree-removal-gate.ps1` (Claude) | `:201-202`, `:361` | same | same structure (`:365-398`) | Yes, effectively unconditional |
| `validate-bash.ps1` (Claude) | `:123`, `:127` | `git push`, `git reset` | structural leg returns a denylist literal only when the segment's tokens also contain `--force`/`-f` or `--hard` (`:124-128`); a wrapper's quoted argument is one token, so the flag must sit outside the quotes. Example: `pwsh -NoProfile -f ./scripts/legit-push.ps1` (`legit` contains `git`, `-f` is a pwsh token) returns `git push -f` | Yes, when a matching flag token is present |
| `validate-bash.ps1` (Codex) | `:96`, `:100` | same | same | Same |
| `enforce-orchestration-preimplementation-gate.ps1` (Claude) | `:142` | `git add`, `git commit` | `Test-ImplementationCommand` true (`:144-157`), so the readiness checkpoint is consulted (`:338`, `:348-412`); allow when ready | No; checkpoint check (the documented contract) |
| `enforce-orchestration-preimplementation-gate.ps1` (Codex) | `:161` | same | same | No; checkpoint check |
| `enforce-epic-merge-gate.ps1` (Claude) | `:128`, `:134`, `:342-343` | `gh pr merge --merge` | requires a `--merge` flag (token or raw substring, `:343-352`); then checkpoint and authorization chain (`:357-399`) | No; checkpoint/authorization check |
| `enforce-epic-merge-gate.ps1` (Codex) | `:63`, `:69`, `:141-142` | same | same | No; checkpoint check |

Hooks that dot-source the helper but do not call the resolver: `enforce-parallel-abandon-gate.ps1` uses only `Read-CommandLineSegment` and `Test-CommandLineSegmentRawScan` (`:144`, `:183`, `:218`, `:226`), with adjacent-phrase substring scans (`:152-155`). It does not use R2 and is out of scope.

Concrete false-positive fixtures (each derived by tracing the code paths above; not executed in this read-only session):

- Promotion: the issue reproduction (section 2.4).
- pr-author Case B: `pwsh -NoProfile -Command 'Select-String -Path README.md -Pattern "high priority" | ForEach-Object { "create" }'` (`gh` in `high`, `pr` in `priority`, `create` literal).
- Worktree gates: `pwsh -NoProfile -Command 'git worktree list --porcelain | Select-String -NotMatch "removed"'` (`remove` in `removed`).
- validate-bash: `pwsh -NoProfile -f ./scripts/legit-push.ps1`.
- Preimplementation (checkpoint-gated): `pwsh -NoProfile -Command 'Write-Output "digit address"'`.

## 4. How `gh api ... issues -X POST` is detected

`enforce-promotion-mcp-only.ps1:136-141` (Codex `:133-138`) evaluates, per segment against `ScanText`:

`(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))`

It does not use the resolver or R2, so the fix does not touch it. Both the bare form and a wrapped form (`bash -c "gh api repos/o/r/issues -X POST"`, where `ScanText` is raw) deny today and continue to deny.

Pre-existing gaps observed in this regex (not caused by #824 and not in its acceptance criteria): `--method=POST`, `-XPOST`, a global option between `gh` and `api` (`gh -R o/r api ...`), implicit POST through `-f`/`-F`/`--field`/`--raw-field`/`--input`, and the GraphQL `createIssue` mutation. Recommend recording these as a follow-up rather than widening #824.

## 5. Mirrors and parity enforcement

Every candidate production file has one bundled mirror.

| Canonical | Mirror | Enforced by |
|---|---|---|
| `.claude/hooks/hook-command-invocation.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (every repo `.claude` file present in the bundle with identical text) |
| `.codex/hooks/hook-command-invocation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:114-120` (byte identity for `SharedModuleNames`, `:30`); `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215` |
| any new `.claude/hooks/*.ps1` | bundled copy plus a `paths` entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (current entries `:55-56`) | `test_push_down_claude_pack_manifest_completeness.py:139` (every bundled hook listed in a pack manifest) |
| any new `.codex/hooks/*.ps1` | bundled copy plus a `paths` entry in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (current entries `:45-46`) | `legacy-codex-hook-contracts.Tests.ps1:137-142` (each `SharedModuleNames` member listed); `test_push_down_codex_and_agents_pack_manifest_completeness.py` |

Additional constraints:

- `legacy-codex-hook-contracts.Tests.ps1:96-112` parse-checks every `SharedModuleNames` member in both roots and enforces the 500-line cap. A new Codex shared module must be added to the inline list at `:30`. That test file is 497 lines; the change must stay on line 30 and add no lines.
- No test asserts byte identity between the `.claude` and `.codex` copies of `hook-command-invocation.ps1`. They are currently identical in content and line numbers (verified by matching every grep hit at the same line numbers on both copies: `:92`, `:112`, `:114`, `:119`, `:145`, `:166`, `:202`, `:240`, `:271`, `:336`, `:360`, `:422`, `:457`, `:482`). Keeping them identical is a convention, not an enforced invariant. The plan should keep them identical.
- `codex-bundle-hook-probe.Tests.ps1:158-171` counts registered hooks from the bundle config (21 total, 17 PreToolUse). A dot-sourced module is not a registration and does not change those counts.
- A repo-side edit does not change what an installed extension pushes down until the extension is rebuilt and reinstalled; this is a release concern only.

## 6. Existing test suites, coverage, and CI

### 6.1 Suites that exercise the affected behaviour

| Suite | Lines | Relevance |
|---|---|---|
| `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | 330 | Fail-closed rules context `:200-229`; signature pins `:300-328` |
| `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` | 267 | Codex mirror of the same cases (`:201` onward) |
| `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | 197 | promotion deny/allow scoping through `Invoke-PromotionMcpOnlyDecision` |
| `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | 183 | Codex sibling; seam takes mapped `tool_input` JSON |
| `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1`, `tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1` | 214 each | decision surface |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 336 | wrapper deny pins 1-7 (`:123-203`) |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`, `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 147 / 79 | wrapper literal pins |
| `tests/scripts/claude-hooks/enforce-{epic,parallel}-worktree-removal-gate.TriggerScoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | — | worktree scope |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, Codex sibling | — | wrapper deny pins 2, 3, 5 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` `:140-145`, Codex sibling `:92-93` | — | wrapped `gh pr merge --merge` |
| `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` | — | AT-6 pwsh wrapper case (`:174-180`) |

Every existing wrapper case that expects a deny uses an adjacent spelling (`bash -c 'git add .'`, `echo x | xargs git add`, `echo "$(git add .)"`, `bash -c "gh pr merge --merge 688"`, `bash <<'EOF'` with `gh pr create` in the body, and the others listed above). A token-aware sequence match keeps all of them. One test name becomes inaccurate and should be renamed: "classifies a wrapper-led segment whose raw text carries the words in any arrangement" (`claude-hooks/hook-command-invocation.Tests.ps1:201`, `codex-hooks/hook-command-invocation.Tests.ps1:201`). Its assertions remain valid.

### 6.2 Coverage configuration and CI

- Coverage population comes from `config/poshqc-coverage.json:3-9` (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`). A new module under either hooks root enters the coverage denominator automatically. Bundled mirrors under `extensions/` are not measured.
- `.github/workflows/_poshqc.yml:8-52` (Windows): `Invoke-PoshQCFormat` with a dirty-tree check (`:22-30`), `Invoke-PoshQCAnalyze` (`:32-36`), `Invoke-PoshQCTest` with coverage (`:38-42`).
- `.github/workflows/_poshqc.yml:54-90` (Linux): Pester over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled (`:76-78`).
- `quality-tiers.yml:28-33` classifies `.claude/hooks` and `.codex/hooks` as T3: uniform 85% line coverage applies; there is no property-test or mutation obligation.

## 7. Runtime parity

`.codex/hooks` carries parallel implementations of five of the eight affected Claude hooks: promotion, validate-bash, preimplementation gate, epic worktree-removal gate, and epic merge gate. There is no Codex pr-author hook and no Codex parallel worktree-removal gate. All Codex hooks dot-source `.codex/hooks/hook-command-invocation.ps1`, so a change to the shared helper on both surfaces corrects both runtimes without touching any per-hook file.

## 8. Candidate designs

### Option A (recommended): token-aware raw sequence matcher in a new shared module, used by R2

Replace the predicate in R2 (`hook-command-invocation.ps1:202-205`, both surfaces) with a new pure function `Test-CommandLineRawInvocation`, defined in a new sibling module `hook-command-raw-invocation.ps1` that `hook-command-invocation.ps1` dot-sources next to the scanner (`:17`). The R1 Unbalanced branch, R3, R3a, all public signatures, and every hook caller stay unchanged.

Matcher grammar, applied to the segment's `RawText`, case-insensitive (`(?i)`), compiled from `CommandWord` and `SubcommandPath`:

- **Leading boundary:** `(?<![\w-])`. A preceding `&`, `;`, `|`, `(`, `{`, whitespace, newline, `'`, `"`, `=`, `$`, `/`, or `\` is accepted, so `& gh`, `"gh`, `(gh`, `/usr/bin/gh`, and `C:\tools\gh` qualify. `through`, `high`, `legit`, `digit`, and `New-Object` do not.
- **Command word:** the escaped literal, then optional `(?:\.exe)?` for Windows path-qualified spellings, then an optional closing quote `(?:\\?['"])?` for `"C:\Program Files\GitHub CLI\gh.exe" issue create` and `& \"gh\" issue create`.
- **Option run before each subcommand element:** `(?:\s+-[^\s'"]*(?:\s+(?:"[^"]*"|'[^']*'|[^\s'"-][^\s'"]*))?)*`. This mirrors R3's absorption before every element (`:219-224`) and R3a's treatment of an unmodeled dash token as a match. It covers `gh -R o/r issue create`, `gh --repo=o/r issue create`, and `git -C "../my wt" worktree remove`. Each iteration must start with whitespace followed by `-`, and a value cannot start with `-`, which limits backtracking.
- **Subcommand element:** `\s+(?:\\?['"])?<escaped literal>(?:\\?['"])?`; whitespace normalisation comes from `\s+`.
- **Trailing boundary:** `(?![\w-])`, so `new` does not match `New-Object` or `newline`, and `remove` does not match `removed`.
- **Expansion positions (fail-closed tier):** each position (the command word and each subcommand element) also accepts a shell expansion token: `\$[A-Za-z_]\w*`, `\$\{[^}]*\}`, `\$\([^)]*\)`, or a backtick span. A match counts only when at least one position matched its literal. This keeps detection of `bash -c 'x=create; gh issue $x'` and `bash -c 'c=gh; $c issue create'`, which raw containment detects today, while the reproduction has no position sequence that satisfies it (`$parts =`, `$t in`, `$t }`). This tier is what keeps requirement 4 ("do not weaken detection of real bypasses") true relative to current behaviour.

Fail-closed handling:

- An Unbalanced segment still classifies at R1 before R2 is evaluated (`:198-200`). No change.
- Obfuscations that raw containment already misses (`g""h`, `g\h`, `$(printf g)h`) remain undetected. This is not a regression.
- R2 still returns `OperandIndex = -1`, so the worktree gates still deny a real wrapped removal (`bash -c "git worktree remove x"`) because no path resolves, and the merge and preimplementation gates still route real wrapped invocations to their checkpoint checks.

Contract correction (requirement and acceptance criterion 5):

- Retain `Test-CommandLineRawContainment` for `Test-CommandLineMention` only. Rewrite its description (`:96-99`) to say that it is a loose containment test used only by the informational mention predicate, and that no classification or deny decision is made from it.
- Rewrite the R2 sentence in the `Resolve-CommandLineInvocation` description (`:172-174`) and the option-table comment (`:28-30`) so they no longer claim that an over-classification only forces a checkpoint check. State instead that R2 requires a token-aware command sequence, and name the callers for which a classification is a hard deny (promotion, pr-author Case B, worktree gates, validate-bash).
- Optionally move `Test-CommandLineRawContainment` into the new module, which frees about 26 lines in `hook-command-invocation.ps1`.

Advantages: one change point per runtime fixes all four hard-deny families and narrows the checkpoint-check families. No hook file and no public signature changes, so the signature pins (`hook-command-invocation.Tests.ps1:300-328`) stay green. The `.claude` and `.codex` copies remain identical.

Limitations: one new file per runtime plus mirrors and manifest entries (section 10). The regex is more complex than the issue's example pattern, so it needs direct unit cases for every boundary and option form.

### Option B (rejected): per-hook token-aware regex in the promotion hook only

Have the promotion hook stop calling `Test-CommandLineInvocation` for wrapper or substitution segments and run its own regex. Rejected because the pr-author, worktree-gate, and validate-bash hard denies would remain (requirement 2), the matcher would be duplicated across hooks, and a structural-only switch on `Test-CommandLineInvocation` would break the pinned parameter list (`hook-command-invocation.Tests.ps1:300-304`).

### Option C (rejected): keep containment and route it to a checkpoint check

Rejected because the promotion hook and `validate-bash` have no checkpoint to consult, and the worktree gates cannot authorize a null path, so routing would still end in a deny for those callers.

## 9. Behaviour semantics after the fix

| Input | Expected | Deciding leg |
|---|---|---|
| Reproduction (section 2.4) | allow | adjacency regex no match; R2 token-aware no match |
| `pwsh -NoProfile -Command 'Write-Output "through"; "issue"; New-Object Text.StringBuilder'` | allow | as above |
| `gh issue create --title x` / `gh issue new --title x` | deny | adjacency regex and R3 |
| `GH  Issue  Create` | deny | adjacency regex `(?i)` + `\s+`; R3 (`-ne` is case-insensitive) |
| `pwsh -NoProfile -Command 'gh issue create --title x'` | deny | adjacency regex on raw `ScanText`; R2 |
| `pwsh -c "& gh issue new"` | deny | adjacency regex; R2 |
| `bash -c "gh issue create"` | deny | adjacency regex; R2 |
| `bash -c "gh -R o/r issue create"` | deny | R2 option run (adjacency regex does not match) |
| `bash -c 'x=create; gh issue $x'` | deny | R2 expansion tier |
| `gh api repos/o/r/issues -X POST` | deny | `gh api` lookahead regex |
| `gh --repo o/r issue list` | allow | unchanged |
| `echo "unterminated` | deny (promotion) | R1 Unbalanced, unchanged |
| `pwsh -NoProfile -f ./scripts/legit-push.ps1` | no validate-bash block | R2 no match |
| `pwsh -NoProfile -Command 'git worktree list --porcelain \| Select-String -NotMatch "removed"'` | worktree gates allow | R2 no match |
| `pwsh -NoProfile -Command 'Select-String -Path README.md -Pattern "high priority" \| ForEach-Object { "create" }'` | pr-author allow | R2 no match |
| `bash -c "git worktree remove ../x"` | worktree gates deny | R2 match, null path |

## 10. Required file changes (Option A)

Production, all edits mirrored byte-identically:

1. `.claude/hooks/hook-command-raw-invocation.ps1` (new): `Test-CommandLineRawInvocation`, plus an optional pattern-builder helper. Pure, with no I/O.
2. `.codex/hooks/hook-command-raw-invocation.ps1` (new): identical content.
3. `.claude/hooks/hook-command-invocation.ps1`: dot-source the new module; R2 calls `Test-CommandLineRawInvocation`; contract comments corrected (`:28-30`, `:96-99`, `:172-174`).
4. `.codex/hooks/hook-command-invocation.ps1`: identical edit.
5. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1` (new mirror).
6. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` (mirror).
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1` (new mirror).
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` (mirror).
9. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add `.claude/hooks/hook-command-raw-invocation.ps1`.
10. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: add `.codex/hooks/hook-command-raw-invocation.ps1`.

No hook entry-point file needs a code change. Comment-only updates to `enforce-promotion-mcp-only.ps1:122-125` on either surface are optional. If made, they must also be mirrored.

Test files (no production impact):

- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30`: append the new module name to the inline list, with no new lines.
- New `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1` and `tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1`, mirroring source structure.
- Extend the promotion trigger-scoping suites (Claude 197 lines, Codex 183) and the invocation suites (Claude 330, Codex 267); all have room under 500.
- Add one false-positive regression each to the pr-author, worktree-gate (Claude epic, Claude parallel, Codex epic), and validate-bash (Claude, Codex) trigger-scoping suites.

## 11. File-size check (500-line limit)

| File | Current lines | Effect |
|---|---|---|
| `.claude/hooks/hook-command-invocation.ps1` | 483 | In-place addition would exceed 500. The new module avoids this; net change is about +2 for the dot-source and comments, or about -24 if `Test-CommandLineRawContainment` moves out. |
| `.codex/hooks/hook-command-invocation.ps1` | 483 | Same |
| `.claude/hooks/hook-command-scanner.ps1` / `.codex/...` | 483 | Not touched; do not place the matcher here |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 497 | Inline edit to line 30 only |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 474 | Not touched |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 487 | Not touched |
| New `hook-command-raw-invocation.ps1` | — | Expected under 120 lines |

Line counts come from a Grep `^` count per file and are consistent with the Read tool output (the Read tool shows one additional empty trailing line).

## 12. Testing implications

Test strategy, consistent with the Pester policy (Arrange-Act-Assert, no temporary files, pure seams):

1. **Unit cases for `Test-CommandLineRawInvocation`, on both surfaces.** Positive: adjacent; extra whitespace; mixed case; leading `&`, `;`, `|`, `(`, `"`, `'`, newline; `/usr/bin/gh`; `C:\tools\gh.exe`; quoted `.exe` path; escaped quotes `\"gh\"`; `-R x`, `--repo=x`, `-C "a b"`, an unmodeled dash option; expansion in the command position and in a subcommand position. Negative: `through issue New-Object`; `legit push`; `git worktree list ... removed`; `high priority ... create`; `gh issue newline`; `gh issue list`; all-expansion `$a $b $c`.
2. **Negative control against restoring containment.** Use one fixture that `Test-CommandLineRawContainment` reports as true. In the same `It`, assert that containment is true and that `Test-CommandLineInvocation` returns false for that fixture. If R2 is reverted to containment, the second assertion fails. Repeat it at hook level by asserting `allow` for the reproduction through `Invoke-PromotionMcpOnlyDecision` on both surfaces.
3. **Promotion acceptance matrix, on both surfaces.** One `It` per row of section 9 for the promotion hook. Each deny row also asserts the exact reason via `Get-PromotionMcpOnlyGhIssueBlockedReason`.
4. **Audit regressions.** pr-author Case B fixture, worktree-gate fixtures (Claude epic, Claude parallel, Codex epic), validate-bash `-f` fixture (Claude, Codex), and a preimplementation fixture asserting `Test-ImplementationCommand` is false. Each should be marked expect-fail before the fix.
5. **Preservation.** The existing wrapper deny pins in section 6.1 must stay green without edits. Rename the "any arrangement" test title on both surfaces.
6. **Parity and contract.** Run `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, plus `legacy-codex-hook-contracts.Tests.ps1`.
7. **Toolchain.** `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest` with coverage. Changed lines in the new module and in `hook-command-invocation.ps1` must be covered; the population includes both hooks roots.

## Numeric Derivation Evidence

### Claim N1: 34 resolver-family call expressions in 13 hook files (Claude 22 in 8 files, Codex 12 in 5 files)

- **Complete Family:** production call expressions of `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, and `Test-CommandLineFlag` (every public entry point that reaches `Resolve-CommandLineInvocation`), plus any direct call of `Resolve-CommandLineInvocation` or `Test-CommandLineRawContainment`, in canonical hook files.
- **Exhaustive Search Scope:** `.claude/hooks/*.ps1` and `.codex/hooks/*.ps1`. Bundled mirrors are counted separately as identical copies.
- **Inclusion Rules:** a source line that invokes one of the functions with arguments. Continuation lines that hold a second invocation (promotion `:127` / Codex `:124`) count separately.
- **Exclusion Rules:** function definitions and internal calls inside `hook-command-invocation.ps1`; doc-comment mentions (for example `enforce-epic-merge-gate.ps1:103`, `:105`; `enforce-epic-worktree-removal-gate.ps1:123`); tests; docs.
- **Primary Search Strategy or Query Expression:** Grep `Resolve-CommandLineInvocation|Test-CommandLineInvocation|Test-CommandLineRawContainment|Get-CommandLineOperand|Get-CommandLineFlagValue|Test-CommandLineFlag\b|Test-CommandLineMention` over each hooks root, excluding `hook-command-invocation.ps1`, then manually removing comment lines.
- **Primary Member Set:** Claude: epic-merge `128, 134, 342, 343`; preimplementation `142`; epic-worktree `140, 141, 355`; validate-bash `123, 127`; promotion `126, 127`; epic-base-branch `92, 100, 138`; pr-author-helpers `279, 280, 290, 291`; parallel-worktree `201, 202, 361`. Codex: epic-worktree `58, 59, 126`; epic-merge `63, 69, 141, 142`; preimplementation `161`; promotion `123, 124`; validate-bash `96, 100`.
- **Primary Count:** 34 (Claude 22, Codex 12).
- **Cross-check Search Strategy or Query Expression:** Grep the literal argument form `-CommandWord '` over `{.claude,.codex}/hooks/*.ps1`. This catches every call because each caller passes a quoted literal command word, whereas the shared helper passes `$CommandWord`.
- **Cross-check Member Set:** Codex: epic-worktree `58, 59, 126`; epic-merge `63, 69, 141, 142`; validate-bash `96, 100`; preimplementation `161`; promotion `123, 124`. Claude: validate-bash `123, 127`; promotion `126, 127`; epic-base-branch `92, 100, 138`; pr-author-helpers `279, 280, 290, 291`; parallel-worktree `201, 202, 361`; preimplementation `142`; epic-worktree `140, 141, 355`; epic-merge `128, 134, 342, 343`.
- **Cross-check Count:** 34.
- **Member-set Comparison:** after normalising to `file:line`, the two sets are identical, with no extra or missing member. Neither search found a direct call of `Resolve-CommandLineInvocation` or `Test-CommandLineRawContainment` outside the helper.

### Claim N2: `Test-CommandLineRawContainment` has exactly two call sites per copy (R2 and `Test-CommandLineMention`)

- **Complete Family:** all invocations of `Test-CommandLineRawContainment` in production PowerShell.
- **Exhaustive Search Scope:** `{.claude,.codex,extensions/drm-copilot/resources}/**/*.ps*1`.
- **Inclusion Rules:** invocation lines. **Exclusion Rules:** the `function` definition line.
- **Primary Search Strategy or Query Expression:** the family Grep from N1, repo-wide.
- **Primary Member Set:** `hook-command-invocation.ps1:203` and `:482` in each of four copies (two canonical, two mirrors).
- **Primary Count:** 2 per copy, 8 total.
- **Cross-check Search Strategy or Query Expression:** Grep `RawContainment` (substring, any context) over the same scope.
- **Cross-check Member Set:** `:92` (definition, excluded), `:203`, `:482` in each of the same four copies.
- **Cross-check Count:** 2 invocations per copy, 8 total.
- **Member-set Comparison:** identical after excluding the definition line.

These counts are research context. Any acceptance criterion in `spec.md` that relies on them should cite this section.

## Automation Feasibility

No human interaction is required. Every change is a deterministic text edit to PowerShell modules, JSON manifests, and Pester or pytest suites. Every verification step runs non-interactively: the PoshQC format, analyze, and test commands, the Linux hook-suite Pester run, and pytest for the bundle and manifest contracts. The hook decision seams (`Invoke-PromotionMcpOnlyDecision`, `Get-PrAuthorBypassReason`, `Get-BlockedPatternMatch`, `Test-ImplementationCommand`, the worktree-gate decision functions) are pure and accept literal command strings, so every acceptance case runs in-process without a live `gh`, network, clock, or temporary file. One environmental note, from repository memory and not verified in this session: in an agent worktree, command text containing `bash` or `pwsh` can be refused by the worktree-isolation guard, so local Pester runs may need the PoshQC MCP runner or CI.

## Out-of-scope observations (candidate follow-ups)

- `gh api` write-surface gaps (section 4).
- `sudo gh pr create ...` and `sudo gh issue create ...`: `sudo` is neither a scanner wrapper (`hook-command-scanner.ps1:21-24`) nor a transparent wrapper (`hook-command-invocation.ps1:23`), so R3 does not match. The promotion adjacency regex still catches the issue form; the pr-author hook does not catch the PR form.
- Backslash-newline continuation outside quotes (`gh issue \` then a newline, then `create`): the tokenizer produces a `\` token (`hook-command-scanner.ps1:391-397`, `:83-93`), R3 fails, and the masked text defeats the adjacency regex. This is a pre-existing gap and is not affected by R2.
- `validate-bash` Leg 1 (`.claude/hooks/validate-bash.ps1:197-199`) uses ordinal substring search for multi-word literals in raw-scanned segments. For example, `digit push -fx` contains `git push -f`. This is adjacency-based, not the containment rule, and lower risk.
- `bash -c "git -C x push --force"` is not blocked today: Leg 1 needs contiguity, and the structural leg needs a `--force` token outside the quoted argument (`validate-bash.ps1:123-126`). This is pre-existing and unchanged by Option A.
