# Remediation Cycle 1 — Closeout Summary, issue #554

Timestamp: 2026-08-28T00-57
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T16]
Command: Reconciliation of the twenty-three evidence artifacts this cycle produced; no additional command was issued
EXIT_CODE: 0

- Issue: **#554**
- Remediation cycle: **1**
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3`
- Branch head at Phase 0: `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`
- Merge base: `1e991b86d78e4f979922b79268f19ca0e5ab19e3`
- Work mode: `full-bug`; acceptance-criteria source is `spec.md` exclusively

## Per-finding disposition

### R1 (audit B1) — CLOSED

`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` was a new production file at
81.82% (24 uncovered of 132), below the 85% uniform threshold. The executor's decision-D5
attribution was rejected by the cycle-1 audit because every uncovered function takes a `[string]` and
returns a `[string]`, so calling one constructs no `Agent` envelope.

- **Closing tasks:** [P1-T2], [P1-T3], [P1-T4] — seven `It` blocks covering the unknown-mode
  `return ''` at line 197, the whole body of `Find-OrchestrationDelegationTargetFolder`, and the whole
  body of `Find-OrchestrationDelegationIssueNumber`.
- **Proving artifact:** `evidence/qa-gates/r1-codex-modes-coverage.2026-08-27T22-47.md`
- **Outcome:** 130 covered / **2 missed** / 132 measured = **98.48%**. The two are the accepted
  `Write-Debug` catch at lines 94-95. Line 197 and both function bodies verified covered by per-line
  probe.

### R2 (audit B2) — CLOSED

`Test-PreparationModeDelegation` at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
lines 153-186 lost its only production call site when this branch replaced
`Test-ImplementationDelegation`. Ten measurable lines covered at the merge base became uncovered — a
coverage regression on pre-existing lines, prohibited by `.claude/rules/general-unit-test.md`.

- **Closing tasks:** [P2-T1], [P2-T2] — four `It` blocks covering all three conjuncts, plus a
  marker-set parity assertion.
- **Proving artifact:** `evidence/qa-gates/r1-claude-gate-coverage.2026-08-27T22-47.md`
- **Outcome:** all ten measurable lines in 170-185 covered, uncovered list **empty**. File moves
  80.67% to **88.00%**.
- **Closed test-only.** The production-side alternative — deleting the orphaned function and
  `$script:PreparationModeMarkers` from all four hook copies — was **explicitly not taken**. It would
  touch production, contradict the "Not modified" list in `spec.md`, and break the passing Codex
  legacy-contract test at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lines
  249-250. The secondary concern the inputs recorded — two independent implementations of the
  preparation-marker rule in one file — is addressed by [P2-T2]'s parity assertion, which was probed
  and confirmed falsifiable at [P2-T5].

### R3 (audit B3) — CLOSED

`Get-OrchestrationModeDenyReason` was uncovered on the Codex surface at lines 352-353. It implements
acceptance criterion (Amendment 3).

- **Closing task:** [P1-T5] — two `It` blocks, epic and parallel.
- **Proving artifact:** `evidence/qa-gates/r1-codex-gate-coverage.2026-08-27T22-47.md`
- **Outcome:** line 352 `ci = 1`, line 353 `ci = 2`. **Both covered.**

### R4 (audit B4) — CLOSED

Line 210 of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — the classifier's
non-orchestrator allow branch — was the one uncovered added line the four-group characterization did
not account for, on the only surface where the `Agent` transport is reachable.

- **Closing tasks:** [P2-T3], and [P2-T4] for the non-blocking N4 companion.
- **Proving artifact:** `evidence/qa-gates/r1-claude-gate-coverage.2026-08-27T22-47.md`
- **Outcome:** line 210 **covered**, `ci = 1`. The [P2-T4] decision-level case additionally asserts
  the spec-sanctioned permissive widening explicitly, with `-CheckpointRaw` bound to an unready value
  so the allow cannot pass vacuously.

## Accepted residuals, by group, with the corrected counts

| Group | Corrected count | Previously stated | Membership | Status after remediation |
| --- | --- | --- | --- | --- |
| 1 — injected read seams | **16** | 18 | `.claude` 266-270, 278-282; `.codex` 292-296, 304-308 | unchanged, accepted |
| 2 — non-injected arm and Codex declared-path deny | **3** | 3 | `.claude` 408; `.codex` 421-422 | unchanged, accepted; **cause corrected** |
| 3 — decision-D5 transport-constrained | **39** | 40 | `.codex` gate 352-353 and 426-443; `.codex` modes 197, 228-250, 268-274 | **24 closed by R1 and R3**; 15 remain |
| 4 — `Write-Debug` catch | **4** | 2 | both `-modes.ps1` copies, lines 94-95 | unchanged, accepted |
| **Sum** | **62** | 63 | | |

**The reconciling line is `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 210**,
which the four-group characterization did not account for and which R4 closed. **62 + 1 = 63**, the
correct total, which was itself never in error.

