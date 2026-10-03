# Remediation Inputs (Issue #824)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-03T10-30
**Feature folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `90566dd4b1fa172cf6b559c79a2cb392211c6498`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Blocking finding count:** 1
**Remediation plan target:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-03T10-30.md` (to be authored by `atomic-planner`)

## Audit Artifacts

- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/policy-audit.2026-10-03T10-30.md` (Section 8, G-1)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/code-review.2026-10-03T10-30.md` (Findings Table, CR-1; advisory CR-2)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/feature-audit.2026-10-03T10-30.md` (27 PASS, 1 PARTIAL AC-14, 1 pending-CI AC-27, 0 FAIL)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8: the code review contains a Blocker (CR-1), and AC-14 is PARTIAL. Toolchain checks pass and coverage meets every file-level threshold.

## Findings

### R1 — Token-aware R2 matcher no longer detects five wrapped bypass forms

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction is confined to the pure matcher module hook-command-raw-invocation.ps1 (four byte-identical copies) and new Pester rows; every reproduction string is recorded below, and no external system, policy change, or human decision is involved.

**Problem.** `Get-CommandLineRawInvocationPattern` requires exactly one token (literal or single expansion) per subcommand position, separated by `\s+`. The reviewer reproduced the forms below through `Invoke-PromotionMcpOnlyDecision` (Claude envelope `{tool_name, tool_input.command}` and Codex mapped envelope `{command}`) and `Invoke-EpicWorktreeRemovalGateDecision` (checkpoint seams returning null). Each is denied at the merge base `f6ef5b2f` and allowed at head `90566dd4`, on both runtimes. The control `gh issue create --title x` is denied at both commits.

| ID | Command (verbatim) | Hook | Base | Head |
|---|---|---|---|---|
| B1 | `bash -c 'cmd="issue create"; gh $cmd'` | promotion (Claude, Codex) | deny | allow |
| B2 | `pwsh -c '$a = "issue","create"; gh @a'` | promotion (Claude, Codex) | deny | allow |
| B3 | `bash -c 'args=(issue create); gh "${args[@]}"'` | promotion (Claude, Codex) | deny | allow |
| B4 | `bash -c "gh issue \` followed by a newline, then `create"` (PowerShell: `'bash -c "gh issue \' + "`n" + 'create"'`) | promotion (Claude, Codex) | deny | allow |
| B5 | `bash -c 'a="worktree remove"; git $a ../x'` | epic worktree-removal gate (Claude) | deny | allow |

Issue requirement 4 says "Do not weaken detection of real bypasses". AC-14 states that detection of real bypasses caught by raw containment "is not weakened". B5 lets a real worktree removal past the gate that protects active worktrees.

**Required fix (in `hook-command-raw-invocation.ps1`; copy byte-identically to `.codex/hooks/` and both extension mirrors):**

1. Separator: accept a backslash-newline continuation as whitespace between positions (a repeated group whose alternatives are one whitespace character or a backslash followed by an optional carriage return and a line feed, in place of `\s+`), so B4 matches.
2. Trailing expansion absorption: when the command word matched as a literal, allow one expansion or splat token to stand in for all remaining subcommand positions. Tokens are `$name`, `${...}`, `$(...)`, a backtick span, `@name`, and `@(...)`, optionally quoted. Count the match only if each remaining subcommand literal also occurs token-bounded (`(?<![\w-])word(?![\w-])`) somewhere in the raw text. This covers B1, B2, B3, and B5 without reintroducing the #824 false positive, because the reproduction has no token-bounded `gh`.
3. Keep every existing row green. In particular, the reproduction (P824-A1), P824-A2, P824-A3, A824-PR1, A824-WT1 (both gates), A824-VB1, A824-PI1, R824-N1..N7, and N824-1 must still pass unchanged.
4. Keep `hook-command-raw-invocation.ps1` under 500 lines and the public signature of `Test-CommandLineRawInvocation` unchanged.

**Required tests (tag `Issue824`, both runtimes where the suite exists):**

- Unit rows in both `hook-command-raw-invocation.Tests.ps1` files: B1-B5 raw texts classify (`$true`). Add a negative row showing that absorption requires the remaining literals: `gh $x` alone with `issue` and `create` absent does not classify for `issue create`.
- Promotion suites (`enforce-promotion-mcp-only.TriggerScoping.Tests.ps1`, `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1`): deny rows for B1-B4 asserting `Get-PromotionMcpOnlyGhIssueBlockedReason`.
- Worktree suites (Claude epic, Claude parallel, Codex epic): deny row for B5.

**Verification commands:**

- `Invoke-Pester` with `-TagFilter Issue824` on the 17 affected suites, then the full `Invoke-PoshQCTest -Root .` with coverage. The raw-invocation modules must stay at or above 85% lines with no uncovered changed line.
- `Invoke-PoshQCFormat -Root .` (no rewrite) and `Invoke-PoshQCAnalyze -Root .` (zero findings).
- `sha256sum` across the four copies of `hook-command-raw-invocation.ps1` (one distinct hash).
- `poetry run pytest` on the four parity files named in AC-24.
- Fail-before evidence: run the new B1-B5 rows against head `90566dd4` and record that they fail; record pass-after under `evidence/regression-testing/`.

**AC impact:** AC-14 is re-checked by the reaudit when the five forms are denied on both runtimes.

## Advisory Items (do not gate the exit condition)

- **A1 / CR-2 (Minor), recommended in the same change.** A command-position expansion followed by literal subcommands classifies even when the command word never occurs: `pwsh -c 'Write-Output "$prefix issue create"'` (promotion, now denied) and `pwsh -c 'Write-Host "$path worktree remove"'` (epic worktree gate, now denied). Both were allowed at the merge base. Suggested rule: accept the command-position expansion only if the command word occurs token-bounded elsewhere in the raw text (as in `c=gh; $c issue create`). Add allow rows for both.
- **A2 / G-2.** Repo-wide PowerShell line coverage is 84.72% (merge base 84.67%). The cause is `.codex/scripts` and `scripts/dev-tools`, which this branch does not touch. Recommend a follow-up potential record; no action in this cycle.
- **A3 / G-3.** File the six spec Non-Goals follow-ups as potential records.

## Do Not Do

- Do not reword or delete existing tests or assertions to make them pass; AC-16 and AC-29 forbid assertion edits.
- Do not restore `Test-CommandLineRawContainment` as a classification path, and do not route any R2 match to a weaker outcome.
- Do not change hook entry-point decision logic, deny reason strings, `.claude/settings.json`, or hook registration.
- Do not modify `.claude/rules/` or `.github/instructions/`.
- Do not edit `spec.md` criterion text; only AC-14's checkbox changes, and only at reaudit.
- Do not expand scope to the spec Non-Goals items (`gh api` write-surface gaps, `sudo`, unquoted backslash continuation outside wrappers, validate-bash Leg 1).
