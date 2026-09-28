# Feature Audit: enforcement-hook-trigger-matches-whole-command-text (#545)

**Audit Date:** 2026-09-07
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration`
**Head Branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/cleanup-merged-worktrees-hardening-integration` (commit `6dff80ed4596bec088d548b23013e6077e32c484`)
- **Head branch/commit:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` (commit `77cb427df4e219dc2603fad791b8669eaf96629b`)
- **Merge base:** `6dff80ed4596bec088d548b23013e6077e32c484` — a direct ancestor of the head, so the unscoped range `6dff80ed..77cb427d` is evaluable
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (913 lines, generated 2026-09-07 17:32:27 UTC, head SHA matches)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (547 lines)
  - Feature evidence: `docs/features/active/…-545/evidence/**` — 100 artifacts across `baseline/`, `qa-gates/`, `regression-testing/`, `issue-updates/`, `other/`
  - Direct verification by this reviewer: `git diff`, `cmp`, `wc -l`, `grep`, `poetry run pytest`, and Python parsing of `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`
- **Feature folder used:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545` — selected because its `-545` suffix matches the issue number in the branch name and it carries the primary changed scoping documents
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** Explicit. The marker `- Work Mode: full-bug` is persisted at `issue.md:12`. Under the work-mode contract, `full-bug` resolves the acceptance-criteria source to `spec.md` alone; `user-story.md` is present in the folder but is **not** an AC source for this mode and was not evaluated as one.
- **Scope note:** The audit is the **full branch diff against the resolved base**, not any plan, task, or phase subset. No caller instruction attempted to narrow it; the delegating prompt explicitly assigned scope determination to this reviewer. 168 files changed (+9928 / −149): 63 `.ps1`, 2 `.psd1`, 2 `.json`, 101 `.md`. PowerShell is the only coverage language with changed files.
- **Coverage-evidence validity note:** The coverage figures were measured at commit `5903d0c7`, the pre-rebase equivalent of `HEAD~1`. This reviewer verified the measurement remains valid for the head: `git diff --name-only 5903d0c7 77cb427d` restricted to all in-scope hook, test, settings, and manifest paths returns **no output**, and the only difference between `HEAD~1` and `HEAD` is 15 Markdown files.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md` — **only source** (work mode `full-bug`)

Criteria live under the `## Acceptance Criteria` heading at line 1451, terminated by `## Risks & Mitigations` at line 1650. **37 checkbox items**, enumerated programmatically rather than counted by eye. Criterion numbering below is positional (AC-01 … AC-37) and is this audit's convention; `spec.md` does not number them.

### Acceptance criteria (abbreviated labels; full text at the cited `spec.md` line)

1. AC-01 (L1453) — Over-match regression test exists and is recorded failing against the unfixed hooks.
2. AC-02 (L1457) — Under-match regression test exists and is recorded failing against the unfixed hooks.
3. AC-03 (L1461) — Both regression tests pass after the fix, on both sides, with pass-after output recorded.
4. AC-04 (L1463) — Scanner produces the five D2 Piece 1 properties; a named case per heredoc rule.
5. AC-05 (L1468) — Three ordered `ScanText` clauses; exact 14-member wrapper set pinned through `Get-CommandLineWrapperName`.
6. AC-06 (L1476) — Structural relocation classifier implements the six D2 Piece 3 steps, with five named cases.
7. AC-07 (L1480) — Named trigger literals are byte-unchanged, verified by diff inspection.
8. AC-08 (L1484) — Every D3 fail-closed row has a named case per applicable side, including seven wrapper deny pins.
9. AC-09 (L1488) — **No existing denial is weakened**; enumerated suites pass unmodified except one reversed `It` per side.
10. AC-10 (L1494) — Issue #539 exemption layer unchanged; allow-side only; consulted at the same point (R5).
11. AC-11 (L1498) — `enforce-promotion-mcp-only.ps1` changed in all four copies to evaluate per-segment scan text.
12. AC-12 (L1503) — `enforce-pr-author-skill-helpers.ps1` changed in both Claude copies; relocating spellings classify.
13. AC-13 (L1508) — Parser ships as exactly two dot-sourced `.ps1` files at four locations (eight files), ≤ 500 lines each.
14. AC-14 (L1514) — Registration set complete: fourteen entries across five registry files; coverage-list edits textually identical.
15. AC-15 (L1521) — Both parity mechanisms green in the same change; both pack-manifest assertions pass.
16. AC-16 (L1526) — Recomputed pair-hash parity evidence recorded, computed at the final commit.
17. AC-17 (L1530) — Every touched or added file ≤ 500 lines, verified by contract suite and an explicit artifact.
18. AC-18 (L1533) — Line coverage ≥ 85% on every changed/added production file; scanner inside the denominator both sides.
19. AC-19 (L1537) — No Python introduced anywhere; the no-python scan passes with the new helper in its scan set.
20. AC-20 (L1541) — Issue #539's `spec.md` annotated additively at all five D8 locations, additions only.
21. AC-21 (L1546) — All nine in-scope hooks carry a diff across their full copy sets; no policy file and no tenth hook touched.
22. AC-22 (L1554) — Issue #591 recorded as superseded and closed on merge; the PR body states it and names #591.
23. AC-23 (L1558) — PoshQC toolchain passes clean in a single pass, format → analyze → test, results recorded.
24. AC-24 (L1562) — Manual replay recorded: five over-match instances proceed; `git -C <dir> add .` denies.
25. AC-25 (L1565) — Promotion hook, all four copies, denies relocating `gh issue create` / `issue new` (AT-5); paired negative allows.
26. AC-26 (L1573) — AT-1 latent-bypass case denies with an `EPIC_WORKTREE_REMOVAL_BLOCKED` reason; fail-before recorded.
27. AC-27 (L1581) — AT-2 issue #591 operand mis-parse fixed; returns `688` not `2026`; two paired negatives.
28. AC-28 (L1587) — AT-4 merge-gate over-match allows; recorded failing as a deny against the unfixed hook.
29. AC-29 (L1591) — AT-6 wrapper deny pin still denies; runs in the same suite as AT-1…AT-5 and AT-7.
30. AC-30 (L1597) — AT-7 cross-runtime divergence closed; both path getters return the path, not `--force`.
31. AC-31 (L1604) — `validate-bash.ps1` matching-primitive change delivered and pinned (AT-8, AT-9, AT-10); six literals byte-unchanged; existing pins pass.
32. AC-32 (L1611) — `enforce-parallel-abandon-gate.ps1` fixed in both Claude copies and pinned (AT-11, AT-12); seam test passes.
33. AC-33 (L1620) — `enforce-pr-author-skill.epic-base-branch.ps1` fixed in both Claude copies; 113-line existing suite passes unmodified.
34. AC-34 (L1627) — Codex merge gate does not acquire the Claude copy's unanchored digit-scan defect.
35. AC-35 (L1631) — D12 parser contract documented and honoured; a named case per function; three constant accessors pinned.
36. AC-36 (L1639) — `Test-CommandLineFlag` exists and is exercised by all three presence-only call sites.
37. AC-37 (L1644) — The two D11.6 follow-ups filed as separate potential entries, each citing this spec.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-01 | Over-match regression test recorded failing | PASS | `evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md`, `fail-before-codex-triggerscoping.2026-09-07T11-44.md` | `ls docs/features/active/…-545/evidence/regression-testing/` | Seven `[expect-fail]` artifacts present under the required path. |
| AC-02 | Under-match regression test recorded failing | PASS | `evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md`, `fail-before-codex-commandexemption.2026-09-07T11-52.md` | same | `git -C ../x add .` direction covered. |
| AC-03 | Both directions pass after the fix, both sides | PASS | `evidence/regression-testing/pass-after-both-directions.2026-09-07T17-22.md` — seven `[expect-fail]` artifacts, seven paired pass-after runs, **zero unpaired** | Local JUnit parse | Corroborated: `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` 59 cases 0 fail; `*.TriggerScoping.Tests.ps1` suites 0 fail. |
| AC-04 | Five scanner properties + a case per heredoc rule | PASS | `hook-command-scanner.ps1` returns `RawText`, `MaskedText`, `Tokens`, `CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`, `Unbalanced`, `ScanText` — the five named plus three additions | `cat .claude/hooks/hook-command-scanner.ps1`; local JUnit | `hook-command-scanner.Tests.ps1` 42 cases, 0 failures. All seven heredoc rules named in the criterion are implemented: `<<`, `<<-`, quoted delimiter, multiple pending heredocs, unterminated body, `<<<` here-string, non-literal delimiter → `Unbalanced`. |
| AC-05 | Three `ScanText` clauses + exact 14-member wrapper set | PASS | `ConvertTo-CommandLineSegmentRecord` applies the clauses in order (`Unbalanced` → `HasLiveSubstitution` → `IsWrapperLed` → `MaskedText`); the constant holds exactly the 14 names of D2 Piece 2 | Source inspection + `Get-CommandLineWrapperName` accessor | Constant, accessor, and spec list agree. The D11.4 optional additions were not adopted, so no amendment was required. |
| AC-06 | Six D2 Piece 3 steps + five named cases | PASS | `Resolve-CommandLineInvocation` implements `VAR=` skip → transparent-wrapper skip → command-word match → option absorption → subcommand match → operand index | Local JUnit: `hook-command-invocation.Tests.ps1` 44 cases, 0 failures | All five named cases present, including the `git log --grep add` negative that distinguishes structure from adjacency. |
| **AC-07** | **Trigger literals byte-unchanged** | **PARTIAL** | Four of five literal groups verified byte-unchanged **against this audit's merge-base** `6dff80ed`; the pr-author clause is falsified | `git diff 6dff80ed..HEAD -- '*.ps1' > /tmp/full.diff`; `grep -E "^-" /tmp/full.diff \| grep -E "<literal>"`; `grep -nE "^[-+].*bgh" /tmp/full.diff` | **Adjudication below.** Verified byte-unchanged: the five preimplementation trigger patterns (all 4 copies), the four promotion forbidden-token literals (4 copies), the `gh issue create/new` expression string (4 copies), `$ghApiIssuesPostPattern` whole declaration line (4 copies), the six `validate-bash` denylist literals (4 copies), `$script:CdChainedReadCommandPattern` (2 copies), and the two abandon token constants (2 copies). No `-` line in the full diff removes any of them; only *usages* changed. **Falsified:** `'(?i)\bgh\s+pr\s+create\b'` and `'(?i)\bgh\s+pr\s+edit\b'` deleted at diff lines 397/398 and 3430/3431; `'(?i)\bgh\s+pr\s+create\b'` also deleted at 441/3474. |
| **AC-08** | Every D3 row has a named case per applicable side | PASS | `evidence/qa-gates/d3-row-test-mapping.2026-09-07T16-08.md`; `evidence/qa-gates/deny-preservation-audit.2026-09-07T16-11.md` | Local JUnit per-suite parse | All seven wrapper deny pins are asserted **on the preimplementation-gate side**, where D3's rows are stated. `pwsh -NoProfile -Command "Invoke-Pester …"` passes in `enforce-orchestration-preimplementation-gate.Tests.ps1` (35 cases, 0 failures) and in the AT-6 case. See AC-09 for the separate finding that D3's wrapper guarantee was never re-derived for `validate-bash.ps1`. |
| **AC-09** | **No existing denial is weakened** | **PARTIAL** | Every *enumerated* clause verified passing; the *headline invariant* is falsified for `validate-bash.ps1` wrapper forms | Source trace of `Get-BlockedPatternMatch`; `grep -rn 'bash -c\|sh -c\|pwsh -Command\|pwsh -NoProfile' tests/scripts/*/validate-bash*.ps1` → **no matches** | **Enumerated clauses PASS**, independently corroborated from the local JUnit: Claude gate suite 35/0, Codex classification table (incl. `git commit -m "wip"` → `$true`) 43/0, D4 rows 14a–14d both sides 59/0 each, absolute-path suites 33/0 and 35/0, pr-author suites 43+9+3+18/0 apart from the ambient case. Exactly two `It` assertions reversed, as intended. **Headline FAILS:** `Get-BlockedPatternMatch` leg 1 compares the six literals against `$segment.Tokens`, never `$segment.ScanText`, so a quoted span collapses to one token and no contiguous run matches. `bash -c "rm -rf /tmp/x"`, `sh -c 'rm -rf /'`, and `pwsh -Command "Remove-Item -Recurse -Force x"` returned a literal before this change (`$Command.Contains($pattern)`) and return `$null` after it. All four `validate-bash` copies affected; **no test pins any wrapper form**. This contradicts D3 rows 2 and 4 and is not covered by the D4 residuals (D4.1 is over-match, D4.2 obfuscation, D4.3 *unlisted* wrappers — `bash`, `sh`, `pwsh` are listed members). See code review CR-1. |
| AC-10 | #539 exemption layer unchanged | PASS | `evidence/qa-gates/539-exemption-layer-unchanged.2026-09-07T16-12.md`; `enforce-orchestration-preimplementation-gate-helpers.ps1` absent from the changed-file list | `git diff --name-only 6dff80ed..HEAD \| grep helpers` | The exemption remains allow-side only and is consulted at the same point: the diff shows only the loop condition changed, not the position of the exemption consultation. 59/0 on both CommandExemption suites, including all eight allow-side D4 cases. |
| AC-11 | Promotion hook, all four copies, per-segment scan text | PASS | Diff of `enforce-promotion-mcp-only.ps1` shows the token loop and both `gh` expressions moved onto `$segment.ScanText`, plus the structural `gh` leg | `git diff`; `cmp -s` for all four copies | Local JUnit: `enforce-promotion-mcp-only.Tests.ps1` 29/0, `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` 8/0. Named cases assert receipt-value allow and genuine-invocation deny. |
| AC-12 | pr-author helpers, both Claude copies | PASS | Diff shows `$isPrCreate` / `$isPrEdit` on `Test-CommandLineInvocation` and `$hasBodyFile` / `$hasInlineBody` on `Test-CommandLineFlag` | `git diff`; local JUnit | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` 18/0. `--body` does not match `--body-file` by exact token comparison. Every `PR_*` reason code is unchanged in the diff. |
| AC-13 | Two `.ps1` files, eight copies, ≤ 500 lines, no `.psm1`, no `.claude/lib/` | PASS | All eight files verified present; both are `.ps1`; 450 and 483 lines | `for p in …; do [ -f "$p/$f" ]; done`; `wc -l`; `grep 'CLAUDE_\|Console]::In\|Read-Host'` → none; `ls .claude/hooks/hook-command*.psm1` → none; `git diff --name-only … -- '.claude/lib/**'` → none | Both define functions only, read no stdin, contain no `$env:CLAUDE_` reference. Claude and Codex canonical copies are byte-identical to each other (`cmp -s`). |
| AC-14 | Fourteen registration entries across five files | PASS | Counted from the diff: 2 manifests × 2 helpers = 4; `$script:SharedModuleNames` × 2 = 2; 2 coverage lists × 2 helpers × 2 runtime paths = 8. Total **14** | `git diff … -- '**/core.json' '**/pester.runsettings.psd1' 'legacy-codex-hook-contracts.Tests.ps1'` | The two `pester.runsettings.psd1` hunks are **textually identical**, as `test_poshqc_bundled_parity.py` requires — that test passes (`poetry run pytest`, this reviewer). Eight additional coverage entries for four previously-unregistered Codex hooks are additive and consistent with the Coverage Exclusion Policy. |
| AC-15 | Both parity mechanisms green in the same change | PASS | `evidence/qa-gates/parity-mechanisms.2026-09-07T15-57.md`; `final-pack-manifest-completeness.2026-09-07T17-27.md` (2 passed, 16 passed) | `cmp -s` over all 18 canonical/bundle pairs → **all identical**; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Independently re-derived by this reviewer rather than accepted from the artifact. `test_bundled_claude_payload_contains_required_runtime_files` and `test_poshqc_bundled_module_files_match_repo_root_sources` both pass. |
| AC-16 | Recomputed pair-hash parity at the final commit | PASS | `evidence/other/pair-hash-parity.2026-09-07T15-52.md`, confirmed by `[P13-T1]` as still describing the final tree | `cmp -s` (byte comparison, stronger than hash equality) | This reviewer verified content identity directly for all 18 pairs rather than re-deriving the hashes, which is a superset of the hash claim. |
| AC-17 | Every touched or added file ≤ 500 lines | PASS | Max over all 63 changed `.ps1` files is **exactly 500** | `while read f; do wc -l < "$f"; done < /tmp/ps1list.txt \| sort -rn`; `awk '$1>500'` → **no rows** | Two files sit at exactly 500 (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its mirror), i.e. zero headroom. Compliant, but see code review CR-7. |
| AC-18 | Line coverage ≥ 85% on every changed/added production file | PASS | `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md` — **18 of 18 PASS**, lowest 88.3117% | CI run `34145103168`; independent XML re-derivation by this reviewer | Nine Claude-side percentages independently re-derived from `artifacts/pester/powershell-coverage.xml` by package-qualified parsing and match the recorded CI figures to four decimal places. `hook-command-scanner.ps1` is inside the denominator on **both** sides (97.7778% Claude, 100.0000% Codex). This reviewer confirmed the stated reason for not using the MCP runner: the local MCP-produced coverage XML contains **zero** `hook-command-scanner` occurrences. |
| AC-19 | No Python introduced anywhere | PASS | `evidence/qa-gates/no-python-scan.2026-09-07T15-58.md` | `git diff --name-only 6dff80ed..HEAD \| grep '\.py$'` → **no matches** | The no-python suite scans `$script:ScanRoot` recursively for `.ps1`/`.psm1`, so the new helpers are in its scan set by construction rather than by list maintenance. No added or modified file invokes a Python interpreter. |
| AC-20 | #539 spec annotated additively at five locations | PASS | `evidence/qa-gates/539-spec-additive-only.2026-09-07T15-40.md` | `git diff 6dff80ed..HEAD -- 'docs/features/active/…-539/spec.md'` | The diff for that file contains additions only; no existing sentence, table row, or decision text is edited in place. Each note cites issue #545. |
| AC-21 | Nine hooks, full copy sets, nothing else touched | PASS | Exactly 11 canonical `.claude/hooks/` and 7 canonical `.codex/hooks/` files changed (9 hooks + 2 parser files) | `grep -E '^(\.claude\|\.codex)/hooks/' /tmp/all.txt`; `grep -E '^(\.claude/rules/\|\.github/instructions/)' /tmp/all.txt` → **none** | Five hooks in all four locations, four Claude-only hooks in two locations each — verified individually. No policy file modified; no tenth hook modified. |
| **AC-22** | **#591 supersession recorded; PR body states it** | **PARTIAL** | Supersession text exists at `evidence/issue-updates/issue-591.2026-09-07T15-41.md` with `PostedAs: unknown`; no separate follow-up candidate filed for the four D11 instances | `ls docs/features/potential/2026-09-07-*` → exactly the two D11.6 entries, neither a #591 instance | **Adjudication below.** Two of three clauses are satisfied and verifiable now. The third — "The pull-request body states the supersession and names issue #591" — depends on a PR body that does not exist for this branch. This is a **pre-PR gate condition for `pr-author`**, not a code or evidence gap. It cannot be closed at review time and must not be checked off speculatively. |
| AC-23 | PoshQC toolchain clean in a single pass | PASS | `final-poshqc-format.2026-09-07T17-03.md` (set-difference 0), `final-poshqc-analyze.2026-09-07T17-05.md` (0 diagnostics), `final-selfhosted-test.2026-09-07T17-11.md` | Timestamps 17-03 → 17-05 → 17-11, strictly monotonic | Single-pass claim accepted. The supporting observation is the right one: a formatter set-difference of 0 (not the exit code, which is 0 either way) plus a working tree in which every outstanding path afterwards is Markdown. |
| AC-24 | Manual replay recorded | PASS | `evidence/qa-gates/manual-replay.2026-09-07T16-05.md` | Artifact inspection | Five 2026-08-24 over-match instances each proceed; `git -C <dir> add .` denies against a not-ready checkpoint. |
| AC-25 | Promotion hook denies relocating `gh issue create`/`new` (AT-5) | PASS | Diff adds the structural `gh` leg to all four copies with concrete owner/repo literals | Local JUnit: `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` 8/0 | Named case per side. The paired negative `gh --repo drmoisan/drm-copilot issue list` allows, asserted in the same file — verified present. |
| AC-26 | AT-1 latent-bypass case denies | PASS | `evidence/regression-testing/pass-after-acceptance-cases.2026-09-07T17-20.md`; fail-before recorded | Local JUnit: `hook-command-parser.AcceptanceCases.Tests.ps1` 11 cases, 0 failures | Recorded failing (as an allow) against the unfixed hook and passing after, in the same suite run. |
| AC-27 | AT-2 #591 operand mis-parse fixed | PASS | `Get-EpicMergeGateCommandPrNumber` now resolves via `Get-CommandLineOperand` then `Get-CommandLineFlagValue`; the unanchored digit-scan branch is deleted | Source inspection; local JUnit `enforce-epic-merge-gate.Tests.ps1` 56/0 | Returns `688` not `2026`. Both paired negatives present: bare `--merge` → `$null`, `gh pr merge 410 --merge` → `410`. The function help documents both original failure directions. |
| AC-28 | AT-4 merge-gate over-match allows | PASS | Structural scope filter `Test-CommandLineInvocation` + `Test-CommandLineFlag` replaces the two raw-text matches | Local JUnit: `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` 9/0 | Recorded failing as a deny with `EPIC_MERGE_GATE_BLOCKED` against the unfixed hook. |
| AC-29 | AT-6 wrapper deny pin still denies | PASS | `evidence/qa-gates/deny-preservation-audit.2026-09-07T16-11.md` §1, row 4 | Local JUnit: `enforce-orchestration-preimplementation-gate.Tests.ps1` 35 cases, **0 failures** | `Test-ImplementationCommand` returns `$true` for `pwsh -NoProfile -Command "Invoke-Pester …"`. The case runs in the same suite as AT-1…AT-5 and AT-7, and the existing pin at line 140 passes unmodified. |
| AC-30 | AT-7 cross-runtime divergence closed | PASS | `$script:CommandLineStandaloneFlagNames` includes `--force`, so it contributes no operand; both path getters return the path | Local JUnit: `enforce-parallel-worktree-removal-gate.Tests.ps1` 45/0, `enforce-epic-worktree-removal-gate.Tests.ps1` 46/0 | Both return `/repo/worktrees/item-a-101` for `git worktree remove --force /repo/worktrees/item-a-101`, where both returned `--force` before. The existing flag-after-path case passes unmodified. |
| AC-31 | `validate-bash.ps1` primitive change delivered and pinned | PASS | AT-8/AT-9/AT-10 cases present; six `Get-BlockedBashPattern` literals byte-unchanged | Local JUnit: `validate-bash.Tests.ps1` **26 cases, 0 failures**; `validate-bash.TriggerScoping.Tests.ps1` 7/0 | Every enumerated clause is satisfied and independently corroborated: the six existing denylist pins and eight existing `cd`-chain pins pass unmodified. **Note:** the wrapper-form weakening is a *separate* defect that falls under AC-09's headline invariant, not under any clause AC-31 enumerates. Recording it here as well would double-count it. |
| AC-32 | `enforce-parallel-abandon-gate.ps1` fixed and pinned | PASS | `Test-ParallelAbandonSegmentDisposition` recognises both spellings by deriving them from `$script:AbandonDispositionToken`; the dot-source is placed below lines 41–42 so both literals keep their single-assignment form and line numbers | Local JUnit: `enforce-parallel-abandon-gate.Tests.ps1` **24 cases, 0 failures** (the 24 existing cases, incl. order-independence at line 62); `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` 3/0; `test_parallel_abandon_token_seam.py` passes | **AT-12's gate is satisfied.** The criterion forbids check-off until the equals-joined bypass is confirmed by an executed run rather than derived from `argparse` semantics; `evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md` supplies that confirmation. |
| AC-33 | `enforce-pr-author-skill.epic-base-branch.ps1` fixed, both copies | PASS | `Test-EpicBaseBranchOverride` evaluates through `Test-CommandLineInvocation`; `--base` comes from `Get-CommandLineFlagValue` | Local JUnit: `enforce-pr-author-skill.epic-base-branch.Tests.ps1` **9 cases, 0 failures**; `…TriggerScoping.Tests.ps1` 2/0 | The existing suite passes unmodified. Case-sensitive branch-name comparison preserved via `-cne`, matching the previous `-cnotmatch` semantics. Both `cmp -s` copies identical. |
| AC-34 | Codex merge gate acquires no digit scan | PASS | `.codex/hooks/enforce-epic-merge-gate.ps1` resolves the PR number through `Get-CommandLineOperand` (line 55) and `Get-CommandLineFlagValue` (line 61) only | `grep -n "Matches\[\|-match '.*\\\\d" .codex/hooks/enforce-epic-merge-gate.ps1` | The two `-match '^\d+$'` occurrences are **anchored validations of an already-extracted token**, not unanchored whole-text scans. Verified by direct source inspection, not only by the evidence artifact. |
| AC-35 | D12 parser contract documented and honoured | PASS | Signatures of all six public functions compared line-by-line against the D12 code blocks: parameter names, types, `[Parameter(Mandatory)]`, `[AllowEmptyString()]`/`[AllowNull()]`/`[ValidateNotNullOrEmpty()]` attributes, and `[OutputType]` all match | Source comparison of `spec.md` L887–1160 against both parser files | Three constant accessors exist and are pinned: `Get-CommandLineWrapperName`, `Get-CommandLineTransparentWrapperName`, `Get-CommandLineGlobalOption`. A named case per function asserts parameter names and `OutputType`. |
| AC-36 | `Test-CommandLineFlag` exists and serves all three call sites | PASS | Present in both parser copies. Call sites confirmed: `enforce-epic-merge-gate.ps1` (`--merge`), `enforce-pr-author-skill-helpers.ps1` (`--body`, `--body-file`), both worktree-removal gates (`--force`) | `evidence/qa-gates/test-commandlineflag-call-sites.2026-09-07T16-13.md`; source inspection | Named cases assert an absent flag is distinguished from a valueless present flag, and that `--body` does not match `--body-file` by exact token comparison. |
| AC-37 | Two D11.6 follow-ups filed as separate potential entries | PASS | `docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md` (4812 bytes) and `…-parallel-abandon-equals-joined-disposition-runtime-confirmation.md` (5810 bytes) | `ls -la docs/features/potential/2026-09-07-*` | Both exist as separate entries, not folded in. Each cites this specification and D11.6. |

### Adjudication: AC-07 (referred by the orchestrator)

**Verdict: PARTIAL. The criterion is unsatisfiable as written, and the cause is a specification defect rather than an implementation defect.**

The orchestrator declined to resolve this in its own favour and offered its reading as an argument. Evaluated independently, that reading is largely right but reaches the wrong disposition.

What is verifiable: four of the five literal groups AC-07 names are byte-unchanged. This audit re-performed the check against **its own merge-base** `6dff80ed` rather than relying on the evidence artifact, which used base `288ca214`. In the full `*.ps1` diff, no `-` line removes any of the five preimplementation trigger patterns, the four promotion forbidden-token literals, `$ghApiIssuesPostPattern`, the six `validate-bash` denylist literals, `$script:CdChainedReadCommandPattern`, or the two abandon token constants. Only *usages* were removed. The `gh issue create/new` expression string survives byte-identically inside a reindented line — the criterion says "expressions", not "lines", so that is conformant.

What is falsified: `'(?i)\bgh\s+pr\s+create\b'` and `'(?i)\bgh\s+pr\s+edit\b'` are deleted outright.

The decisive point is that the conflict is **internal to `spec.md`**. D12's "Call-site rewrites for the D11 hooks" table directs `enforce-pr-author-skill-helpers.ps1 L170–171` → `Test-CommandLineInvocation`, which takes no pattern operand. That same table marks four other rows explicitly "**byte-unchanged**" — the promotion token loop, promotion L110–111, preimplementation L137, and `validate-bash` L73 — and pointedly does **not** so mark the pr-author rows. That asymmetry is deliberate drafting, not oversight, and it makes D12 the later and more specific statement. AC-31 independently requires `Test-EpicBaseBranchOverride` to evaluate through `Test-CommandLineInvocation`, which necessarily removes the third literal. The delivered code is conformant to D12 and to AC-31.

