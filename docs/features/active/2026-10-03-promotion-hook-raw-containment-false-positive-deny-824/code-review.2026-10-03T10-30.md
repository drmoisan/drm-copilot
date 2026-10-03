# Code Review: Token-aware R2 raw invocation matcher (#824)

---

**Review Date:** 2026-10-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its suffix matches issue 824 in the branch name.
**Base Branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `90566dd4b1fa172cf6b559c79a2cb392211c6498`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes the reported false-positive deny by replacing rule R2 of `Resolve-CommandLineInvocation`. R2 classified a wrapper-led or live-substitution segment when the command word and every subcommand element appeared anywhere in the raw text as substrings. It now calls `Test-CommandLineRawInvocation`, which builds a regex requiring a token-bounded, ordered sequence. The regex allows optional `.exe`, quotes, a run of dash options before each element, and a shell-expansion stand-in at any position provided one position matches literally. The change is one new 109-line module per runtime, a one-line call-site edit, and corrected comments, all byte-identical across `.claude`, `.codex`, and both extension mirrors. Tests are well structured: 97 Issue824-tagged rows, a negative control that the reviewer confirmed fails when R2 is reverted, and per-hook regressions for every caller family in the audit record.

The reviewer probed the matcher beyond the AC fixtures, comparing merge-base and head hook decisions through the real decision entry points on both runtimes. The fix removes the reported false positive. It also stops detecting five wrapped bypass forms that raw containment denied, including a real `git worktree remove` through the epic worktree-removal gate. Issue requirement 4 says not to weaken detection of real bypasses, and the general clause of AC-14 says detection is "not weakened", so this is recorded as a Blocker.

**What changed:**
- `.claude/hooks/hook-command-raw-invocation.ps1` and `.codex/hooks/hook-command-raw-invocation.ps1` (new): `Get-CommandLineRawInvocationPattern`, `Test-CommandLineRawInvocation`.
- `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1`: dot-source the module (line 18), call it in R2 (line 211), and correct three comments (AC-22).
- Mirrors, both `pack-manifests/core.json`, `legacy-codex-hook-contracts.Tests.ps1` line 30, and 16 Pester suites.

**Top 3 risks:**
1. Wrapped bypasses that split the subcommand path across one expansion, a splat, or a line continuation are no longer denied by the promotion hook or the worktree-removal gates (CR-1).
2. An expansion in the command position followed by literal subcommands now classifies when no command literal exists anywhere, a new narrow false-positive class (CR-2).
3. The PR has not been opened, so the Windows PoshQC and Linux hook-suite CI jobs (AC-27) have not run.

