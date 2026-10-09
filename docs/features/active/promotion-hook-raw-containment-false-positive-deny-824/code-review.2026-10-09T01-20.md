# Code Review: Structural command-invocation matcher (#824, bundles #742 and #733)

---

**Review Date:** 2026-10-09
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its suffix matches issue 824 in the branch name.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (tip `1f30667b`; merge base `991aae0a`)
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (local `c1a-824-resume`, head `6ecc591c`)
**Review Type:** Initial review (S6)

---

## Executive Summary

The branch replaces the substring-containment fallback (`Test-CommandLineRawContainment`, removed) on the command-classification path with a structural, payload-aware matcher. `Read-CommandLineInvocationSegment` produces one record per command visible in a command line, including POSIX wrapper payloads, PowerShell payloads parsed with `Parser.ParseInput`, double-quoted substitution bodies, and xargs-injected commands. `Get-CommandLineInvocation` classifies each record Structural, Indeterminate, or no match, with a whole-token presence fallback that is suppressed only when the payload is proven inert through a fixed sink allowlist. The three worktree-removal gates authorize every derived target through `Resolve-CommandLineInvocationTarget` and deny Indeterminate with the existing `TARGET_WORKTREE_NOT_DERIVABLE` detail. The pr-author skill hook reads `--body-file` structurally and normalizes it behind a single session-root seam. A new per-segment allowlist hook is registered in the pr-author agent frontmatter.

Evidence reviewed: the full diff against the epic integration branch (143 files), the regenerated PR context (`artifacts/pr_context.summary.txt`, head `6ecc591c`), all QC pass 2 artifacts, and reviewer-run checks at HEAD (hash parity, line counts, 1088 Pester tests over the changed and adjacent suites, 27 pytest parity tests, evidence-location validator, and targeted matcher probes). The implementation follows the spec's design items and keeps every unresolvable case fail-closed. No Blocking finding was identified.

**What changed:**
Four new shared modules (`hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-heredoc.ps1`) on both `.claude/hooks/` and `.codex/hooks/`; a rewritten classifier in `hook-command-invocation.ps1`; `Delimiter` and `TokenText` fields on scanner records; per-target authorization in `enforce-epic-worktree-removal-gate.ps1` (both surfaces) and `enforce-parallel-worktree-removal-gate.ps1`; a masked-text adjacency check in `enforce-promotion-mcp-only.ps1` (both surfaces); structural body-file reading in `enforce-pr-author-skill-helpers.ps1`; the new `enforce-pr-author-command-allowlist.ps1`; pr-author agent and skill documentation; byte-identical bundled mirrors; and pack-manifest entries.

**Top 3 risks:**
1. Any PowerShell payload that fails to parse (or an undecodable `-EncodedCommand`, or a depth-limit hit) is Indeterminate for every governed query regardless of word presence, so the promotion hook and the preimplementation gate deny it with a reason that names a command it does not contain.
2. The pr-author allowlist admits `git log` with any arguments, including `--output=<file>`, which writes a file.
3. Each consumer call re-runs the full iterator (including `Parser.ParseInput` for PowerShell payloads); hooks that call several matcher functions parse the same command text several times per PreToolUse invocation. No latency measurement was recorded.

**PR readiness recommendation:** **Go** — no Blocking or Major findings; the remaining items are Minor or Info and the PR-stage acceptance steps (AC-20, AC-21, AC-24) proceed in normal PR flow.

---

## Findings Table