The orchestrator's rule-R2 framing ("the fix must change HOW detection happens, never WHAT is detected") is sound and is exactly why the other four groups were preserved. But it does not make AC-07 *inapplicable*; it explains why AC-07's fifth clause was superseded. A criterion that a document's own later sections contradict is not satisfied — it is defective, and the honest record is PARTIAL plus an amendment, not a silent pass. The criterion therefore remains unchecked, and the remediation is documentation-only.

### Adjudication: AC-22 (referred by the orchestrator)

**Verdict: PARTIAL. Correctly left unchecked; not remediable at review time.**

Three clauses. Two are satisfied and verifiable now: the supersession text exists at
`evidence/issue-updates/issue-591.2026-09-07T15-41.md`, and no separate follow-up candidate was filed
for the merge-gate, worktree-removal, abandon-gate, or `validate-bash` instances — verified by
inspecting `docs/features/potential/`, which contains exactly the two D11.6 entries, neither of which
is a #591 instance. The third clause requires the PR body to state the supersession and name #591, and
no PR exists for this branch.

The orchestrator's handling was correct on both counts: it did not check the criterion off
speculatively, and it recorded `PostedAs: unknown` rather than implying the comment had been posted.
This is a **gate condition on `pr-author`**, not a defect. It should be closed by the PR author, and
the criterion checked off only once the PR body carries the statement.

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 34 criteria
- **PARTIAL:** 3 criteria (AC-07, AC-09, AC-22)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Every criterion was evaluated against evidence this reviewer inspected. Where local tooling permitted,
the executor's claims were independently re-derived rather than accepted: coverage percentages from the
raw XML, per-suite pass counts from the raw JUnit, byte parity by `cmp` over all 18 pairs, line counts
by `wc -l` over all 63 changed files, literal preservation by diff inspection against this audit's own
merge-base, and evidence-location compliance by the repository validator. Every re-derivation agreed
with the recorded evidence. No criterion required an UNVERIFIED disposition.

