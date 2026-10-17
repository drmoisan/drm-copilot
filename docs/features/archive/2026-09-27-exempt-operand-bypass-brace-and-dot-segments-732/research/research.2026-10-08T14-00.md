# Research: C1b preimplementation operand and scope precision (#732, #738, #745, #735)

- Epic: #852 (`enforcement-hook-precision`), child C1b
- Branch: `bug/exempt-operand-bypass-brace-and-dot-segments-732` (based on `origin/epic/enforcement-hook-precision-integration`)
- Date: 2026-10-08T14-00
- Phase: preparation (research only; no source change)

## Research Method and Tool Limits

- Tools available in this session: file read, content search, file glob, and web fetch. No shell tool was available, so `git hash-object`, `git fetch`, `git log`, `gh issue view`, and any read-only `pwsh` evaluation were **not executed**.
- Issue bodies for #732, #738, #745, and #735 were read from the in-repo promoted lifecycle records (`docs/features/potential/promoted/2026-09-27-*.md`) and from the feature folder `issue.md` (`## Bundled Issues`), not from `gh`. Issue comments were not read. The plan must re-read `gh issue view <n> --json body,comments` for all four issues before editing.
- File hashes were not computed. Byte identity of the four helper copies is asserted by an existing SHA256 parity test (see Q2); this session verified structural identity only (identical function line numbers in all four copies).
- Branch state for C1a and C2 was read from the local ref store of the shared git directory (no fetch). It may be stale relative to `origin`.
- All reproductions below are static traces of the code. None was executed.

## Summary of Findings

1. **#735 (Codex shell on Windows).** On current `openai/codex` `main`, a native Windows Codex session runs model-issued commands through PowerShell by default (`pwsh`, else Windows PowerShell 5.1, else `cmd.exe`). The model can override the shell per call through the `exec_command` `shell` parameter (`bash`, `sh`, `zsh`, `cmd`, `pwsh`, `powershell`), and the PreToolUse payload carries only `tool_input.command` (the raw string), with neither the chosen shell nor `workdir`. **The shell that will execute a given command therefore cannot be determined from the hook payload.** The fail-closed option is required on the Codex surface.
2. **#732.** Both reported operand shapes pass `Test-ExemptOrchestrationOperand` because the function prefix-matches after a PowerShell-style `\` to `/` rewrite and only rejects a segment equal to `..`. Under a POSIX shell, `{..,..}` expands to `..` and `\.` unescapes to `.`, so both operands resolve to `src/...`. The same POSIX-versus-PowerShell divergence also affects command-level shapes that the helpers currently admit (for example `git commit -m fix\;done -- <exempt path>` is a pathless commit under PowerShell).
3. **Recommended #732 design.** Keep the change in place in the helpers file (net line reduction): deny a backslash anywhere in the command text, add `{ } , ( ) @` to the outside-quote deny set, and replace the operand prefix logic with an ASCII allowlist (`^[A-Za-z0-9._/-]+$`), a leading-slash deny, a `..`-segment deny, and the exact five-tree prefix test. Three existing allow rows reverse to deny (D4 row 18, LACS allow 3, and one ChainEscape row).
4. **#738.** Both surfaces read only the first segment's `git -C` value at index 2 (`Get-OrchestrationEpicScopeSelector`). An unresolvable selector silently yields "not epic scope" and falls to the single-feature path. On Claude, a Write/Edit `file_path` into another worktree is not used for epic-scope resolution at all. Codex `workdir` is not present in the hook payload on current Codex, so it cannot be resolved; the AC needs an explicit amendment.
5. **C1a and C2 status.** Local refs show the epic C1a branch (`bug/promotion-hook-raw-containment-false-positive-deny-824-r2`) and C2 branch (`bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565`) both at the integration tip `173bae48`, with no commits of their own. A separate, earlier `bug/promotion-hook-raw-containment-false-positive-deny-824` branch (`dc0d8d4c`) carries commits titled "replace R2 raw containment with a token-aware sequence matcher" and ends in a WIP commit. Its content was not read. The C1a API names are therefore **not fixed**.
6. **#745.** `.agents/skills/epic-plan/SKILL.md` (231 lines) and its Codex bundle mirror lack the Integration Commit Form and trailer forms. Tests cover U+2018, U+2019, U+201C, and U+201D only; U+201A, U+201B, and U+201E have no deny row. No test pins `--trailer --`. The repository configures **no PowerShell line-length limit** (`PSAvoidLongLines` is not enabled). Helpers line 131 is 140 characters and line 78 is 144 characters. D5 (heredoc messages): recommend defer.

---

## Q1. #735: Which shell OpenAI Codex uses to execute commands on Windows

### Evidence (external, `openai/codex` `main`, fetched 2026-10-08; commit SHA not exposed by the fetch tool)