All findings are Non-blocking. Blocking count: 0.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/hook-command-invocation.ps1` (and Codex copy, mirrors) | `Get-CommandLineInvocation`, lines 359-361; `hook-command-payload-powershell.ps1` lines 169-172 | A PowerShell payload parse error yields an Unbalanced record, and Unbalanced, DecodeFailure, and DepthLimit records are classified Indeterminate for every command word and subcommand path without a word-presence test. Reviewer probe: `pwsh -NoProfile -Command 'Write-Output (1'` is denied by the promotion hook with `PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation ...` and is an Indeterminate `git add` match for the preimplementation gate. The base branch classified such wrapper-led segments only on raw containment of the governed words. | Track as a follow-up for the matcher owner: either require whole-token presence before an Unbalanced/Opaque payload record classifies for a query, or have consumers emit a parse-specific deny reason. No change on this branch; the behavior matches spec design item 7 ("Unbalanced, parse error, decode failure, or depth limit: Indeterminate"). | Fail-closed is preserved, but the deny reason misattributes the cause, which costs a diagnosis round when an agent sends a malformed payload. | `sh <SCRATCHPAD>/probe.sh` output: `PROMO [pwsh -NoProfile -Command 'Write-Output (1'] => DENY ... gitAddMatches=1 Indeterminate/Unbalanced`; base `git show 991aae0a:.claude/hooks/hook-command-invocation.ps1` lines 197-205 |
| Minor | `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `Test-PrAuthorAllowlistForm`, lines 68-70 | `git log` and `git rev-parse` are allowed with any trailing arguments. `git log --output=<file>` writes the log to a file, so the allowlist admits a file write. Reviewer probe: `git log --output=artifacts/x.txt -1` is allowed. Redirection operators are correctly denied. | Add `--output` (and `--output=`) to a denied-option check for `git log` in a follow-up, or document the residual in the allowlist header. | The hook's stated purpose is a command boundary for an agent whose Bash permissions are not enforced under `bypassPermissions`; a write path through an allowed form weakens that boundary. Spec design item 12 allows `git log ...` without restriction, so this is a design residual rather than a spec deviation. | Probe output: `ALLOW-HOOK [git log --output=artifacts/x.txt -1] => ALLOW`; `ALLOW-HOOK [git log -1 > out.txt] => DENY` |
| Minor | `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-2-parity-hashes.2026-10-08T23-24.md` | Output Summary | The artifact states "16 groups, every group DISTINCT=1" but lists 15 group lines. | Correct the stated count in a later evidence touch, or leave as recorded; the parity result itself is correct. | Evidence text should match its own listing so audit counts can be relied on. | Reviewer `Get-FileHash` recomputation at HEAD: 6 shared groups (4 copies each) and 9 mirror pairs, all identical, hashes equal to the artifact's values |
| Minor | `.claude/hooks/enforce-promotion-mcp-only.ps1` (and Codex copy) | `Get-PromotionBypassReason`, adjacency loop (diff hunk at original line 117) | `spec.md` Boundaries lists the promotion adjacency regex as unchanged. The regex text is unchanged, but its input moved from `ScanText` to `MaskedText`. | Record the deviation in the PR description. No code change: the move is required for AC-9 (`pwsh -c 'Write-Output "gh issue create"'` allowed), and wrapped forms are still caught by the structural check below it. | A reader comparing the spec boundary to the diff will otherwise see an unexplained change. | Diff inspection; PM-02..PM-13 pass; reviewer probes for heredoc-fed `bash`, `cat <<EOF \| bash`, `sh -o pipefail -c '...'`, and unquoted `$(gh issue create ...)` all deny |
| Info | `.claude/hooks/hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, consumers | `Get-CommandLineInvocation` callers | No memoization: `enforce-pr-author-skill-helpers.ps1` calls `Test-CommandLineInvocation`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag` (twice), and `Get-CommandLineInvocation` for one command, each re-running the iterator; the promotion hook runs it twice. | If latency becomes visible, cache the record list per command text within one hook process. | Spec sets no latency budget; recorded so that a later regression has a known starting point. | Code inspection |
| Info | `.claude/hooks/hook-command-invocation.ps1` | `Get-CommandLineInvocation`, lines 387-395 | A wrapped removal combined with any other non-sink command in the same payload resolves Indeterminate (the sibling record triggers NotProvenInert for the root), so only a single-command wrapped removal is authorizable. Reviewer probe: `pwsh -Command 'Set-Location C:/x; git worktree remove rel'` resolves Indeterminate. | None required; document in the C3 (#850) hand-off that wrapped removals must be single-command payloads to be authorizable. | Fail-closed and consistent with spec design item 7; AC-5 covers the single-command wrapped forms, which resolve to Targets. | Probe output `TARGET [...] => Indeterminate []`; EW/PW/CW-08..12 pass |
| Info | `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1` | lines 187 and 191 | Two `It` blocks carry the same row ID `OP-15` (Indeterminate W rows and Targets W rows). | Renumber one row in a later test touch. | Duplicate IDs make ledger-to-test traceability ambiguous. | File inspection |
| Info | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (line 151) | Pre-existing failure (baseline set B_FULL). At HEAD it denies with `TARGET_WORKTREE_NOT_DERIVABLE` from checkpoint target resolution, before the body-file check, so this row cannot exercise Check 1. Check 1 is exercised by PA-06..PA-15 and REG-13..REG-17. | Out of scope for C1a; the C3 (#850) work on pr-author target resolution should restore this row. | Distinguishes the pre-existing failure from the changed check. | Reviewer probe of `Invoke-PrAuthorSkillDecision` at HEAD; baseline `evidence/baseline/pester-full-coverage.2026-10-08T17-32.md` |
| Info | `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `Get-PrAuthorCommandAllowlistDecision`, lines 182-188 | Allowed commands return an explicit `permissionDecision: allow` rather than no decision. Other PreToolUse hooks still run and a deny from any of them prevails, so the skill hook remains effective. | None required. | Recorded so a later change to hook precedence semantics is evaluated against this choice. | Code inspection; spec design item 12 |
| Info | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | whole file | Both files are at 497 lines, 3 lines below the 500-line limit. | Split before the next addition. | Prevents a later child (C1b, C3) from breaching the limit with a small edit. | Reviewer line count at HEAD |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The classifier never decides on substring containment. Presence uses one whole-token predicate (`Test-CommandLineWordPresent`, `(?<![\w-])word(?![\w-])`), and `Test-CommandLineRawContainment` is removed entirely (reviewer `Get-Command` probe returns nothing; `Grep` finds no production reference).
- Fail-closed boundaries are explicit and ordered: Unbalanced, DecodeFailure, and DepthLimit classify first; unmodeled options classify Indeterminate; Structural matches carry operands and `OperandsComplete`; presence fallback applies only to non-top-level records and only once per root.
- `Resolve-CommandLineInvocationTarget` returns `Targets` only when every match is Structural with exactly one literal operand and complete operands, so no unreadable operand routes to an allow. Multi-target commands are authorized per target (probe: `git worktree remove a && git worktree remove b` resolves `Targets [a,b]`; `git worktree remove a b` resolves Indeterminate).
- The worktree gates extract the per-target cascade into `Get-EpicWorktreeRemovalTargetDenial` / `Get-CodexWorktreeRemovalTargetDenial` without changing the cascade order (epic checkpoint, parallel checkpoint, sanctioned-removal manifest).
- The body-file normalization isolates the session root behind `Get-PrAuthorBodyFileRoot`, which is the seam C3 (#850) needs.
- The allowlist hook evaluates every record at every depth, rejects nested, non-literal, wrapper-led, assignment-led, and redirected segments, and restricts `sha256sum` and `date -u` to whole-command use; the decision function is a pure seam (`Invoke-PrAuthorCommandAllowlistDecision`).
- Claude, Codex, and bundled copies are byte-identical (reviewer recomputation).

#### API and safety notes

- Public signatures named in the spec are preserved; `Resolve-CommandLineInvocation` adds `Status`. `Get-CommandLineGlobalOption` adds `Terminal`.
- All new functions are advanced functions with typed, validated parameters and comment-based help. PSScriptAnalyzer reported 0 findings.
- No `ShouldProcess` surface applies: the hooks are read-only decision functions.
- `$script:CommandLineTransparentWrapperNames` is defined in `hook-command-invocation.ps1` and read by `Skip-CommandLineTransparentWrapper` in `hook-command-payload.ps1`; this works because resolution occurs at call time after all files are dot-sourced, but the payload module is not usable on its own. This is consistent with the documented load order.

#### Error handling and logging

- Parse, decode, and depth conditions are data (Indeterminate records), not exceptions. `ConvertFrom-CommandLineEncodedCommand` catches only `System.FormatException`.
- The allowlist hook converts a payload anomaly into a deny and always returns exit 0, matching the PreToolUse contract that exit 1 is non-blocking.
- Deny reasons keep their leading tokens; the only new token is `PR_AUTHOR_COMMAND_NOT_ALLOWED:` (`qc-pass-2-deny-tokens.2026-10-08T23-24.md`).
- No logging is added, as the spec states.

---

## Test Quality Audit

The test additions are table-driven, pure-string, and mapped to acceptance criteria by row ID. Coverage evidence shows 100% of instrumented changed lines covered and every changed production file at 93.33% or higher. Fail-before and pass-after evidence exists for all seven named reproductions. Negative-control rows stub substring classification back in and confirm the rows then fail.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-command-payload.Tests.ps1` — PY-01..PY-27: iterator records, wrapper extraction per wrapper and flag spelling, decode success and failure, depth limit, inert proof per sink. Covers the new module completely.
- `tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1` — IV-01..IV-24: classifier rules, terminal options, leaf normalization, signature pins, negative control (IV-17).
- `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` — REG-01..REG-21 named reproductions plus the prior-run corpus.
- `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1` — OP-01..OP-16 target resolver and readers (one duplicated ID, see Findings).
- `tests/scripts/claude-hooks/enforce-*-worktree-removal-gate.Issue824.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1` — per-gate allow, deny, multi-target, Indeterminate rows through checkpoint seams.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1` — Check 1 spellings, different-segment canonical path, inline body, wrapped form.
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` — AL-01..AL-38 including frontmatter registration (AL-33) and procedure-form allowance (AL-34, AL-35).
- `evidence/regression-testing/fail-before-pass-after-summary.2026-10-08T22-44.md` — every named reproduction failed at the base and passed after.
- `evidence/qa-gates/coverage-delta.2026-10-08T23-20.md` — per-file baseline, post-change, and changed-line coverage; no decrease.

### Quality assessment prompts

- **Determinism:** No clock, sleep, temporary file, or network use in the changed tests (reviewer search). Two pre-existing full-suite failures read ambient checkpoint state; none of the new suites do.
- **Isolation:** Each row targets one decision or one record property; gate rows mock only read seams.
- **Speed:** 1088 tests in 29 s in the reviewer run.
- **Diagnostics:** Deny-reason prefix assertions and `-Because` clauses identify the failing command span.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or keys. |
| No unsafe subprocess or command construction | ✅ PASS | The matcher never executes payloads; `Parser.ParseInput` parses in memory. The hooks add no process, file, or network I/O beyond existing payload acquisition and checkpoint reads. |
| Input validation at boundaries | ⚠️ PARTIAL | Wrapper, substitution, heredoc, encoded, and xargs inputs are handled fail-closed. Residuals (Non-blocking): `git log --output=<file>` passes the allowlist; malformed PowerShell payloads deny with a misattributed reason (Findings rows 1-2). |
| Error handling remains explicit | ✅ PASS | Indeterminate records carry `Reason`; deny text keeps existing prefixes; allowlist payload anomalies deny. |
| Configuration / path handling is safe | ✅ PASS | `--body-file` is normalized (`GetRelativePath`, backslash conversion, `./` strip) and matched with `-cmatch '^artifacts/pr_body_(\d+)\.md$'`; a path outside the session root yields a `..`-led relative path and is denied. Frontmatter hook command matches the existing `pwsh -NoProfile -File .claude/hooks/<name>.ps1` registration style in `.claude/settings.json`. |
| Byte-identical surfaces | ✅ PASS | Reviewer `Get-FileHash` at HEAD: 6 shared modules identical across 4 copies; 9 hook/agent/skill files identical to their bundled mirrors. |

---

## Research Log

No external research was required. The review relied on the repository's spec, research document (`research/research.2026-10-08T14-00.md`), base-branch source (`git show 991aae0a:...`), and reviewer probes against HEAD.

---

## Verdict

The change is ready for normal PR flow. It removes the substring-classification defect class identified in #824, #742 item 1, and #733 items 2-4, keeps every unresolvable case fail-closed, and is covered by unit, regression, negative-control, and static tests with complete changed-line coverage. The findings are Minor or Info: two design residuals (misattributed deny reason for malformed PowerShell payloads; `git log --output` in the allowlist), one evidence text count error, one spec-boundary wording deviation, and maintainability notes. None blocks the PR; the two design residuals are suitable follow-up items for the epic.
