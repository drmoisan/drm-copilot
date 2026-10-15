# pr-author docs-only exemption hardening (Spec)

- **Issue:** #927
- **Parent (optional):** #901 (PR #924, merged at head `e467c693` before remediation cycle 3 ran)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the only acceptance-criteria source; no `user-story.md`)
- **Requirements source:** `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/issue.md`
- **Research:** `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research.2026-10-15T11-52.md`

## Context

- Summary: the docs-only exemption added by #901 lets `gh pr create` skip the failed orchestrator-state checkpoint preflight when the branch diff against `origin/<base>` lists only paths under `docs/`. The exemption weakens an enforcement gate, so every input it does not inspect is a bypass route. Review of #901 recorded three findings that were classified as related follow-ups but were not remediated because PR #924 merged first:
  - CR-1 (Medium): the base-branch reader inspects only tokens that begin with `-B`. A clustered shorthand such as `-dB other`, or a repository override (`-R`, `--repo`, inline `GH_REPO=`), makes gh target a different base or repository than the one the exemption diffed against, while the exemption still allows the call.
  - CR-2 (Low): path separation depends on PowerShell preserving NUL bytes in captured native `git` stdout. No guard checks that property and no test executes the capture statements of the git seam.
  - PA-N3 / PA-N2: the #901 evidence record contains timestamps that are contradicted by recorded file-modification epochs and commit times, one `EXIT_CODE` value that was never observed, and an unchecked `## Evidence Checklist`.
- Observed environment(s): any host running the Claude Code PreToolUse hook `.claude/hooks/enforce-pr-author-skill.ps1`; main at `f6915d42`.
- Customer impact and severity: Medium. A `gh pr create` call without a passing checkpoint can be allowed for a branch whose diff against the actual gh target base contains non-docs paths. The sanctioned pr-author command shape does not use the affected flags, so the exposure is to non-sanctioned or adversarial command shapes.
- First observed: #901 review cycle 2 (`docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/policy-audit.2026-10-13T11-40.md`, `code-review.2026-10-13T11-40.md`).

## Repro & Evidence

- Steps to reproduce:
  1. CR-1: with no checkpoint file and a docs-only branch, evaluate `gh pr create --base main -dB other --body-file artifacts/pr_body_1.md`. `Get-PrAuthorDocsOnlyBaseName` returns `main` (the token `-dB` does not begin with `-B`), the exemption diffs against `origin/main`, and gh applies base `other`. The same occurs with `-R o/r`, `--repo o/r`, `--repo=o/r`, or an inline `GH_REPO=o/r` prefix, which retarget the repository.
  2. CR-2: the capture statement (`& git -C $WorktreeRoot @GitArgs 2>$null`), the `$code = $LASTEXITCODE` read, the catch-block `return $failure`, and the success `return [pscustomobject]@{ ... }` of `Invoke-PrAuthorDocsOnlyGitExe` are executed by no test (cited: local coverage XML and CI run `38321045586`).
  3. PA-N3 / PA-N2: inspect `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/` and `.../issue.md` lines 48-51.
- Expected vs actual:
  - Expected: the exemption denies with `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` before any git call when any base or repository override shape is present; it denies with `DOCS_ONLY_EXEMPTION_DIFF_FAILED` when diff output is non-empty and not NUL-terminated; evidence timestamps are not contradicted by recorded sources and exit codes appear only when observed.
  - Actual: see Context.
- Frequency: deterministic for each listed command shape.

## Scope & Non-Goals

### In scope

- CR-1: extend the token check in `Get-PrAuthorDocsOnlyBaseName` to deny single-dash tokens containing `B` or `R`, `--repo` / `--repo=` tokens, and an inline `GH_REPO=` prefix token; extend the E3 message text.
- CR-2: add a NUL-termination guard after the diff exit-code check; add an injectable `-GitCommand` parameter to `Invoke-PrAuthorDocsOnlyGitExe` so tests execute the seam body without starting a process.
- Header documentation in `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and `.claude/hooks/enforce-pr-author-skill.ps1`, and the byte-identical bundled mirrors of both files.
- New test rows in the DocsOnly Pester suites. Throughout this spec, "the DocsOnly suites" means `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`.
- PA-N3: in-place correction of the contradicted #901 evidence rows using the reconstructed-bound annotation format.
- PA-N2: check-off of the #901 `## Evidence Checklist` items with citations.

