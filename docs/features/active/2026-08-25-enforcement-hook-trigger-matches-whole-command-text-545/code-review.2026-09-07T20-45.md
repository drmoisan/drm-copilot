# Code Review: Enforcement-hook trigger scoping (#545) — re-audit closing remediation cycle 1

- Issue: #545
- Base: `epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
- Head: `85a3c3448c0900762e47d03f4fed2a9442cc1ef9`
- Timestamp: 2026-09-07T20-45
- Round: re-audit closing remediation cycle 1 (supersedes `code-review.2026-09-07T17-44.md`)
- Scope: full branch diff (202 files), not the remediation delta

## Executive Summary

The branch replaces whole-command-text regex triggers in nine enforcement hooks, across two
runtimes and four copy locations, with a shared quote-, escape-, and heredoc-aware scanner and a
structural invocation matcher. The design is well argued, the code is clean and well documented,
and the delivery discipline is high: 18 canonical/bundle pairs are byte-identical, the two parser
files are byte-identical across runtimes, every changed file is inside the 500-line cap, coverage is
above threshold on all 18 changed production files, and 2381 Pester cases pass with only two
independently confirmed ambient failures.

The prior round's single blocking finding, R-1, is **closed and verified**. The fix adds a
raw-`ScanText` `IndexOf` condition to the `validate-bash.ps1` denylist leg, gated on exactly the
three disjuncts the scanner itself uses to select raw scan text. The third disjunct (`Unbalanced`),
which preflight added beyond the remediation inputs, is correct, necessary, and pinned; the
adjudication is in the policy audit.

One blocking finding remains, and it is the same defect class in four locations the R-1 fix did not
reach. `Resolve-CommandLineInvocation` correctly classifies a wrapper-led segment by raw
containment, but `Test-CommandLineFlag` and `Get-CommandLineFlagValue` then read the segment's
collapsed `Tokens`, so every flag on a wrapper-led segment reads as absent. Four call sites treat an
absent flag — or an absent token — as *out of scope* and allow. The result is four denials that
existed before this branch and do not exist after it, on the epic merge gate, the parallel abandon
gate, the pr-author inline-body check, and the `cd`-chained-read rule. None is covered by spec D4's
three accepted residual risks; all four contradict AC-09 and the D3 conclusion; and none is pinned
by a test, because the seven D3 wrapper deny pins live at the parser and preimplementation-gate
level, where the behavior is correct.

The repository already contains the correct shape for the fix in `enforce-promotion-mcp-only.ps1`,
which pairs a `ScanText` scan with a structural `Test-CommandLineInvocation` leg. Applying that
shape to the four sites closes the finding without touching any byte-unchanged literal.

Recommendation: **No-Go pending remediation of R-2.** Everything else is ready.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| **Blocking** | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1` (+2 bundle copies) | `Invoke-EpicMergeGateDecision`, Claude L397–400 / Codex L131–133 | `$hasMergeFlag = Test-CommandLineFlag … '--merge'` reads the matched segment's `Tokens`. For `bash -c "gh pr merge --merge 688"` the segment is wrapper-led, tokens are `bash`, `-c`, `gh pr merge --merge 688`, so `--merge` reads absent and `-not $hasMergeFlag` returns `Get-EpicMergeGateAllowDecision`. The pre-change filter `$commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b'` matched raw text and kept the command in scope. | Conjoin a wrapper-aware leg: treat the flag as present when the segment is wrapper-led, carries a live substitution, or is unbalanced and `$segment.ScanText` contains the flag token, mirroring the R-1 fix. Add a wrapper deny pin per side. | A merge gate that allows an unauthorized `gh pr merge` through a one-word wrapper is a weakened denial on an irreversible action. D4 accepts over-match inside wrappers (D4.1) and unlisted wrappers (D4.3); `bash` is listed and this is under-match. | Traced pre- and post-change control flow; `git show 6dff80ed:.claude/hooks/enforce-epic-merge-gate.ps1` L377 vs head L397–400; `Test-CommandLineFlag` body at `hook-command-invocation.ps1` L444–453; no `bash -c` case exists in either merge-gate trigger-scoping suite. |
| **Blocking** | `.claude/hooks/enforce-parallel-abandon-gate.ps1` (+1 bundle copy) | `Test-ParallelAbandonCommandInScope` L165–166; `Test-ParallelAbandonCommandConfirmed` L200–205 | Both functions iterate `Read-CommandLineSegment` and pass `@($segment.Tokens)` to `Test-ParallelAbandonSegmentDisposition`, with no wrapper/live-substitution/unbalanced fallback. For `bash -c "python … --disposition abandon"` the quoted span collapses to one token, so neither the adjacent pair nor the `=`-joined form matches, and the command is out of scope. The pre-change `$NormalizedCommand.Contains('--disposition abandon', OrdinalIgnoreCase)` matched and denied absent `--confirm-abandon`. | Add a second condition to `Test-ParallelAbandonSegmentDisposition`'s call sites: when the segment is wrapper-led, carries a live substitution, or is unbalanced, test `$segment.ScanText` for both spellings by ordinal case-insensitive `IndexOf`. Both token literals stay byte-unchanged in their single-assignment form. Add a wrapper deny pin. | This gate is the confirmation barrier for abandoning a parallel work item. Losing it to a listed wrapper is a weakened denial on a destructive action, and AC-09 forbids it. | Diff of the hook at `6dff80ed..85a3c344`; `ConvertTo-CommandLineToken` L69–96 confirms the quoted-span collapse; `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` contains no wrapper case. |
| **Blocking** | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (+1 bundle copy) | `Get-PrAuthorBypassReason` L190–191 and L205–210 | `$hasInlineBody = Test-CommandLineFlag … '--body'` reads collapsed tokens. For `bash -c "gh pr edit 42 --body 'x'"`, `isPrEdit` is true (raw containment) but both flags read absent, so the `isPrEdit` no-body branch returns `$null` — allow. The pre-change `$CommandText -match '(?i)--body(?!-file)\b'` matched raw text and Case A denied with `PR_AUTHOR_SKILL_BLOCKED`. | Same wrapper-aware fallback for the two flag reads. Note the `isPrCreate` path is already fail-closed (Case B denies when both flags read absent), so only the `isPrEdit` branch needs the fix. | An inline-body PR edit is exactly what the pr-author skill gate exists to prevent; a wrapper defeats it. | Head L205–210 vs `git show 6dff80ed:.claude/hooks/enforce-pr-author-skill-helpers.ps1` L177–178; `Test-CommandLineFlag` body. |
| **Blocking** | `.claude/hooks/validate-bash.ps1` (+1 bundle copy) | `Get-CdChainedReadCommandMatch` L274–297 | The function walks segments comparing `$segment.CommandWord` against `cd` and the read-command family. A wrapper-led segment's command word is `bash`, and `&&` inside a quoted span is not a delimiter, so `bash -c "cd /x && head f"` is one segment that never matches. The pre-change `$script:CdChainedReadCommandPattern` matched the raw text and denied. This is also a deviation from the normative D12 call-site table, which directs `validate-bash.ps1 L105` to "the `cd`-chained pattern evaluated per segment against `ScanText`". | Add the D12-directed leg alongside the existing `CommandWord` walk, not instead of it: for a segment that is wrapper-led, carries a live substitution, or is unbalanced, evaluate `$script:CdChainedReadCommandPattern` against `$segment.ScanText`. This also makes the retained constant live again, resolving C-3. | The docstring's stated narrowing ("a cd-then-read phrase occurring only inside a quoted span or a heredoc body … allows after this change") describes the *masking* mechanism in a non-wrapper segment. It does not describe or justify the wrapper case, where the scanner deliberately does **not** mask. The two are different mechanisms with different intent. | Scanner main loop L326–354 confirms `&&` inside `inDouble` is consumed, not delimited; `Get-CdChainedReadCommandMatch` L280–297; spec D12 call-site rewrite table, `spec.md` L1198. |
| Medium | `.claude/hooks/validate-bash.ps1`, `.codex/hooks/validate-bash.ps1` | `Get-BlockedPatternMatch` leg 1, L191–201 | Whole-token equality means `rm -rfv /tmp/x` no longer matches the `rm -rf` literal, because `-rfv` is not `-rf`. The pre-change `String.Contains` matched the prefix and denied. | Consider adding `rm -rfv` and `rm -fr` handling, or a flag-cluster-aware comparison for single-letter option clusters, in a follow-up. Do not change the six byte-unchanged literals to achieve it. | This is the intended consequence of the D11.3 ruling that "no token boundary of any kind" is a defect, and it is the same mechanism that delivers AT-8's required `--force-with-lease` allow. It is a chosen trade, but the spec does not enumerate it, so it should not be discovered later as a surprise. | `Get-BlockedBashPattern` L53–60; `Test-BlockedPatternTokenRun` whole-token comparison; spec D11.3 L777–796. |
| Low | `.claude/hooks/validate-bash.ps1` | L222 | `$script:CdChainedReadCommandPattern` is assigned and never read. It is retained deliberately to discharge the AC-07 byte-unchanged obligation, and the retention is documented in the adjacent comment block. | Fixing R-2.d makes the constant live again, which is the cleaner resolution than leaving a documented dead assignment. If R-2.d is fixed as recommended, this finding closes with it. | A constant retained only to satisfy a text-preservation obligation is a maintenance hazard: a future reader cannot tell from the code whether it is load-bearing. | Grep of `validate-bash.ps1` shows one assignment at L222 and zero reads. |
| Low | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (+1 bundle copy) | whole file | The file is exactly 500 lines — at the cap with zero headroom. | Pair any future edit to this file with an extraction into a helper. No action required on this branch. | The next one-line addition to this file fails the line-cap gate, which will surface as a confusing CI failure in an unrelated change. | Independent `wc -l` over every changed `.ps1`; this file and its bundle copy are the two largest at 500. |
| Informational | `.claude/hooks/hook-command-scanner.ps1` | `$script:CommandLineWrapperNames` L21–24 | The wrapper set omits `ssh`, `su`, `doas`, `sudo`, `parallel`, `nice`, `stdbuf`, `setsid`, `script`, and `find -exec`. A command outside the set that executes its quoted argument bypasses every raw-text scan. | No action. Adding members is a one-line, test-pinned change if a need appears. | Explicitly accepted as residual risk D4.3, and D11.4 records the seven-member expansion proposal as an implementation judgment rather than a fixed decision. Recorded here so the review shows it was considered, not missed. | Spec D4.3 L459–463; D11.4 L797–810; membership pinned by `hook-command-scanner.Tests.ps1` L311–319. |
| Informational | `.claude/hooks/enforce-promotion-mcp-only.ps1` | L104–141 | This hook is the correct reference implementation of the design: byte-unchanged literals scanned against `$segment.ScanText`, the adjacency-requiring `gh issue create/new` expression scanned against `$segment.ScanText`, and a structural `Test-CommandLineInvocation` leg added alongside for the relocating spelling. | Use it as the model when remediating R-2. | Naming the in-repo precedent makes the remediation concrete and reduces the chance of a fifth variant of the same bug. | Read of L104–141. |

## Implementation Audit

### The shared parser is the strongest part of the change

`hook-command-scanner.ps1` (450 lines) performs a single left-to-right pass producing segment
records with `RawText`, `MaskedText`, `Tokens`, `CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`,
`Unbalanced`, and `ScanText`. Both parser files are pure string logic with no disk, process,
network, clock, or environment access — verified by reading both end to end; the only `Join-Path`
calls are the `$PSScriptRoot` dot-source lines.

Specific things done well:

- **Segment delimiters include the subshell, group, and substitution openers.** `(`, `)`, `{`, `}`,
  and backtick are in `$script:CommandLineSegmentDelimiters`, and `$(` is handled alongside. This is
  what closes the `(git add .)` and `$(git add .)` non-match bypasses, and the comment at L27–30 says
  so explicitly.
- **`Unbalanced` is assigned per segment, not globally.** The post-loop
  `if ($inSingle -or $inDouble -or $pending.Count -gt 0) { $unbalanced = $true }` applies to the
  final record only. Because an unterminated quote consumes all subsequent delimiters, everything
  after the opening quote is genuinely one segment, so earlier balanced segments are not
  contaminated. This is subtle and correct.
- **The transparent-wrapper set is a strict subset of the wrapper carve-out set**, with the comment
  at L20–22 of `hook-command-invocation.ps1` stating the deliberate overlap so `env git worktree
  remove x` classifies by both mechanisms.
- **Unmodeled dash-leading tokens classify.** `Skip-CommandLineOption` reports `Unmodeled`, and
  `Resolve-CommandLineInvocation` returns a match with `OperandIndex = -1`. Over-classification
  forces a checkpoint check; under-classification is a bypass. The right direction, and documented.
- **The `--base` comparison was tightened, not just ported.** The old
  `-cnotmatch [regex]::Escape("--base $integrationBranch")` was a substring test, so
  `--base epic/foo-extra` satisfied a requirement for `--base epic/foo`. The new
  `$baseValue -cne $integrationBranch` is exact, and the case sensitivity the old form had is
  preserved with a comment explaining why (branch names are case-sensitive).

### Where the design's fail-closed posture holds

For a wrapper-led, live-substitution, or unbalanced segment, `Resolve-CommandLineInvocation`
classifies and reports `OperandIndex = -1`. Call sites that then find no operand or no flag value
correctly deny:

| Call site | Behavior on `OperandIndex = -1` |
|---|---|
| `enforce-epic-worktree-removal-gate.ps1` L377–391 | `$worktreePath` is `$null`, no checkpoint record matches, returns `EPIC_WORKTREE_REMOVAL_BLOCKED`. Fail-closed. |
| `enforce-parallel-worktree-removal-gate.ps1` L243–257 | Same shape. Fail-closed. |
| `enforce-pr-author-skill.epic-base-branch.ps1` L106–110 | `$baseValue` is `$null`, returns `EPIC_BASE_BRANCH_MISMATCH`. Fail-closed. |
| `enforce-pr-author-skill-helpers.ps1` `isPrCreate` branch L199–202 | Both flags absent, Case B denies. Fail-closed. |
| `enforce-orchestration-preimplementation-gate.ps1` L139–147 | Uses `ScanText` directly, never flag reads. Correct. |
| `enforce-promotion-mcp-only.ps1` L104–141 | Uses `ScanText` plus a structural leg. Correct. |
| `validate-bash.ps1` denylist leg 1, post R-1 fix | Raw `IndexOf` on `ScanText`. Correct. |

### Where it does not hold

The four sites in the findings table. The distinguishing property is simple and worth stating
because it makes the remediation checkable: **a call site is safe when an absent operand or flag
leads to a deny, and unsafe when it leads to an allow or an out-of-scope return.** Every unsafe site
in this branch is one where flag absence is treated as a scope filter rather than as missing
authorization.

This is not a defect in `Test-CommandLineFlag` itself. D12 defines the fail-closed rules for
`Test-CommandLineInvocation` and does not define fail-closed behavior for flag retrieval on a
non-structural match, so the function is contract-conformant. The gap is at the four call sites, and
the fix belongs there.

## Test Quality Audit

| Dimension | Assessment |
|---|---|
| Determinism | Strong. Every new suite carries an explicit determinism note naming what it does not touch. No `Start-Sleep`, no wall-clock read, no temporary file, no `TestDrive` write in the new suites. |
| Regression-first discipline | Strong. Fail-before and pass-after artifacts exist for every acceptance case under `evidence/regression-testing/`, including `fail-before-r1-claude.2026-09-07T19-41.md` / `pass-after-r1-claude.2026-09-07T19-44.md` and the Codex equivalents. Four of the five cases per side failed before the R-1 fix; `R1-C4`/`R1-X4` are negatives that passed throughout, and the artifacts say so rather than claiming five-of-five. |
| Case naming | Strong. Names carry the acceptance identifier and the asserted decision, e.g. `R1-C5 denies rm -rf carried inside an unterminated quoted span`. |
| Comment quality | Strong. Each new case explains the *mechanism* it exercises, not just the expectation. `R1-C5`'s comment states it "fails against a two-disjunct fix and passes only against the three-disjunct fix," which is exactly the property a future reader needs. |
| Membership pinning | Strong. `Get-CommandLineWrapperName` is asserted at exactly 14 members with a sorted string comparison; `Get-CommandLineTransparentWrapperName` at exactly 5; all three global-option tables by exact sorted membership. |
| Heredoc rule coverage | Complete. All seven rules AC-04 names have a named case: `<<`, `<<-` with tab-indented terminator, quoted delimiter, multiple pending heredocs on one line, unterminated body masking to end of text, `<<<` not a heredoc, non-literal delimiter forcing a raw scan. |
| **Gap** | The seven D3 wrapper deny pins exist only at the parser level and at the preimplementation gate. No wrapper case exists in the merge-gate, abandon-gate, or pr-author-edit decision-surface suites. That is precisely the blind spot the four blocking findings occupy: the pins prove `Test-CommandLineInvocation` classifies the wrapper form, and stop short of proving the hook still denies it. Remediation must add a decision-surface wrapper pin per affected hook per side, not another parser-level pin. |

## Security / Correctness Checks

| Check | Result |
|---|---|
| Byte-unchanged trigger literals | Verified. The six `Get-BlockedBashPattern` literals, the promotion hook's four forbidden tokens and its `gh issue create`/`new` expression and `$ghApiIssuesPostPattern` declaration, the five preimplementation trigger patterns, `$script:CdChainedReadCommandPattern`, and the two abandon token constants are all present unchanged at head. |
| Deleted literals justified | Verified. The pr-author `gh pr create` / `gh pr edit` expressions are deleted, which AC-07 as amended records as superseded by the D12 call-site rewrite rather than byte-unchanged. The amendment is a genuine correction of an unsatisfiable obligation, not a weakening of one: a function taking no pattern operand cannot preserve a pattern string. |
| No new secrets or credentials | Verified. No `.env`, token, or credential appears in the diff. |
| No policy document modified | Verified. Zero files under `.github/instructions/` or `.claude/rules/` in the diff. |
| No Python introduced | Verified. Zero `.py` production files added; zero Python-interpreter references in either parser file; the no-Python scan suite globs recursively so the new files are automatically in its scan set. |
| Issue #539 spec annotated additively | Verified. Three table cells and one bullet were touched, in every case by *appending* a `**Superseded in part by issue #545:**` clause after the pre-existing text, plus one wholly new paragraph. Every pre-existing sentence is preserved verbatim; no sentence, row disposition, or decision text was rewritten. |
| Fail-closed on envelope anomalies | Verified unchanged. Each gate still denies on an unparseable or missing `tool_input`, with the property-level absence of `command` remaining an allow (the gate's scope filter). |
| Hook family posture claim | Consistent. D4.2 states the family is "a policy deterrent, not a security boundary," and nothing in the change implies tamper-resistance. R-2 is a regression against the deterrent's own prior strength, which is the standard AC-09 sets, not a claim that the deterrent should be a boundary. |

## Research Log

- Traced `ConvertTo-CommandLineToken` character by character to confirm a balanced quoted span
  contributes one token and that whitespace inside it does not split. This is the mechanism behind
  both R-1 and R-2.
- Traced the scanner's main loop to confirm `&&` inside a double-quoted span is consumed by the
  `inDouble` branch and does not delimit, which is why `bash -c "cd /x && head f"` is a single
  segment.
- Compared `hook-command-scanner.ps1` L151 against `validate-bash.ps1` L197 to confirm the R-1 fix's
  three disjuncts are set-identical with the scanner's own ScanText selection.
- Extracted the base-commit copies of `enforce-epic-merge-gate.ps1` and
  `enforce-pr-author-skill-helpers.ps1` and diffed the scope filters by hand to establish the
  pre-change decision for each R-2 command, rather than inferring it.
- Enumerated every consumer of `Read-CommandLineSegment` across both runtimes and classified each by
  whether it reads `ScanText`, routes through `Test-CommandLineInvocation`, or reads `Tokens`
  directly. That enumeration is what bounded R-2 to four sites rather than leaving it open-ended.
- Re-derived per-file coverage from `powershell-coverage.xml` with package-qualified selection and
  matched 9 of 9 reproducible rows against the CI-reported figures.
- Re-derived the JUnit pass table and confirmed both failures are in unmodified test files driving
  unmodified or behaviorally equivalent hooks.

## Verdict

**No-Go pending remediation of R-2.**

Blocking findings: **1** (R-2, with four enumerated instances sharing one root cause).

R-1 from the prior round is closed and independently verified, including the un-specified third
disjunct, which is correct and necessary rather than over-broad.

Everything outside R-2 is ready to merge: the parser design, the copy-set delivery, parity,
coverage, line cap, registration completeness, evidence discipline, and the cross-issue annotation
of #539. R-2 is a bounded, four-site change with an in-repo reference implementation
(`enforce-promotion-mcp-only.ps1`) and a mechanical test obligation (one decision-surface wrapper pin
per affected hook per side). It does not require redesign.
