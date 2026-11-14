# Code Review: PreToolUse hook dispatcher, one process per tool call (#1159)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
**Feature Folder Selection Rule:** the only feature folder carrying issue #1159; no version subfolder
**Base Branch:** `main` (merge base `2c8dee6dd3a82f210561d9efe623767ae902de51`)
**Head Branch:** `feature/hook-dispatcher-process-cost-1159` at `9478c4b659092881c0db1fe2e8e04f90bfad3189` (PR #1177)
**Review Type:** Post-remediation re-review (R4, main-sync cycle 1) and concurrent PR review; scope is the full branch diff

---

## Executive Summary

The branch replaces the per-hook PreToolUse registrations in `.claude/settings.json` and `.codex/config.toml` with one dispatcher registration per runtime. Each dispatcher reads its generated registry (`pretooluse-dispatch.json`), selects the groups whose matcher admits the tool name, runs every selected hook unchanged in its own script scope in one `pwsh` process, and combines decisions by the D4 precedence. The change set is 241 files: 7 new production PowerShell files, D6 `-Force` removals and D13 tail rewrites in dispatched hooks, bundle mirrors, pack manifests, documentation, a process-level parity suite and a measurement tool. Evidence reviewed: PR context at the reviewed head, all final QA evidence, the cycle 1 integration records, direct parsing of the coverage artifacts, a real-process probe of both dispatchers, and CI on the reviewed and predecessor heads.

The implementation is well structured and well tested locally. Two defects outside the local gate set block merge: the new `.claude/lib/hook-dispatch` project has no tier entry, and a TypeScript push-down test that derives registered Codex hooks from `config.toml` was not re-targeted to the registry.

**What changed:**
New `HookDispatch.psm1` (registry, matcher, combination), `HookDispatchRunner.psm1` (in-process and per-process runners with seams), Claude and Codex entry scripts, the Codex `hook-dispatch.ps1`, two registries, `HookProcessCost.psm1` and `Measure-HookProcessCost.ps1`; single dispatcher registrations in settings and config and their bundle copies; registry-aware test helpers in PowerShell and Python; docs. Cycle 1 changed one line in `.claude/hooks/enforce-model-routing-receipt-docs.ps1` and its bundle copy.

**Top 3 risks:**
1. CI `tier-classification` fails (QT008), so the Python test and coverage steps in CI have not run at any recent head.
2. The TypeScript closure test fails at the registry shape, so the TypeScript push-down closure guard currently proves nothing for the dispatched Codex hooks.
3. The Linux hook-suite CI result for the reviewed head is pending.

**PR readiness recommendation:** **Needs Revision** — two blocking CI failures caused by the branch (F1, F2).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `quality-tiers.yml` | `projects` list | F1: the new project folder `.claude/lib/hook-dispatch` has no tier entry; `check_quality_tiers` reports `QT008: discovered project '.claude/lib/hook-dispatch' has no entry`. | Add a `.claude/lib/hook-dispatch` entry with a tier and rationale consistent with the sibling `.claude/lib/*` runtime libraries (T3 entries such as `.claude/lib/hook-payload`); rerun `check_quality_tiers` and record evidence. | CI `quality-checks7` fails at `tier-classification`, which also skips the CI pytest and Python coverage-threshold steps. | Local `poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree>` prints QT008; the same command on the main checkout prints `quality-tiers: OK (33 entries, 33 discovered projects)`; CI run 43573314091 job 132382261143 step 13 failure; run 43570680445 log line `QT008`. |
| Blocker | `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` | `collectRegisteredHookClosure`, lines 163-193 | F2: the helper collects closure roots only from `command =` lines of the bundle `.codex/config.toml`. After the branch, those lines name only the dispatcher, so `codex-bundle-publish.integration.test.ts` line 100 (`expect(required.length).toBeGreaterThan(21)`) receives 10 and fails. | Add every hook named by `.codex/hooks/pretooluse-dispatch.json` in the bundle as a closure root, as `registry_hook_paths` does in `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`; run the root and extension Jest suites with coverage and record evidence. | Spec AC line 203 requires every test that pinned the per-hook registration shape to read the registry, and AC line 201 requires the dependency-closure tests to pass. Root TypeScript and extension test jobs fail on both runners. | CI run 43570680445 (head f97b8e543, same TypeScript and bundle content as the reviewed head): `FAIL extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts`, `Expected: > 21, Received: 10`; run 43573314091 root TypeScript and extension jobs fail at the test step. |
| Info | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | lines 47-57 | Unguarded `Import-Module ... -Force` lines remain in two helpers dot-sourced by dispatched hooks (also `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` line 30). They are outside the D6 set, which covers guarded imports only, and the PR body discloses them. | No change required for this PR. Consider a follow-up within D6's intent if a trace ever shows a second load. | In the current registry order each of these helpers is the first loader of its modules within a call, and the parity test `loads each stateless shared module once per call` passes. | `HookDispatchRunner.psm1` snapshot logic counts a forced re-import as a new instance; `pester.2026-11-14T07-45.md` green; PR body Risks section. |
| Info | `.claude/hooks/invoke-pretooluse-dispatch.ps1` | payload parsing | A payload with no parseable `tool_name` yields a `HOOK_DISPATCH_BLOCKED:` deny. Per-hook processes would previously have treated such a payload hook by hook. | No change required; the host always sends a tool name. Record as intended fail-closed behavior. | D8 lists registry failures explicitly; this extends fail-closed handling to an unselectable payload, which is the safer direction. | Reviewer probe: non-JSON payload piped to both entry scripts returned a deny with `HOOK_DISPATCH_BLOCKED: the PreToolUse payload carries no tool_name`. |
| Info | `artifacts/` (local gate set) | final QA loop | The plan's final QA loop ran Pester, pytest, the leak scan and static loops but neither Jest nor `check_quality_tiers`, so both F1 and F2 were first visible in CI. | When remediating, add the two commands to the cycle's final QA and record them. | Both failures were present on every head since the registry change, including the pre-cycle head e8d3f29df. | CI runs 43568271547 and 43570680445 show the same two failures. |

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- `registry_hook_paths` and the optional `registry_text` argument in `test_codex_core_manifest_closure.py` add the registry as closure roots without changing the existing config path.

#### Typing and API notes
- Full annotations (`str | None`, `set[str]`); pyright clean.

#### Error handling and logging
- Test helpers only; no broad catches.

### TypeScript implementation audit (if applicable)

#### What changed well
- No TypeScript file is in the branch diff.

#### Type safety and maintainability
- The unchanged helper `collectRegisteredHookClosure` is now out of step with the Python twin (F2).

#### Error handling and logging
- Not applicable to the branch diff.

### PowerShell implementation audit (if applicable)

#### What changed well
- Hooks run unchanged with `&` in their own script scope; console writers, stdin, location, strict mode and `$ErrorActionPreference` are restored in `finally`.
- Seams (script-invoker, stdin-replayer, process-starter) make the runner testable without starting processes.
- The `isolation` field gives a one-edit revert to per-process execution.
- Cycle 1: the arrived stateless `DocsReceiptRevision.psm1` import lost `-Force`; the module holds two load-time constants only (reviewer read of the D6 audit and the module).

#### API and safety notes
- The runner sets the global `LASTEXITCODE` to a sentinel per hook so an unchanged sentinel maps to exit 0; this is necessary because hook scripts report exit codes through that variable.
- The registry hook path is resolved to a hooks-folder sibling before the dynamic `&` call (D9 carve-out).

#### Error handling and logging
- Registry and guard failures fail closed (`HOOK_DISPATCH_BLOCKED:` or exit 2); per-hook terminating errors map to no decision, matching per-process behavior.

### C# implementation audit (if applicable)

#### What changed well
- No C# file is in the branch diff.

#### Type safety and API notes
- Not applicable.

#### Error handling and logging
- Not applicable.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `evidence/qa-gates/pester.2026-11-14T07-45.md` (24357 tests, 0 failures; per-file coverage table)
- `evidence/qa-gates/pytest.2026-11-14T07-50.md` (16723 passed)
- `evidence/qa-gates/leak-scan.2026-11-14T07-51.md`, `powershell-static.2026-11-14T07-29.md`, `python-static.2026-11-14T07-29.md`, `consistency.2026-11-14T07-52.md`, `self-review.2026-11-14T07-53.md`
- `artifacts/pester/powershell-coverage.xml` and `artifacts/python/coverage-final.json`, parsed directly by the reviewer

### Quality assessment prompts
- The parity suite enumerates hooks from the registries and registrations at test time and compares per-hook and combined outcomes between real processes and the dispatcher.
- The module-load test detects a forced re-import because the runner snapshot keys module instances by object identity.
- No local test exercises the TypeScript push-down closure, which is the gap behind F2.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Leak scan 0 failures; no allowlist change. |
| No unsafe subprocess or command construction | ✅ PASS | Child processes use `ProcessStartInfo.ArgumentList` with `-NoProfile -File <path>`; the path is resolved to a hooks-folder `.ps1` sibling. |
| Input validation at boundaries | ✅ PASS | Registry schema validated; payload without a tool name fails closed. |
| Error handling remains explicit | ✅ PASS | Fail-closed dispatcher errors; per-hook failures keep per-process outcomes. |
| Configuration / path handling is safe | ✅ PASS | Registry paths are repository-relative and checked for existence. |

---

## Research Log

- `git diff --name-status 2c8dee6dd..9478c4b65` and `git diff 1083e7680..HEAD` (cycle 1 code delta: one line in one hook and its mirror).
- CI: `gh pr checks 1177`; job step lists and annotations for runs 43573314091 and 43573314076; failure logs of run 43570680445; main push run 43559694003 at the merge base (only `poshqc / PowerShell QC static` failed there).
- Local reproduction of QT008 at the reviewed head and control run on the main checkout.
- Real-process probe of both dispatchers with allow, deny and non-JSON payloads.
- Coverage XML and JSON parsed by a scratch script.

---

## Verdict

**Needs Revision.** Two blocking findings (F1 tier entry, F2 TypeScript closure test helper). Both are contained and autonomous. Info rows require no change.