### Non-goals

- CR-3 (operator decision D5): the diff continues to compare local `HEAD` against `origin/<base>` with the three-dot range. The diff argument list and the `($commit + '...HEAD')` range are not changed.
- Ambient `GH_REPO`: a `GH_REPO` value exported in an earlier shell call or inherited from the session environment is not visible in the command text. It is a documented residual limit, not a requirement of this item.
- pflag simulation: no table of boolean versus value-taking gh shorthands is added. The rule is a conservative letter test that accepts some false denials (see Design).
- No new reason code. `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` and `DOCS_ONLY_EXEMPTION_DIFF_FAILED` are reused with extended or additional message text.
- No change to `.claude/hooks/enforce-pr-author-skill-helpers.ps1` or its mirror, the shared command parsers (`hook-command-invocation*.ps1`), `pack-manifests/core.json`, or any `.codex/` content. No `.codex` copy of the hook exists.
- No evidence file is renamed.

## Root Cause Analysis

- CR-1 (confirmed by code read): `Get-PrAuthorDocsOnlyBaseName` loops over `$match.Segment.Tokens` and returns `$null` only when a token satisfies `StartsWith('-B', Ordinal)`. gh uses spf13/pflag, which parses a single-dash cluster left to right: boolean letters consume themselves and a value-taking letter consumes the remainder, the `=` text, or the next argument. Therefore `-dB other` sets base `other`. `-R`/`--repo` (inherited gh option) and the `GH_REPO` environment variable retarget the repository; none is inspected. `Get-CommandLineFlagValue` reads only the long `--base` flag.
- CR-2 (confirmed by code read): `ConvertFrom-PrAuthorDocsOnlyNameList` splits on `[char]0`. `git diff --name-only -z` terminates every entry with NUL. If the native-command capture dropped or replaced NUL, entries would concatenate into one string that may begin with `docs/` (for example `docs/a.md.claude/x.ps1`) and pass E7. No guard detects this. The seam invokes the literal `git` executable, and the repository purity hook (`.claude/hooks/check-powershell-test-purity.ps1`) correctly forbids `Mock git` and `Start-Process` in tests, so its body has no test route.
- PA-N3 / PA-N2 (cited from research section 7): three evidence files record `Timestamp: 2026-10-13T00-00` although their content derives from a run whose coverage XML mtime is 2026-10-13T10:51:17Z; several rows added by commits `ff1b7cbd4` and `70e58ca84` are stamped later than those commits (commit times are cited, not observed); `p1-poshqc-direct-run.2026-10-12T19-50.md` records `EXIT_CODE: 0` for a run whose exit code its rerun file states was not observed; `local-powershell-coverage.2026-10-12T19-50.md` records a value matching America/New_York local time rather than UTC.
- Affected components: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (`Invoke-PrAuthorDocsOnlyGitExe`, `Get-PrAuthorDocsOnlyBaseName`, `Get-PrAuthorDocsOnlyExemption`, comment-based help), `.claude/hooks/enforce-pr-author-skill.ps1` (header only), their bundled mirrors, and the #901 feature folder.

## Proposed Fix

### Design summary

1. **CR-1 base and repository override detection** (`Get-PrAuthorDocsOnlyBaseName`, token loop). Replace the `StartsWith('-B')` test. Return `$null` when any token in `$match.Segment.Tokens`:
   - is a single-dash token: `Length -ge 2`, first character `-`, second character not `-`, and `Substring(1)` contains `B` or `R` under ordinal, case-sensitive comparison. This covers `-B x`, `-Bx`, `-B=x`, `-dB x`, `-R x`, `-Rx`, `-dR x`. Lowercase `-b` (body) and `-r` (reviewer) are not matched.
   - equals `--repo` or begins with `--repo=` (ordinal-ignore-case, consistent with the existing `--base=` comparison; case-insensitive matching only widens denial).
   - begins with `GH_REPO=` (ordinal-ignore-case). The token list includes `VAR=value` prefixes of the gh segment, so an inline prefix such as `GH_REPO=o/r gh pr create ...` is visible.
   The checks run before the `--base` count check and before any git call; the decider maps `$null` to E3 `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED`. The E3 message is extended to state that the exemption requires exactly one explicit `--base <branch>` and does not accept `-B`, `-R`, `--repo`, a single-dash shorthand cluster containing `B` or `R`, or an inline `GH_REPO=` prefix. The reason code is unchanged.
