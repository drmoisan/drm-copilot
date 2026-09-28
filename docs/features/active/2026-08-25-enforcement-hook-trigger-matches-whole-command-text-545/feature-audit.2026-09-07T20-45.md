# Feature Audit: Enforcement-hook trigger scoping (#545) — re-audit closing remediation cycle 1

- Issue: #545
- Timestamp: 2026-09-07T20-45
- Round: re-audit closing remediation cycle 1 (supersedes `feature-audit.2026-09-07T17-44.md`)

## Scope and Baseline

| Field | Value |
|---|---|
| Base branch (resolved) | `epic/cleanup-merged-worktrees-hardening-integration` |
| Merge-base SHA | `6dff80ed4596bec088d548b23013e6077e32c484` |
| Head SHA | `85a3c3448c0900762e47d03f4fed2a9442cc1ef9` |
| Head branch | `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` |
| Diff range | `6dff80ed..85a3c344`, unscoped |
| Work mode | `full-bug` (`issue.md` line 12) |
| AC source | `spec.md` only |
| Files changed | 202 |
| Audit scope | Full branch diff. No caller narrowing was accepted; see `## Rejected Scope Narrowing` in `policy-audit.2026-09-07T20-45.md`. |

The merge-base is a direct ancestor of the head, so the unscoped `git diff 6dff80ed..85a3c344` is
the authoritative change set for this audit. It was used in preference to any per-phase or
per-remediation view.

## Acceptance Criteria Inventory

`spec.md` `## Acceptance Criteria` (line 1451) contains **37** checkbox items, at `spec.md` lines
1453 through 1655. State at the start of this audit: 36 checked, 1 unchecked (AC-22).

Counted from the `## Acceptance Criteria` heading to the next equal-or-shallower heading
(`## Risks & Mitigations`, line 1661), excluding the severity checkboxes at lines 69–72 and the
evidence checkbox at line 150, which belong to other sections.

| # | `spec.md` line | Criterion (abbreviated) |
|---|---|---|
| AC-01 | 1453 | Over-match regression test exists and is recorded failing pre-fix |
| AC-02 | 1457 | Under-match regression test exists and is recorded failing pre-fix |
| AC-03 | 1461 | Both regression tests pass after the fix, both sides |
| AC-04 | 1463 | Scanner produces the five D2 Piece 1 properties; seven named heredoc cases |
| AC-05 | 1468 | Three ordered ScanText clauses; wrapper set pinned at exactly fourteen members |
| AC-06 | 1476 | Structural relocation classifier, six steps, five named cases |
| AC-07 | 1480 | Trigger literals byte-unchanged; pr-author expressions superseded (amended) |
| AC-08 | 1495 | Every D3 fail-closed row has a named case; seven wrapper deny pins |
| AC-09 | 1499 | **No existing denial is weakened** |
| AC-10 | 1505 | Issue #539 exemption layer unchanged |
| AC-11 | 1509 | `enforce-promotion-mcp-only.ps1` on per-segment scan text, all four copies |
| AC-12 | 1514 | `enforce-pr-author-skill-helpers.ps1` on per-segment scan text, both Claude copies |
| AC-13 | 1519 | Parser ships as exactly two dot-sourced `.ps1` files in eight locations |
| AC-14 | 1525 | Fourteen registration entries across five registry files |
| AC-15 | 1532 | Both parity mechanisms green in the same change |
| AC-16 | 1537 | Recomputed pair-hash parity evidence at the final commit |
| AC-17 | 1541 | Every touched or added file at or under 500 lines |
| AC-18 | 1544 | Pester line coverage >= 85% on every changed or added production file |
| AC-19 | 1548 | No Python introduced anywhere |
| AC-20 | 1552 | Issue #539's `spec.md` annotated additively at all five D8 locations |
| AC-21 | 1557 | All nine in-scope hooks carry a diff across the full copy set |
| AC-22 | 1565 | Issue #591 recorded as superseded and named in the PR body |
| AC-23 | 1569 | PoshQC toolchain passes clean in a single pass |
| AC-24 | 1573 | Manual replay recorded |
| AC-25 | 1576 | AT-5: relocating `gh issue create` / `issue new` denies, all four copies |
| AC-26 | 1584 | AT-1: latent-bypass worktree removal denies |
| AC-27 | 1592 | AT-2: issue #591 operand mis-parse fixed |
| AC-28 | 1598 | AT-4: merge-gate over-match allows |
| AC-29 | 1602 | AT-6: wrapper deny pin still denies |
| AC-30 | 1608 | AT-7: cross-runtime worktree-path divergence closed |
| AC-31 | 1615 | `validate-bash.ps1` matching-primitive change delivered and pinned (D11.3) |
| AC-32 | 1622 | `enforce-parallel-abandon-gate.ps1` fixed and pinned (AT-11, AT-12) |
| AC-33 | 1631 | `enforce-pr-author-skill.epic-base-branch.ps1` fixed in both Claude copies |
| AC-34 | 1638 | Codex merge gate does not acquire the Claude copy's digit-scan defect |
| AC-35 | 1642 | D12 parser contract documented and honoured |
| AC-36 | 1650 | `Test-CommandLineFlag` exists and serves all three presence-only call sites |
| AC-37 | 1655 | Two deferred D11.6 follow-ups filed as separate potential entries |

