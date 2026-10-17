# Research: pr-author docs-only exemption hardening (Issue #927)

- Timestamp: 2026-10-15T11-52 (UTC)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927` (worktree HEAD `1906799e4`, main at `f6915d42`)
- Requirements source: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/issue.md` (Work Mode `full-bug`)
- Parent item: #901 (PR #924, merged)
- Method limitation: this session had file read, search, and web fetch tools only. No shell was available, so no `git`, `pwsh`, Pester, or hash command ran. The timestamp above was read from a network UTC clock (`timeapi.io`) because the host clock could not be read without a shell. The byte-identity, commit-time, and coverage facts below are marked "verified" only where a file read established them; otherwise they are marked "cited" (taken from a committed review artifact) or "to verify" (a command the plan must run).

## 1. Current State

### 1.1 Hook file content and line map

`.claude/hooks/enforce-pr-author-skill.docs-only.ps1` is 265 lines. Functions and line ranges (verified by Read):

| Lines | Element | Notes |
|---|---|---|
| 1-32 | Comment-based help | E1-E7 condition table at 13-20; E3 text at 15-16 says "no -B token" |
| 33-34 | `[CmdletBinding()] param()` | |
| 36-71 | `Invoke-PrAuthorDocsOnlyGitExe` | single git seam; never throws |
| 59-62 | failure object, root existence check | covered by the existing nonexistent-root test row |
| 63-66 | `try { $lines = @(& git -C $WorktreeRoot @GitArgs 2>$null); $code = $LASTEXITCODE }` | lines 64, 65 uncovered (cited) |
| 67-69 | `catch { return $failure }` | line 68 uncovered (cited) |
| 70 | `return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }` | uncovered (cited) |
| 73-94 | `Test-PrAuthorDocsOnlyCheckpointPresence` | |
| 96-139 | `Get-PrAuthorDocsOnlyBaseName` | CR-1 target |
| 121-130 | token loop over `$match.Segment.Tokens` | line 124: `if ($text.StartsWith('-B', [System.StringComparison]::Ordinal)) { return $null }`; line 127 counts `--base` / `--base=` |
| 131-138 | single-`--base` check, `Get-CommandLineFlagValue`, spelling regex, `..` check | |
| 141-167 | `ConvertFrom-PrAuthorDocsOnlyNameList` | line 162 splits on `[char]0` |
| 169-198 | `Get-PrAuthorDocsOnlyPathViolation` | EMPTY_DIFF / NON_DOCS_PATH |
| 200-265 | `Get-PrAuthorDocsOnlyExemption` | E1 224-226, E2 227-229, E3 230-233, E4 235-248, E5 250-258, E6/E7 260-263 |
| 251 | diff args: `diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD` | CR-3 (D5) site; must not change |
| 256-258 | `if ($null -eq $diff -or $diff.ExitCode -ne 0) { ... DOCS_ONLY_EXEMPTION_DIFF_FAILED ... }` | CR-2 guard insertion point is immediately after this block |

Uncovered lines 64, 65, 68, 70 are cited from `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/policy-audit.2026-10-13T11-40.md` line 146 and `code-review.2026-10-13T11-40.md` line 29/32 (local XML and CI run `38321045586` both report `docs-only.ps1` LINE covered=57 missed=4).

### 1.2 Callers and wiring

- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (438 lines) dot-sources the sibling at line 58 and calls `Get-PrAuthorDocsOnlyExemption` at line 424 only in the non-epic branch after the preflight fails; line 426 composes `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary> (docs-only exemption not applied: <Reason>)`. No change needed in this file.
- `.claude/hooks/enforce-pr-author-skill.ps1` (355 lines) documents the exemption in its header at lines 26-41 (line 29: "exactly one explicit --base <branch> and no -B token"; line 38: DIFF_FAILED "the diff exits non-zero or throws"). Its header must be updated to describe the new conditions.

### 1.3 Shared parser behavior relevant to CR-1 (verified by Read)