2. **CR-2 NUL-termination guard** (`Get-PrAuthorDocsOnlyExemption`). Immediately after the existing `if ($null -eq $diff -or $diff.ExitCode -ne 0)` block: let `$diffText = [string]$diff.Output`; if `$diffText.Length -gt 0` and `$diffText` does not end with `[char]0`, return `Exempt = $false` with `DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/<base> did not return NUL-terminated output.` Empty output passes the guard and reaches `DOCS_ONLY_EXEMPTION_EMPTY_DIFF` unchanged. `$diffText` is passed to `ConvertFrom-PrAuthorDocsOnlyNameList`.
3. **CR-2 seam injection** (`Invoke-PrAuthorDocsOnlyGitExe`). Add `[ValidateNotNullOrEmpty()][string] $GitCommand = 'git'` and change the capture statement to `& $GitCommand -C $WorktreeRoot @GitArgs 2>$null`. Production callers in `Get-PrAuthorDocsOnlyExemption` do not pass `-GitCommand`, so production behavior is unchanged. Tests pass the name of a test-local PowerShell function.
4. **Documentation.** Update the E3 and E5 rows of the comment-based help and the `.DESCRIPTION` of `Get-PrAuthorDocsOnlyBaseName` in the docs-only file, and the `Docs-only` block of the `enforce-pr-author-skill.ps1` header (the `--base` condition sentence and the `BASE_UNRESOLVED` / `DIFF_FAILED` sub-code descriptions). Record the ambient `GH_REPO` residual limit in the docs-only file header.
5. **Mirrors.** Copy both edited hook files byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
6. **PA-N3 evidence corrections** (Markdown edits, no rename) in `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/`. For each corrected file, the first `Timestamp:` row is set to the upper end of its bound, and these rows are added directly after it:
   - `TIMESTAMP_RECONSTRUCTED: true`
   - `TIMESTAMP_ORIGINAL: <previous value>`
   - `TIMESTAMP_BOUNDS_UTC: <lo> .. <hi>` (`UNRECORDED` when no source records a lower bound)
   - `TIMESTAMP_DERIVATION: <sources: recorded XML mtime epochs, confirmed commit times>`

   Target files and research-proposed bounds (research table 7.2; all UTC, `YYYY-MM-DDTHH-MM`):

   | File | Original | Proposed bound | Bound depends on commit time |
   |---|---|---|---|
   | `p1-pester-junit.2026-10-12T19-50.md` | `2026-10-13T00-00` | `2026-10-13T10-51 .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p1-poshqc-test-invocation.2026-10-12T19-50.md` | `2026-10-13T00-00` | `UNRECORDED .. 2026-10-13T10-51` | no |
   | `p1-xml-regenerated.2026-10-12T19-50.md` | `2026-10-13T00-00` | `2026-10-13T10-51 .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p1-poshqc-direct-run.2026-10-12T19-50.md` | `2026-10-13T11-30` | `2026-10-13T10-51 .. 2026-10-13T11-14` | no |
   | `p1-direct-xml-regenerated.2026-10-12T19-50.md` | `2026-10-13T11-32` | `2026-10-13T11-14 .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p1-pester-junit-direct.2026-10-12T19-50.md` | `2026-10-13T11-34` | `2026-10-13T11-14 .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `local-powershell-coverage-direct.2026-10-12T19-50.md` | `2026-10-13T11-36` | `2026-10-13T11-14 .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p2-ac-state.2026-10-12T19-50.md` | `2026-10-13T11-38` | `UNRECORDED .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p2-scope-before-stage.2026-10-12T19-50.md` | `2026-10-13T11-39` | `UNRECORDED .. 2026-10-13T11-17` | `ff1b7cbd4` |
   | `p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` | `2026-10-13T11-32` | `2026-10-13T11-14 .. 2026-10-13T11-28` | no |
   | `p1-pester-junit-direct-rerun.2026-10-12T19-50.md` | `2026-10-13T11-36` | `2026-10-13T11-28 .. 2026-10-13T11-34` | `70e58ca84` |
   | `local-powershell-coverage-direct-rerun.2026-10-12T19-50.md` | `2026-10-13T11-37` | `2026-10-13T11-28 .. 2026-10-13T11-34` | `70e58ca84` |
   | `local-powershell-coverage.2026-10-12T19-50.md` | `2026-10-13T06-55` | `2026-10-13T10-51 .. 2026-10-13T11-17` | `ff1b7cbd4` |

   Commit times and file-to-commit membership above are cited, not observed. Before editing, the executor runs `git show -s --format=%cI ff1b7cbd4 70e58ca84` and `git show --name-status ff1b7cbd4 70e58ca84 -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence`, records the output as evidence, and derives each commit-dependent bound from the confirmed values. If a confirmed value moves a bound so that the original timestamp is no longer contradicted, that file is left unchanged and the reason is recorded in the evidence.

   `p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` (original `11-34`) is left unchanged: its value is not contradicted at minute resolution.

   Additionally, in `p1-poshqc-direct-run.2026-10-12T19-50.md`: replace `EXIT_CODE: 0` with `EXIT_CODE: NOT_OBSERVED`, add `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`, and revise the Output Summary so that it no longer interprets an exit code of 0.
7. **PA-N2.** In `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`, change each `## Evidence Checklist` item (baseline, targeted verification, end-state) to `- [x]`, each with a parenthetical citation: baseline (`evidence/baseline/`), targeted verification (`evidence/qa-gates/` and `evidence/regression-testing/`), end-state (`evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` and the PR #924 merge at `e467c693`).

