# Code Review: Regenerate path after an integration merge (#1156)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/regenerate-after-integration-merge-1156`
**Feature Folder Selection Rule:** named by the caller; matches branch `feature/regenerate-after-integration-merge-1156` and issue #1156
**Base Branch:** `main` (resolved `origin/main` at `2c8dee6dd3a82f210561d9efe623767ae902de51`, equal to the merge base)
**Head Branch:** `feature/regenerate-after-integration-merge-1156` at `6bb6365d1bf4aafcbc958ebf2b9e295a22dc1a90`
**Review Type:** Re-audit after remediation cycle 1 (prior set `*.2026-11-14T04-29.md`, findings R1 and R2)

---

## Executive Summary

The re-audit covers the full branch diff from the merge base `2c8dee6dd` to the head `6bb6365d1` (148 files, 13582 insertions, 49 deletions), with particular attention to the cycle 1 changes and the third merge of `origin/main`.

R1 is closed: `quality-tiers.yml` classifies `.claude/lib/regeneration` as T3 next to the other `.claude/lib/*` runtime libraries, and the reviewer's run of `scripts.dev_tools.check_quality_tiers` at the head reports `quality-tiers: OK (34 entries, 34 discovered projects)` with exit 0.

R2 is closed: the `-Invoker` default of `Invoke-RegenerationProcess` now resolves `argv[0]` through `Resolve-RegenerationExecutable` (one `Get-Command -CommandType Application` pipeline in its `-Resolver` default, so PATHEXT applies on Windows) and builds the start from `Get-RegenerationProcessStartSpec`, which routes a resolved `.cmd` or `.bat` file through `ComSpec` with `/d`, `/c`, the path, and each argument as its own `ArgumentList` item. An unresolvable name throws `executable <name> cannot be resolved`; the rest of AD-1 (no `UseShellExecute`, asynchronous reads of both streams before `WaitForExit`, forwarding to `[Console]::Error`, one `[int]` result) is unchanged. The executor's probe shows `npm --version` returning one Int32 equal to 0 through `npm.cmd`; the reviewer's probe confirms batch paths with spaces and parentheses, argument pass-through for `%*` shims, refusal of `%`, and a direct `.exe` exit code.