- `.claude/hooks/hook-command-invocation.ps1` lines 47-51: the gh global-option table models `-R` and `--repo` as `WithArgument`. `Skip-CommandLineOption` (138-193) splits `--name=value` and absorbs modeled options before each subcommand element, so `gh -R x pr create`, `gh --repo=x pr create`, and `gh pr -R x create` all classify `Structural`. A bare cluster such as `-Rx` before a subcommand element is unmodeled, classifies `Indeterminate`, and `Get-CommandLineStructuralMatch` returns `$null`, so E3 already denies that shape.
- `$match.Segment.Tokens` is the whole record's token list (quotes stripped), including `VAR=value` prefixes, the command word, global options before the subcommand, and every token after it. The loop at lines 122-130 therefore sees `-R`/`--repo` wherever they appear in the gh segment.
- `Get-CommandLineFlagValue` (`hook-command-invocation-operands.ps1` lines 70-123) reads only the named long flag (`--base` and `--base=`); it never reads `-B`.

### 1.4 Mirrors and lockstep surfaces (verified)

| Surface | Path | Must change | Evidence |
|---|---|---|---|
| Canonical hook | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | yes | Read |
| Bundled mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | yes, byte-identical | Read: all 265 lines identical in content to the canonical file |
| Canonical main hook (header doc only) | `.claude/hooks/enforce-pr-author-skill.ps1` | yes | header lines 26-41 |
| Bundled mirror of main hook | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | yes, byte-identical | Grep: identical header lines 29, 36 |
| Pack manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` line 52 | no (path list only, no hash) | Read lines 40-59 |
| Codex hook | `.codex/hooks/**` | none exists | Glob `.codex/**/*pr-author*` returns only six `.codex/agents/pr-author*.toml` files |
| Codex/agents bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/` | none (no hook copy) | Glob |
| Copilot bundle | `extensions/drm-copilot/resources/customizations/.github/` | none (only `agents/pr-author.agent.md`) | Glob |
| SHA or hash manifest | none found | n/a | Grep for `enforce-pr-author-skill` in `*.json,*.txt,*.yml,*.yaml,*.sha256,*.csv` finds only `core.json`, the two `settings.json` files, and historical fixtures/evidence |

Byte identity: content identity was verified line by line through Read; `.gitattributes` line 1 (`* text=auto eol=lf`) normalizes line endings. Exact byte identity (BOM, trailing newline) was not hashed in this session; the plan must run `cmp -s` (or `Get-FileHash`) on both pairs. The enforcing test is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110), which asserts that every distributable `.claude/**` file exists in the bundle with equal UTF-8 text.

### 1.5 Line-count headroom (500-line limit)

| File | Lines now | Estimated after change |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | 265 | about 285 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 355 | about 358 (header only) |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` | 218 | about 280 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` | 209 | about 225 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` | 149 | about 165 (optional row) |

All stay well under 500.

## 2. gh flag semantics (CR-1)

Verified from `https://cli.github.com/manual/gh_pr_create` and the pflag parser source (`spf13/pflag` `flag.go`):

- Value-taking shorthands of `gh pr create`: `-a` assignee, `-B` base, `-b` body, `-F` body-file, `-H` head, `-l` label, `-m` milestone, `-p` project, `-r` reviewer, `-T` template, `-t` title. Boolean shorthands: `-d` draft, `-e` editor, `-f` fill, `-w` web. Inherited: `-R, --repo [HOST/]OWNER/REPO` (value-taking).
- pflag shorthand parsing walks a cluster left to right. A boolean letter consumes itself; a value-taking letter consumes the rest of the cluster (`-Bother`), the text after `=` (`-B=main`), or the next argument (`-B main`). So `-dB other` is draft plus base `other`, and `-dR o/r` is draft plus repo `o/r`. Shorthand letters are case-sensitive (`-b` is body, `-r` is reviewer).
- Long flags: `--name=value` or `--name value`; pflag performs no prefix abbreviation.
- `GH_REPO` (environment) also retargets the repository ("specify the GitHub repository in the [HOST/]OWNER/REPO format for commands that otherwise operate on a local repository").

pr-author invocations (verified in `.claude/agents/pr-author.md` lines 68-69 and 109-122, `.claude/skills/parallel-orchestrate/SKILL.md` line 246): `gh pr create` with `--body-file`, `--head`, `--base main`, and `--title`. No single-dash token and no `-R`/`--repo` is used, so the rule below produces no false denial on the sanctioned command shape.

### Minimal fail-closed rule

In the token loop of `Get-PrAuthorDocsOnlyBaseName`, return `$null` (E3 deny) when any token:

1. is a single-dash token (`Length -ge 2`, first char `-`, second char not `-`) whose characters after the leading dash contain `B` or `R` under ordinal, case-sensitive comparison (`$text.Substring(1).IndexOfAny([char[]]@('B','R')) -ge 0`); this subsumes the current `StartsWith('-B')` test and covers `-B x`, `-Bx`, `-B=x`, `-dB x`, `-R x`, `-Rx`, `-dR x`; or
2. equals `--repo` or starts with `--repo=` (case-insensitive is acceptable and fails closed).

Accepted false denials (fail closed, not used by pr-author): a value-taking letter followed by inline text containing `B`/`R` (for example `-tBump`), and a dash-leading value token such as `--title "-Rework"`.

Not detectable from the command text: an ambient `GH_REPO` exported in an earlier Bash call or inherited from the session. An inline prefix (`GH_REPO=o/r gh pr create ...`) is detectable because the `VAR=value` token is in `Segment.Tokens`. Decision for the spec: whether to deny an inline `GH_REPO=` prefix token (one condition, one test row; same retargeting class as `-R`). Recommendation: include it and record the ambient-environment case as a documented residual limit.

## 3. CR-2: NUL-termination guard and seam coverage

### 3.1 Guard

Insert after line 258 in `Get-PrAuthorDocsOnlyExemption`:

- Let `$diffText = [string]$diff.Output`.
- If `$diffText.Length -gt 0 -and -not $diffText.EndsWith([char]0)`, return `DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base did not return NUL-terminated output.` (reuses the existing code; distinct message text).
- Pass `$diffText` to `ConvertFrom-PrAuthorDocsOnlyNameList` at line 260.

Rationale: `git diff --name-only -z` terminates every entry with NUL and prints no trailing newline, so a correct capture always ends with `[char]0`. If PowerShell ever dropped or replaced NUL, entries would concatenate into one string that could begin with `docs/` (for example `docs/a.md.claude/x.ps1`) and pass E7; the guard denies instead. Empty output still reaches E6 (EMPTY_DIFF) because the guard requires non-empty output. A path containing a line feed still ends with NUL after the seam's ``-join "`n"``.

All existing diff mocks end with NUL (`"docs/a.md`0"`, `".claude/hooks/x.ps1`0"`, `".claude/x.md`0docs/x.md`0"`, `"docs/a.md`0docs/b.md`0"`) or are empty, so no existing row changes outcome (verified by Read of the three DocsOnly suites).

### 3.2 Executing lines 64-70 without running git

Constraints (verified):

- `.claude/hooks/check-powershell-test-purity.ps1` lines 103-107 deny test content matching `^\s*Mock\s+git\b` or `Mock 'git'`, and line 118 denies `Start-Process`.
- The DocsOnly suite headers state that no row starts a process or runs git; `.claude/rules/general-unit-test.md` forbids external processes in unit tests.

Recommended seam change (repository precedent: `scripts/dev-tools/run-actionlint.ps1` lines 99-111 `Invoke-ActionlintExe -CommandPath`, tested in `tests/scripts/dev-tools/run-actionlint.Tests.ps1` lines 307-321 by passing a non-executable command name and setting `$global:LASTEXITCODE`):