### Boundaries and invariants to preserve

- Every failure path denies. No new code path returns `Exempt = $true`.
- `Invoke-PrAuthorDocsOnlyGitExe` never throws and remains the single executable seam.
- E1-E7 evaluation order is unchanged; the new CR-1 checks are part of E3 and run before any git call; the new CR-2 check is part of E5 and runs after the exit-code check and before E6.
- The diff argument list (`diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD`) is unchanged (CR-3 / D5).
- The outer prefix `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` composed in the helpers file is unchanged.
- The exemption never applies under epic scope (unchanged).

### Dependencies or blocked work

- None. Coverage observation depends on the Windows CI artifact `poshqc-test-results` produced on the PR head.

### Implementation strategy

#### Files/modules to change

1. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`
3. `.claude/hooks/enforce-pr-author-skill.ps1` (header comment only)
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`
5. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`
6. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1`
8. `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`
9. The #901 evidence files listed in Design item 6.

#### Functions impacted

- `Invoke-PrAuthorDocsOnlyGitExe` (new optional `-GitCommand` parameter).
- `Get-PrAuthorDocsOnlyBaseName` (token checks).
- `Get-PrAuthorDocsOnlyExemption` (E3 message, NUL guard).

#### Error handling

- Both changes return deny objects; neither introduces a throw.

#### Rollback

- Revert the PR. The hook files and mirrors revert together; the #901 evidence edits are documentation-only.

### Technical specifications

- `Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot <string> -GitArgs <string[]> [-GitCommand <string> = 'git']` returns `[pscustomobject]@{ ExitCode = <int>; Output = <string> }`; output lines are joined with `` `n ``.
- `Get-PrAuthorDocsOnlyBaseName` keeps its string-or-`$null` contract.
- Backward compatibility: callers that omit `-GitCommand` observe identical behavior. Commands of the sanctioned pr-author shape (`gh pr create --title ... --body-file ... --head ... --base main`) resolve the same base as before.
- Performance: one additional string scan per token and one `EndsWith` check; negligible.

## Assumptions, Constraints, Dependencies

- Assumption: `$match.Segment.Tokens` contains `VAR=value` prefixes, global options before the subcommand, and all tokens after it, with quotes stripped (research 1.3, verified by code read).
- Constraint: unit tests start no process, run no git, create no temporary file, and contain no `Mock git`, `Mock 'git'`, or `Start-Process` text (`.claude/rules/general-unit-test.md`, `.claude/hooks/check-powershell-test-purity.ps1`). A test-local function literally named `git` is not used.
- Constraint: PowerShell verification uses PoshQC MCP tools for pass/fail and CI evidence for coverage. PoshQC MCP results carry no per-line output, so no per-line coverage claim is drawn from them.
- Constraint: every edited production and test file stays under 500 lines.
- Evidence produced during execution is written under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/<kind>/`.

## Data / API / Config Impact

- User-facing change: the E3 and the new E5 deny messages text. Reason codes are unchanged.
- No configuration, schema, or manifest change. `pack-manifests/core.json` lists paths only.

## Test Strategy

