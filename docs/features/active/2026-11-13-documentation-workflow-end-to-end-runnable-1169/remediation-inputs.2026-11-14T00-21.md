# Remediation Inputs — Issue 1169

Timestamp: 2026-11-14T00-21
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Head: `32d8c602dd87008bfce69d2c0609a9c04bc0ee43` (PR #1175)
Base: `main`, merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`
Source review artifacts:
- `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/policy-audit.2026-11-14T00-21.md`
- `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/code-review.2026-11-14T00-21.md`
- `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/feature-audit.2026-11-14T00-21.md`
Remediation plan target: `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/remediation-plan.2026-11-14T00-21.md`
Prior cycle: none (first review).

Path note: three findings, all autonomous. F3 changes the read seam of a hook sibling and the baseline mock lines of up to 38 existing suites, so it is design scope and the cycle takes the full path. The mode is proportionate when F3 is fixed by reusing a seam (no spec criterion, public interface, or file outside the branch diff plus tests and mirrors changes). If the planner instead revises the cleanup-suite criterion, the cycle becomes `Remediation-Mode: design`.

## Findings requiring remediation

### F1 — CR1: a single `=`-form commit option throws in the docs-estate prefilter

Severity: Blocking (Medium)
Remediability: autonomous
Remediability-Evidence: The fix is a one-line array-preservation change in a hook file already in the branch diff, copied to its three byte-identical mirrors, plus new rows in two existing branch suites; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`; `.codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`; `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1`.
- Observed: in `Get-OrchestrationDocsEstateSegmentShape`, line 135 assigns `$rest` from an `if` statement; one remaining token is unrolled to a string, so for `git commit --file=msg.txt` `$rest[0]` is a `[char]` and line 158 throws on `IndexOf`. The caller declines silently. Same for `--message=<m>` and `--trailer=<t>` as the only option, with or without `git -C <absolute root>`.
- Required change: keep `$rest` an array (for example `$rest = @(if ($Token.Count -gt $index + 1) { $Token[($index + 1)..($Token.Count - 1)] })`). Copy the file byte-identically to the three mirrors.
- Tests: in both gate suites add allow rows (valid profile, docs-only staged index) for `git commit --file=<f>`, `git commit --message=<m>`, and `git commit --trailer=<t>` as the only option, and one row with two `=`-form options; add one direct-call row asserting `Get-OrchestrationDocsEstateCommandShape` returns one `commit` shape for `git commit --file=<f>`. Confirm the new rows fail on the current head before the fix.
- Verification: PoshQC format and analyze on the edited files; the parity suite `hook-docs-estate-context.Parity.Tests.ps1`; one `Invoke-PoshQCParallelTest` run with 0 failures; per-file coverage of both gate-docs copies not below 94.20% and 91.30%.

### F2 — CR2: stale `RECEIPT_ABSENT` remediation text

Severity: Blocking (Low)
Remediability: autonomous
Remediability-Evidence: The fix edits one message string in a module already in the branch diff, its bundle copy, and one assertion in an existing branch suite; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `.claude/lib/docs/DocsCompleteGate.psm1`; `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCompleteGate.psm1`; `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1`.
- Observed: line 187 tells the operator to run `validate -Mode docs-complete with -Revision and -WriteReceipt for the pull request head`. Under the A4 rule the receipt revision is the snapshot revision, which `-WriteReceipt` now supplies by default.
- Required change: state the documented command (`Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt`, whose revision defaults to the inventory snapshot revision) and name `## Refresh After Rebase or Source Change` of the documentation-workflow skill. Keep the reason code `RECEIPT_ABSENT`. Copy to the bundle.
- Tests: extend the `RECEIPT_ABSENT` row of `DocsCompleteGate.Tests.ps1` to assert the new text and the absence of `for the pull request head`. If `enforce-docs-complete-gate.Tests.ps1` pins the old message text, update that row as well.
- Verification: as F1 (one parallel Pester run); `DocsCompleteGate.psm1` stays at 100% lines.

### F3 — FA1: the cleanup-leg suites the spec requires unchanged carry an added seam token

Severity: Blocking (Medium)
Remediability: autonomous
Remediability-Evidence: Both remedies change only files already in the branch diff, their tests, mirrors, and the spec criterion text the planner owns; neither needs an external party or CI result, and the 1157 precedent resolved the same class inside the item.
Finding-Scope: design

- Files: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`; `enforce-orchestration-preimplementation-gate-docs.ps1` (four copies); the other suites that gained the same token (listed in `evidence/qa-gates/phase-gate.P3.2026-11-13T22-33.md`); `spec.md` (A1, cleanup-suite criterion, now unchecked).
- Observed: spec A1 requires both cleanup-leg suites to pass unchanged. Each now registers `Get-OrchestrationDocsEstateFileText` in its baseline mock list, because the epic-state isolation discovery guard requires a baseline mock for each closure read seam. Executor deviation D2 disclosed it.
- Required change (preferred, proportionate): read the profile through a seam the cleanup suites already null-mock in their outermost `BeforeAll`, so that `git diff eb73f1dff..HEAD` over both cleanup suites is empty, and remove the added token from the other suites where it becomes unnecessary. Check the transparency of that seam first: if any suite replaces it with a path-agnostic mock, guard the docs leg against reading that content as a profile (the 1157 cycle-1 plan records the same check). Keep the no-profile deny text byte-identical.
- Alternative (design mode): revise the criterion so that a baseline isolation mock with no assertion change is admitted, with the reason recorded in `spec.md` and the PR body.
- Then: check off the criterion in `spec.md` with the evidence.
- Verification: the discovery guard `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, both cleanup suites, both docs-estate gate suites, the parity suite, and the end-to-end scenario pass in one `Invoke-PoshQCParallelTest` run; for the preferred route, the `git diff` over both cleanup suites is empty.

## Non-remediation items (record only)

- CR3 (Medium, owner decision for a follow-up): the A1 and A2 docs path set admits profile-defined roots and artifact directories outside `docs/`, which E7 and M9 do not; the skill sentence "denied at commit, PR creation, and merge" does not describe that case. Spec-conformant; the default profile is unaffected.
- CR4 (Low): four new suites have no `AfterAll` function removal, contrary to the spec suite-hygiene sentence; Pester container scoping and the cleanup-suite precedent apply.
- Warnings: `DocsLedgerCommands.psm1` 707 lines (two copies), `enforce-docs-complete-gate.Tests.ps1` 757 lines.
- Pending CI on PR #1175 (Pester shards 1 to 3, `quality-checks7 ... (3.13)`): not a finding.

## Orchestrator Scope Decision (2026-11-14T00:31Z)

The owner directs autonomous mode (OD-1) and requires related findings to be fixed inside this item through remediation cycles. The orchestrator therefore adds the two non-blocking items to this cycle and sets the mode to design:

- CR3 is in scope. Decision: narrow the A1 and A2 docs path set so that it admits only paths under `docs/` (documentation roots and artifact directories that lie under `docs/`) plus the one docs-init workflow constant. A profile-defined root or artifact directory outside `docs/` is then declined by the commit and delegation legs, which matches E7 and M9 and the issue constraint that a non-docs path is denied at commit, at PR creation, and at merge. Rationale: this keeps all three gates consistent and fail-closed without widening the global E7/M9 exemption. The spec A1/A2 criteria and the D-A1-roots decision are revised accordingly; deny tests cover a root outside `docs/` at the commit and delegation legs.
- CR4 is in scope: add the `AfterAll` function removal to the four new suites, following the cleanup-suite precedent.
- F3 may take either remedy; the preferred seam-reuse remedy is still preferred. If the criterion is revised instead, record the reason in `spec.md`.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run per gate; no single-file, serial, shuffled, or reversed run. Test-order dependence is a violation.
- Tests create no files, set no environment variables, and use forward-slash synthetic roots.
- No new Python; no hook invokes Python.
- Evidence is append-only, every timestamp is read from the clock, and no artifact records an absolute path.
- Keep all hook and library copies byte-identical across `.claude/`, `.codex/`, and both bundles.
- Do not change any other spec criterion text; do not weaken an assertion.
- Any commit makes this review stale, so a re-review follows.
