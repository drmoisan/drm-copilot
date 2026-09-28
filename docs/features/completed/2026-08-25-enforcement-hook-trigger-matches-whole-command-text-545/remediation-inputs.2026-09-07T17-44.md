# Remediation Inputs — enforcement-hook-trigger-matches-whole-command-text (#545)

**Timestamp:** 2026-09-07T17-44
**Authored by:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
**Head Branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` @ `77cb427df4e219dc2603fad791b8669eaf96629b`

## Pointer to the audit artifacts that produced these findings

- `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/policy-audit.2026-09-07T17-44.md` — §8 findings G-1 through G-9, §10 verdict
- `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/code-review.2026-09-07T17-44.md` — findings table CR-1 through CR-10
- `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/feature-audit.2026-09-07T17-44.md` — AC evaluation, the two adjudications, and the AC-09 check-off change

## Why remediation is triggered

Two of the SKILL's trigger conditions are met:

- The policy audit contains a **FAIL** row (Deny-side behavioral preservation, §7 and §8 G-1).
- Required acceptance criteria are **PARTIAL** (AC-07, AC-09, AC-22).

Not triggered by: coverage (95.4618% repo-wide, 18/18 files ≥ 85%, new files 96.77–100%), toolchain
(format, lint, test all clean in a single pass), evidence locations (validator exit 0), parity (all 18
pairs byte-identical), file size (max 500), or the `modified-workflow-needs-green-run` rule (no
workflow path modified).

## Handoff note

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the remediation **plan** is authored
by `atomic-planner`, not by this reviewer. This artifact supplies the enumerated fix list, the
do-not-do list, and the audit pointers that the planner consumes. This reviewer did not author a plan
file, and did not modify source code — only the single AC checkbox change recorded in the feature
audit's check-off section.

---

## Remediation-required findings

### R-1 — Restore the wrapper carve-out for the `validate-bash.ps1` denylist. **Blocking.**

**Files (all four copies must change identically):**

- `.claude/hooks/validate-bash.ps1`
- `.codex/hooks/validate-bash.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`

**Location:** `Get-BlockedPatternMatch`, leg 1, lines 146–151 in each copy.

**Current behavior (defect).** Leg 1 splits each of the six byte-unchanged literals from
`Get-BlockedBashPattern` into whitespace-delimited tokens and looks for that sequence as a contiguous
run inside `$segment.Tokens`. Because `ConvertTo-CommandLineToken` collapses a balanced quoted span
into a **single token**, a multi-token literal can never match inside a wrapper's quoted argument. The
scanner computes the wrapper carve-out correctly into `$segment.ScanText` — `IsWrapperLed` is `$true`
and `ScanText` equals `RawText` — but leg 1 never reads that field.

Traced for `bash -c "rm -rf /tmp/x"`:
- `Tokens` = `['bash', '-c', 'rm -rf /tmp/x']`
- pattern tokens for `'rm -rf'` = `['rm', '-rf']`
- candidate runs `['bash','-c']` and `['-c','rm -rf /tmp/x']` — neither matches
- leg 2 (`Get-BlockedStructuralGitMatch`) tests only `git push` / `git reset`, so it does not apply
- result: `$null` → **allow**

Before this change the same input returned `'rm -rf'` via `$Command.Contains('rm -rf')` → **deny**.

**Expected behavior.** The six denylist literals must continue to match inside a wrapper-led or
live-substitution segment, exactly as spec D3 rows 2 and 4 state ("deny — wrapper carve-out scans
raw"), while the intended over-match fix is preserved: `git commit -m "docs: explain why rm -rf is
banned"` must still allow, because that segment is **not** wrapper-led and its quoted span is masked.

**Suggested shape** (the planner may choose a different implementation with the same observable
behavior):

Inside the existing `foreach ($pattern …) { foreach ($segment …) { … } }`, add a second condition
alongside the token-run test:

```powershell
if (Test-BlockedPatternTokenRun -Token @($segment.Tokens) -PatternToken $patternTokens) {
    return $pattern
}
if (($segment.IsWrapperLed -or $segment.HasLiveSubstitution) -and
    $segment.ScanText.IndexOf($pattern, [System.StringComparison]::Ordinal) -ge 0) {
    return $pattern
}
```

Constraints on the fix:

- **Leg 1 must still be evaluated in full, over every literal and every segment, before any leg 2
  evaluation.** This ordering is what keeps `git push origin --force` returning the literal
  `'git push origin --force'` rather than leg 2's `'git push --force'`, which
  `tests/scripts/claude-hooks/validate-bash.Tests.ps1:29` asserts.
- The six literals returned by `Get-BlockedBashPattern` must stay **byte-unchanged** (AC-31, rule R2).
- Use `Ordinal` or `OrdinalIgnoreCase` consistently with the pre-change `String.Contains` semantics;
  the pre-change call was culture-insensitive `Contains`.
- The Codex copy has no `cd`-chain rule; do not add one.

**New pinning cases required — three per side, six total.** Add to
`tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` and
`tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`:

| Input | Expected |
|---|---|
| `bash -c "rm -rf /tmp/x"` | `'rm -rf'` |
| `sh -c 'git reset --hard'` | `'git reset --hard'` |
| `pwsh -NoProfile -Command "Remove-Item -Recurse -Force build"` | `'Remove-Item -Recurse -Force'` |

Plus one negative per side confirming the over-match fix is not regressed:

| Input | Expected |
|---|---|
| `git commit -m "docs: explain why rm -rf is banned"` | `$null` (already asserted; must still pass) |

**Verification commands:**

```
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test   # scan_folders: tests/scripts/claude-hooks, tests/scripts/codex-hooks
```

Confirm from `artifacts/pester/pester-junit.xml`, per suite:
- `validate-bash.Tests.ps1` — **26 cases, 0 failures** (the six existing denylist pins and eight existing `cd`-chain pins must remain green)
- `validate-bash.TriggerScoping.Tests.ps1` — 7 existing + 4 new cases, 0 failures
- `validate-bash-decision-surface.Tests.ps1` — 0 failures
- `validate-bash-trigger-scoping.Tests.ps1` — existing + 4 new cases, 0 failures

Then re-establish parity and coverage:

```
# byte parity, canonical vs bundle, both runtimes
cmp -s .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
cmp -s .codex/hooks/validate-bash.ps1  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1

# line cap
wc -l .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1     # must remain <= 500

# coverage (route substitution: the MCP runner cannot see this branch's CodeCoverage.Path entries)
gh workflow run .github/workflows/_poshqc.yml
gh run watch <run-id>
# .claude/hooks/validate-bash.ps1 must stay >= 85% (was 94.3182%)
# .codex/hooks/validate-bash.ps1  must stay >= 85% (was 100.0000%)
```

**Acceptance criterion this closes:** AC-09 (`spec.md` line 1488) — re-check the box only after the six
new cases pass and the existing 26 + 7 Claude cases remain green.

---

### R-2 — Amend AC-07 to record the D12 supersession. **Non-blocking, documentation only.**