- Add `[ValidateNotNullOrEmpty()][string] $GitCommand = 'git'` to `Invoke-PrAuthorDocsOnlyGitExe` and change line 64 to `& $GitCommand -C $WorktreeRoot @GitArgs 2>$null`. Production callers (lines 237, 251) pass nothing, so behavior is unchanged.
- Tests pass the name of a test-local function (for example `Invoke-DocsOnlyFakeGit`) with `-WorktreeRoot $PSScriptRoot` (an existing directory, so line 60 passes without creating any file):
  - success row: the fake sets `$global:LASTEXITCODE = 0` and emits `"docs/a.md`0docs/b.md`0"`; assert `ExitCode 0`, `Output` equal and ending with `[char]0`, and that the fake received `-C <root>` followed by the GitArgs (executes 64, 65, 70);
  - multi-line row: the fake emits two strings; assert they are joined with `` `n `` (70);
  - non-zero row: the fake sets `$global:LASTEXITCODE = 128`; assert `ExitCode 128`;
  - throw row: the fake throws; assert the failure object `ExitCode -1`, `Output ''` (executes 68).
- Reset `$global:LASTEXITCODE` in `BeforeEach`/`AfterEach` for independence (precedent: 14+ suites set `$global:LASTEXITCODE`, for example `tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1` line 27).

Limit: these rows prove the seam's capture-and-join logic, not that the real PowerShell native-command capture preserves NUL. The guard in 3.1 makes that property safety-irrelevant (a lost NUL denies). Post-change line numbers shift; the spec should name the statements ("the `& $GitCommand` capture, `$code = $LASTEXITCODE`, the catch return, and the success return of `Invoke-PrAuthorDocsOnlyGitExe`") rather than fixed line numbers.

## 4. Test suites

| Suite | Lines | Structure | Seam handling | Proposed additions |
|---|---|---|---|---|
| `enforce-pr-author-skill.DocsOnly.Tests.ps1` | 218 | `Describe` + `Context` per helper; `-ForEach` accept/reject tables at 130-159 | calls helpers directly; one seam row (nonexistent root) at 205-217 | reject rows: `-dB other`, `-Bother`, `-B=main`, `-R o/r`, `-Ro/r`, `-dR o/r`, `--repo o/r`, `--repo=o/r`, `gh -R o/r pr create --base main`, `gh --repo o/r pr create --base main`, optional `GH_REPO=o/r gh pr create --base main`; accept rows: `-d --base main`, `--base main -H feature/x`, `--base main -t Docs`; four seam rows from 3.2 |
| `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` | 209 | `Context 'predicate rows'`, `BeforeEach` mocks `Test-PrAuthorDocsOnlyCheckpointPresence` and `Invoke-PrAuthorDocsOnlyGitExe` by `-ParameterFilter { $GitArgs[0] -eq ... }` | mocks the seam | `denies diff output that does not end with NUL` (Output `"docs/a.md"`, expect `DOCS_ONLY_EXEMPTION_DIFF_FAILED*`); `denies -R before any git call` (expect BASE_UNRESOLVED, seam invoked 0 times) |
| `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` | 149 | end-to-end through `Invoke-PrAuthorSkillDecision` | mocks the seam | optional: one `--repo` row asserting `deny` and `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` |

CI execution (verified in `.github/workflows/_poshqc.yml`): job `poshqc-linux-hooks` ("PowerShell hook suites (Linux)", lines 54-90) runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled, so all three suites run on Linux. Job `poshqc` ("PowerShell QC", windows-latest, lines 8-52) runs `Invoke-PoshQCTest` with coverage and uploads `artifacts/pester/powershell-coverage.xml` as artifact `poshqc-test-results`. The fake-function approach has no OS dependency (`$PSScriptRoot` exists on both).

### Existing tests that the new rule could break

None found. Every command reaching the exemption in the three DocsOnly suites uses long flags only (`--base`, `--title`, `--body-file`). Suites that use `gh --repo ... pr create` (`enforce-pr-author-skill.TriggerScoping.Tests.ps1` lines 94-110; `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` line 52) deny earlier with `PR_CONTEXT_MISSING` or exercise the epic-base check, and never assert an exemption allow. Only the three DocsOnly suites mock `Invoke-PrAuthorDocsOnlyGitExe` (Grep count). The existing reject row `the -B short form` remains valid.

## 5. Coverage tooling

- `config/poshqc-coverage.json`: roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; the bundled mirror is outside the population (no duplicate measurement).
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: `CodeCoverage.OutputFormat = 'CoverageGutters'`, `OutputPath = 'artifacts/pester/powershell-coverage.xml'`, `CoveragePercentTarget = 0`.
- The PoshQC MCP test runner did not apply `config/poshqc-coverage.json` in #901 (`evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md` line 6: no class entry for `docs-only.ps1`), and MCP results carry no output detail. A plan must not assert a per-line figure from an MCP result.
- Observation route for lines 64-70 (post-change equivalents): download the Windows CI artifact (`gh run download <run-id> -n poshqc-test-results`) and parse `powershell-coverage.xml`: the `sourcefile` element named `enforce-pr-author-skill.docs-only.ps1` under the `.claude/hooks` package, `line` elements with `nr` equal to the four statement lines must have `ci` greater than 0, and the file `LINE` counter must show `missed` 0 for those statements. A local direct `Invoke-PoshQCTest -Root <worktree>` run produces the same XML (route used in #901 cycle 2), but an agent worktree's isolation guard refuses command text containing `pwsh`, so the CI artifact is the dependable route.

## 6. Deny reason codes (verified)

| Code | Current text | Change |
|---|---|---|
| `DOCS_ONLY_EXEMPTION_NOT_CREATE` | `only gh pr create is eligible.` | none |
| `DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT` | `a checkpoint file exists at '<path>', so its preflight governs.` | none |
| `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` (E3, line 232) | `pass exactly one explicit --base <branch>; the -B short form is not read.` | extend text to name shorthand clusters containing B or R, `-R`, and `--repo` (and `GH_REPO=` if adopted) |
| `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` (E4, line 247) | `refs/remotes/origin/<base> does not resolve to a commit in the target worktree.` | none |
| `DOCS_ONLY_EXEMPTION_DIFF_FAILED` (line 257) | `git diff against origin/<base> could not be computed.` | add a second return with a NUL-termination message |
| `DOCS_ONLY_EXEMPTION_EMPTY_DIFF` | `the branch diff lists no path.` | none |
| `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH` | `'<path>' is outside docs/.` | none |

All tests assert codes with `-BeLike '<CODE>*'` or `-Match '<CODE>'`; no test asserts the E3 message tail (Grep for `short form is not read` finds only the hook files and #901 docs). The outer prefix `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` (helpers line 426) is unchanged.

## 7. PA-N3 / PA-N2: #901 evidence record

Folder: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/`. Per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` lines 49 and 58, `Timestamp` is UTC from the host clock, never composed or estimated, and existing files are not renamed.

### 7.1 Reference times

| Source | Value | UTC | Status |
|---|---|---|---|
| MCP-run coverage XML mtime (`XML_MTIME_AFTER_EPOCH` in `p1-xml-regenerated`, `XML_MTIME_MCP_RUN_EPOCH` in `p1-direct-run-before`) | 1791888677 | 2026-10-13T10:51:17Z | computed |
| MCP-run XML report name | `Pester (10/13/2026 06:51:02)` | 10:51:02Z if America/New_York (-04:00) | consistent with the mtime |
| First direct-run XML mtime (`p1-direct-xml-regenerated`, `local-powershell-coverage-direct`) | 1791890071 | 2026-10-13T11:14:31Z | computed |
| Rerun XML mtime (`p1-direct-xml-regenerated-rerun`, `local-powershell-coverage-direct-rerun`) | 1791890931 | 2026-10-13T11:28:51Z | computed |
| Pre-cycle XML mtime (`XML_MTIME_BEFORE_EPOCH`) | 1791845953 | 2026-10-12T22:59:13Z | computed |
| Commit `ff1b7cbd4` | 07:17 -04:00 | about 11:17Z | cited (policy-audit line 155); to verify with `git show -s --format=%cI ff1b7cbd4` |
| Commit `70e58ca84` | 07:34 -04:00 | about 11:34Z | cited; to verify with `git show -s --format=%cI 70e58ca84` |

Epoch arithmetic: 2026-10-13T00:00:00Z = 1767225600 (2026-01-01) + 285 x 86400 = 1791849600.

### 7.2 Affected rows

File-to-commit membership is inferred from `code-review.2026-10-13T11-40.md` lines 38-40 (14 files in `ff1b7cbd4`, four rerun files in `70e58ca84`) and from the 18 `*.2026-10-12T19-50.md` evidence files; the plan must confirm with `git show --name-status ff1b7cbd4 70e58ca84 -- <folder>/evidence`.

| # | File (under `evidence/`) | Line | Current | Finding | Derivable bound (UTC) |
|---|---|---|---|---|---|
| 1 | `qa-gates/p1-pester-junit.2026-10-12T19-50.md` | 1 | `Timestamp: 2026-10-13T00-00` | PA-N3(a); reads results of the MCP run | 2026-10-13T10-51 .. 11-17 |
| 2 | `qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md` | 1 | `Timestamp: 2026-10-13T00-00` | PA-N3(a); MCP run completed when its XML was written | run ended 10:51:17Z; start not recorded; at or before 10-51 |
| 3 | `qa-gates/p1-xml-regenerated.2026-10-12T19-50.md` | 1 | `Timestamp: 2026-10-13T00-00` | PA-N3(a); the file itself records mtime 10:51:17Z | 10-51 .. 11-17 |
| 4 | `qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md` | 3 | `Timestamp: 2026-10-13T11-30` | later than commit; run ended 11:14:31Z | start 10-51 .. 11-14 |
| 4b | same file | 5 | `EXIT_CODE: 0` | PA-N3 unobserved exit code (rerun file line 9 states it was never observed) | set to not observed; the observed value is in `p1-poshqc-direct-run-rerun` |
| 4c | same file | 6 | Output Summary "Exit code 0 means..." | depends on the unobserved value | revise |
| 5 | `qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md` | 3 | `11-32` | later than commit | 11-14 .. 11-17 |
| 6 | `qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md` | 3 | `11-34` | later than commit | 11-14 .. 11-17 |
| 7 | `qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md` | 3 | `11-36` | later than commit | 11-14 .. 11-17 |
| 8 | `qa-gates/p2-ac-state.2026-10-12T19-50.md` | 3 | `11-38` | later than commit | at or before 11-17 |
| 9 | `qa-gates/p2-scope-before-stage.2026-10-12T19-50.md` | 3 | `11-39` | later than commit | at or before 11-17 |
| 10 | `qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` | 3 | `11-32` | stamped after the run it records ended (11:28:51Z) | start 11-14 .. 11-28 |
| 11 | `qa-gates/p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` | 3 | `11-34` | not contradicted at minute resolution | 11-28 .. 11-34 |
| 12 | `qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md` | 3 | `11-36` | later than commit `70e58ca84` | 11-28 .. 11-34 |
| 13 | `qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` | 3 | `11-37` | later than commit `70e58ca84` | 11-28 .. 11-34 |
| 14 | `qa-gates/local-powershell-coverage.2026-10-12T19-50.md` | 1 | `06-55` | not named in #927; same class: matches America/New_York local time (the file cites report name `06:51:02`, which is 10:51Z) | 10-55 if the local-time reading holds; bound 10-51 .. 11-17 |

Rows not contradicted by any recorded value: `remediation-baseline/phase0-instructions-read` (`00-07`), `p0-local-coverage-before` (`00-08`), `p0-repo-state` (`00-09`), `p1-direct-run-before` (`11-04`, inside 10:51:17Z .. 11:14:31Z). Leave unchanged.

Note on PA-N3(c): the policy audit says `70e58ca84` introduces rows `11-32` to `11-37` later than the commit. At minute resolution only `11-36` and `11-37` are later than 11:34Z; `11-32` is contradicted by the rerun XML mtime instead, and `11-34` is not contradicted. The exact second of the commit decides row 11.

No row's exact true value is derivable; every correction is a bound. Recommended correction format (no file rename): keep one `Timestamp:` row first (the collector in `scripts/dev_tools/pr_context/verification_evidence.py` lines 125-133 reads the first `Timestamp`, `Command`, and `EXIT_CODE` occurrence and requires only a non-empty `Timestamp`), set its value to the bound's upper end, and add `TIMESTAMP_RECONSTRUCTED: true`, `TIMESTAMP_ORIGINAL: <old value>`, `TIMESTAMP_BOUNDS_UTC: <lo> .. <hi>`, and `TIMESTAMP_DERIVATION: <epoch and commit sources>` rows. For row 4b use `EXIT_CODE: NOT_OBSERVED` plus `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`; the collector then classifies that file `unparseable`, which is the accurate state. Alternative accepted by the issue: retain the original values and add only the annotation rows; this keeps the inaccurate value as the parsed `Timestamp` and is not preferred.

### 7.3 PA-N2

`issue.md` lines 48-51: `## Evidence Checklist` with `- [ ] baseline`, `- [ ] targeted verification`, `- [ ] end-state`. Evidence exists for each: baseline in `evidence/baseline/` (8 files stamped `2026-10-11T10-38`); targeted verification in `evidence/qa-gates/` and `evidence/regression-testing/`; end state in `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` plus the PR #924 merge at `e467c693` (cited in the #927 issue). Recommendation: check all three with a parenthetical citing the folder or file.