| # | Source | Finding |
|---|---|---|
| E1 | `codex-rs/shell-command/src/shell_detect.rs`, `default_user_shell_from_path` (approx. line 265-268) | `if cfg!(windows) { get_shell(ShellType::PowerShell).unwrap_or_else(ultimate_fallback_shell) }`. On Windows the passwd/user shell path is not consulted (`get_user_shell_path` is `#[cfg(unix)]`). |
| E2 | same file, `get_powershell_shell` (approx. lines 228-237) and constants (approx. lines 211-218) | Searches `pwsh` (fallback `C:\Program Files\PowerShell\7\pwsh.exe`), then `powershell` (fallback `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`). |
| E3 | same file, `ultimate_fallback_shell` | On Windows: `ShellType::Cmd`, `cmd.exe`. |
| E4 | same file, `detect_shell_type` and `get_shell_by_model_provided_path` | A model-provided shell path is classified by name or file stem: `zsh`, `sh`, `cmd`, `bash` (including `bash.exe` and a Git Bash path), `pwsh`, `powershell`. Unknown names (for example `wsl.exe`) fall back to `ultimate_fallback_shell` (cmd on Windows). |
| E5 | `codex-rs/core/src/shell.rs`, `derive_exec_args` (approx. lines 28-56) | Bash/Zsh/Sh: `[shell, "-lc" or "-c", command]`; PowerShell: `[shell, "-NoProfile" (when not login), "-Command", command]`; Cmd: `[shell, "/c", command]`. |
| E6 | `codex-rs/core/src/tools/handlers/shell_spec.rs` | The shell tool is `exec_command` with `cmd` (string), `workdir` (string, "Defaults to the turn cwd"), `shell` ("Shell binary to launch. Defaults to the user's default shell."), `login`, `tty`. On Windows (`cfg!(windows)`) the description appends `windows_shell_guidance()`, which tells the model to prefer native PowerShell cmdlets. |
| E7 | `codex-rs/core/src/tools/spec_plan.rs`, `add_shell_tools` | `include_shell_parameter: true` with no feature-flag condition, so the model may always supply `shell`. |
| E8 | `codex-rs/core/src/tools/handlers/unified_exec.rs`, `get_command` | Uses `args.shell` via `get_shell_by_model_provided_path` when supplied, else the session shell; then `derive_exec_args(&args.cmd, use_login_shell)`. |
| E9 | `codex-rs/core/src/tools/handlers/unified_exec/exec_command.rs`, `pre_tool_use_payload` | `tool_name: HookToolName::bash()`, `tool_input: json!({ "command": args.cmd })`. Neither `shell` nor `workdir` is in the payload. |
| E10 | `codex-rs/core/src/tools/hook_names.rs` | Canonical hook names: `Bash` (no matcher aliases), `apply_patch` (aliases `Write`, `Edit`), `spawn_agent` (alias `Agent`). Aliases are internal and stdin keeps the canonical name. |
| E11 | `codex-rs/core/src/hook_runtime.rs`, `run_pre_tool_use_hooks` / `tool_hook_cwd` | The payload `cwd` is `environments.local_environment_cwd()` or `turn.cwd`, never the per-call `workdir`. |
| E12 | Codex hooks documentation (`https://learn.chatgpt.com/docs/hooks`, redirected from `https://developers.openai.com/codex/hooks`) | `Bash` and `apply_patch` use `tool_input.command` (string). `command_windows` overrides the hook command on Windows. Hook commands run with the session `cwd`. No statement names the shell that executes the hooked command. |

### Evidence (in repository)

- `.codex/config.toml:119-150` registers `enforce-orchestration-preimplementation-gate.ps1` under matcher `^Bash$`, and `:185-222` under `^(apply_patch|Edit|Write)$`. Matcher `:152-153` includes `shell_command`, a tool name that current Codex no longer emits (E10).
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:464` dispatches `Bash` and `apply_patch` to the command leg; any other tool name goes through the Edit/Write mapping. It reads `tool_input.command` through `Get-StringProperty` (`:383`) and never reads `workdir`.
- `docs/features/completed/2026-07-25-codex-pretooluse-hook-transport-415/research/2026-07-25T18-30-codex-pretooluse-hook-transport-research.md:96-109`: repository fixtures model `Bash` and `shell_command` as `{ command: string }`; no live Codex payload capture exists in the repository.
- `docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/code-review.2026-09-27T04-30.md:134`: "Checked repository docs for the interpreter behind Codex `Bash` commands on Windows and found no record." The same review (`:46`) states the Claude surface executes `Bash` through Git Bash (not independently re-verified here).
- No `workdir` reference exists in any `.codex/` file (search result: only feature-document mentions).

### Finding

- **Default (native Windows, current `main`):** PowerShell (`pwsh` preferred, then Windows PowerShell 5.1), with `cmd.exe` as the last fallback (E1-E3).
- **Per call:** the model may select `bash`, `sh`, `zsh`, `cmd`, `pwsh`, or `powershell` (E4, E6-E8). On a Windows host with Git for Windows, `bash` resolves to a POSIX shell.
- **Configuration dependence:** a Codex session run inside WSL (or on Linux/macOS) uses the Unix branch (passwd login shell, then bash/zsh, then `/bin/sh`). The answer therefore differs by host and by per-call model choice.
- **Hook visibility:** the PreToolUse payload contains the raw `cmd` string only (E9, E12). The hook cannot observe the selected shell or the `workdir` (E9, E11).
- **Version range:** applies to `openai/codex` `main` as fetched on 2026-10-08 (the `exec_command` unified-exec tool with hook support). The Codex version installed for this repository was not determined. Older Codex versions exposed `shell` (argv array) and `shell_command` tools; their hook payload shapes were not verified in this session.
- **Confidence:** high for the Windows default (direct source code). High that the payload omits `shell` and `workdir` (direct source code). Overall determination for the gate: **the executing shell is undetermined per command**, so the fail-closed option governs every Codex-surface parsing change.

### Implications for parsing

- The shared helpers must deny any shape whose meaning differs between a POSIX shell and PowerShell. Divergence classes found:
  - Backslash: an escape in POSIX outside single quotes; a literal path separator in PowerShell (`\;`, `\&`, `\|`, `\.`, `docs\features\...`).
  - Brace expansion `{a,b}` and `{a..b}` (POSIX); script block or literal (PowerShell).
  - Unquoted comma: literal in POSIX; array separator in PowerShell argument mode, which passes `a,b` to a native command as two arguments (likely; not executed here because no shell tool was available).
  - Unquoted `@name`: literal in POSIX; splatting in PowerShell.
  - Unquoted `(` `)`: subshell or syntax error in POSIX; subexpression in PowerShell argument mode.
  - Typographic quotes U+2018 to U+201E: literal in POSIX; quote characters in PowerShell (already denied).
  - `$` and backtick: already denied outside single quotes; literal inside single quotes in both shells.
- `cmd.exe` is reachable (fallback, or model-chosen `shell: cmd`) and adds further divergences that the POSIX-versus-PowerShell rule does not cover: `'` is not a quote character in cmd, and `%VAR%` and `^` are interpreted. Example: `git commit -m 'x src/prod.ts y' -- docs/features/active/x/a.md` is admitted today; under cmd, `src/prod.ts` becomes a commit pathspec. This is recorded as a residual risk and an open question.

