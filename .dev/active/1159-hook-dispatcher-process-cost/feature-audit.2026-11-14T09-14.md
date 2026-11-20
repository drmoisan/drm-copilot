# Feature Audit: Hook process cost, one dispatcher per tool call (#1159)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
**Base Branch:** `main`
**Head Branch:** `feature/hook-dispatcher-process-cost-1159`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (R4, remediation cycle 2 plus main sync) and concurrent PR #1177 review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `1d9f14e2c595b0065ad42a24188620f320ac514c`)
- **Head branch/commit:** `feature/hook-dispatcher-process-cost-1159` (commit `5a58ecdc239fce59d73db7194cfaa371f3df355a`)
- **Merge base:** `1d9f14e2c595b0065ad42a24188620f320ac514c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 09:14:20 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/**`
  - Additional evidence: reviewer re-runs at the reviewed head (root Jest with coverage, `pytest -n auto` with coverage, `Invoke-PoshQCParallelTest`, `check_quality_tiers`); CI run 43579582942 (completed on the reviewed head during the review, 26 of 26 checks passed); `artifacts/pr_body_1159.md` (equal to the posted PR #1177 body apart from a trailing newline)
- **Feature folder used:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`.
- **Scope note:** Full branch diff against the merge base, not the cycle 2 remediation scope. No scope narrowing was requested by the caller. The main-sync merge is neutral for the branch: per-path `--numstat` from the old merge base to `bf1805ec0` equals that from the new merge base to the reviewed head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/spec.md` — primary source (26 checkbox items under `## Acceptance Criteria`, lines 168-208)
- `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/user-story.md` — secondary source (11 checkbox items, lines 53-63)

### Acceptance criteria

Criteria are identified below by source file and line number; the full text is in the source files and is not rewritten here.

#### From spec.md
- S168 measurement tool per runtime and scenario; S169 measurement unit tests; S170 before and after reports; S171 process counts before and after
- S175 single Claude registration; S176 single Codex registration with timeout sum; S177 registries reproduce merged groups; S178 runtime matcher semantics; S179 in-process isolation, payload read once; S180 shared modules without `-Force`; S181 no short-circuit
- S185 no decision logic edited, per-hook suites unchanged; S186 process-level parity suite; S187 parity corpus coverage; S188 D4 combination; S189 absent isolation means per-process; S190 fail-closed self-failure; S191 D13 baseline; S192 Python-invocation guard carve-out
- S196 PR body quotes before and after cost
- S200 bundle settings, config and mirrors; S201 pack manifests and push-down contract, completeness and closure tests pass; S202 docs and brief copies; S203 registration-shape tests re-targeted to the registry; S204 frontmatter and non-PreToolUse registrations unchanged
- S208 one Pester run, one pytest run, leak scan, 85% per changed file, no file at 801 lines

#### From user-story.md
- U53 measurement tool and append-only reports; U54 process counts; U55 single registrations; U56 single payload read, own scopes, no short-circuit, modules once; U57 parity suite and per-hook suites; U58 precedence; U59 isolation default; U60 fail-closed; U61 Python-invocation guard; U62 PR reports cost; U63 bundle, manifests, docs consistent and push-down contract tests pass

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S168 | Measurement tool | PASS | `scripts/dev-tools/Measure-HookProcessCost.ps1`, `HookProcessCost.psm1`; unchanged since the previous review | `git diff --name-status 9478c4b65..5a58ecdc2` | Coverage in policy audit 1.2.1 |
| S169 | Measurement unit tests | PASS | `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` in the reviewer Pester run | `Invoke-PoshQCParallelTest` | Seams injected |
| S170 | Before and after reports | PASS | `evidence/baseline/hook-process-cost.2026-11-11T04-27.md`, `evidence/regression-testing/hook-process-cost.2026-11-14T06-35.md`; cycle 2 consistency record shows an empty diff for both | read of `consistency.2026-11-14T09-09.md` | Append-only |
| S171 | Process counts | PASS | Before 12/13/9/1 (Claude), 12/15/2/6 (Codex); after 1 in every scenario | read of both reports | Unchanged |
| S175 | Single Claude registration | PASS | `.claude/settings.json` PreToolUse has one entry invoking `.claude/hooks/invoke-pretooluse-dispatch.ps1` | `node` parse of settings at the reviewed head | #1156 did not touch settings |
| S176 | Single Codex registration | PASS | One `[[hooks.PreToolUse]]` table at `.codex/config.toml` line 119 with `command` and `command_windows`, timeout 690 | `grep` of config | — |
| S177 | Registries reproduce groups | PASS | #1156 did not change `.claude/settings.json` or `.codex/config.toml` between the old and new merge base, so the byte-equal regeneration record `main-sync-registrations.2026-11-14T07-09.md` still applies | `git diff --name-only 2c8dee6dd 1d9f14e2c` | — |
| S178 | Matcher semantics | PASS | `HookDispatch.Tests.ps1`, `hook-dispatch.Tests.ps1` green in the reviewer Pester run | `Invoke-PoshQCParallelTest` | — |
| S179 | In-process isolation | PASS | Runner and entry scripts unchanged since the previous review | `git diff 9478c4b65..5a58ecdc2 -- .claude/lib/hook-dispatch .claude/hooks/invoke-pretooluse-dispatch.ps1` empty | — |
| S180 | Modules without `-Force` | PASS | D6 audits unchanged; arrived #1156 hook files contain no `Import-Module`; module-load parity test green | `grep` of the four arrived files | Unguarded `-Force` in two helpers is outside D6 (code-review Info) |
| S181 | No short-circuit | PASS | Runner unchanged; unit test green | Pester | — |
| S185 | No decision logic edited | PASS | Hook edits are D6 `-Force` removals and the separately evidenced D13 tails; cycle 2 changed no hook | `git diff` of `.claude/hooks` | — |
| S186 | Process-level parity suite | PASS | `PreToolUseDispatch.Parity.Tests.ps1` green in the reviewer Pester run | Pester | — |
| S187 | Parity corpus | PASS | 6 hooks reported by name as skipped rows with NoEnvelope reasons | Pester | — |
| S188 | D4 combination | PASS | `HookDispatch.Tests.ps1` green | Pester | — |
| S189 | Absent isolation | PASS | Runner per-process branch test; shipped registries set `in-process` (reviewer `node` read: `isolation in-process`) | code and registry read | — |
| S190 | Fail-closed self-failure | PASS | Unit tests; previous reviewer real-process probe; code unchanged | Pester | — |
| S191 | D13 baseline | PASS | `evidence/baseline/d13-tail-output.2026-11-11T04-37.md`, `d13-tail-output.2026-11-14T07-19.md` | read of evidence | — |
| S192 | Python-invocation guard | PASS | Helper carve-out and fixtures green | Pester | — |
| S196 | PR body quotes cost | PASS | `artifacts/pr_body_1159.md` lines 19-37 quote both reports and cite both paths | `gh pr view 1177 --json body` compared with the file | Body is otherwise stale (code-review N1, non-blocking) |
| S200 | Bundle copies and mirrors | PASS | Reviewer `cmp`: bundle settings, config, both registries, both entry scripts, `hook-dispatch.ps1`, both runner modules byte-identical | `cmp` | — |
| S201 | Manifests and push-down tests pass | PASS | Python closure and contract tests green (reviewer pytest 16730 passed); TypeScript `codex-bundle-publish.integration.test.ts` green (reviewer root Jest 5579 passed; `jest-extension.2026-11-14T09-01.md` 5557 passed); CI root TypeScript tests pass on both runners at the reviewed head | `npm run test:unit:coverage`; `pytest -n auto` | F2 closed; checked in source by cycle 2 |
| S202 | Docs and brief copies | PASS | Unchanged since the previous review; the merged brief copies carry both the #1159 and #1156 paragraphs | `git show --cc 5a58ecdc2` | — |
| S203 | Registration-shape tests re-targeted | PASS | `collectRegisteredHookClosure` reads `.codex/hooks/pretooluse-dispatch.json`; cycle 2 sweep (`main-integration.2026-11-14T08-49.md`) and the reviewer's independent `git grep` find no other consumer | code read; `git grep` | F2 closed |
| S204 | Frontmatter and non-PreToolUse unchanged | PASS | Settings and config diffs touch only the PreToolUse blocks | `git diff` of settings and config | — |
| S208 | Local gates | PASS | Reviewer Pester run at the reviewed head (policy audit 1.2.1); pytest 16730 passed; cycle 1 leak scan 0 failures with no allowlist change; every changed production PowerShell file at or above 85%; largest covered file 593 lines | coverage XML parse | — |
| U53 | Measurement and reports | PASS | As S168-S170 | — | — |
| U54 | Process counts | PASS | As S171 | — | — |
| U55 | Single registrations | PASS | As S175-S177 | — | — |
| U56 | Single read, own scopes, modules once | PASS | As S179-S181 | — | — |
| U57 | Parity and per-hook suites | PASS | As S185-S186 | — | — |
| U58 | Precedence | PASS | As S188 | — | — |
| U59 | Isolation default | PASS | As S189 | — | — |
| U60 | Fail-closed | PASS | As S190 | — | — |
| U61 | Python-invocation guard | PASS | As S192 | — | — |
| U62 | PR reports cost | PASS | As S196 | — | — |
| U63 | Bundle, manifests, docs; push-down contract tests pass | PASS | As S200-S203 | — | F2 closed |

Definition of Done item "Behavior matches acceptance criteria on Windows and on the Linux hook-suite CI job": PENDING-CI. `poshqc / PowerShell hook suites (Linux)` passed on run 43579582942 at the reviewed head, which completed during this review with all 26 checks passing. Per `### CI-Dependent Criteria`, the item stays unchecked here; the item's orchestrator run checks it off at S9 after it records the CI gate.

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None among the acceptance criteria. The Linux hook-suite Definition of Done item awaits the orchestrator's S9 check-off (CI already green).
2. Non-blocking: the posted PR body predates remediation cycles 1 and 2 and the main sync (code-review N1).

**Recommended follow-up verification steps:**

1. CI run 43579582942 is green on `5a58ecdc2`, including `quality-checks7` (tier classification and Python coverage thresholds), the PowerShell shards and `poshqc / PowerShell hook suites (Linux)`. The orchestrator records `ci_gate` and checks off the Linux Definition of Done item at S9, then re-runs the gate if that check-off moves the head.
2. Refresh the PR body through the `pr-author` route before merge.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS items are checked off and the pending-CI item stays unchecked.

Source-file changes made by this review: none. The three items the previous review reverted (`spec.md` lines 201 and 203, `user-story.md` line 63) were re-checked by cycle 2 task [P1-T11] in commit `bf1805ec0`. This review evaluates them as PASS and leaves them checked.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 37
- Checked off (delivered): 37
- Remaining (unchecked): 0
- Items remaining: none among the acceptance criteria; the `spec.md` Definition of Done item "Behavior matches acceptance criteria on Windows and on the Linux hook-suite CI job" stays unchecked as pending-CI

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 26 | 26 | 0 | Checkbox-backed; Definition of Done Linux item pending-CI |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed |
