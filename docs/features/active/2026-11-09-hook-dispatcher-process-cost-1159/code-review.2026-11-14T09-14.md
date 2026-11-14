# Code Review: PreToolUse hook dispatcher, one process per tool call (#1159)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
**Feature Folder Selection Rule:** the only feature folder carrying issue #1159; no version subfolder
**Base Branch:** `main` (merge base `1d9f14e2c595b0065ad42a24188620f320ac514c`)
**Head Branch:** `feature/hook-dispatcher-process-cost-1159` at `5a58ecdc239fce59d73db7194cfaa371f3df355a` (PR #1177)
**Review Type:** Post-remediation re-review (R4, remediation cycle 2 plus a main-sync merge of issue #1156) and concurrent PR review; scope is the full branch diff

---

## Executive Summary

The branch replaces the per-hook PreToolUse registrations in `.claude/settings.json` and `.codex/config.toml` with one dispatcher registration per runtime. Each dispatcher reads its generated registry (`pretooluse-dispatch.json`), selects the groups whose matcher admits the tool name, runs every selected hook unchanged in its own script scope in one `pwsh` process, and combines decisions by the D4 precedence. The branch diff against the new merge base is 275 files (11448 insertions, 972 deletions).

Remediation cycle 2 closed both blocking findings of the previous review. F1: `quality-tiers.yml` now classifies `.claude/lib/hook-dispatch` as T3, and `check_quality_tiers` at the reviewed head prints `quality-tiers: OK (35 entries, 35 discovered projects)` (reviewer run). F2: `collectRegisteredHookClosure` now seeds the closure roots with the hooks named by the bundle `.codex/hooks/pretooluse-dispatch.json` through the new exported `registryHookPaths`, which uses the same command-path pattern as the Python twin `registry_hook_paths`. CI `root-typescript-tests` passes on ubuntu-latest and windows-latest at the reviewed head.

The main-sync merge `5a58ecdc2` is neutral for the branch: `git diff --numstat` from the old merge base to the cycle 2 head `bf1805ec0` equals `git diff --numstat` from the new merge base to the reviewed head, path by path (275 paths, no difference). The arrived #1156 hook files import no module, and #1156 did not touch `.claude/settings.json` or `.codex/config.toml`, so the registries still reproduce the merged registrations.

**What changed:**
Cycle 2: one `quality-tiers.yml` entry; `registryHookPaths` and the registry-aware `collectRegisteredHookClosure` in `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts`; a new unit-test file `real-bundle-filesystem.test-helpers.test.ts` (3 cases); two added assertions in `codex-bundle-publish.integration.test.ts`; acceptance-criteria checkbox state. Whole branch: new `HookDispatch.psm1`, `HookDispatchRunner.psm1`, Claude and Codex entry scripts, Codex `hook-dispatch.ps1`, two registries, `HookProcessCost.psm1` and `Measure-HookProcessCost.ps1`, single dispatcher registrations and their bundle copies, D6 `-Force` removals, D13 tail rewrites, registry-aware test helpers in PowerShell, Python and TypeScript, and documentation.

**Top 3 risks:**
1. The posted PR body predates remediation cycles 1 and 2 and the main sync. It cites pre-cycle evidence, omits the cycle 2 files, and still states that a main sync is required (finding N1, non-blocking).
2. CI ran concurrently with this review. Run 43579582942 completed on the reviewed head with all 26 checks passing, including the Linux hook-suite job, the PowerShell shards and `quality-checks7` (tier check and Python coverage gate). The remaining step is the orchestrator's S9 CI-gate record.
3. The local coverage reports predated the merge commit, so the reviewer re-ran the root Jest, pytest and Pester coverage gates at the reviewed head (see the policy audit).

**PR readiness recommendation:** **Go**. No blocking finding remains, and CI is green on the reviewed head. Refresh the PR body before merge (N1, non-blocking).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `quality-tiers.yml` | `projects`, entry after `.claude/lib/hook-payload` | Previous finding F1 is closed. The `.claude/lib/hook-dispatch` entry is T3 and uses the sibling runtime-library rationale. | None. | CI `tier-classification` failed with QT008 before the fix. | Reviewer run of `poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree>` at `5a58ecdc2`: `quality-tiers: OK (35 entries, 35 discovered projects)`, exit 0 (the merged head also carries the #1156 `.claude/lib/regeneration` entry); `evidence/remediation-baseline/quality-tiers.2026-11-14T08-45.md` (fail-before), `evidence/qa-gates/quality-tiers.2026-11-14T09-02.md`. |
| Info | `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` | `registryHookPaths`, `collectRegisteredHookClosure` | Previous finding F2 is closed. The helper reads the bundle registry and adds its 21 hook paths to the closure roots. A missing registry throws, so the helper fails closed. The pattern `/\/(\.codex\/hooks\/[^/"']+\.ps1)/` equals the Python `_HOOK_COMMAND_PATH`. | None. | Spec AC lines 201 and 203 require the closure tests to pass and every shape-pinning test to read the registry. | `evidence/remediation-baseline/jest-root.2026-11-14T08-48.md` (fail-before: `Expected: > 21, Received: 10`); `evidence/qa-gates/jest-root.2026-11-14T09-01.md`, `jest-extension.2026-11-14T09-01.md` (0 failed); reviewer `node` count of registry hook paths = 21; CI `root-typescript-tests` ubuntu and windows pass at `5a58ecdc2`; reviewer root Jest re-run at the reviewed head (policy audit, section 1.2.1). |
| Minor | `artifacts/pr_body_1159.md` (posted PR #1177 body) | `## What Changed`, `## Verification`, `## Follow-ups` | N1: the posted body equals the artifact (apart from a trailing newline) but describes the branch before remediation cycles 1 and 2. Verification cites `pester.2026-11-14T06-25.md` and `pytest.2026-11-14T06-32.md`, not the final records. What Changed omits the `quality-tiers.yml` entry, the TypeScript helper and the new Jest test file. Follow-ups line 138 still states that a main sync is required before merge, and the branch has since merged `origin/main` twice. | Regenerate the body through the `pr-author` route before merge. Cite the final cycle 2 records, list the cycle 2 files, and remove the stale main-sync follow-up. | A reviewer reading the PR sees outdated verification figures and an open follow-up that is already done. Spec AC line 196 (the cost report quotes) is still satisfied, so this does not block. | `gh pr view 1177 --json body` compared with `artifacts/pr_body_1159.md`; body lines 90-98 and 138. |
| Nit | `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` | lines 110-111 | `expect(required).toEqual(expect.arrayContaining(registryHooks))` holds by construction, because `collectRegisteredHookClosure` seeds `pending` with the same `registryHookPaths` result. The `missing` assertion that follows is the check that discriminates. | Optional: keep the assertion as documentation or replace it with a count bound tied to the registry size. | An assertion that cannot fail adds no protection. The test as a whole does discriminate: the pre-fix helper fails it (fail-before record). | Code read of the helper (line 233) and the test. |
| Info | `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` | `registryHookPaths` | On a malformed registry shape (for example `hooks` not an array), the TypeScript twin skips the entry, while the Python twin raises `AttributeError`. Both read the same shipped registry, which `Read-HookDispatchRegistry` schema-validates at run time, and the `> 21` bound catches a total loss of registry roots. | No change required. | Divergence on malformed input only. The behavior on the shipped registry is identical. | Unit case `skips a registry hook whose command names no .codex/hooks script`; code read of `test_codex_core_manifest_closure.py` lines 160-180. |
| Info | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | lines 47-57 | Carried forward from the previous review: unguarded `Import-Module ... -Force` lines remain in two helpers dot-sourced by dispatched hooks (also `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` line 30). They are outside the D6 set and disclosed in the PR body. | No change required for this PR. | The parity test `loads each stateless shared module once per call` passes. | Reviewer `grep` at the reviewed head; Pester re-run (policy audit). |

No covered file in the branch diff is at or above 700 logical lines. The largest is `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 593 lines, measured over 134 added or modified covered files. `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- No Python file changed in cycle 2. The branch's three Python test files (`test_codex_core_manifest_closure.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_discovery_publication_contracts.py`) are unchanged since the previous review, which found them compliant.

#### Typing and API notes
- `registry_hook_paths(registry_text: str) -> set[str]` and `registry_text: str | None = None`; pyright clean in the cycle 1 static record.

#### Error handling and logging
- Test helpers only; no broad catches.

### TypeScript implementation audit (if applicable)

#### What changed well
- `registryHookPaths` parses the registry as `unknown` and narrows it with the `isRecord` and `arrayProperty` guards. It uses no type assertion and no suppression.
- The helper returns paths in registry order without duplicates. A `Set` preserves insertion order, which the first unit case asserts.
- The new unit tests use in-memory text only and follow the Arrange-Act-Assert structure.

#### Type safety and maintainability
- The TSDoc on `collectRegisteredHookClosure` names both root sources and the fail-closed read.
- Prettier, ESLint and the extension type check (including `typecheck:test`) report 0 findings (`evidence/qa-gates/typescript-static.2026-11-14T09-00.md`).

#### Error handling and logging
- A missing registry or invalid JSON throws, so the test fails rather than passing with fewer roots.

### PowerShell implementation audit (if applicable)

#### What changed well
- No PowerShell file changed in cycle 2 (`evidence/qa-gates/conditional-gates.2026-11-14T09-07.md`). The previous review's assessment stands: hooks run unchanged with `&` in their own script scope, runner seams make the runner testable, and the `isolation` field gives a one-edit revert.
- The main sync brought `hook-epic-regeneration.ps1` and `enforce-epic-merge-gate-regeneration.ps1` (both runtimes). They are dot-sourced helpers, not registered hooks, and contain no `Import-Module` or dot-source line.

#### API and safety notes
- The registry hook path is resolved to a hooks-folder sibling before the dynamic `&` call (D9 carve-out); unchanged.

#### Error handling and logging
- Registry and guard failures fail closed (`HOOK_DISPATCH_BLOCKED:` or exit 2); unchanged.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- Cycle 2 records: `evidence/remediation-baseline/quality-tiers.2026-11-14T08-45.md`, `typescript-static.2026-11-14T08-47.md`, `jest-root.2026-11-14T08-48.md`, `jest-extension.2026-11-14T08-49.md`; `evidence/other/main-integration.2026-11-14T08-49.md`; `evidence/qa-gates/typescript-static.2026-11-14T09-00.md`, `jest-root.2026-11-14T09-01.md`, `jest-extension.2026-11-14T09-01.md`, `quality-tiers.2026-11-14T09-02.md`, `pytest.2026-11-14T09-07.md`, `conditional-gates.2026-11-14T09-07.md`, `consistency.2026-11-14T09-09.md`, `self-review.2026-11-14T09-09.md`.
- Reviewer re-runs at the reviewed head: root Jest with coverage, `pytest -n auto` with coverage, and `Invoke-PoshQCParallelTest` (figures in the policy audit).

### Quality assessment prompts
- Discrimination: the integration test fails against the pre-fix helper (`Received: 10`) and passes after the fix. The `missing` assertion fails if any registry hook is absent from the published payload.
- Consumer sweep: the cycle 2 sweep classifies every code and test hit outside the trees cycle 1 covered. The reviewer's independent `git grep` for `PreToolUse` in `*.ts` and for `.PreToolUse` / `hooks.PreToolUse` in `*.ts`, `*.py`, `*.cjs` and `*.mjs` found no other reader of the registration shape. The remaining hits are prose comments in `extensions/drm-copilot/src` and Python fixtures that build their own config text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Cycle 2 adds test code and one YAML entry only; leak scan from the cycle 1 final loop showed 0 failures with no allowlist change. |
| No unsafe subprocess or command construction | ✅ PASS | No new process start in cycle 2; the dispatcher's `ProcessStartInfo.ArgumentList` construction is unchanged. |
| Input validation at boundaries | ✅ PASS | `registryHookPaths` narrows parsed JSON from `unknown`; registry schema validation in the dispatcher is unchanged. |
| Error handling remains explicit | ✅ PASS | Missing registry throws in the test helper; dispatcher failures stay fail-closed. |
| Configuration / path handling is safe | ✅ PASS | Bundle paths are built with `node:path` joins; reviewer `cmp` shows the repository and bundle copies of settings, config, both registries, both entry scripts, `hook-dispatch.ps1` and both runner modules are byte-identical. |

---

## Research Log

- `git diff --name-status 9478c4b65..bf1805ec0` (cycle 2 delta) and `git show --cc 5a58ecdc2` (merge commit).
- Merge neutrality: `git diff --numstat 2c8dee6dd bf1805ec0` compared with `git diff --numstat 1d9f14e2c 5a58ecdc2`: identical across 275 paths.
- `git diff --name-only 2c8dee6dd 1d9f14e2c`, filtered for registration, hook, tier and manifest paths. #1156 changed hook helpers, pack manifests and `quality-tiers.yml`, but not `.claude/settings.json` or `.codex/config.toml`.
- Reviewer `check_quality_tiers` run at the reviewed head; `node` count of registry hook paths; `cmp` of mirrors; `git grep` consumer sweep.
- AC trail: `git show` of `8b3759ea5` and `bf1805ec0` for `spec.md` and `user-story.md`.
- CI: `gh pr checks 1177` and `gh run list --commit 5a58ecdc2` (run 43579582942; 26 of 26 checks passed by the end of the review).
- PR body: `gh pr view 1177 --json body` compared with `artifacts/pr_body_1159.md`.

---

## Verdict

**Go.** Previous findings F1 and F2 are closed and verified. No blocking finding remains. CI run 43579582942 is green on the reviewed head (26 of 26 checks, including the Linux hook-suite job). One Minor finding (N1, stale PR body) and one Nit are non-blocking; refresh the PR body before merge.