## 8. CR-3 (D5) unchanged

The proposed edits touch only the token loop (lines 122-130), the E3 message (line 232), the seam's executable token and parameter block (lines 54-57, 64), and a new block after line 258. The diff argument list on line 251, including `($commit + '...HEAD')`, is unchanged, and the existing Exemption row `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` (lines 189-197) continues to pin it.

## 9. Candidate Approaches

Selected:

- CR-1: extend the existing token loop in `Get-PrAuthorDocsOnlyBaseName` with the cluster-letter and `--repo` checks, reusing E3 `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` with an extended message. Smallest change, keeps the helper's string-or-null contract, and errs toward denial.
- CR-2: NUL-termination guard in the decider reusing `DOCS_ONLY_EXEMPTION_DIFF_FAILED`, plus an injectable `-GitCommand` parameter on the seam so a test-local function executes the seam body.
- PA-N3/PA-N2: in-place edits of the affected rows with reconstruction annotations; checklist check-off with citations.

Rejected alternatives:

- Full pflag simulation with a table of boolean versus value-taking shorthands: avoids rare false denials but adds a table that drifts when gh adds flags; more code for no sanctioned-caller benefit.
- New sub-code `DOCS_ONLY_EXEMPTION_REPO_OVERRIDE`: clearer text but requires changing the helper's return contract; the extended E3 message carries the same information.
- Guard inside `ConvertFrom-PrAuthorDocsOnlyNameList`: that helper returns paths, not reason codes; the decider owns the codes.
- Covering lines 64-70 with `Mock -CommandName git` or a test function literally named `git`: evades the purity hook's text pattern while defeating its intent.
- Running real git in a unit test: violates the no-external-process rule; CI shallow checkouts also make history-dependent assertions unreliable.
- Splitting the seam into a smaller process wrapper: moves the uncovered `& git` line rather than executing it, so it does not satisfy the issue.

