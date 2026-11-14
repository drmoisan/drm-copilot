# Feature Audit: Hook process cost, one dispatcher per tool call (#1159)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
**Base Branch:** `main`
**Head Branch:** `feature/hook-dispatcher-process-cost-1159`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (R4, main-sync cycle 1) and concurrent PR #1177 review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `2c8dee6dd3a82f210561d9efe623767ae902de51`)
- **Head branch/commit:** `feature/hook-dispatcher-process-cost-1159` (commit `9478c4b659092881c0db1fe2e8e04f90bfad3189`)
- **Merge base:** `2c8dee6dd3a82f210561d9efe623767ae902de51`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 07:56:52 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/**`
  - Additional evidence: CI runs 43573314091 (reviewed head, in progress), 43570680445 (predecessor f97b8e543), 43559694003 (main at the merge base); `artifacts/pr_body_1159.md` (the posted PR #1177 body, compared with `gh pr view 1177 --json body`: equal apart from a trailing newline)
- **Feature folder used:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`.
- **Scope note:** Full branch diff against the merge base, not the cycle 1 remediation scope. No scope narrowing was requested by the caller.

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
| S168 | Measurement tool | PASS | `scripts/dev-tools/Measure-HookProcessCost.ps1`, `HookProcessCost.psm1`; reports carry median/mean/max and the grandchild exclusion statement | `git diff --name-status 2c8dee6dd..HEAD` | Coverage 86.36% and 99.44% |
| S169 | Measurement unit tests | PASS | `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` in the green Pester run | `Invoke-PoshQCParallelTest` | Seams injected |
| S170 | Before and after reports | PASS | `evidence/baseline/hook-process-cost.2026-11-11T04-27.md`, `evidence/regression-testing/hook-process-cost.2026-11-14T06-35.md`, each with the four fields | read of both files | Not edited after creation (single commit each) |
| S171 | Process counts | PASS | Before 12/13/9/1 (Claude), 12/15/2/6 (Codex); after 1 in every scenario | read of both reports | Matches the Phase 0 inventory |
| S175 | Single Claude registration | PASS | `.claude/settings.json` PreToolUse has one entry invoking the dispatcher with the union matcher | `node` parse of settings | Union test in the Pester run |
| S176 | Single Codex registration | PASS | One `[[hooks.PreToolUse]]` table at `.codex/config.toml` line 119 with `command` and `command_windows` | `grep` of config | Timeout sum tested |
| S177 | Registries reproduce groups | PASS | `main-sync-registrations.2026-11-14T07-09.md`: byte-equal regeneration at the new merge base | read of evidence | — |
| S178 | Matcher semantics | PASS | `HookDispatch.Tests.ps1`, `hook-dispatch.Tests.ps1` green | `Invoke-PoshQCParallelTest` | — |
| S179 | In-process isolation | PASS | `HookDispatchRunner.psm1` lines 124-162; entry script reads payload once | code read | — |
| S180 | Modules without `-Force` | PASS | D6 audits `d6-module-audit.2026-11-11T05-37.md`, `d6-module-audit.2026-11-14T07-19.md`; cycle 1 edit verified in diff; module-load parity test green | `git diff 1083e7680..HEAD` | Unguarded `-Force` in two helpers is outside D6 (code-review Info) |
| S181 | No short-circuit | PASS | Runner loops every selected hook; unit test green | code read | — |
| S185 | No decision logic edited | PASS | Hook edits are D6 `-Force` removals and the separately evidenced D13 tails | `git diff` of `.claude/hooks` | — |
| S186 | Process-level parity suite | PASS | `PreToolUseDispatch.Parity.Tests.ps1` green | `Invoke-PoshQCParallelTest` | — |
| S187 | Parity corpus | PASS | 6 hooks reported by name as skipped rows with NoEnvelope reasons | `pester.2026-11-14T07-45.md` | — |
| S188 | D4 combination | PASS | `HookDispatch.Tests.ps1` green | `Invoke-PoshQCParallelTest` | — |
| S189 | Absent isolation | PASS | Runner per-process branch test; shipped registries set `in-process` | code and registry read | — |
| S190 | Fail-closed self-failure | PASS | Unit tests; reviewer probe of a non-JSON payload returned `HOOK_DISPATCH_BLOCKED:` on both runtimes | `sh <scratch>/r4-1159-probe.sh` | — |
| S191 | D13 baseline | PASS | `evidence/baseline/d13-tail-output.2026-11-11T04-37.md`, `d13-tail-output.2026-11-14T07-19.md` | read of evidence | Cycle 1: FailOpen no for the 4 changed hooks |
| S192 | Python-invocation guard | PASS | Helper carve-out and fixtures green | `Invoke-PoshQCParallelTest` | — |
| S196 | PR body quotes cost | PASS | `artifacts/pr_body_1159.md` lines 19-37: per-scenario table, both evidence paths, "none" for increased wall time; figures match the two reports | `gh pr view 1177 --json body` compared with the file | Newly checked off |
| S200 | Bundle copies and mirrors | PASS | `cmp` equal for bundle settings, config, both registries, runner; `main-integration.2026-11-14T07-28.md` 17 of 17 pairs | `cmp` | — |
| S201 | Manifests and push-down tests pass | FAIL | Manifests list the files (Python closure test green), but the TypeScript push-down closure test `codex-bundle-publish.integration.test.ts` fails in CI (expected more than 21 closure files, received 10) | CI run 43570680445 log | Finding F2; reverted to unchecked |
| S202 | Docs and brief copies | PASS | Six brief copies share blob `6266dbe0`; README and architecture doc in diff | `git ls-files -s` | — |
| S203 | Registration-shape tests re-targeted | FAIL | `real-bundle-filesystem.test-helpers.ts` `collectRegisteredHookClosure` still reads only `config.toml` command lines | code read; CI failure | Finding F2; reverted to unchecked |
| S204 | Frontmatter and non-PreToolUse unchanged | PASS | Settings and config diffs touch only the PreToolUse blocks | `git diff` of settings and config | — |
| S208 | Local gates | PASS | Pester 24357/0 failures; pytest 16723 passed; leak scan 0 failures, no allowlist diff; lowest changed file 86.36%; largest file 593 lines | read of qa-gates evidence; coverage XML parse | — |
| U53 | Measurement and reports | PASS | As S168-S170 | — | — |
| U54 | Process counts | PASS | As S171 | — | — |
| U55 | Single registrations | PASS | As S175-S177 | — | — |
| U56 | Single read, own scopes, modules once | PASS | As S179-S181 | — | — |
| U57 | Parity and per-hook suites | PASS | As S185-S186 | — | — |
| U58 | Precedence | PASS | As S188 | — | — |
| U59 | Isolation default | PASS | As S189 | — | — |
| U60 | Fail-closed | PASS | As S190 | — | — |
| U61 | Python-invocation guard | PASS | As S192 | — | — |
| U62 | PR reports cost | PASS | As S196 | — | Newly checked off |
| U63 | Bundle, manifests, docs; push-down contract tests pass | FAIL | As S201 and S203 | — | Finding F2; reverted to unchecked |

Definition of Done item "Behavior matches acceptance criteria on Windows and on the Linux hook-suite CI job": PENDING-CI. The Linux hook-suite job was pending at review time on the reviewed head; it succeeded at predecessor head f97b8e543, whose code differs only by the one-line cycle 1 edit. It stays unchecked. The Definition of Done item "Toolchain pass completed" is checked in the source but CI tier classification and Jest fail (F1, F2); the reviewer did not edit Definition of Done items.

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 34 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 3 criteria (S201, S203, U63)

**Top gaps preventing PASS:**

1. F2: the TypeScript push-down closure helper does not read the Codex registry, so the closure test fails in CI.
2. F1: `quality-tiers.yml` has no entry for `.claude/lib/hook-dispatch`; CI `tier-classification` fails and skips the CI pytest and coverage steps.

**Recommended follow-up verification steps:**

1. After the fixes, run `poetry run python -m scripts.dev_tools.check_quality_tiers`, `npm run test:unit:coverage` at the root and the extension Jest suite, and record each as new evidence.
2. Confirm CI green on the new head, including `poshqc / PowerShell hook suites (Linux)`, then check off the Linux Definition of Done item at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS items were checked off and FAIL items left unchecked.

Source-file changes made by this review:
- Checked off: `spec.md` line 196 (PR body quotes cost) and `user-story.md` line 62 (PR reports cost).
- Reverted to unchecked because the evaluation is FAIL: `spec.md` line 201, `spec.md` line 203 and `user-story.md` line 63. Each had been checked before this review; the CI evidence for finding F2 contradicts them.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 37
- Checked off (delivered): 34
- Remaining (unchecked): 3
- Items remaining: spec.md S201 (pack manifests and push-down contract, completeness and closure tests pass); spec.md S203 (every test that pinned the per-hook registration shape reads the registry); user-story.md U63 (bundle, manifests and docs consistent and push-down contract tests pass)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 26 | 24 | 2 | Checkbox-backed |
| `user-story.md` | 11 | 10 | 1 | Checkbox-backed |