**File:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`, acceptance criterion at line 1480.

**Current state (defect).** AC-07 requires "the pr-author hook's `gh pr create` / `gh pr edit`
expressions" be byte-unchanged. The same document's D12 "Call-site rewrites for the D11 hooks" table
directs `enforce-pr-author-skill-helpers.ps1 L170–171` to `Test-CommandLineInvocation`, which takes no
pattern operand, and AC-31 independently requires `Test-EpicBaseBranchOverride` to do the same. The
three literals are therefore necessarily deleted. The criterion cannot be satisfied by any
implementation that conforms to D12 and AC-31.

**Expected behavior.** Amend AC-07 so it states the surviving obligation accurately. The byte-unchanged
requirement holds — and is verified — for:

- the five preimplementation-gate trigger pattern strings (4 copies)
- the promotion hook's four forbidden-token literals (4 copies)
- the promotion hook's `gh issue create/new` expression string (4 copies)
- the promotion hook's `$ghApiIssuesPostPattern` declaration line (4 copies)
- the six `validate-bash` denylist literals (4 copies)
- `$script:CdChainedReadCommandPattern` (2 copies)
- the two abandon token constants (2 copies)

Add a sentence recording that the pr-author `gh pr create` / `gh pr edit` expressions are **superseded**
by the D12 call-site rewrite table and by AC-31, and cite
`evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` §4 as the supporting record.

**Do not change any code for this item.** The implementation is correct; the criterion is not.

**Verification command:**

```
git diff 6dff80ed4596bec088d548b23013e6077e32c484..HEAD -- '*.ps1' > /tmp/full.diff
grep -E "^-" /tmp/full.diff | grep -E "<each retained literal>"    # must return nothing
```

**Acceptance criterion this closes:** AC-07 (`spec.md` line 1480).

---

### R-3 — Include the issue #591 supersession in the PR body. **Non-blocking; gate condition on `pr-author`.**

**Not remediable by a code change.** The supersession text already exists at
`evidence/issue-updates/issue-591.2026-09-07T15-41.md` (currently `PostedAs: unknown`), and the
"no separate follow-up candidate" clause is already satisfied — `docs/features/potential/` contains
exactly the two D11.6 entries, neither of which is a #591 instance.

**Action:** when `pr-author` runs, the PR body must state the supersession and name issue #591. Then
check off AC-22 (`spec.md` line 1554) and update `PostedAs:` in the evidence artifact.

---

## Recommended follow-ups — file, do not fix in this cycle

These are recorded so they are not lost. None blocks the PR.

| ID | Finding | Why not fixed here |
|---|---|---|
| F-1 | Leaf-of-path wrapper resolution: `/bin/bash -c 'git add .'` and `/usr/bin/env git add .` are not wrapper-led under exact-membership matching, so their argument is masked and no hook classifies. Same class as accepted residual D4.3, but D4.3's justification does not cover an absolute-path spelling of a wrapper that *is* in the set. | AC-05 pins **exact** membership of the 14-name set. A fix requires amending D2 Piece 2 and AC-05 in the same change so the constant, the test, and the spec continue to agree. Out of scope for a remediation cycle. |
| F-2 | `Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath` are now byte-identical copy-pasted bodies in two files. Extract into `hook-command-invocation.ps1` as e.g. `Get-WorktreeRemovalTargetPath` and make both hooks one-line delegations, preserving their names, signatures, and `$null`-on-miss contracts. | A refactor, not a defect fix. The pinning cases at `enforce-epic-worktree-removal-gate.Tests.ps1:136,141` and `enforce-parallel-worktree-removal-gate.Tests.ps1:78` would be unaffected, but the change touches four files for no behavioral gain in this cycle. |
| F-3 | `$script:CdChainedReadCommandPattern` at `.claude/hooks/validate-bash.ps1:204` is write-only — referenced nowhere and pinned by no test — while a parallel live constant `$script:CdChainedReadCommandWords` drives the actual logic. Add a Pester case deriving the word set from the pattern and asserting equality, so the two cannot drift. | Depends on the R-2 decision: if AC-07 is amended to drop the retention obligation, deleting the constant becomes the simpler option. |
| F-4 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` `Context 'allowed commands'` (`BeforeEach` at lines 127–140) does not mock `Get-PrAuthorCheckpointContent`, unlike three sibling contexts at lines 297, 317, 363. It reads the real gitignored `artifacts/orchestration/orchestrator-state.json` and fails locally when that file carries `epic_mode: true`. Fix: add `Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }`. | Confirmed **not** change-caused: the pre-#545 code path yields the identical deny for the identical ambient state. The suite is outside the nine-hook scope D11 defines. Leaving it unfixed was the correct call. |
| F-5 | Epic amendment EA-3: `Test-ChildCheckpointAllowsEpicMerge` (`.claude/hooks/enforce-epic-merge-gate.ps1:177`) takes only `$Checkpoint` and is consulted first, so an `epic_mode` / `step9_status: passed` checkpoint authorizes merging any PR. **Correction to the previously recorded scope:** the Codex sibling is `Test-CodexChildMergeReady` (`.codex/hooks/enforce-epic-merge-gate.ps1:69`, consulted at line 137 with only `-Checkpoint $child`), not `Test-CodexCheckpointAllowsMerge`. Both copies need the fix. | A pre-existing authorization hole that #545 neither introduces nor widens. Fixing it exceeds the nine-hook scope. **Ensure it is carried into the epic's follow-up register**, since its scope grew during execution and it currently lives only in a spec that is about to be archived. |
| F-6 | `enforce-parallel-abandon-gate.ps1` normalizes whitespace (`-replace '\s+', ' '`) **before** segmentation, so newlines are collapsed before `Read-CommandLineSegment` sees the text and this hook cannot recognise a heredoc terminator line. Direction is safe (flattened heredoc → `Unbalanced` → raw scan), but the ordering is undocumented. | Cosmetic/documentation. Either pass the raw `CommandText` to the scanner, or state the ordering in the function help. |
| F-7 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle mirror sit at **exactly 500 lines** — the policy cap, zero headroom. D12 names this hook family as the subject of imminent edits by epic children D and G. | Extract a helper (the mode-routing or exemption-consultation block are natural seams) before the next edit, so child work is not blocked by the cap. |