## 10. Requirements Mapping (proposed acceptance criteria inputs for spec.md)

- AC-A (CR-1 B clusters): `Get-PrAuthorDocsOnlyBaseName` returns `$null`, and the exemption denies with `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` before any git call, for a single-dash token containing `B` (ordinal), including `-dB other`, `-Bother`, `-B=main`.
- AC-B (CR-1 repo override): the same for a single-dash token containing `R`, `--repo`, and `--repo=`, before or after the `pr create` subcommand; optionally inline `GH_REPO=`.
- AC-C (no false denial): `--base main` with `-d`, `-H <branch>`, `-t <title>`, `--head`, `--title`, `--body-file` still resolves `main`, and the AC-1 allow row of #901 still passes.
- AC-D (CR-2 guard): non-empty diff output not ending with `[char]0` denies with `DOCS_ONLY_EXEMPTION_DIFF_FAILED`; empty output still yields `DOCS_ONLY_EXEMPTION_EMPTY_DIFF`.
- AC-E (CR-2 coverage): a test executes the four seam statements; the Windows CI coverage XML shows those lines covered.
- AC-F (mirrors): both bundled mirrors byte-identical (`cmp -s`), and the Python parity test passes.
- AC-G (docs): E3/E5 header text in `docs-only.ps1` and the Docs-only block in `enforce-pr-author-skill.ps1` describe the new conditions.
- AC-H (CR-3): the diff argument list and `...HEAD` range are unchanged.
- AC-I (PA-N3): each row in 7.2 is corrected or annotated per the chosen format; no evidence file is renamed.
- AC-J (PA-N2): the #901 Evidence Checklist items are checked or annotated.
- AC-K: toolchain (PoshQC format, analyze, Pester) passes; every edited PowerShell file stays under 500 lines; line coverage of the edited hook files is at least 85% in CI.