Group 2's cause is corrected in the re-issued artifact: the `.codex` members 421-422 are the
`declared-checkpoint-path` deny return, **not** the non-injected `else` arm. That arm is line 430,
already inside the 426-443 residual. The superseded artifact carried the wrong cause at its line 102
(heading) and line 110 (cause sentence); its line 104 line list was accurate.

## The issue #555 exception

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **lines 426 through 443**, **15
measurable lines** — the epic/parallel decision branch. Driving it requires constructing a delegation
payload for the Codex decision function, which **decision D5 prohibits** because `.codex/config.toml`
registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name. **Issue #555** owns the
transport gap and is out of scope for #554. The file therefore ships at **83.33%**, and this is **the
one coverage exception this feature ships with**. It is recorded as its own named exception at
[P3-T9] condition 5 and is not absorbed into any aggregate.

## Zero production files changed

**Zero production files changed in this remediation cycle.** Proved twice, from opposite directions:

- **From the diff side** ([P3-T11]): the union of the branch-head diff and the untracked listing
  contains exactly **two** `.ps1` paths, both under `tests/`, and **zero** paths under
  `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/resources/`.
- **From the content side** ([P3-T13]): all four mirrored production pairs re-verified by SHA-256.
  Each pair's two hashes are equal, and each of the four equals the value recorded in
  `final-mirror-pair-hashes.2026-08-27T22-42.md` — so not one production byte changed, including
  changes a line-oriented diff cannot see.

The four `-helpers.ps1` copies share one object hash with their merge-base state, and the pre-existing
Claude mode-resolution suite is byte-untouched. The six pre-existing suites are absent from the diff
and pass with **242 tests, 0 failures** ([P3-T10]).

## The Scope Note deviation

The remediation directive named
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
as the Claude-side edit target for R2 and R4. **[P0-T8] measured that file at 494 lines**, leaving
**6 lines of headroom** against the 500-line cap in `.claude/rules/general-code-change.md`. R2 and R4
require approximately fifty lines; even R4's single smallest case does not fit in six.

The R2 and R4 cases were therefore placed in a new sibling suite,
**`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`**,
following the precedent `spec.md` §Test Strategy set when
`enforce-orchestration-preimplementation-gate.Tests.ps1` stood at 461 of 500 lines and "must not
grow". Consequences: two test files written, zero production files, no pre-existing suite edited, and
the named target left byte-untouched — a stronger outcome than the directive required. The new file
is declared in the blast radius by insertion 1 of [P3-T14].

## Final numbers

| Measurement | Baseline | Final |
| --- | --- | --- |
| Pester passed / failed | 3799 / 0 | **3816 / 0** (+17, exactly the ten Phase 1 plus seven Phase 2 cases) |
| Repository-wide LINE coverage | 94.2212% | **94.6809%** |
| `.claude/…/gate.ps1` | 80.67% | **88.00%** |
| `.claude/…/gate-modes.ps1` | 98.48% | **98.48%** |
| `.codex/…/gate.ps1` | 82.10% | **83.33%** (named #555 exception) |
| `.codex/…/gate-modes.ps1` | 81.82% | **98.48%** |
| Uncovered changed lines, aggregate | 63 | **38** |
| Aggregate changed-line coverage | 81.90% | **89.08%** |
| PSScriptAnalyzer findings | 0 | **0** |
| Files reformatted by the format stage | 0 | **0** |

The PowerShell toolchain loop completed in **iteration 2**; iteration 1 was abandoned at the analyze
stage on one `PSUseShouldProcessForStateChangingFunctions` finding against a fixture helper, corrected
by renaming `New-ClassifierToolInput` to `ConvertTo-ClassifierToolInput`.

**Acceptance criterion:** the single unchecked criterion was re-evaluated at [P3-T15] and **checked**.
All **35** of `spec.md`'s acceptance criteria are now `- [x]`. No criterion text was amended.

## Note on issue #510

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
is a **pytest** node, not Pester, so it cannot appear in any Pester run of this cycle and cannot
affect the zero-failure results. The cycle-1 policy audit recorded at its finding N6 that the
condition did not reproduce in this worktree. No state file was deleted.

Output Summary: All four Blocking findings **R1, R2, R3, and R4 are CLOSED**, each with a named
closing task and a proving evidence artifact. Accepted residuals recorded by group with the corrected
counts **16 / 3 / 39 / 4** plus the reconciling `.claude` line 210. The one shipping exception is
`.codex/…gate.ps1` **lines 426-443**, tied to **issue #555**. **Zero production files changed**,
proved by diff and by SHA-256. The Scope Note deviation is stated: the Claude-side cases went into
the new sibling suite because the named target stood at **494 lines with 6 lines of headroom**.