---

## Do-not-do list

- **Do not weaken any existing denial.** The whole point of R-1 is that one was weakened. Every fix must
  move the deny surface outward or leave it unchanged, never inward.
- **Do not change the six literals returned by `Get-BlockedBashPattern`,** the five preimplementation
  trigger patterns, the four promotion forbidden-token literals, either promotion `gh` expression, the
  two abandon token constants, or `$script:CdChainedReadCommandPattern`. Rule R2 governs the literal
  text; only the comparison primitive and the operand may change.
- **Do not modify policy documents** under `.claude/rules/` or `.github/instructions/`.
- **Do not modify any hook outside the nine in D11's list**, and do not add a tenth hook to the change.
- **Do not fix `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`** or
  `codex-pretooluse-integration.Tests.ps1` in this cycle. Both are ambient-state failures in unmodified
  suites, outside the nine-hook scope, and green on a clean CI checkout. Fixing them here is scope creep
  and would obscure the R-1 signal.
- **Do not fix EA-3 (F-5) here.** File it; its scope spans two merge-gate copies and a checkpoint
  contract change.
- **Do not add a coverage `exclude` entry** for any production path, and do not remove any existing
  `CodeCoverage.Path` entry. The Coverage Exclusion Policy forbids excluding production files; this
  change correctly *added* eight files to the denominator.
- **Do not break canonical/bundle byte parity.** Every edit to a canonical hook must be mirrored
  byte-for-byte into its bundle copy in the same change, and re-verified by `cmp`.
- **Do not exceed 500 lines** in any production, test, or reusable script file.
- **Do not use the MCP test runner for coverage figures.** It resolves runsettings from the installed
  VS Code extension and cannot see this branch's new `CodeCoverage.Path` entries — independently
  confirmed: the local MCP-produced `artifacts/pester/powershell-coverage.xml` contains zero
  `hook-command-scanner` occurrences. Use a `workflow_dispatch` of `.github/workflows/_poshqc.yml`.
- **Do not check off AC-07, AC-09, or AC-22** until their specific closure conditions above are met.
- **Do not silently skip a toolchain stage.** If `pwsh` remains uninvocable, record a
  `TOOLCHAIN_SUBSTITUTION` note naming the substitute route in every affected evidence artifact, as this
  execution correctly did.
- **Do not write evidence outside** `docs/features/active/<feature>/evidence/<kind>/`.

---

## Exit condition for this remediation cycle

The cycle may close when all of the following hold:

1. R-1 is implemented in all four `validate-bash.ps1` copies, with six new pinning cases (three per
   side) passing and the 26 existing `validate-bash.Tests.ps1` cases plus the 7 existing
   `validate-bash.TriggerScoping.Tests.ps1` cases still green.
2. R-2's spec amendment is recorded.
3. Canonical/bundle byte parity re-verified for both changed `validate-bash.ps1` files.
4. PoshQC format → analyze → test completes in a single pass with no restart.
5. Per-file line coverage re-measured via `_poshqc.yml` dispatch; both `validate-bash.ps1` copies
   remain ≥ 85%.
6. AC-07 and AC-09 re-evaluated to PASS and checked off; AC-22 remains open pending `pr-author`.
7. F-1 through F-7 are filed as follow-up entries or carried into the epic register, not fixed here.

Blocking count at the close of this audit: **1** (R-1).