Required repository file changes:

1. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`
3. `.claude/hooks/enforce-pr-author-skill.ps1` (header lines 26-41 only)
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`
5. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`
6. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (optional end-to-end row)
8. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` (Evidence Checklist)
9. The evidence files in table 7.2 rows 1-14 (one file per numbered row; row 4 carries three edits), minus any row the spec decides to leave unchanged (candidates: row 11, row 14).

Unchanged: `enforce-pr-author-skill-helpers.ps1` and its mirror, `pack-manifests/core.json`, all `.codex/` content, and every shared parser file.

## 11. Testing Implications

- Order: add the failing rows first (reject rows for B/R clusters and `--repo`; NUL guard row); confirm they fail against the current hook; then change the hook.
- Seam rows: use the `-GitCommand` injection with a test-local function and `$PSScriptRoot` as the root; reset `$global:LASTEXITCODE` per test; no file writes, no process starts, no `Mock git` text.
- Verification: PoshQC MCP format/analyze/test for pass or fail only; per-file and per-line coverage from the Windows CI artifact `poshqc-test-results`; Linux hook-suite job for cross-platform pass.
- Mirror check: `cmp -s` on both pairs, plus `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

## Numeric Derivation Evidence

### N1: copies of the docs-only hook file

- Complete Family: every repository file whose content is the docs-only exemption hook.
- Exhaustive Search Scope: entire worktree, including `.claude/`, `.codex/`, `.github/`, and `extensions/drm-copilot/resources/**`.
- Inclusion Rules: a PowerShell file defining `Get-PrAuthorDocsOnlyExemption`.
- Exclusion Rules: Markdown plans and reviews that quote the code.
- Primary Search Strategy or Query Expression: Glob `**/enforce-pr-author-skill*` from the worktree root.
- Primary Member Set: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep for the content string `Docs-only exemption from the checkpoint preflight` across the worktree; plus Glob `**/*pr-author*` under `.codex/` and `extensions/drm-copilot/resources/**`.
- Cross-check Member Set: the same two `.ps1` files plus `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/plan.2026-10-11T10-38.md` (excluded: Markdown); the `.codex` and resource globs return no further hook file.
- Cross-check Count: 2 after exclusion.
- Member-set Comparison: identical sets.

### N2: #901 evidence files recording `Timestamp: 2026-10-13T00-00`

- Complete Family: all evidence files under the #901 folder whose filename stamp is `2026-10-12T19-50`.
- Exhaustive Search Scope: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/**`.
- Inclusion Rules: `Timestamp:` row value exactly `2026-10-13T00-00`.
- Exclusion Rules: review artifacts outside `evidence/`.
- Primary Search Strategy or Query Expression: Grep `2026-10-13` with line numbers in the folder, filtered to `Timestamp: 2026-10-13T00-00`.
- Primary Member Set: `qa-gates/p1-pester-junit`, `qa-gates/p1-poshqc-test-invocation`, `qa-gates/p1-xml-regenerated` (each `.2026-10-12T19-50.md`).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: Glob listing of the folder (18 files carry the `2026-10-12T19-50` stamp: 4 in `remediation-baseline/`, 14 in `qa-gates/`), the `Timestamp` value of each taken from the grep listing, and direct Read of the three candidates.
- Cross-check Member Set: the same three files; the other 15 carry `00-07`, `00-08`, `00-09`, `06-55`, `11-04`, `11-30`, `11-32` (2), `11-34` (2), `11-36` (2), `11-37`, `11-38`, `11-39`.
- Cross-check Count: 3.
- Member-set Comparison: identical sets.

### Withheld numeric assertions

- The number of rows stamped later than commits `ff1b7cbd4` and `70e58ca84` is withheld: the commit times are cited, not observed, and file-to-commit membership is inferred. The plan must derive it from `git show -s --format=%cI` and `git show --name-status`.
- The uncovered-line count (4) is cited from two review artifacts and CI run `38321045586`, not re-derived in this session.

## Automation Feasibility

All work is automatable by agents with the following route notes:

- Hook, mirror, and test edits: Write/Edit tools. Test content must avoid the purity-hook patterns (`Mock git`, `Start-Process`, `$env:TEMP`).
- Mirror parity: `cmp -s` or `Get-FileHash` comparisons and the Python parity test via `poetry run pytest`.
- Commit times and file membership for PA-N3: `git show -s --format=%cI <sha>` and `git show --name-status <sha>`; read-only.
- PoshQC format, analyze, and test: PoshQC MCP tools for pass/fail. MCP results carry no output detail and the MCP runner did not apply `config/poshqc-coverage.json` in #901, so per-line coverage must come from the Windows CI artifact (`gh run download <id> -n poshqc-test-results`) or from a direct `Invoke-PoshQCTest` run where the worktree guard permits it.
- Evidence corrections in the #901 folder are Markdown edits; no rename.
- No step requires manual operator action, provided the CI artifact route is available for coverage.