---

## Q2. #732: `Test-ExemptOrchestrationOperand`

### Copies and identity

| Copy | Lines | Structural check |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | functions at 58, 110, 163, 220, 278, 339, 438 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | same line numbers |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | same line numbers |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | same line numbers |

- SHA256 identity of all four is asserted by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:31-42`, and the 500-line cap by `:44-53`. The Codex pair is also checked by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30,96-110` (`SharedModuleNames`). Hashes were not computed in this session.

### Callers and exempt-tree set

- Exempt trees (`helpers:22-28`): `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, `artifacts/orchestration/`. The defect applies to all five, not only `active`.
- Call chain: `Test-ExemptOrchestrationStagingCommand` (`helpers:438`) -> `Test-ExemptOrchestrationSegmentToken` (`:489`) -> `Test-ExemptOrchestrationOperand` (`:431`). The predicate is called only from `Test-ImplementationCommand` index 0 (git staging trigger): `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:153` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:173` (plus the two bundled gate copies at the same lines). It is allow-side only: a false result restores the deny path.
- `Split-OrchestrationCommandLine` and `ConvertTo-OrchestrationCommandToken` are also called by `Get-OrchestrationEpicScopeSelector` in both epic-scope files (see Q3).

### Why the two shapes are exempt (static trace)

`docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts`:
1. `Test-OrchestrationCommandTextUnresolvable` (`:110-161`): no `$`, backtick, `<`, `>`, `#`, typographic quote, or backslash, so false.
2. Splitter and tokenizer: one segment, one operand token.
3. Operand (`:220-276`): no leading `:`; `\`->`/` rewrite changes nothing; not rooted; segments are `{..,..}`, none equal to `..` (`:258`); no `*?[` (`:265`); prefix `docs/features/active/` matches (`:270-273`), so true.
4. Bash expands the word to eight copies of `docs/features/active/../../../src/prod.ts` (the #713 reviewer confirmed the expansion with `echo`; `code-review.2026-09-27T04-30.md:47`), which git normalizes to `src/prod.ts`. Under PowerShell the literal string reaches git and names no file.

`docs/features/active/.\./.\./.\./src/x.ps1`:
1. Command text: the backslashes are not before a quote and not inside double quotes, so `Test-OrchestrationCommandTextUnresolvable` returns false (`:131`, `:148`).
2. Operand: the rewrite at `:246` produces `docs/features/active/././././././src/x.ps1`; no `..` segment; prefix matches, so true.
3. Bash removes the escapes, producing `docs/features/active/../../../src/x.ps1` = `src/x.ps1`. PowerShell treats `\` as a separator, producing a path inside the tree. Recorded by #710 in `docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/evidence/other/follow-up-d7-operand-gap.md:9`.

Root cause: the `\`->`/` rewrite (D4 row 18) adopts the PowerShell reading of a backslash, while the splitter (`:78`) adopts the POSIX reading, and the operand check has no model of brace expansion.

### Related command-level divergence currently admitted

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1:177-186` asserts `git commit -m fix\;done -- docs/features/active/x/spec.md` is exempt on both surfaces. Under PowerShell this runs `git commit -m fix\` (a pathless commit of the index) followed by a failing `done` command. Under the #735 finding this row must reverse.

### Recommended normalization design (allow-side only; every ambiguity denies)

Command-text level (`Test-OrchestrationCommandTextUnresolvable`):
1. Deny a backslash anywhere: replace the two `Contains` tests on line 131 with `$CommandText.Contains('\')`. This subsumes the escaped-quote checks and the double-quote backslash branch (`:147-150`, removable), and it brings line 131 to about 107 characters (#745 item 4).
2. Extend `$script:OutsideQuoteCommandCharacters` (`:35`) from `> < #` to `> < # { } , ( ) @`. These cover brace expansion and PowerShell array, splat, and subexpression syntax in message tokens as well as operands. The change is one constant line.

Operand level (`Test-ExemptOrchestrationOperand`):
3. Deny unless the operand matches `^[A-Za-z0-9._/-]+$` (ASCII allowlist, `-cmatch`). This subsumes the leading-colon check (`:241`), the drive-letter check (`:253`), UNC, `~`, `%`, `^`, `!`, `=`, `+`, quotes-inside-tokens, whitespace, non-ASCII look-alikes, brace, comma, and the glob/bracket characters `* ? [ ]`.
4. Deny a leading `/` (rooted, including `//`).
5. Deny any segment equal to `..` (kept).
6. Exact prefix test against the five trees (kept).
7. Remove the `\`->`/` rewrite (`:246`) and the wildcard literal-prefix logic (`:262-268`). `$script:PathspecWildcardCharacters` stays because `Test-ExemptOrchestrationSelector` uses it (`:332`).

Rationale for dropping dot-segment collapse: with backslash and `..` both denied, a path that starts with an exempt prefix cannot leave it lexically, so a collapse step adds code without changing any decision. `.` segments are harmless. Leading `./` stays denied by the prefix test (current behaviour).

Glob note: no existing allow test and no skill document uses a glob operand under an exempt tree (searched `tests/**` and `.claude/.agents/.github/.codex` Markdown for `git add <tree>/...[*?{]`; zero matches). Denying `* ? [` therefore reverses no tested allow row; D4 rows 15a-15c remain denies.

Character-set check: no tracked file under `docs/features/` contains a space, `,`, `+`, `@`, `#`, `~`, `=`, `(`, `)`, `{`, `}`, `!`, `$`, `%`, `'`, `[`, or `]` (glob `docs/features/**/*[ ,+@#()~{}=&!$%'\[\]]*`, zero matches; the glob character-class form was validated against a positive control).

Intentional reversals the spec must record:

| Row | File and line | Today | After |
|---|---|---|---|
| D4 row 18 backslash operand allow | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:106-116`; Codex suite `:106-116` | allow | deny |
| LACS allow 3 backslash selector | Claude suite `:310`; Codex suite `:313` | allow | deny |
| ChainEscape escaped-semicolon exempt | `...helpers.ChainEscape.Tests.ps1:177-186` | exempt | not exempt |

### Line budgets and placement

| File | Lines now | Expected change |
|---|---|---|
| helpers (four copies) | 497 | about -8 net for the design above; +3 if line 78 is also wrapped; +2 for a header note on shell-agnostic parsing. Fits under 500. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 466 | none for #732 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 487 | none for #732 |
| Claude CommandExemption suite | 493 | in-place row moves only (line-neutral) |
| Codex command-exemption suite | 496 | in-place row moves only (line-neutral) |

Recommendation: edit in place in the helpers file (the #713 D7 precedent, `docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/spec.md:266`). A new sibling would need four copies, entries in both `pack-manifests/core.json` files (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:41`, `.../codex-and-agents-customizations/pack-manifests/core.json:43`), a `SharedModuleNames` entry (`legacy-codex-hook-contracts.Tests.ps1:30`), and parity coverage. Coverage configuration is directory-based (`config/poshqc-coverage.json` roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`), so no coverage entry is needed in either case. New tests go in a new file (both existing CommandExemption suites are at 493 and 496 lines).

### Same prefix-match idiom elsewhere (scope note only)

| Location | Idiom | Note |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:86` and `.codex/hooks/...:88` (`Test-FeatureDocumentationOrEvidencePath`) | `-cmatch '(^|/)docs/features/active/'` | Path leg (Write/Edit, and Codex `apply_patch` file markers at `.codex/...:140-151`). A `file_path` of `docs/features/active/../../src/x.ps1` classifies as non-implementation. The comment at `.claude/...:113-115` assumes the Write tool emits no `..`; not verified. Candidate follow-up of the same severity class. |
| `.claude/...:249`, `.codex/...:275` (`Test-OrchestrationReady`) | `StartsWith('docs/features/active/')` | Reads checkpoint content, not command text. Low exposure. |
| `.codex/hooks/enforce-epic-planning-only.ps1:129` | `-match '(^|/)docs/features/(?:active|potential)/'` | Same unanchored-`..` pattern. |
| `.claude/hooks/enforce-completion-helpers.ps1:92`, `.codex/hooks/enforce-completion-helpers.ps1:92` | `StartsWith($prefix)` | Not reviewed in depth. |
| `.claude/hooks/validate-task-researcher-output.ps1:77` | `StartsWith('docs/features/', ...)` | Output validator. |
| `.claude/hooks/enforce-feature-folder-order.ps1:87` | anchored regex `docs/features/(active|archive)/[^/]+/plan\.md$` | `[^/]+` admits `..` as a folder name. |
| `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1:38`, `.codex/hooks/...-epic-scope.ps1:38`, both `-modes.ps1` (`:395`, `:392`) | `(^|/)docs/features/epics/` | Checkpoint field validation. |

---

## Q3. #738: Epic-scope target resolution

### Current behaviour

Claude (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, 279 lines):
- `Get-OrchestrationEpicScopeSelector` (`:212-238`) splits with the helpers splitter, tokenizes **only `Segments[0]`**, and returns `token[2]` only when `token[0] -ceq 'git'` and `token[1] -ceq '-C'`. A second `-C`, a selector in any later segment, a `cd` segment, a wrapper-led segment, and `--git-dir`/`--work-tree` are not read.
- `Get-OrchestrationEpicScopeDecision` (`:240-279`) passes that one selector to `Resolve-EpicScopeCheckpoint -MatchWorktreeHead`. For the path leg the selector is `$null`, so a Write/Edit `file_path` in another worktree is evaluated against the session root's HEAD.
- `Resolve-EpicScopeCheckpoint` (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1:278-381`): `Find-WorktreeResolutionRoot` returns `$null` for a relative path (`WorktreeResolution.psm1:282-285`), so a relative `-C` yields `selector-unresolved` and `IsEpicScope = $false`. `target-worktree-ambiguous` is also returned as not epic scope. In both cases the gate falls through to the single-feature path; neither is an explicit deny.
- The single-feature path (`Resolve-OrchestrationGateTarget`, epic-scope file `:159-160`) reuses the same first selector through `Resolve-WorktreeOperandTarget` (`WorktreeRunResolution.psm1:450-488`), which joins a relative selector to the session root and falls back to the session worktree when the operand lies in no worktree.

Codex (`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, 189 lines; `...-epic-resolution.ps1`, 493 lines):
- `Get-OrchestrationEpicScopeSelector` (`:67-93`) is the same first-segment, index-2 logic.
- `Resolve-EpicScopeCheckpoint` (`epic-resolution.ps1:432-493`) reads only the **session-root** epic checkpoint, then compares the selector worktree's HEAD with its `integration_branch`. `selector-unresolved` and `branch-mismatch` return not epic scope.
- `workdir`: absent from the payload (Q1 E9, E11). The gate's session root is `(Get-Location).Path` (`epic-scope.ps1:179`), which equals the hook process cwd (the session cwd, E12). A model-chosen `workdir` is invisible to the hook.
- `apply_patch` leg: `Get-OrchestrationEpicScopeDecision` receives the patch text as `-Command`; it has no `-C`, so file-marker paths (`*** Update File: <path>`) are never used for target resolution, including absolute paths into another worktree.

### `hook-command-invocation.ps1` API on this branch (483 lines; `.codex/hooks/hook-command-invocation.ps1` is the Codex copy)

| Function | Signature | Returns |
|---|---|---|
| `Get-CommandLineTransparentWrapperName` | `()` | `string[]` (`command env nohup time timeout`) |
| `Get-CommandLineGlobalOption` | `-CommandWord <string>` | `pscustomobject { WithArgument: string[]; Standalone: string[] }`; git `WithArgument` = `-C -c --git-dir --work-tree --namespace --exec-path` |
| `Test-CommandLineRawContainment` | `-RawText -CommandWord -SubcommandPath` | `bool` (case-insensitive substring containment; the R2 rule C1a replaces) |
| `Skip-CommandLineOption` | `-Token -StartIndex -Option` | `pscustomobject { Index: int; Unmodeled: bool }` (values are skipped, not returned) |
| `Resolve-CommandLineInvocation` | `-CommandText -CommandWord -SubcommandPath` | `$null` or `{ Segment; OperandIndex }` for the **first** matching segment only; `OperandIndex = -1` for non-structural matches |
| `Test-CommandLineInvocation` | same | `bool` |
| `Get-CommandLineOperand` | same | `string[]` (first matched segment) |
| `Get-CommandLineFlagValue` | `+ -FlagName` | `string` or `$null` |
| `Test-CommandLineFlag` | `+ -FlagName` | `bool` |
| `Test-CommandLineMention` | same as `Test-CommandLineInvocation` | `bool` |

Segment source: `Read-CommandLineSegment -CommandText` in `hook-command-scanner.ps1` (483 lines; `:303-483`) returns records `{ RawText, MaskedText, Tokens, CommandWord, IsWrapperLed, HasLiveSubstitution, Unbalanced, ScanText }` (`:153-162`, documented `:319-335`). It splits on `; & | newline ( ) { } $(` and backtick, which differs from the helpers splitter (`; & | newline` only).

No existing function enumerates **every** matching segment or returns the `-C` values of a segment.

### C1a and C2 branch status (local refs, not fetched)

- `bug/promotion-hook-raw-containment-false-positive-deny-824-r2` = `173bae48` = `origin/epic/enforcement-hook-precision-integration`; no commits of its own; no `docs/features/active/*-824` folder on this branch.
- `bug/promotion-hook-raw-containment-false-positive-deny-824` = `dc0d8d4c`. Its reflog records "fix(824): replace R2 raw containment with a token-aware sequence matcher", "restore wrapped-bypass detection and extend to removal gates", "harden hook raw-invocation gates and add kcov coverage gate", ending in "wip(824): record remediation cycle 3 baseline and partial test changes". This appears to be an earlier, separate run. Its files were not read.
- `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565` = `173bae48`; no commits of its own.

### Recommended design for per-segment resolution

Placement: one new pure, byte-identical shared file, for example `enforce-orchestration-preimplementation-gate-targets.ps1`, in the four hook roots. It is dot-sourced by each surface's epic-scope file and consumes `Read-CommandLineSegment` and `Get-CommandLineGlobalOption` (plus C1a's wrapper and substitution matcher once named). Neither `hook-command-invocation.ps1` (483 lines, owned by C1a) nor the helpers file (497) nor the Codex resolution file (493) has room. The Claude (279) and Codex (189) epic-scope files have room for the decision changes.

Proposed contract (names are proposals):

```
Get-OrchestrationCommandTarget -Command <string> -FilePath <string> -SessionRoot <absolute>
  -> [pscustomobject] @{ Resolved = [bool]; Targets = [string[]]; ReasonCode = [string]; Detail = [string] }
```

Rules (fail closed; `Resolved = $false` with a reason code):
1. Path leg: an absolute `file_path` contributes its own path; a relative one contributes the session root. On Codex, also apply this to each `apply_patch` file-marker path.
2. Command leg: any `Unbalanced` segment is unresolved.
3. A segment whose command word changes the working directory (`cd`, `pushd`, `popd`, `chdir`, `Set-Location`, `sl`, `Push-Location`, `Pop-Location`) is unresolved.
4. A wrapper-led or live-substitution segment that C1a's matcher reports as invoking `git` is unresolved (its inner `-C` is not visible).
5. A `GIT_DIR=`, `GIT_WORK_TREE=`, `GIT_COMMON_DIR=`, or `GIT_INDEX_FILE=` prefix, or a `--git-dir`/`--work-tree` option, is unresolved.
6. For each `git` segment, walk the global options with the `git` option table and collect every `-C` value. A relative value, or one carrying a `.` or `..` segment, is unresolved (the #738 record asks to "fail closed on unresolvable or relative paths"; this matches LACS L4/L5). A segment with no `-C` contributes the session root.
7. `Targets` is the distinct set of normalized absolute targets.

Decision (`Get-OrchestrationEpicScopeDecision`, both surfaces):
- Evaluate epic scope for the session root and for every resolved target.
- No candidate is epic scope: return `$null` (single-feature path unchanged).
- Any candidate is epic scope, and the set is unresolved, mixed (some targets not epic scope), ambiguous, or any target fails `Get-EpicCommandLegReadinessFailure`: deny. Keep the `PREIMPLEMENTATION_GATE_BLOCKED:` leading token (epic Shared Design).
- All targets are epic scope and pass readiness (merge in progress per target): allow.
- On Claude, `target-worktree-ambiguous` changes from "not epic scope" to a deny when it arises for a target.

Codex `workdir`: not observable on current Codex. The AC item "on Codex the `workdir`" cannot be implemented from the payload. Options for the spec: (a) amend the AC to record that `workdir` is unobservable and the session root is the default target, with a follow-up asking for upstream payload support; (b) Codex-only strict mode in epic scope: deny an implementation-classified segment unless it pins its target with an absolute `git -C` (an absolute `-C` makes git independent of cwd and `workdir`). Option (b) changes Codex epic-orchestrator command forms and its skill documentation. See Open Questions.

API names not yet fixed (verify after C1a merges into the integration branch, before editing): the name, signature, and return shape of C1a's token-aware wrapper and substitution matcher; whether `Test-CommandLineRawContainment` survives; whether `Resolve-CommandLineInvocation` keeps `{ Segment; OperandIndex }`; whether the scanner record fields (`Tokens`, `CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`, `Unbalanced`) are unchanged; and whether C1a adds a helper that returns global-option values. Verification command for the plan: `git show origin/epic/enforcement-hook-precision-integration:.claude/hooks/hook-command-invocation.ps1` (and `hook-command-scanner.ps1`).

---

## Q4. Upstream C2 (#565) conflict region

- `Find-OrchestrationDelegationTargetFolder` occupies `enforce-orchestration-preimplementation-gate-modes.ps1:215-251` on all four copies; the longest-match sort is at `:236` in each (`.claude/hooks`, `.codex/hooks`, and both bundles; confirmed by search). Claude modes is 480 lines, Codex modes 477 (the pair is not byte-identical).
- C2 has no commits yet (Q3). C1b should **not edit any `-modes.ps1` copy**. None of the recommended C1b changes requires it.
- Indirect overlap: both children edit the preimplementation gate test area. C1b should add new test files rather than edit `*mode-resolution*` suites (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, 492 lines; Codex `...-mode-resolution.Tests.ps1`, 332 lines).

---

## Q5. #745: Trailer documentation and tests

### Documentation

- `.claude/skills/epic-plan/SKILL.md:180-216` and `.claude/skills/parallel-plan/SKILL.md:604-641` (and their bundles under `extensions/drm-copilot/resources/claude-customizations/`) carry the Integration Commit Form and "Attribution trailers (issue #713)" sections.
- `.agents/skills/epic-plan/SKILL.md` (231 lines) has neither section; sections are `Integration Branch` (`:61`), `Concurrent Preparation` (`:66`), `Fan-In` (`:154`). The Codex bundle mirror is `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`. Recommended insertion: after `## Integration Branch` (`:61-64`), adapted to Codex wording.
- If the #732 design is adopted, the "Quoting rules" paragraph in all six skill documents (`.claude` epic-plan and parallel-plan, their two bundles, and the two `.agents` epic-plan copies) must also state: backslash anywhere is denied; `{ } , ( ) @` are denied outside quotes; operands must be plain forward-slash repo-relative paths using `A-Z a-z 0-9 . _ / -`.

### Line 131 and the line-length limit

- Helpers line 131 is 140 characters (manual count; the same text in all four copies). Line 78 is 144 characters (manual count).
- No PowerShell line-length limit is configured: `scripts/powershell/PoshQC/settings/pssa.settings.psd1` does not enable `PSAvoidLongLines` (an opt-in rule), `.claude/rules/powershell.md` states none, and `.github/instructions/*` contain no line-length rule. The only configured limits are Python (`pyproject.toml:85,89`, 88).
- Recommendation: the spec states the target explicitly as 120 characters (the `PSAvoidLongLines` default `MaximumLineLength`, quoted from general knowledge of the rule; not verified in this session). The #732 design shortens line 131 to about 107 characters. Wrapping line 78 is optional and outside the AC.

### Trailer test coverage (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`, 103 lines, runs on both runtimes)

Covered admit rows (`:44-55`): separate-value `--trailer`; `--trailer=`; two trailers; multi-message single-quoted paragraph; single-quoted backtick; single-quoted `$` and `$(x)`; chained add plus trailer commit; rooted selector with trailer; `#` inside single and double quotes; inline angle brackets in double quotes; empty single-quoted trailer value.

Covered deny rows (`:69-93`): unquoted redirection; `$(...)` and `$VAR` in operands; `$`, `$(...)`, and backtick in double quotes; heredoc recipe; `$'...'`; `&&` and `;` chains; non-exempt pathspec with trailer; pathless commit with trailer; `git add --trailer`; dangling `--trailer`; `-F`; `--file=`; `-F -` heredoc; `#'` desynchronization; trailing comment; mid-word `#`; unbalanced single quote; escaped single quote; three typographic rows using U+2018, U+2019, U+201C, U+201D.

Missing:
- `--trailer` taking `--` as its value (CR-4, `code-review.2026-09-27T04-30.md:49`): add the admit row `git commit -m x --trailer -- docs/features/active/x/a.md` and the deny row `git commit -m x --trailer -- src/x.ts`. The helper consumes `--` as the value at `helpers:402-408`, which matches git parse-options per the review.
- Typographic deny rows for U+201A, U+201B, U+201E.

### D5 (heredoc-fed commit messages): defer

- The #713 decision was "document as not admitted" (`.../713/spec.md:264`).
- Under the #735 finding, heredoc syntax is shell-specific: POSIX `<<'EOF'` has no PowerShell equivalent (PowerShell uses `@' '@` here-strings, and `<` is reserved), and cmd has neither. Modeling heredocs in a byte-identical shared helper would require shell-specific parsing that the hook cannot select, because the executing shell is unknown.
- `<` is already in the outside-quote deny set, and the helpers file has little headroom.
- The two admitted forms (`--trailer` and the one-paragraph multi-`-m` form) already carry both attribution trailers.
- Recommendation: **defer**. Keep the documented non-admission and record the rationale in the spec.

---

## Q6. Test infrastructure

### Pester suites for these hooks

Claude surface (`tests/scripts/claude-hooks/`): `enforce-orchestration-preimplementation-gate.Tests.ps1` (467), `.CommandExemption.Tests.ps1` (493), `.AttributionTrailer.Tests.ps1` (103, both runtimes), `-helpers.ChainEscape.Tests.ps1` (198, both surfaces), `-helpers.Parity.Tests.ps1` (54), `.EpicScope.Tests.ps1` (362), `.OperandResolution.Tests.ps1` (249), `.WorktreeResolution.Tests.ps1` (279), `.TriggerScoping.Tests.ps1` (338), `-classifier.Tests.ps1` (160), `-mode-resolution.Tests.ps1` (492), `-absolute-paths.Tests.ps1` (229), `hook-command-invocation.Tests.ps1` (330), `hook-command-scanner.Tests.ps1` (387), `hook-command-parser.AcceptanceCases.Tests.ps1` (230).

Claude library: `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, `EpicScopeResolution.RunTarget.Tests.ps1`, `EpicScopeReadiness.Tests.ps1`, `WorktreeResolution.Manifest.Tests.ps1`.

Codex surface (`tests/scripts/codex-hooks/`): `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (496), `-epic-scope.Tests.ps1` (480), `-epic-resolution.Tests.ps1` (445), `-mode-resolution.Tests.ps1` (332), `-mode-routing.Tests.ps1` (205), `-trigger-scoping.Tests.ps1` (352), `codex-preimplementation-gate-absolute-paths.Tests.ps1` (244), `legacy-codex-hook-contracts.Tests.ps1`.

### How they run

- `.claude/rules/powershell.md:15-20`: format (`run_poshqc_format`), analyze (`run_poshqc_analyze`), test (`run_poshqc_test`) through the drm-copilot MCP, with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Runsettings: `Run.Path = scripts, tests/powershell, tests/scripts`; JUnit to `artifacts/pester/pester-junit.xml`; coverage `CoverageGutters` to `artifacts/pester/powershell-coverage.xml`; `CoveragePercentTarget = 0`; no path list (coverage population from `config/poshqc-coverage.json`, per issue #527).
- Coverage roots: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. Bundle copies under `extensions/` are not measured.
- Known tooling constraint: the MCP `run_poshqc_test` tool rewrites the coverage artifact using installed-extension settings (`docs/features/completed/codex-gates-4-5-lack-epic-scope-707/evidence/other/follow-ups.md:12`). The plan should obtain coverage evidence by invoking the in-repo PoshQC module directly.
- CI: the `poshqc` job runs on `windows-latest` (`.../707/evidence/other/follow-ups.md:9`).

### Bundle-parity and manifest tests

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` (four-copy SHA256 identity and 500-line cap).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30,96-110` (Codex root/bundle parse, 500-line cap, byte identity for `SharedModuleNames`).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (every distributable `.claude/**` file equals its bundle copy).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215` (repo `.codex`/`.agents` contracts present in the bundle).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_codex_core_manifest_closure.py` (needed if a new hook file is added).

---

## Numeric Derivation Evidence

No numeric count is proposed as a new acceptance criterion. Two counts already appear in the bundled AC text; their derivations are recorded here so the spec can restate them.

### Claim N1: the helpers module has four copies that must stay byte-identical

- Complete Family: every file named `enforce-orchestration-preimplementation-gate-helpers.ps1` in the repository, plus every file defining `Test-ExemptOrchestrationOperand`.
- Exhaustive Search Scope: the whole worktree (all directories, including `extensions/`).
- Inclusion Rules: a tracked file with that exact name, or a file containing `function Test-ExemptOrchestrationOperand`.
- Exclusion Rules: documentation and fixture files that merely mention the name (`docs/**`, `tests/fixtures/**` JSON).
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate*.ps1`, filtered to the `-helpers.ps1` name.
- Primary Member Set: `.claude/hooks/...-helpers.ps1`; `.codex/hooks/...-helpers.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...-helpers.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...-helpers.ps1`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: content search `^function |IndexOfAny\(\$script:TypographicQuoteCharacters\)|^    return \$true$` with glob `**/enforce-orchestration-preimplementation-gate-helpers.ps1`, listing files that define `Test-ExemptOrchestrationOperand`; plus the hard-coded root list in `Parity.Tests.ps1:18-23`.
- Cross-check Member Set: the same four paths (each reports `function Test-ExemptOrchestrationOperand` at line 220).
- Cross-check Count: 4.
- Member-set Comparison: identical normalized sets; no duplicates.

### Claim N2: three typographic quote code points lack a denied-test row

- Complete Family: the code points in `$script:TypographicQuoteCharacters` (`helpers:36`).
- Exhaustive Search Scope: the constant at `helpers:36` and its docstring (`:118`); for coverage, every `*.ps1` test file under `tests/`.
- Inclusion Rules: a code point is covered when a test command string contains it.
- Exclusion Rules: Python tests unrelated to the gate (`tests/scripts/dev_tools/test_potential_to_issue_*.py`, `test_pr_context_integration.py`).
- Primary Search Strategy or Query Expression: read `helpers:36` (family); content search `\[char\]0x[0-9A-Fa-f]+` (only-matching) over `tests/**/*preimplementation*.ps1` (coverage).
- Primary Member Set: family {U+2018, U+2019, U+201A, U+201B, U+201C, U+201D, U+201E}; covered {U+2018, U+2019, U+201C, U+201D} (`AttributionTrailer.Tests.ps1:91-93`); missing {U+201A, U+201B, U+201E}.
- Primary Count: 3 missing.
- Cross-check Search Strategy or Query Expression: docstring range "U+2018 to U+201E" (`helpers:118`) enumerated as a contiguous range (family); content search for literal characters `[‘’‚‛“”„]|\\u201|U\+201` over all of `tests/` (coverage by a different encoding).
- Cross-check Member Set: family range 2018-201E = the same seven; literal-character search finds no gate test row (only unrelated Python files), so the covered set remains the four `[char]` rows; missing {U+201A, U+201B, U+201E}.
- Cross-check Count: 3 missing.
- Member-set Comparison: identical missing sets.

---

## Automation Feasibility

No step requires human interaction. Every change (helpers, epic-scope files, new shared target file, tests, skill documents, bundle mirrors, pack manifests) can be made and validated by agents through the PoshQC loop and the pytest parity contracts. The #735 determination came from source evidence, so a live Codex probe is not required. The optional manual Codex epic main-sync named in #738 (`#707 follow-up 2`) is not needed for any AC. Two operator decisions are needed before the spec is approved (Open Questions 1 and 2); these are decisions, not manual steps.

---

## Risks

1. **Narrowing breaks agent habits.** Backslash operands, `-C C:\...` selectors, unquoted commas or parentheses in messages, and glob operands will be denied. Mitigation: document the accepted forms in all six skill documents; the deny reason prefix is unchanged.
2. **C1a API drift.** The per-segment resolver depends on C1a's not-yet-written API. Mitigation: verify the names listed in Q3 at execution start; isolate consumption in the new shared target file.
3. **cmd residual.** `cmd.exe` is reachable on Codex Windows (fallback or `shell: cmd`). It does not treat `'` as a quote, so single-quoted messages can become pathspecs. The POSIX-versus-PowerShell rule does not close this.
4. **Codex `workdir` unobservable.** The #738 Codex `workdir` AC cannot be met from the payload; without option (b) a Codex command can still operate in a model-chosen directory during an epic merge.
5. **Path-leg `..` gap.** `Test-FeatureDocumentationOrEvidencePath` admits `docs/features/active/../..` file paths on both gates and Codex patch markers. It is outside the bundled AC.
6. **Line caps.** Helpers (497), Codex resolution (493), `WorktreeRunResolution.psm1` (497), `WorktreeResolution.psm1` (500), and both CommandExemption suites (493, 496) have little or no headroom. New logic and tests must go to new files.
7. **Merge order.** C1b depends on C1a and C2. Rebasing after their merge may move the line numbers cited here.
8. **Stale evidence.** Branch state was read without a fetch, and issue comments were not read.

## Recommendations for Spec and Plan

Spec:
1. Record the #735 finding (Q1) as a decision: the executing shell is undetermined per command on Codex; the shared helpers adopt shell-agnostic, fail-closed parsing on both surfaces.
2. Adopt the #732 design in Q2 (backslash anywhere denied; outside-quote set `> < # { } , ( ) @`; ASCII operand allowlist; leading `/` and `..` denied; exact five-tree prefix). Record the three intentional reversals (D4 row 18, LACS allow 3, ChainEscape escaped semicolon).
3. Adopt the per-segment target contract in Q3. State explicitly: relative or dot-segment `-C` is unresolved; unresolved, mixed, or ambiguous targets deny when any candidate is epic scope; the single-feature path is unchanged.
4. Amend the #738 Codex `workdir` AC per the operator decision (Open Question 1).
5. Set the line-length target for #745 item 4 to 120 characters and record that no analyzer rule enforces it.
6. Record D5 as deferred, with the Q5 rationale.
7. Keep deny reasons on the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix and add stable reason codes for new denies (for example `target-unresolvable`, `target-mixed`, `target-ambiguous`).
8. Non-goals: no `-modes.ps1` edits (C2), no `hook-command-invocation.ps1` or scanner edits (C1a), no path-leg `..` fix (follow-up), no cmd-specific modeling (follow-up).

Plan:
1. Phase 0: re-read issue bodies and comments with `gh issue view <n> --json body,comments`; fetch; confirm C1a and C2 have merged into the integration branch; record the C1a API (Q3 list); compute `git hash-object` for the four helper copies (baseline).
2. Fail-before tests (new files, both surfaces): the two #732 shapes; `\;`, `\&`, `\|`, `.\.`, `docs\features\...`; brace, comma, `@`, parentheses in messages and operands; glob operands under an exempt tree; the three reversed rows.
3. Helpers edit in place, propagated byte-identically to four copies; parity test green; line count under 500.
4. New shared target file (four copies) plus both `pack-manifests/core.json` entries, a `SharedModuleNames` entry, and parity coverage (extend the helpers parity test pattern to the new file name).
5. Epic-scope decision changes in `.claude/hooks/...-epic-scope.ps1` and `.codex/hooks/...-epic-scope.ps1` (and bundles). New gate-level suites for #738 on both surfaces: second segment into a different worktree, repeated `-C`, relative `-C`, unresolvable `-C`, `cd` chain, wrapper-led segment, Write/Edit `file_path` into another worktree, and Codex `apply_patch` absolute marker.
6. #745: `.agents/skills/epic-plan/SKILL.md` and its bundle mirror; the quoting-rule update in the four `.claude` skill copies; AttributionTrailer rows (CR-4 admit and deny, U+201A, U+201B, U+201E).
7. Record the #735 finding in the helpers header and the Codex gate header. Where it goes under `.claude/rules/` is Open Question 4.
8. Toolchain loop per `.claude/rules/powershell.md`; coverage of every changed file in `.claude/hooks` and `.codex/hooks` at line coverage of 85% or more, with evidence from a direct PoshQC module run; the pytest parity and manifest suites listed in Q6.
9. File follow-ups: path-leg `..` gap (Q2 scope note), cmd divergence (Risk 3), and the remaining prefix-idiom sites.

## Open Questions

1. **Codex `workdir` (#738 AC).** Choose (a) amend the AC to "unobservable; session root is the target; follow-up for upstream payload support", or (b) Codex-only strict mode requiring an absolute `git -C` for implementation-classified git segments in epic scope. Recommendation: (a) for C1b, because (b) changes Codex epic-orchestrator command forms outside this child's documented scope. File (b) as a follow-up candidate.
2. **cmd divergence.** Accept as a recorded residual with a follow-up (recommended), or deny on all surfaces any single-quoted span containing whitespace. The second option removes the #713 single-quoted trailer forms.
3. **Path-leg `..` gap** in `Test-FeatureDocumentationOrEvidencePath` (both gates). Recommendation: a follow-up issue rather than C1b scope.
4. **Where to record #735 under `.claude/rules/`.** `CLAUDE.md` makes `.github/instructions/*` canonical and asks that they not be modified. A new `.claude/rules/` file needs frontmatter (`test_claude_rules_frontmatter.py`) and a bundle mirror. Recommendation: record the finding in the hook headers and this research artifact; ask the operator before adding a rules file.
5. **C1a API names.** Unknown until C1a merges (Q3). The plan must verify before editing.
6. **Single-feature target resolution** (`Resolve-OrchestrationGateTarget`) still uses the first selector. Recommendation: leave unchanged in C1b (the AC scopes #738 to epic-scope resolution) and note it as a follow-up.
7. **Issue comments** for #732, #738, #745, and #735 were not read in this session; they may contain decisions that override this research.