**Top gaps preventing PASS:**

1. **AC-09 — an existing denial is weakened and unpinned (Major).** `Get-BlockedPatternMatch` leg 1 in
   all four `validate-bash.ps1` copies compares the six denylist literals against `$segment.Tokens`
   rather than `$segment.ScanText`, so the wrapper carve-out never reaches it.
   `bash -c "rm -rf /tmp/x"`, `sh -c 'rm -rf /'`, and `pwsh -Command "Remove-Item -Recurse -Force x"`
   denied before this change and allow after it. No test in any of the four `validate-bash` suites pins
   a wrapper form. This contradicts spec D3 rows 2 and 4 and is not among D4's accepted residuals.
   **This is the one gap that should be closed before merge.**
2. **AC-07 — the criterion is internally unsatisfiable (Minor, documentation only).** Its pr-author
   clause is contradicted by the same spec's D12 call-site table and by AC-31. Requires a spec
   amendment recording the supersession; no code change.
3. **AC-22 — blocked on an artifact that does not yet exist (Minor, not remediable here).** Two of three
   clauses satisfied; the third depends on a PR body. A `pr-author` gate condition.

**Recommended follow-up verification steps:**

1. Fix CR-1: give `Get-BlockedPatternMatch` leg 1 a `ScanText` comparison for segments where
   `IsWrapperLed -or HasLiveSubstitution`, preserving leg-1 ordering so `git push origin --force` still
   returns its own literal. Add three pinning cases per side. Re-run
   `tests/scripts/claude-hooks/validate-bash*.Tests.ps1` and
   `tests/scripts/codex-hooks/validate-bash*.Tests.ps1` and confirm the 26 + 7 existing Claude cases and
   the 329-line Codex decision-surface suite still pass. Then re-check AC-09.