- Order: add the failing reject rows and the NUL-guard row first, confirm they fail against the current hook, then change the hook.
- `enforce-pr-author-skill.DocsOnly.Tests.ps1` (helper-level):
  - `Get-PrAuthorDocsOnlyBaseName` reject rows (return `$null`): `--base main -dB other`, `--base main -Bother`, `-B=main`, `--base main -R o/r`, `--base main -Ro/r`, `--base main -dR o/r`, `--base main --repo o/r`, `--base main --repo=o/r`, `gh -R o/r pr create --base main`, `gh --repo o/r pr create --base main`, `GH_REPO=o/r gh pr create --base main`. The existing `-B` short-form row is retained.
  - Accept rows (return `main`): `-d --base main`, `--base main -H feature/x`, `--base main -t Docs`, and the pr-author long-flag shape `gh pr create --title "docs: x" --body-file artifacts/pr_body_927.md --head bug/x --base main`.
  - Seam rows using `-GitCommand` with a test-local function and `-WorktreeRoot $PSScriptRoot`, with `$global:LASTEXITCODE` reset in `BeforeEach`/`AfterEach`:
    - success: fake sets `$global:LASTEXITCODE = 0` and emits `"docs/a.md`0docs/b.md`0"`; assert `ExitCode` 0, `Output` equal to the emitted text and ending with `[char]0`, and that the fake received `-C`, the root, then the GitArgs in order.
    - multi-line: fake emits two strings; assert `Output` joins them with `` `n ``.
    - non-zero: fake sets `$global:LASTEXITCODE = 128`; assert `ExitCode` 128.
    - throw: fake throws; assert `ExitCode` -1 and `Output` `''`.
- `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (decider-level, seam mocked):
  - diff Output `"docs/a.md"` (no trailing NUL), exit 0: Reason like `DOCS_ONLY_EXEMPTION_DIFF_FAILED*` and matching `NUL`.
  - diff Output `''`, exit 0: Reason like `DOCS_ONLY_EXEMPTION_EMPTY_DIFF*` (retained or added).
  - `-R o/r` with `--base main`: Reason like `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*`, and `Invoke-PrAuthorDocsOnlyGitExe` invoked exactly 0 times.
  - `-dB other` with `--base main`: same assertions.
  - existing row `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` retained unchanged.
