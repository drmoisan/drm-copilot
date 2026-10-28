# Acceptance Criteria Tracking (P6-T9)

Timestamp: 2026-10-28T13-51
Command: per-item check-off in docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md against the evidence mapped in the plan's `## AC Traceability`
EXIT_CODE: 0

Source: `spec.md` only (work mode `full-bug`), `### Acceptance Criteria` (AC1-AC8) and `## Acceptance Criteria` (GEN1-GEN8). Each item was changed from `- [ ]` to `- [x]` individually with its text unchanged.

| Item | State | Evidence |
|---|---|---|
| AC1 delegation line required by orchestrate skill and orchestrator agent | checked | `evidence/other/prose-contracts.2026-10-28T13-25.md` (PC-01, PC-02); `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (AA-01 to AA-12) |
| AC2 pr-author skill accepts the delegation-prompt source; `- None` only when no source has an entry | checked | `evidence/other/prose-contracts.2026-10-28T13-25.md` (PC-03, PC-04) |
| AC3 a check fails when the delegation omits the line while the checkpoint has `issue-num` | checked | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md` (AA-02 to AA-05, AA-08, AA-09 failed before); `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (pass after) |
| AC4 current-branch target derivation; detached HEAD or unreadable branch keeps NoTarget | checked | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md` (CB rows failed before); `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-03 to CB-13, CB-15 pass) |
| AC5 `TARGET_WORKTREE_NOT_DERIVABLE` message names create and edit forms and states `--head` is not valid for edit | checked | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-14); `evidence/other/prose-contracts.2026-10-28T13-25.md` (PC-06) |
| AC6 `Bash(gh pr view *)` tool entry; allowlist permits only the exact view form; tests cover it | checked | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md` (AL-39, AL-49, PC-07 failed before); `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (AL-39 to AL-49, CB-16, PC-07 pass) |
| AC7 skill and agent require the closing-reference verification after every create or edit | checked | `evidence/other/prose-contracts.2026-10-28T13-25.md` (PC-05 skill and agent, AL-34) |
| AC8 mirrors and seven-stage toolchain | unchecked (pending-CI) | Local evidence passes: `evidence/other/bundle-parity.2026-10-28T13-25.md`, `evidence/qa-gates/contract-final.2026-10-28T13-50.md`, `evidence/qa-gates/pester-full.2026-10-28T13-48.md`. Gap: the toolchain criterion depends on CI on the PR head (`poshqc / PowerShell QC` shards and `poshqc / PowerShell hook suites (Linux)`), which cannot run before the PR exists. Owner: the item's orchestrator run at S9. |
| GEN1 Repro steps produce expected behavior in all documented environments | unchecked (pending-CI) | Windows evidence passes (CB-07, CB-15, AL-39, AA-02 in `evidence/qa-gates/pester-gss.2026-10-28T13-31.md`). Gap: the documented environments include Linux CI; the Linux hook-suite job runs only on the PR head. |
| GEN2 Regression tests added and passing | checked | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md`; `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (454 passed, 0 failed) |
| GEN3 Edge cases and invalid inputs handled | checked | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-02, CB-04 to CB-06, CB-09, CB-12, AL-40 to AL-48, AA-04, AA-05, AA-09) |
| GEN4 No unintended behavior changes outside scope | unchecked | Gap: mapped evidence is the P6-T10 self-review, which is written after this task. |
| GEN5 Logs/telemetry updated and validated | checked | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-14 deny guidance, AA-02 deny reason) |
| GEN6 Performance constraints met | checked | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-11, CB-13: git is not invoked when a signal is present) |
| GEN7 Full toolchain pass (format, lint, type-check, test) | checked | `evidence/qa-gates/powershell-format.2026-10-28T13-28.md`, `evidence/qa-gates/powershell-analyze.2026-10-28T13-28.md`, `evidence/qa-gates/pester-full.2026-10-28T13-48.md`, `evidence/qa-gates/contract-final.2026-10-28T13-50.md` |
| GEN8 Docs/config references updated | checked | `evidence/other/prose-contracts.2026-10-28T13-25.md`; `evidence/qa-gates/contract-final.2026-10-28T13-50.md` (manifest completeness) |

Output Summary: 16 items; 13 checked; 3 unchecked: AC8 and GEN1 (pending-CI on the PR head), GEN4 (awaiting the P6-T10 self-review).