2. Amend AC-07 in `spec.md` to record that its pr-author clause is superseded by the D12 call-site table
   and AC-31, then re-check AC-07.
3. At `pr-author` time, include the issue #591 supersession statement from
   `evidence/issue-updates/issue-591.2026-09-07T15-41.md` in the PR body, then check off AC-22.
4. File follow-ups for the two residuals that should not be fixed in this change: leaf-of-path wrapper
   resolution (CR-5 — needs a simultaneous amendment to D2 Piece 2 and AC-05) and the duplicated
   worktree-path helper bodies (CR-3).
5. Confirm epic amendment EA-3 is carried into the epic's follow-up register. **Correction for that
   register:** the Codex sibling is `Test-CodexChildMergeReady` at `.codex/hooks/enforce-epic-merge-gate.ps1:69`,
   consulted at line 137 with only `-Checkpoint $child`, not `Test-CodexCheckpointAllowsMerge` as
   previously reported. The substance of the finding — same single-parameter shape, consulted first, a
   fix needs both copies — is confirmed correct.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if represented as markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Changes made to `spec.md` by this review

**One checkbox changed: AC-09 was un-checked.**

AC-09 (`spec.md` line 1488) was `[x]` on entry. This audit evaluates it **PARTIAL**, because its
headline invariant "No existing denial is weakened" is falsified by the `validate-bash.ps1`
wrapper-with-quoted-argument regression documented above, even though every clause it enumerates
passes. The tracking rule that PARTIAL items "must remain unchecked" requires the box to be cleared so
the source file does not assert a verified state the evidence contradicts. Only `- [x]` → `- [ ]`
changed; the criterion text is untouched.