- `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (end-to-end through `Invoke-PrAuthorSkillDecision`): one row with `--repo o/r --base main` asserting a deny whose reason contains `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` and `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED`.
- Toolchain: PoshQC MCP format, analyze, and test over the edited hook files and the DocsOnly suites; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; byte comparison (`cmp -s` or `Get-FileHash`) of each canonical/bundled pair.
- Coverage: from the PR head Windows CI artifact `poshqc-test-results` (`artifacts/pester/powershell-coverage.xml`), read the `sourcefile` element for `enforce-pr-author-skill.docs-only.ps1` under `.claude/hooks`; confirm the post-change lines of the seam statements named in AC-9 have `ci` greater than 0, and read the file `LINE` counter for each edited hook file. The Linux job `poshqc-linux-hooks` provides the cross-platform pass.
- Limit: seam rows prove the capture-and-join logic, not that real native-command capture preserves NUL. The CR-2 guard makes a lost NUL deny.

## Acceptance Criteria

CI-dependent criteria are marked **[CI-dependent]**; they are verified from the PR head CI run and checked off at S9 by the item's orchestrator run.

- [ ] AC-1 (CR-1, B clusters): `Get-PrAuthorDocsOnlyBaseName` returns `$null`, and `Get-PrAuthorDocsOnlyExemption` returns `Exempt = $false` with a Reason beginning `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` without invoking `Invoke-PrAuthorDocsOnlyGitExe`, for every command containing a single-dash token (not `--`) whose characters after the leading dash contain `B` (ordinal, case-sensitive), verified by passing test rows for `-dB other`, `-Bother`, `-B=main`, and the existing `-B` row in `enforce-pr-author-skill.DocsOnly.Tests.ps1` and a zero-invocation row in `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`.
- [ ] AC-2 (CR-1, repository override): the same denial before any git call occurs for a single-dash token containing `R` (`-R o/r`, `-Ro/r`, `-dR o/r`), for a token equal to `--repo` or beginning with `--repo=`, both after the `pr create` subcommand and before it (`gh -R o/r pr create ...`, `gh --repo o/r pr create ...`), and for an inline `GH_REPO=o/r` prefix token in the gh segment, verified by passing test rows in `enforce-pr-author-skill.DocsOnly.Tests.ps1` and a zero-invocation `-R` row in `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`.
- [ ] AC-3 (CR-1, end-to-end): a passing row in `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` drives a `gh pr create ... --repo o/r --base main` command through `Invoke-PrAuthorSkillDecision` and asserts a deny whose reason contains both `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` and `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED`.
- [ ] AC-4 (CR-1, no false denial): `Get-PrAuthorDocsOnlyBaseName` returns `main` for `-d --base main`, `--base main -H feature/x`, `--base main -t Docs`, and the pr-author long-flag shape `gh pr create --title ... --body-file artifacts/pr_body_<N>.md --head <branch> --base main`, verified by passing accept rows; every pre-existing allow row in the DocsOnly suites still passes.
- [ ] AC-5 (CR-1, message): the E3 Reason text produced by `Get-PrAuthorDocsOnlyExemption` for an unresolved base keeps the code `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` and names `--base`, `-B`, `-R`, `--repo`, shorthand clusters containing `B` or `R`, and `GH_REPO=`, verified by reading the hook source.
- [ ] AC-6 (CR-2, guard): when the mocked diff seam returns exit code 0 and non-empty Output that does not end with `[char]0`, `Get-PrAuthorDocsOnlyExemption` returns `Exempt = $false` with a Reason beginning `DOCS_ONLY_EXEMPTION_DIFF_FAILED` whose text names NUL termination; when it returns exit code 0 and empty Output, the Reason begins `DOCS_ONLY_EXEMPTION_EMPTY_DIFF`; both verified by passing rows in `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`.
- [ ] AC-7 (CR-2, seam injection): `Invoke-PrAuthorDocsOnlyGitExe` declares `[ValidateNotNullOrEmpty()][string] $GitCommand = 'git'` and invokes `& $GitCommand -C $WorktreeRoot @GitArgs 2>$null`; neither call site in `Get-PrAuthorDocsOnlyExemption` passes `-GitCommand`; verified by reading the hook source.
- [ ] AC-8 (CR-2, seam rows): `enforce-pr-author-skill.DocsOnly.Tests.ps1` contains passing seam rows that call `Invoke-PrAuthorDocsOnlyGitExe -GitCommand <test-local function> -WorktreeRoot $PSScriptRoot` for the success case (ExitCode 0, Output ending with `[char]0`, fake received `-C`, the root, and the GitArgs in order), the multi-line join case, the non-zero exit case (ExitCode 128), and the throwing case (ExitCode -1, Output `''`); `$global:LASTEXITCODE` is reset per test; and none of the DocsOnly suites contains `Mock git`, `Mock 'git'`, `Start-Process`, temporary-file use, or function named `git`, verified by test pass and text search.
- [ ] AC-9 (CR-2, coverage) **[CI-dependent]**: in the `powershell-coverage.xml` of the Windows CI artifact `poshqc-test-results` for the PR head, the lines of the `& $GitCommand` capture statement, the `$code = $LASTEXITCODE` statement, the catch-block `return $failure`, and the success `return [pscustomobject]@{ ... }` of `Invoke-PrAuthorDocsOnlyGitExe` in `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` each have a covered-instruction count greater than 0, with the run ID and line numbers recorded in evidence.
- [ ] AC-10 (CR-3 pinned, non-goal): the diff `-GitArgs` array in `Get-PrAuthorDocsOnlyExemption` is unchanged from main `f6915d42` (`'diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD')`), and the existing row `runs the diff with -z, --no-renames, --no-relative, and the three-dot range` in `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` passes unmodified.
- [ ] AC-11 (documentation): the docs-only file's comment-based help E3 and E5 rows and the `Get-PrAuthorDocsOnlyBaseName` `.DESCRIPTION` describe the new conditions, the docs-only file header records the ambient `GH_REPO` residual limit, and the `Docs-only` block of the `.claude/hooks/enforce-pr-author-skill.ps1` header describes the B/R shorthand, `-R`, `--repo`, and inline `GH_REPO=` denial and the NUL-termination denial; verified by reading both files.
- [ ] AC-12 (mirrors): `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1` is byte-identical to `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` is byte-identical to `.claude/hooks/enforce-pr-author-skill.ps1`, verified by `cmp -s` or `Get-FileHash` with the result recorded in evidence; and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [ ] AC-13 (PA-N3, commit confirmation): the output of `git show -s --format=%cI ff1b7cbd4 70e58ca84` and of `git show --name-status ff1b7cbd4 70e58ca84 -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence` is recorded under the #927 `evidence/` folder before any #901 evidence row is edited, and every commit-dependent bound applied in AC-14 is derived from those confirmed values.
- [ ] AC-14 (PA-N3, timestamp rows): each file listed in the Design item 6 table has its first `Timestamp:` row set to the upper end of its confirmed bound, followed by `TIMESTAMP_RECONSTRUCTED: true`, `TIMESTAMP_ORIGINAL: <previous value>`, `TIMESTAMP_BOUNDS_UTC: <lo> .. <hi>`, and `TIMESTAMP_DERIVATION: <sources>` rows, except any file whose original value AC-13's confirmed values show is not contradicted, which is left unchanged with the reason recorded in evidence; `p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md` is unchanged; verified by reading each file.
- [ ] AC-15 (PA-N3, unobserved exit code): `p1-poshqc-direct-run.2026-10-12T19-50.md` records `EXIT_CODE: NOT_OBSERVED` and `EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md`, and its Output Summary no longer interprets an exit code of 0; verified by reading the file.
- [ ] AC-16 (PA-N3, no rename): `git diff --name-status main...HEAD -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` lists only `M` entries (no `R`, `A`, or `D`).
- [ ] AC-17 (PA-N2): each item under `## Evidence Checklist` in `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` is `- [x]` with a parenthetical citing its evidence folder or file (baseline: `evidence/baseline/`; targeted verification: `evidence/qa-gates/` and `evidence/regression-testing/`; end-state: `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` and the PR #924 merge at `e467c693`).
- [ ] AC-18 (toolchain): PoshQC MCP format and analyze report no findings for the edited hook files and each of the DocsOnly suites, and PoshQC MCP test reports a pass for each of the DocsOnly suites, with results recorded in evidence.
- [ ] AC-19 (CI test pass) **[CI-dependent]**: the PR head CI run reports success for the Windows `PowerShell QC` job and the Linux `PowerShell hook suites (Linux)` job.
- [ ] AC-20 (file size): every edited `.ps1` file (canonical hooks, mirrors, and each of the DocsOnly suites) is under 500 lines, verified by line count recorded in evidence.
- [ ] AC-21 (coverage threshold) **[CI-dependent]**: in the Windows CI coverage XML for the PR head, line coverage of `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and of `.claude/hooks/enforce-pr-author-skill.ps1` is each at least 85%, with the counters recorded in evidence.
- [ ] AC-22 (scope): `git diff --name-only main...HEAD` lists no file under `.codex/`, no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1` (canonical or bundled), and no `pack-manifests/core.json`.

