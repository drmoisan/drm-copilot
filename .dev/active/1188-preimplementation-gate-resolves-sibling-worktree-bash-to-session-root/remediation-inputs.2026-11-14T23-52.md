# Remediation Inputs — Issue 1188 (initial feature review)

Timestamp: 2026-11-14T23-52
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Issue: 1188
Base: main
Merge-Base: 11c6ecde2e3080722c90bc63289bc160bf9596ea
Reviewed-Head: aca57bf07214fb4436a7459beb1b587eedd6af35
Source review artifacts:
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/policy-audit.2026-11-14T23-52.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/code-review.2026-11-14T23-52.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/feature-audit.2026-11-14T23-52.md`

## Disposition

One finding requires remediation inside this item (owner rule: related findings are fixed in remediation cycles, not deferred). It is autonomous and design-scoped, so the path is full: the fix touches classification, which the spec lists as a non-goal, and AC-14, which pins both gate files to `main`, so a spec revision is part of the cycle. AC-1 to AC-5 and AC-7 to AC-15 evaluate PASS and stay checked; AC-6 evaluates FAIL and stays unchecked. The operand extraction, resolver wiring, mirrors, manifests, brief copies, and coverage need no change. The reviewer's Pester gate at the head passed (27115 passed, 0 failed, 22 skipped; 96.04% repo-wide lines; siblings 100%).

## Finding R1

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The classification change, the spec revision, and the test rows all lie in repository files on this branch and are verifiable by local Pester rows and the parallel gate, with no external system or owner decision needed under the recorded autonomous-mode directive.
Finding-Scope: design
Remediation-Mode: design
Orchestrator-Route-Decision: recommended route (classification supplement in a new byte-identical sibling, spec non-goal and AC-14 revised, V3 restored to the unquoted AC-6 command, N3 made an allow/deny pair). Rationale: owner directive to keep shell-variable operands fail-closed and to fix related findings inside the item; the fallback would leave two known gate fail-opens on main. The Codex gate is at its 500-line cap, so an existing block moves into a sibling before any line is added. The minor `bash --rcfile` finding, the brief sentence on absolute option values, and an appended corrected root-cause record are included in the same cycle.

- Location: `Test-ImplementationCommand` stage 1 in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its Codex twin `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (both unchanged on the branch; the Codex file is at its 500-line cap); rows V3 and N3 in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1`; spec `## Scope & Non-Goals` (classification non-goal) and AC-14.
- Requirement: spec AC-6 requires `npm --prefix $(pwd) run lint` to deny `TARGET_WORKTREE_NOT_DERIVABLE` with no checkpoint read and no listing call on both surfaces. AC-2 and the brief state that `npx --prefix <item> jest` resolves to the item worktree.
- Observed: both gates admit `npm --prefix $(pwd) run lint` with zero reads. Stage 1 matches its patterns per `Read-CommandLineSegment` scan segment, and the scanner splits the unquoted `$(` word into `npm --prefix `, `pwd`, ` run lint`; no segment holds both `npm` and the script word. `Test-OrchestrationGateInvocationConfirmed` (stage 2) returns true for every pattern index, so the executor's attribution to stage 2 (`evidence/regression-testing/fail-before-v3.2026-11-14T22-09.md`) is not the cause. `npx --prefix <item> jest` is also unclassified, because the npx pattern requires the tool word directly after `npx`. Both are gate fail-opens that exist on `main` and that the item's ACs name. `Get-OrchestrationGateCommandTargetOperand` already returns `Unresolved` for the unquoted npm form and the item root for the npx form, so once classified both reach the intended decisions.
- Fix (recommended route): add a stage-1 supplement in a new byte-identical sibling (for example `enforce-orchestration-preimplementation-gate-classify.ps1`, four copies, pack manifests, `$script:SharedModuleNames`, parity rows), so the Codex gate does not grow: (1) evaluate the npm and npx patterns also over the text of scan segments joined across a `$(`, `${`, or backtick split of one shell word (the same grouping that `Get-OrchestrationGateHarvestedRecordIndex` applies), and (2) accept options between `npx` and the tool word (`npx --prefix <v> jest`, `npx -C <v> jest`, `npx --yes jest`). Route the supplement's hit through stage 2 as today. Each gate gains one guarded dot-source and one call; if the Codex gate cannot take two lines, move an existing block into the sibling first, as the spec's owner constraint prescribes. Revise the spec: narrow the classification non-goal to "no command other than these two forms is newly classified" and revise AC-14 to allow the minimal call-site edit, recording the decision and its rationale. Restore V3 to the unquoted AC-6 command on both surfaces, keep the quoted form as an extra row, and make N3 an allow-ready and deny-not-ready pair. Record the corrected root cause in a new evidence file (append-only).
- Fallback route, if the planner judges the classification change disproportionate: revise AC-6 to the quoted form and AC-2 to state that `npx --prefix` is not gated, and correct the brief's `npx --prefix`/`-C` clause to say it applies only once npx with an option is gated. The planner records which route it took and why.
- Verification: fail-before rows for the unquoted V3 and the N3 deny-not-ready pair on both surfaces, red before the classification change and green after; the parallel Pester gate and PowerShell static loop in one pass; the pytest gate for the push-down and brief contract suites; CI including the Linux hook-suite job.

## Non-remediation notes

- Minor (code review): `bash --rcfile <abs> <script>` records the rcfile value as the script operand and denies as ambiguous (fail-closed). Optional fix in the same cycle with a G row.
- Info (code review): separate-token absolute option values outside every worktree (`--junitxml /tmp/j.xml`) make an item command ambiguous, as AC-7 specifies; consider one brief sentence advising relative or inline option values.
- Info (code review): U2 uses the npm missing-value form instead of a trailing `poetry -C`, which carries no governed word and is not harvested.
- Nit: `fail-before-v3.2026-11-14T22-09.md` attributes the V3 miss to stage 2; append a corrected record rather than editing it.
- Owner-directive records: the executor's decision files record OD-1 with class `scheduling`, while the checkpoint entry's class is `merge_timing`; when the orchestrator writes `owner_directive_records`, use the checkpoint class, because the record's `class` must repeat the entry's class.
- The reviewer added the evidence file `evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`; commit it with this review set.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