**No criterion was newly checked off.** All 34 PASS criteria were already `[x]`. AC-07 and AC-22 were
already `[ ]` and remain so, which was the correct prior state.

### AC Status Summary

- Source: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
- Total AC items: **37**
- Checked off (delivered): **34**
- Remaining (unchecked): **3**
- Items remaining:
  - **AC-07** (L1480) — trigger literals byte-unchanged. PARTIAL: four of five literal groups verified byte-unchanged; the pr-author clause is superseded by D12 and AC-31 and requires a spec amendment.
  - **AC-09** (L1488) — no existing denial is weakened. PARTIAL: all enumerated suite clauses pass; the headline invariant is falsified for `validate-bash.ps1` wrapper forms (`bash -c`, `sh -c`, `pwsh -Command`). **Un-checked by this review.**
  - **AC-22** (L1554) — issue #591 supersession. PARTIAL: text and no-duplicate-follow-up clauses satisfied; the PR-body clause is blocked until `pr-author` runs.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 37 | 34 | 3 | Checkbox-backed; sole authoritative source under work mode `full-bug` |
| `user-story.md` | n/a | n/a | n/a | Present in the folder but **not** an AC source under `full-bug`; not evaluated |
| `issue.md` | n/a | n/a | n/a | Work-mode marker source only; not an AC source under `full-bug` |