### Correction of a mis-citation in this reviewer's prior artifact

`feature-audit.2026-09-07T17-44.md` line 131 cited **AC-31** as the criterion covering
`enforce-pr-author-skill.epic-base-branch.ps1`. That contradicted its own numbered index four lines
earlier and is wrong. The index above was re-derived independently from `spec.md` at the current
head by enumerating `^- \[[ x]\]` matches within the `## Acceptance Criteria` section:

- **AC-31** is the `validate-bash.ps1` matching-primitive criterion (D11.3), now at `spec.md` line 1615.
- **AC-33** is the `enforce-pr-author-skill.epic-base-branch.ps1` criterion, now at `spec.md` line 1631.

The prior artifact recorded these at lines 1604 and 1620. Both current line numbers exceed the prior
ones by exactly 11, which is the number of lines the AC-07 amendment added ahead of both — an
independent consistency check that confirms the mapping rather than the mis-citation. `spec.md`'s own
AC-07 amendment text states the same mapping. The remediation plan inherited the mis-citation and it
was caught at preflight round 2 before reaching `spec.md`. It is **not** reproduced here.

## Acceptance Criteria Evaluation

| # | Verdict | Evidence and reasoning |
|---|---|---|
| AC-01 | **PASS** | `evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md` and the Codex counterpart record the heredoc-prose over-match asserted to allow, failing against the unfixed hooks. |
| AC-02 | **PASS** | `evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md` and the Codex counterpart record `git -C ../x add .` against a not-ready checkpoint asserted to deny, failing pre-fix. |
| AC-03 | **PASS** | `pass-after-claude-preimplementation.2026-09-07T13-17.md` and `pass-after-codex-preimplementation.2026-09-07T13-31.md`. Independently corroborated: neither suite appears in the failing set of `artifacts/pester/pester-junit.xml`. |
| AC-04 | **PASS** | `ConvertTo-CommandLineSegmentRecord` emits all five properties (`hook-command-scanner.ps1` L153–161). All seven heredoc rules have named cases in `hook-command-scanner.Tests.ps1`: `<<` (L166), `<<-` tab-indented terminator (L175), quoted delimiter (L183), multiple pending on one line (L191), unterminated body masking to end of text (L200), `<<<` not a heredoc (L209), non-literal delimiter forcing a raw scan (L219). |
| AC-05 | **PASS** | The three clauses are implemented in order at `hook-command-scanner.ps1` L151 and pinned by named cases at `hook-command-scanner.Tests.ps1` L283, L291 (clause 1 outranks clause 3), L297, L303. Membership is asserted through the accessor at L311–319: `Should -Be 14` plus an exact sorted string comparison. The constant holds fourteen members and D2 Piece 2 states fourteen; D11.4's optional additions were not adopted, so no amendment was owed. All three agree. |
| AC-06 | **PASS** | Six steps implemented in `Resolve-CommandLineInvocation` L194–235. All five required cases present in `hook-command-invocation.Tests.ps1`: `git -C` (L29), `git --git-dir` (L34), `git --work-tree` (L39), unmodeled dash-leading token (L44), and `git log --grep add` not classifying (L49). |
| AC-07 | **PASS** | Byte-unchanged verified by reading each literal at head: the five preimplementation trigger patterns, the promotion hook's four forbidden tokens and its `gh issue create`/`new` expression and `$ghApiIssuesPostPattern` declaration line, the six `Get-BlockedBashPattern` literals (L53–60), `$script:CdChainedReadCommandPattern` (L222), and the two abandon token constants at L41–42. The pr-author `gh pr create` / `gh pr edit` expressions are deleted, which the amendment records as superseded by the D12 call-site rewrite. The amendment is sound: `Test-CommandLineInvocation` takes no pattern operand, so the obligation was unsatisfiable, not merely inconvenient. The amendment's own internal cross-reference (AC-33 at former line 1620, AC-31 at former line 1604) matches this reviewer's independently derived index. |
| AC-08 | **PASS** | Every D3 row has at least one named case. The seven wrapper deny pins are present: `xargs`, `bash -c`, `sh -c`, `env`, `pwsh -Command` (`hook-command-parser.AcceptanceCases.Tests.ps1` AT-6 at L172 and `hook-command-invocation.Tests.ps1` L201), heredoc-into-`bash` (L213 unbalanced, plus the scanner heredoc cases), and live substitution inside double quotes (L208). **Limitation recorded:** these pins assert that `Test-CommandLineInvocation` classifies the wrapper form. They do not assert that the merge-gate, abandon-gate, or pr-author-edit *decision surfaces* still deny it, which is the gap AC-09 fails on. The criterion as written is satisfied; the note is carried so remediation targets the right layer. |
| AC-09 | **FAIL** | Four denials that existed at `6dff80ed` do not exist at `85a3c344`, all through the same mechanism: `ConvertTo-CommandLineToken` collapses a wrapper's balanced quoted argument into one token, and four call sites read those collapsed tokens for flag or token presence and treat absence as out-of-scope. See the adjudication below. The criterion's *enumerated* obligations are met — both existing decision suites pass with only the single reversed heredoc `It` per side, the Claude gate suite denials at lines 112–149 pass, the Codex `Test-ImplementationCommand` classification table at lines 348–358 passes including `git commit -m "wip"` returning `$true`, the #539 D4 rows 14a–14d chained relocating denials pass, and the absolute-path and pr-author suites pass. But the criterion's headline requirement is absolute, and four denials are weakened. |
| AC-10 | **PASS** | `enforce-orchestration-preimplementation-gate-helpers.ps1` is absent from the branch diff on both runtimes, so `Test-ExemptOrchestrationStagingCommand` carries no edit. The exemption remains allow-side only and is consulted at the same point: `enforce-orchestration-preimplementation-gate.ps1` L148–153 keeps it inside the `$index -eq 0` staging leg with `continue` rather than `return`, so a chained line carrying any non-git implementation segment still classifies. Corroborated by `evidence/qa-gates/539-exemption-layer-unchanged.2026-09-07T16-12.md`. |
| AC-11 | **PASS** | `enforce-promotion-mcp-only.ps1` L104–141 runs the four byte-unchanged tokens and both `gh` expressions against `$segment.ScanText`, with a structural `Test-CommandLineInvocation` leg alongside for the relocating spelling. Delivered in all four copies (byte parity verified by `cmp -s`). Named cases assert the receipt-value allow and the genuine-invocation, `gh issue create`, `gh issue new`, and single-segment `gh api … -X POST` denials in `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` and the Codex counterparts. |
| AC-12 | **PASS** | `enforce-pr-author-skill-helpers.ps1` L186–191: `isPrCreate`/`isPrEdit` evaluate through `Test-CommandLineInvocation`, so `gh --repo <o/r> pr create` and `gh -R <o/r> pr edit` classify (pinned at `hook-command-invocation.Tests.ps1` L66). Named cases assert the quoted `--body-file` receipt-value allow and that every `PR_*` reason code and receipt check is unchanged. Delivered in both Claude copies, byte-identical. (The wrapper-led `isPrEdit` regression is adjudicated under AC-09, which owns it; AC-12's own enumerated obligations are met.) |
| AC-13 | **PASS** | Exactly two files, `hook-command-scanner.ps1` (450 lines) and `hook-command-invocation.ps1` (483 lines), present at `.claude/hooks/`, `.codex/hooks/`, and both bundle locations — eight files, all byte-identical across all four locations and across runtimes. Both define functions only, read no stdin, contain zero `$env:CLAUDE_` references, and are under 500 lines. Neither is a `.psm1`, and the branch diff adds no file under `.claude/lib/`. |
| AC-14 | **PASS** | Fourteen entries across five registry files, re-derived from the diff: 2 in each pack manifest (4), 2 in `$script:SharedModuleNames` (`legacy-codex-hook-contracts.Tests.ps1` L30), 4 in each PoshQC coverage list (8). The two coverage-list files are byte-identical (`cmp -s`), satisfying the textual-identity requirement of `test_poshqc_bundled_parity.py`. |
| AC-15 | **PASS** | All 18 canonical/bundle pairs byte-identical under `cmp -s`, which is a stronger claim than the byte-identity `It` and the content-equality assertion make. Both pack manifests carry the two new entries. Neither parity suite appears in the JUnit failing set. |
| AC-16 | **PASS** | `evidence/other/pair-hash-parity.2026-09-07T15-52.md` records SHA-256 per pair member, line counts, and the method; `evidence/qa-gates/final-parity-and-line-cap.2026-09-07T20-09.md` recomputes the four `validate-bash.ps1` hashes after the R-1 edit at the cycle-scope anchor. The head commit `85a3c344` touches docs only (`git diff --name-only 3b4f10b9..85a3c344` returns only `docs/` paths), so hashes computed at `3b4f10b9` are current for every `.ps1`. Independently confirmed by this reviewer's `cmp -s` run at the head. |
| AC-17 | **PASS** | Independently re-derived `wc -l` over every `.ps1` in the branch diff: zero files above 500. Largest is `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` at exactly 500 (both copies). Corroborated by `evidence/qa-gates/line-cap-inventory.2026-09-07T16-00.md` and the Codex contract suite's line-cap check, which passes. |
| AC-18 | **PASS** | All 18 changed-or-added canonical production files at or above 85% line coverage; lowest is `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at 88.3117. `hook-command-scanner.ps1` is inside the denominator on both sides (97.7778 Claude, 100.0000 Codex), which required the four new `CodeCoverage.Path` entries. Coverage was produced by CI dispatch of `.github/workflows/_poshqc.yml`, which imports the same self-hosted PoshQC module; the MCP runner was never substituted for a coverage figure. Nine of the eighteen rows were independently re-derived from `artifacts/pester/powershell-coverage.xml` and **all nine match exactly**. |
| AC-19 | **PASS** | Zero `.py` production files added. Zero Python-interpreter references in either parser file. `enforcement-hooks-no-python-invocation.Tests.ps1` builds its scan set by recursive `Get-ChildItem` filtered to `.ps1`/`.psm1`, so the new helpers are automatically in scope without a registration edit; the suite is absent from the JUnit failing set. Corroborated by `evidence/qa-gates/no-python-scan.2026-09-07T15-58.md`. |
| AC-20 | **PASS** | The diff of `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md` touches five locations: D4 rule table row 14, the deny-map rows for the bare relocating spelling and the heredoc mention, design decision D8, and the Rollout & Follow-up deferral bullet. In every case the pre-existing text is preserved verbatim and a `**Superseded in part by issue #545:**` clause is appended, or a wholly new paragraph or sub-bullet is added. No sentence, table-row disposition, or decision text was rewritten. Each note cites issue #545. |
| AC-21 | **PASS** | All nine hooks carry a diff. `enforce-orchestration-preimplementation-gate.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, and `validate-bash.ps1` changed in all four locations each; `enforce-pr-author-skill-helpers.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, and `enforce-pr-author-skill.epic-base-branch.ps1` in their two Claude locations each. Zero files under `.github/instructions/` or `.claude/rules/` in the diff. No hook outside the list is modified; the two new parser files are the shared helper AC-13 mandates, not additional hooks. |
| AC-22 | **UNVERIFIED** | The supersession is recorded in `evidence/issue-updates/issue-591.2026-09-07T15-41.md`, and no separate follow-up candidate was filed for the merge-gate, worktree-removal, abandon-gate, or `validate-bash` instances — both confirmed. The remaining clause requires the **pull-request body** to state the supersession and name issue #591. No PR body exists yet (`artifacts/pr_context.summary.txt` records "GitHub CLI unavailable" and no PR metadata), so the evidence for this clause is not yet producible. This criterion closes on the PR body and correctly remains unchecked. |
| AC-23 | **PASS** | `evidence/qa-gates/final-poshqc-format.2026-09-07T20-04.md` `EXIT_CODE: 0` / `ok: true`; `final-poshqc-analyze.2026-09-07T20-05.md` `EXIT_CODE: 0` / `ok: true`; `final-poshqc-test.2026-09-07T20-08.md` `EXIT_CODE: 2`, attributable in full to the two ambient-state failures this reviewer independently confirmed are not change-caused (see Summary). No auto-fix occurred at the format stage, so no restart was owed. Caveat recorded: the `success` conclusion of CI run `34158596238` is orchestrator-attested and could not be read from the GitHub API in this session. |
| AC-24 | **PASS** | `evidence/qa-gates/manual-replay.2026-09-07T16-05.md` records the five 2026-08-24 over-match instances each proceeding and `git -C <dir> add .` denying against a not-ready checkpoint. |
| AC-25 | **PASS** | The structural `gh` classifier leg is present in all four `enforce-promotion-mcp-only.ps1` copies (Claude L126–130 and the Codex equivalent), byte-identical to their bundles. AT-5 is asserted per side (`hook-command-parser.AcceptanceCases.Tests.ps1` L156 and the Codex trigger-scoping suite) with concrete `drmoisan/drm-copilot` literals, and the paired negative `gh --repo drmoisan/drm-copilot issue list` allow is asserted in the same file (L222). |
| AC-26 | **PASS** | AT-1 at `hook-command-parser.AcceptanceCases.Tests.ps1` L72 drives `Invoke-EpicWorktreeRemovalGateDecision` with `git -C /repo/main worktree remove /repo/worktrees/item-a-101` against an unauthorizing epic checkpoint and asserts a deny beginning `EPIC_WORKTREE_REMOVAL_BLOCKED`. Fail-before recorded in `evidence/regression-testing/`; passing after in the same suite run. |
| AC-27 | **PASS** | AT-2 at L97 asserts `Get-EpicMergeGateCommandPrNumber` returns `688`, not `2026`, for the `cd C:\…\2026-08-29T00-11 && gh pr merge --merge 688` fixture. Both paired negatives pass in the same file: bare `--merge` returns `$null` (L201) and `gh pr merge 410 --merge` returns `410` (L208). |
| AC-28 | **PASS** | AT-4 at L136 drives `Invoke-EpicMergeGateDecision` with a `printf` whose double-quoted text mentions the gated phrase and asserts an allow. Fail-before recorded as a deny with `EPIC_MERGE_GATE_BLOCKED`. |
| AC-29 | **PASS** | AT-6 at L172 asserts `Test-ImplementationCommand` returns `$true` for `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`, in the same suite as AT-1 through AT-5 and AT-7. The existing pin at `enforce-orchestration-preimplementation-gate.Tests.ps1` line 140 passes unmodified. |
| AC-30 | **PASS** | AT-7 at L184 asserts both `Get-ParallelWorktreeRemovalCommandPath` and `Get-EpicWorktreeRemovalCommandPath` return `/repo/worktrees/item-a-101` for `git worktree remove --force /repo/worktrees/item-a-101`. The mechanism is `$script:CommandLineStandaloneFlagNames` containing `--force`, so operand collection does not terminate at the flag. The existing flag-after-path case at `enforce-parallel-worktree-removal-gate.Tests.ps1` line 78 passes unmodified (asserted again at `hook-command-invocation.Tests.ps1` L89). |
| AC-31 | **PASS** | AT-8, AT-9, AT-10 are named cases per side in `validate-bash.TriggerScoping.Tests.ps1` and `validate-bash-trigger-scoping.Tests.ps1` (4, 2, and 4 case instances respectively across both sides in the JUnit artifact). All six literals returned by `Get-BlockedBashPattern` are byte-unchanged at L53–60. The six existing denylist pins and the eight existing `cd`-chain pins in `validate-bash.Tests.ps1` pass unmodified — that suite is absent from the JUnit failing set. (The `cd`-chain wrapper regression is adjudicated under AC-09, which owns it; the eight pins AC-31 names all pass.) |
| AC-32 | **PASS** | AT-11 asserts the `grep` whose quoted search term is the disposition token is out of scope (allow); AT-12 asserts `Test-ParallelAbandonCommandInScope` returns `$true` for the `--disposition=abandon` spelling. Both token literals remain in single-assignment form at lines 41–42, and the dot-source lines were deliberately placed *below* them so those line numbers are unchanged — a considered detail. `test_parallel_abandon_token_seam.py` passes. The 24 existing cases pass unmodified, including the order-independence case at line 62. AT-12's D11.6 gate is discharged: the equals-joined bypass is confirmed by an executed run in `evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md`, not derived from `argparse` semantics alone. (The wrapper-led regression is adjudicated under AC-09.) |
| AC-33 | **PASS** | `Test-EpicBaseBranchOverride` evaluates its trigger through `Test-CommandLineInvocation` (`enforce-pr-author-skill.epic-base-branch.ps1` L72–74) and takes `--base` from `Get-CommandLineFlagValue` with an exact case-sensitive comparison (L106–110), which is a tightening: the old `-cnotmatch [regex]::Escape(...)` was a substring test that a longer branch name could satisfy. Named cases in `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` assert the relocating `gh --repo drmoisan/drm-copilot pr create` classification and that a quoted mention no longer produces `EPIC_BASE_BRANCH_MISMATCH`. The 113-line existing suite is absent from the JUnit failing set. Delivered in both Claude copies, byte-identical. |
| AC-34 | **PASS** | `.codex/hooks/enforce-epic-merge-gate.ps1` contains no unanchored whole-text digit scan. Grep of every regex in the file returns only `'^\d+$'` at L56 and L62, both anchored end to end and both applied to a value already retrieved by `Get-CommandLineOperand` or `Get-CommandLineFlagValue`. The intent is stated in the function's own `.DESCRIPTION` at L45–47. Corroborated by `evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md`. |
| AC-35 | **PASS** | All six public functions match D12's param blocks, types, and return shapes, each pinned by a named case asserting the parameter list and the `OutputType` attribute: `Read-CommandLineSegment` (`hook-command-scanner.Tests.ps1` L340) and `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention` (`hook-command-invocation.Tests.ps1` L300, 306, 312, 318, 324). All three constant accessors exist and are pinned by exact membership cases. |
| AC-36 | **PASS** | `Test-CommandLineFlag` exists (`hook-command-invocation.ps1` L422–453) and is called at all three presence-only sites: `--merge` (merge gate, both runtimes), `--body` and `--body-file` (pr-author helpers), `--force` (both worktree-removal gates). Named cases assert it distinguishes an absent flag from a valueless present flag (`hook-command-invocation.Tests.ps1` L159) and that `--body` does not match `--body-file` (L166), plus the `--flag=value` form (L174). |
| AC-37 | **PASS** | Both D11.6 follow-ups are filed as separate potential entries, not folded in: `docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md` and `docs/features/potential/2026-09-07-parallel-abandon-equals-joined-disposition-runtime-confirmation.md`. Both exist on disk at the head commit. |

### Adjudication of AC-09

AC-09 states, without qualification, "**No existing denial is weakened.**" Four denials present at
`6dff80ed` are absent at `85a3c344`. Each was established by extracting the base-commit copy of the
file and comparing the scope filter directly, not by inference.

| Command | At `6dff80ed` | At `85a3c344` | Mechanism |
|---|---|---|---|
| `bash -c "gh pr merge --merge 688"` | in scope; denies with `EPIC_MERGE_GATE_BLOCKED` absent an authorizing checkpoint | **allows** | `Test-CommandLineFlag … '--merge'` reads the wrapper-led segment's collapsed `Tokens`; `-not $hasMergeFlag` returns the allow decision |
| `bash -c "python … --disposition abandon"` | in scope; denies with `PARALLEL_ABANDON_BLOCKED` absent `--confirm-abandon` | **allows** | `Test-ParallelAbandonCommandInScope` reads `$segment.Tokens` with no wrapper fallback |
| `bash -c "gh pr edit 42 --body 'x'"` | Case A denies with `PR_AUTHOR_SKILL_BLOCKED` | **allows** | `Test-CommandLineFlag … '--body'` reads collapsed tokens; the `isPrEdit` no-body branch returns `$null` |
| `bash -c "cd /x && head f"` | denied by `$script:CdChainedReadCommandPattern` | **allows** | `Get-CdChainedReadCommandMatch` walks `CommandWord`; a wrapper-led segment's command word is `bash`, and quoted `&&` does not delimit |

None of these is covered by an accepted residual risk. D4.1 accepts *over*-match inside wrapper-led
segments and is explicitly deny-biased; these are allow-biased. D4.3 accepts an *unlisted* wrapper
such as `parallel`; `bash` is a listed member of the fourteen-name carve-out set. D3's conclusion
asserts the opposite of the observed behavior: "Every wrapper form D8 cited **that denies today**
keeps its denial."

The root cause is a single one: `Resolve-CommandLineInvocation` implements D12's fail-closed rules
for *classification* and reports `OperandIndex = -1` for a non-structural match, but
`Test-CommandLineFlag` and `Get-CommandLineFlagValue` then iterate `$resolved.Segment.Tokens`
unconditionally. Call sites that treat flag absence as **missing authorization** stay fail-closed
(both worktree-removal gates, the epic-base-branch hook, the pr-author `isPrCreate` branch). Call
sites that treat flag absence as **out of scope** fail open. The four above are the complete set of
the latter, established by enumerating every consumer of `Read-CommandLineSegment` across both
runtimes.

AC-09 is therefore **FAIL** and is unchecked in `spec.md` by this audit. The criterion's enumerated
sub-obligations — the two existing decision suites, the Claude gate suite denials at lines 112–149,
the Codex classification table at lines 348–358, the #539 D4 rows 14a–14d, the absolute-path suites,
and the pr-author suites — all pass, and only the single reversed heredoc `It` per side was
modified. The failure is against the criterion's absolute headline requirement, which is the part
that carries the safety guarantee.

## Summary

| Metric | Value |
|---|---|
| Total acceptance criteria | 37 |
| PASS | 35 |
| PARTIAL | 0 |
| FAIL | 1 (AC-09) |
| UNVERIFIED | 1 (AC-22) |
| Blocking findings | **1** (R-2, four instances, one root cause) |
| Recommendation | **No-Go pending remediation of R-2** |

### R-1 status: closed

The prior round's single blocking finding is verified closed by direct inspection rather than by
accepting the evidence artifact. `Get-BlockedPatternMatch` leg 1 now carries a second condition
scanning `$segment.ScanText` by ordinal `IndexOf`, gated on
`IsWrapperLed -or HasLiveSubstitution -or Unbalanced`. Those three disjuncts are **set-identical**
with the scanner's own ScanText selection at `hook-command-scanner.ps1` line 151, so the leg reads
raw text for exactly the segments the scanner scans raw and never for a segment whose ScanText is
masked. The change is present in all four copies, the four pairs are byte-identical, the six
denylist literals are byte-unchanged, and all ten pinning cases (`R1-C1`–`R1-C5`, `R1-X1`–`R1-X5`)
are present and passing in `artifacts/pester/pester-junit.xml`.

### The third disjunct (`Unbalanced`) was the right call

The remediation inputs specified `IsWrapperLed -or HasLiveSubstitution`. Preflight added
`Unbalanced` and the orchestrator ruled to apply it rather than defer. This reviewer confirms both
the necessity and the boundedness:

- **Necessary.** Without it, `git commit -m "rm -rf /tmp/x` with an unterminated quote takes the
  masked path — the tokenizer never closes the quote, the trailing text becomes one token, no token
  run matches — while the pre-change `String.Contains` denied. That is the R-1 mechanism
  reappearing through a second door left open by R-1's own fix. Deferring it would have closed
  AC-09 while a denial remained weakened, which is exactly the orchestrator's stated ground.
- **Not over-broad.** A segment is `Unbalanced` only when a quote never closes, a heredoc body never
  terminates, or a heredoc delimiter is produced by expansion. In each case the scanner has already
  declared the segment unresolvable and selected `RawText` as scan text under D2 Piece 2 clause 1.
  The disjunct adds no segment to the raw-scan set that the scanner did not already place there.
- **Correctly scoped in the scanner.** `$unbalanced` is reset per segment, and the post-loop
  assignment applies only to the final record. Because an unterminated quote consumes all subsequent
  delimiters, everything after the opening quote is genuinely one segment, so earlier balanced
  segments are not contaminated.
- **Pinned.** `R1-C5` and `R1-X5` assert the case and their comments state it "fails against a
  two-disjunct fix and passes only against the three-disjunct fix."

### Test execution, independently re-derived

`artifacts/pester/pester-junit.xml`: 99 suites, 2381 cases, 2 failures, 0 errors, 0 skipped.

Both failures are ambient-state artifacts of this worktree and were confirmed not change-caused:

- `enforce-pr-author-skill.Tests.ps1 > allowed commands > allows gh pr create --body-file …`: the
  `BeforeEach` omits `Mock Get-PrAuthorCheckpointContent`, so the hook reads the real gitignored
  `artifacts/orchestration/orchestrator-state.json`, which carries `"epic_mode": true` at line 24;
  the fixture command carries no `--base`, so `EPIC_BASE_BRANCH_MISMATCH` is returned. The test file
  is not in the branch diff, and the reviewer verified that the pre-change scope filter
  (`$CommandText -notmatch '(?i)\bgh\s+pr\s+create\b'`) and the post-change one
  (`Test-CommandLineInvocation … @('pr','create')`) both classify the fixture as in scope, so both
  reach the same denial for the same ambient state. Filed as F-4.
- `codex-pretooluse-integration.Tests.ps1`: `enforce-epic-wave-barrier.ps1` denies with
  `EPIC_WAVE_BARRIER_BLOCKED` after reading this worktree's gitignored epic checkpoint. Neither that
  hook nor that test file is in the branch diff.

### What is ready

Everything outside R-2. The parser design, the nine-hook copy-set delivery, byte parity across all
18 pairs and both runtimes, coverage above threshold on all 18 changed production files with zero
missing rows, the 500-line cap with zero violations, fourteen-entry registration completeness,
canonical evidence locations with a clean validator run, the additive #539 annotation, and three
filed follow-up entries.

R-2 is bounded to four call sites, has an in-repo reference implementation in
`enforce-promotion-mcp-only.ps1`, requires no design change, and touches no byte-unchanged literal.

## Acceptance Criteria Check-Off

Actions taken in `spec.md` by this audit, per `acceptance-criteria-tracking`:

| Criterion | Prior state | Action | Reason |
|---|---|---|---|
| AC-09 (`spec.md` line 1499) | `- [x]` | **Unchecked to `- [ ]`** | Evaluated FAIL. Four existing denials are weakened. Per the check-off protocol, an item evaluated FAIL is left unchecked with the gap documented. Criterion text unmodified. |
| AC-22 (`spec.md` line 1565) | `- [ ]` | Left unchecked | Evaluated UNVERIFIED. Its evidence is a PR body that does not yet exist; it closes on the PR body, as the caller stated and as this audit independently confirmed. |
| AC-01 – AC-08, AC-10 – AC-21, AC-23 – AC-37 | `- [x]` | Left checked, no change needed | Evaluated PASS. All were already checked; no criterion required a new check-off this round. |

No criterion text was modified. No criterion was added or removed.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
- Total AC items: 37
- Checked off (delivered): 35
- Remaining (unchecked): 2
- Items remaining:
  - AC-09: "No existing denial is weakened." — FAIL; four wrapper-led denials weakened (R-2)
  - AC-22: "Issue #591 is recorded as superseded by issue #545 and closed on merge. … The pull-request body states the supersession and names issue #591." — UNVERIFIED; closes on the PR body
```