The third main sync (`6bb6365d1`) is a clean merge: its tree equals the `git merge-tree` result of its parents, so no hand resolution occurred. The only overlap with main's #1175 change is the six execution-environment brief copies and the two pack manifests; the six copies share one SHA-256, the manifests parse and keep both sides' entries, all 21 source and bundle pairs are byte-identical, and both frozen-surface digests equal the SHA-256 of the current files. The reviewer ran one `Invoke-PoshQCParallelTest` gate at the merged head (the merge changed 68 PowerShell files after the executor's final gate); it passed with 24724 tests, 0 failures, and 95.94% repo-wide PowerShell lines (`evidence/qa-gates/pester-gate.2026-11-14T06-14.md`).

No blocking finding remains. Two Minor findings and one test-gap Minor are recorded below as non-blocking.

**What changed:**
Since the prior review: one `quality-tiers.yml` entry; two new adapter functions and a rewritten process `-Invoker` default in `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` and its bundle copy; updated AST checks (h) in `Invoke-RegenerationPath.Tests.ps1`; a new suite `Invoke-RegenerationPath.ProcessStart.Tests.ps1` (17 cases); one extended `command` bullet in `spec.md`; cycle evidence; and the merge of `origin/main` at `2c8dee6dd` (#1175).

**Top 3 risks:**
1. The resolved batch path itself is not screened for cmd.exe metacharacters; a PATH directory or declared path holding `&` or `%` makes cmd.exe run a different command line (Minor, CR-3; reviewer probe).
2. The Windows batch-argument restriction is stated in the spec and the function help but not in the orchestrate skill config rules or the rules-file config rules, where a destination repository author reads the config contract (Minor, CR-4).
3. `Invoke-RegenerationPath.ps1` is 788 logical lines, 12 below the 800-line hard limit (Warning).

**PR readiness recommendation:** **Ready with nits** — R1 and R2 are closed; the remaining items are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Get-RegenerationProcessStartSpec` (argument screen) and its bundle copy | CR-3: the screen for whitespace, a double quote, and `&`, `^`, `%`, parentheses, and the redirection and pipe characters applies to each argument but not to `ResolvedPath`. .NET quotes a path containing a space, and cmd.exe keeps that quoted path intact (probe: `p q` and `p (x86)` work). A path holding `&` or `%` is not protected: with `a&b` cmd.exe split the line and tried to run `b\bin\echoargs.cmd` relative to the working directory, and with `pct%OS%` it expanded the variable; both returned exit 1. | Apply the same refusal to `ResolvedPath` for `"`, `&`, the pipe and redirection characters, `^`, and `%` (whitespace and parentheses are safe when quoted), add one case per character class to `Invoke-RegenerationPath.ProcessStart.Tests.ps1`, and copy the file to the bundle. The fix adds about two lines (788 to about 790). | The declared argv and PATH are repository-controlled, so this grants no new capability, and the usual outcome is a non-zero exit and a fallback; but the function's own contract (input reaches the batch file unchanged or the start is refused) does not hold for the path. | `evidence/other/process-start-probe.2026-11-14T05-56.md` |
| Minor | `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md` | `## Merge-Conflict Remediation` item 2; config-rules paragraph of the regeneration section | CR-4: the cycle 1 spec edit states that `argv[0]` resolves through PATH and PATHEXT, that a `.cmd` or `.bat` runs through `ComSpec /d /c`, and that a batch argument with whitespace, a quote, or a cmd.exe metacharacter is refused. The skill and rules text list only the validation rules and say nothing about execution, so they do not contradict the spec, but an author who declares `["npm","run","gen","--","--out","a b"]` learns of the Windows refusal only from a fallback. | Add one sentence to item 2 of the skill and to the rules-file config paragraph (and their bundle copies) stating the resolution and the batch-argument refusal; pin it in `regeneration-path-skill-contract.Tests.ps1`. | Documentation completeness for the config contract; the refusal itself is safe (start failure, exit 1, fallback). | Diff inspection of spec line 67, skill item 2, rules config paragraph |
| Minor | `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1` | `throws for a batch argument holding <Label>` | The refusal cases cover a space, a double quote, and `&` only. A mutant that drops `%`, `^`, a parenthesis, or a pipe or redirection character from the character class would pass the suite. | Extend the `-ForEach` table to one row per character in the class (`%`, `^`, `(`, `)`, `<`, `>`, and the pipe), plus a tab. | Pins the full refusal set that the spec names. | File inspection; the reviewer's real-process probe confirms `%` is refused at the head |
| Warning | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 788 logical lines (700-line advisory tier; 800-line hard limit). | Do not add further logic to this file; a later split of the Merge and Tip flows into a module would bring it below 700. | File-size advisory tier. | `@(Get-Content -LiteralPath <path>).Count` = 788 |
| Warning | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 788 logical lines (byte copy of the source). | Same as above. | File-size advisory tier. | `@(Get-Content -LiteralPath <path>).Count` = 788 |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Resolve-RegenerationExecutable` `-Resolver` default | `Get-Command -Name` treats `*`, `?`, and `[` as wildcards, so an `argv[0]` holding them resolves to the first matching application. | No change required; optionally pass the name through `[WildcardPattern]::Escape`. | Declared argv is repository-controlled; no such name is plausible for a generator. | Diff inspection |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Get-RegenerationProcessStartSpec` | cmd.exe treats `=`, `,`, and `;` as batch parameter delimiters, so `--x=1` reaches `%1` and `%2` as `--x` and `1`, while `%*` keeps it unchanged. npm.cmd and npx.cmd forward `%*`. | No change required. | Behavior recorded for completeness. | `evidence/other/process-start-probe.2026-11-14T05-56.md` |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Invoke-RegenerationMergeFlow`, `Invoke-RegenerationTipFlow`, `Invoke-RegenerationTipRestore` | Carried from the prior review: no `SupportsShouldProcess` on the state-changing adapter functions, consistent with the other orchestration entry points. | Non-blocking. | `.claude/rules/powershell.md` ShouldProcess guidance. | Diff inspection |

No Blocker or Major finding.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Unchanged since the prior review: test-only edits (an in-place digest re-baseline, a fixture-acceptance test, and a handoff-projection test). Both pinned digests still equal the current files after the third merge.

#### Typing and API notes

- No new public Python API surface.

#### Error handling and logging

- No production Python code changed.

### TypeScript implementation audit

#### What changed well

- Unchanged since the prior review: one appended validator case in `epic-orchestrator-state-core.test.ts`.

#### Type safety and maintainability

- No production TypeScript changed; the third merge touched no `.ts` file.

#### Error handling and logging

- Not affected.

### PowerShell implementation audit

#### What changed well

- The R2 fix keeps all system access in one seam default: `Resolve-RegenerationExecutable` reads PATH only through its `-Resolver` default, and `Get-RegenerationProcessStartSpec` is pure and takes `ComSpec` as a parameter, so both are unit tested without a process, a PATH read, or an environment write.
- The `-Invoker` default calls the two functions without a call operator on a variable, so the no-Python guard still passes (35/0 in the executor's gates) and AST check (h) pins the new shape: exactly two commands, `-ComSpec` bound to `$env:ComSpec`, one `ArgumentList.Add` inside the loop over the spec list, two `ReadToEndAsync`, one `WaitForExit`, and one `ExitCode` read.
- Failure handling is unchanged in kind: a throw from resolution or from the spec reaches `Invoke-RegenerationProcessStep`, which reports `Started = $false` with a null exit code; both paths have a direct case.
- stdout stays clean: the probe stdout held only the probe's own lines, and the child output went to stderr.
- The bundle copy is byte-identical to the source (equal SHA-256, and `cmp` over all 21 pairs).

#### API and safety notes

- Batch argument handling is bounded: an argument holding whitespace, a double quote, or one of `&|<>^%()` is refused before the start, which removes argument-borne metacharacter injection. The resolved path is not screened (CR-3).
- On Linux `ComSpec` is unset, and only a resolved `.cmd` or `.bat` path reaches the `ComSpec` check, so Linux behavior is unchanged.

#### Error handling and logging

- Resolution and refusal errors carry the executable name or the refused argument in the message.

---

## Test Quality Audit

The new suite tests the pure spec function on literal paths (`.exe`, extensionless, `.cmd`, `.BAT`, a path with a space), both ComSpec failure forms, three refused argument classes, the resolver contract (returned path, name passed unchanged, null and empty results), and the two failure paths through `Invoke-RegenerationProcessStep`. The AST check (h) for the process default was rewritten to the new shape and remains as strict as before (it pins the command set and every start statement). The refusal table covers three of the nine refused character classes (Minor above). Per OD-4, the reviewer ran no single-file test run; discrimination was judged by inspecting the suite and by the real-process probes.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1` — 17 cases, 113 logical lines.
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` — 123 cases including the rewritten and added (h) checks, 602 logical lines.
- `evidence/other/process-start-probe.2026-11-14T05-00.md` — executor probe: `npm` resolves to `npm.cmd`, one Int32 equal to 0; an unresolvable name throws.
- `evidence/other/process-start-probe.2026-11-14T05-56.md` — reviewer probe of batch-path and argument edge cases.
- `evidence/qa-gates/phase-gate.P1.2026-11-14T05-28.md`, `evidence/qa-gates/pester-final.2026-11-14T05-44.md`, `evidence/qa-gates/pytest-final.2026-11-14T05-49.md`, `evidence/qa-gates/powershell-final-qc.2026-11-14T05-29.md` — executor gates before the third merge.
- `evidence/qa-gates/pester-gate.2026-11-14T06-14.md` — the reviewer's Pester gate at the merged head.

### Quality assessment prompts

- **Determinism:** literal paths and ComSpec values; injected resolvers; mocks only for the two new functions.
- **Isolation:** one behavior per case.
- **Speed:** no process start in tests.
- **Diagnostics:** expected-message wildcards name the failure class.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | One `ArgumentList` item per argument; batch arguments with cmd.exe metacharacters are refused; no `Invoke-Expression` and no `Start-Process`. The unscreened batch path (CR-3) needs a repository-controlled path holding `&` or `%` and grants no capability beyond the declared argv. |
| Input validation at boundaries | ✅ PASS | Config rules 1 to 9 before any git call; unresolvable names throw; batch-argument refusal. |
| Error handling remains explicit | ✅ PASS | Resolution and start failures map to `Started = $false`, exit 1, and the fallback. |
| Configuration / path handling is safe | ✅ PASS | Relative `-ConfigPath` only; the config file is never bundled. |

---

## Research Log

No external research was required. cmd.exe quoting and delimiter behavior was confirmed by direct execution on the review host (`evidence/other/process-start-probe.2026-11-14T05-56.md`).

---

## Verdict

R1 and R2 are closed with code, tests, a spec update, and real-process evidence, and the third main sync is a clean, neutral merge whose mirrors, manifests, brief copies, and pinned digests are consistent. The remaining findings (CR-3, CR-4, the refusal-table test gap, the 788-line Warning, and three Info rows) are non-blocking. Under OD-6 the orchestrator may fold CR-3, CR-4, and the test gap into this item before merge; CR-3 and the test gap together add about two production lines and fit under the 800-line limit.