**PR readiness recommendation:** **Needs Revision** — CR-1 is a verified enforcement regression in hard-deny hooks and should be fixed in the new module before the PR is opened.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/hook-command-raw-invocation.ps1` (and `.codex` copy and mirrors) | `Get-CommandLineRawInvocationPattern`, lines 49-66 | CR-1: The sequence matcher requires one token per subcommand position separated by `\s+`. Five wrapped forms that raw containment denied at the merge base are now allowed on both runtimes: (a) `bash -c 'cmd="issue create"; gh $cmd'`; (b) `pwsh -c '$a = "issue","create"; gh @a'`; (c) `bash -c 'args=(issue create); gh "${args[@]}"'`; (d) `bash -c "gh issue \` + newline + `create"` (bash removes backslash-newline inside double quotes); (e) `bash -c 'a="worktree remove"; git $a ../x'` through the epic worktree-removal gate. | Extend the matcher so that (1) the separator also accepts a backslash-newline continuation, and (2) when the command word matched literally, one expansion or splat token (`$name`, `${...}`, `$(...)`, backtick span, `@name`, `@(...)`) may stand in for the remaining subcommand positions, provided each remaining subcommand literal also occurs token-bounded somewhere in the raw text. Add Issue824-tagged deny rows for (a)-(e) on both runtimes (unit rows plus promotion and worktree-gate rows), and confirm the reproduction, P824-A2, A824-WT1, and A824-PR1 still allow. | The promotion hook and both worktree-removal gates hard-deny on R2. Issue requirement 4 ("Do not weaken detection of real bypasses") and the general clause of AC-14 require no loss of bypass detection. Form (e) removes a worktree past the gate that protects active worktrees. | Reviewer probe at merge base (`git archive f6ef5b2f` of `.claude/hooks`, `.claude/lib`, `.codex/hooks`) and at head, through `Invoke-PromotionMcpOnlyDecision` (Claude envelope and Codex mapped envelope; control `gh issue create` denied on both) and `Invoke-EpicWorktreeRemovalGateDecision` with checkpoint seams returning null: (a)-(d) deny at base, allow at head on both runtimes; (e) deny at base, allow at head. |
| Minor | `.claude/hooks/hook-command-raw-invocation.ps1` (and copies) | lines 55-57, expansion alternative in the command position | CR-2: An expansion in the command position followed by literal subcommands classifies even when the command word never occurs in the text. `pwsh -c 'Write-Output "$prefix issue create"'` is now denied by the promotion hook (allowed at base), and `pwsh -c 'Write-Host "$path worktree remove"'` is now denied by the epic worktree gate (allowed at base). | Allow the command-position expansion only when the command word also occurs token-bounded elsewhere in the raw text (as in `c=gh; $c issue create`), and add an allow row for each example. This can be done in the same change as CR-1. | It is a new false-positive class of the same kind #824 fixes, though narrower than the original. | Reviewer probe, base versus head, both runtimes. |
| Info | `.claude/hooks/hook-command-raw-invocation.ps1` | line 52, `$optionRun` | CR-3: A standalone option can absorb the real subcommand as its "value", so `bash -c "git --no-pager log -S commit"` classifies as `git commit`. Raw containment matched this text too, so this is not a regression, and the only `git commit` caller is the preimplementation gate's checkpoint check. | No action required; optionally add a comment noting the over-classification direction. | Recorded so the behavior is a known property. | Reviewer probe: new `True`, containment `True`. |
| Info | `.claude/hooks/hook-command-raw-invocation.ps1` | whole module | CR-4: Performance is bounded: inputs of 30,000 to 90,000 characters built to stress the option run and repeated prefixes evaluate in 5 ms or less. | None. | Confirms the spec's backtracking claim. | Reviewer probe with n = 1000 and n = 10000 repetitions. |
| Info | `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` | AC-14 | CR-5: AC-14 was checked off by the executor on the strength of its three enumerated cases, which pass. CR-1 contradicts its general clause, so the reviewer grades it PARTIAL and has unchecked it in `spec.md`. | Re-check AC-14 after CR-1 is remediated and reaudited. | Keeps the AC source consistent with verified behavior. | Feature audit AC-14 row. |

One Blocker (CR-1). CR-2 is recommended alongside it but does not block.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix sits in the shared helper, so all 34 resolver call sites in 13 hook files are corrected without per-hook edits. The audit record (`evidence/other/containment-path-hook-audit.md`) inventories them with before and after effects.
- `[regex]::Escape` is applied to the command word and each subcommand, and the pattern is wrapped in a zero-width lookahead so every start index is tried.
- `Test-CommandLineRawContainment` is retained only for the informational `Test-CommandLineMention`, and its documentation now says so (AC-2, AC-22).
- `.claude`/`.codex` and mirror copies are byte-identical (reviewer `sha256sum`: one distinct hash per four-file group).

#### API and safety notes

- Both functions use `[CmdletBinding()]`, `[OutputType()]`, and validated mandatory parameters. Approved verbs. PSScriptAnalyzer reports 0 findings with the repository settings.
- Public signatures pinned by the existing signature tests are unchanged (AC-29).

#### Error handling and logging

- Pure functions with no I/O; no error paths beyond parameter validation. Deny reason strings are unchanged.

---

## Test Quality Audit

The reviewer ran the 17 affected suites with coverage: 359 pass, 0 fail, 97 tagged Issue824. The four parity pytest files pass (27). Format check-only and analyzer runs were clean. The executor's full PoshQC run (6626 tests, 0 failures) and coverage derivation are in `evidence/qa-gates/`.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1` and the Codex copy — 20 positive and 7 negative rows per runtime. Gap: no row for multi-word expansion, splat, or wrapped continuation (CR-1).
- `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` and the Codex copy — N824-1 negative control. The reviewer simulated the revert in-process (redefining `Test-CommandLineRawInvocation` as containment), and `Test-CommandLineInvocation` returned `True`, so the test discriminates.
- Promotion trigger-scoping suites (both runtimes) — AC-5 to AC-14 rows assert the exact deny reason from `Get-PromotionMcpOnlyGhIssueBlockedReason`.
- Per-hook suites (pr-author, epic and parallel worktree gates, validate-bash, preimplementation, epic merge) — one allow or route row per audited false-positive class.
- `evidence/regression-testing/expect-fail-issue824.2026-10-03T09-51.md` and `pass-after-issue824.2026-10-03T09-57.md` — fail-before and pass-after JUnit records.
- `evidence/qa-gates/coverage-delta.2026-10-03T10-13.md` — reproduced by the reviewer from `artifacts/pester/powershell-coverage.xml`.

### Quality assessment prompts

- **Determinism:** literal strings only; no clock, process, network, or temporary file.
- **Isolation:** one behavior per row; checkpoint seams mocked to null.
- **Speed:** 359 tests with coverage in under two minutes.
- **Diagnostics:** `-Because` text names the expected sequence; row labels identify the spelling.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation; regex built from escaped literals. |
| Input validation at boundaries | ✅ PASS | Mandatory parameters; `ValidateNotNullOrEmpty` on the subcommand path. |
| Enforcement hooks preserve bypass detection | ❌ FAIL | CR-1: five wrapped bypass forms now allowed (merge base denied them). |
| Fail-closed for unresolvable segments | ✅ PASS | R1 Unbalanced still classifies before R2; P824-D11 on both runtimes. |
| Regex backtracking bounded | ✅ PASS | CR-4 probe. |

---

## Research Log

No external research was required. Shell semantics used in CR-1 (bash backslash-newline removal inside double quotes, word splitting of an unquoted expansion, PowerShell array splatting with `@name`) are standard documented behavior of bash and PowerShell.

---

## Verdict

The implementation is clean, well documented, consistent across runtimes, and fully tested against its enumerated acceptance criteria. It fixes the reported false positive and the related false positives in every audited caller family. It is not ready for PR because CR-1 shows a verified loss of bypass detection in hard-deny enforcement hooks, which the issue explicitly prohibits. The fix is confined to `hook-command-raw-invocation.ps1` (four byte-identical copies) and new test rows. After remediation and a clean reaudit, the branch should proceed to PR and the S9 CI gate for AC-27.