## Risks & Mitigations

- False denials from the letter rule: a value-taking shorthand followed by inline text containing `B` or `R` (for example `-tBump`) or a dash-leading value token (for example `--title "-Rework"`) denies the exemption. Mitigation: the sanctioned pr-author shape uses long flags only (AC-4); denial falls back to the normal checkpoint requirement, which is the fail-closed direction.
- Ambient `GH_REPO` remains undetectable from command text. Mitigation: documented as a residual limit in the hook header (AC-11); the exemption still requires an absent checkpoint and a docs-only diff against the local repository's `origin`.
- Seam rows do not prove real NUL preservation. Mitigation: the CR-2 guard denies when NUL is absent (AC-6).
- The PR-context evidence collector (`scripts/dev_tools/pr_context/verification_evidence.py`) will classify `p1-poshqc-direct-run.2026-10-12T19-50.md` as unparseable after `EXIT_CODE: NOT_OBSERVED`. This is the accurate state of that record and is accepted.
- Cited commit times may differ from the confirmed values. Mitigation: AC-13 requires confirmation before edits and AC-14 derives bounds from confirmed values.
- Coverage figures cannot be read from PoshQC MCP results. Mitigation: AC-9 and AC-21 use the Windows CI artifact.

## Rollout & Follow-up

- Release: ships with the next extension build through the bundled mirror; the canonical hook takes effect on merge.
- Follow-up: none planned. Ambient `GH_REPO` detection is out of scope by decision.
- Links: issue #927; parent #901; PR #924; research `research/research.2026-10-15T11-52.md`.
