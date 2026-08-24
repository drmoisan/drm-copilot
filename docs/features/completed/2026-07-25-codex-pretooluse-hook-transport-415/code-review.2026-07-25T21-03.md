# Code Review: Codex PreToolUse Hook Transport Repair (#415)

**Review Date:** 2026-07-25
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415`
**Feature Folder Selection Rule:** single active folder whose suffix matches the issue number in the branch name (`bug/codex-pretooluse-hook-transport-415`).
**Base Branch:** `main` (merge-base `009808510363081d0db7684f7b555f2ded4b0b7c`)
**Head Branch:** `bug/codex-pretooluse-hook-transport-415` (`ee98ca7fb69901f541ae10cf8f63f46262f3e6d5`)
**Review Type:** Initial review
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `code-review-template` resolves; the MCP tool itself was unavailable in this session).

---

## Executive Summary

This branch repairs the transport layer of the eight Codex `PreToolUse` handlers registered under the `^(apply_patch|Edit|Write)$` matcher. Before the fix, seven handlers exited 2 on every invocation (their validators hard-required `tool_name == 'apply_patch'`) and the eighth rejected `Edit`/`Write`; well-formed but unmapped `apply_patch` input also exited 2 instead of allowing. The fix extracts one shared, entrypoint-free transport module (`.codex/hooks/codex-pretooluse-file-mapping.ps1`, 474 lines) that all eight handlers dot-source; each handler's allow/deny policy functions are byte-unchanged. Root/bundle byte-identity is restored, including deletion of the unregistered bundle-only `enforce-pr-author-skill.ps1` (cross-referenced to issue #335).

The scope is 59 files (+4389/−1332), of which 23 are production/test logic and the rest feature docs and evidence. Evidence reviewed: the full branch diff (`artifacts/pr_context.appendix.txt` scope, re-derived locally), the executor's 27 evidence artifacts, and independent re-execution of all five affected Pester suites (59 tests), the pytest parity contracts (8 tests), Black, Ruff, and Pyright. Implementation quality is high: the shared module is well-documented, fail-fast where the contract demands exit 2 and deliberately tolerant where the contract demands allow, and the test suites are process-level contract tests that derive their matrix from `.codex/config.toml` so future registrations cannot silently escape coverage.

**What changed:**
- NEW `.codex/hooks/codex-pretooluse-file-mapping.ps1` (+ byte-identical bundle mirror): `ConvertFrom-CodexPreToolUsePayload` (hook-named exit-2 throws for empty stdin / invalid JSON / missing `tool_input`; optional `-RequireSessionId`) and `ConvertTo-CodexFileEditInput` (admission by tool name, direct `file_path` mapping, apply_patch marker parsing, governed-path-scoped Update reconstruction), plus 3 documented internal helpers.
- 8 rewired hooks: per-hook validators/mappers deleted; entrypoints call the shared module; policy functions untouched (verified per-hunk).
- Bundle-only orphan deletion + `pack-manifests/core.json` entry + parity/static list extensions.
- 2 new Pester suites (33 tests) + retargeted mapping-unit assertions in the legacy suite + 1-line pytest exception-list cleanup.

**Top 3 risks:**
1. Coverage instrument gap: the new module and 7 of 8 rewired hooks are outside `CodeCoverage.Path`, so line-coverage regressions in this transport surface would be invisible to the coverage gate (Blocker B1, remediation enumerated).
2. Live Codex `Edit`/`Write` `tool_input` field names are unconfirmed against the live CLI (no captured payloads exist in-repo); the tolerant mapping degrades a shape mismatch to allow, which is the spec-accepted mitigation but means a field-name mismatch would silently disable enforcement for those tool names until observed.
3. The shared parser no longer asserts `hook_event_name == 'PreToolUse'`, so a mis-delivered non-PreToolUse envelope would be evaluated instead of rejected (Minor; registration controls delivery in practice).

**PR readiness recommendation:** **Needs Revision** — implementation and tests are sound and independently re-verified, but two Blocking coverage-evidence findings (policy audit B1/B2) must be remediated before PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` (lines 23-98) | The new production module `codex-pretooluse-file-mapping.ps1` and 7 of the 8 rewired hooks are absent from the coverage allow-list; per-file coverage for the changed production surface is unmeasured (module confirmed absent from `artifacts/pester/powershell-coverage.xml`). | Add the 8 root `.codex/hooks` files to `CodeCoverage.Path` (with in-process dot-source exercise where entrypoint guards limit attribution) and record per-file numbers; see `remediation-inputs.2026-07-25T21-03.md` R1. | `.claude/rules/general-unit-test.md` Coverage Exclusion Policy requires every production file in the coverage denominator; new-file/modified-file thresholds are unverifiable without measurement; the file's own history shows this exact gap drove prior remediation cycles (#275, #301, #344, #357). | `pester.runsettings.psd1` inspection; coverage XML grep; `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md` |
| Blocker | `artifacts/python/lcov.info` (absent) | n/a | No Python coverage artifact exists although the branch changes a Python file (`test_push_down_codex_and_agents_pack_manifest_completeness.py`); the plan explicitly scoped out the full `--cov` run. | Run `poetry run pytest --cov --cov-branch` once and record repo-wide numbers under `evidence/qa-gates/`; see `remediation-inputs.2026-07-25T21-03.md` R2. | Coverage verification is mandatory for every language with changed files; the fail-closed rule applies when the artifact is absent. Mitigating context: test-only change, parity suites green — the gap is evidentiary, not behavioral. | Directory listing (`artifacts/python/` does not exist); plan `[P0-T6]` scope note quoted in policy audit `## Rejected Scope Narrowing` |
| Minor | `.codex/hooks/codex-pretooluse-file-mapping.ps1` | `ConvertFrom-CodexPreToolUsePayload` (lines 121-143) | The shared parser drops the per-hook validators' previous `hook_event_name -eq 'PreToolUse'` assertion; a well-formed payload for a different lifecycle event would now be evaluated rather than rejected with exit 2. | Optional hardening in a follow-up: reject or no-op non-`PreToolUse` `hook_event_name` values. No change required for this fix. | Codex only delivers PreToolUse payloads to these registrations, so the practical exposure is nil; noting it keeps the contract change visible. | Diff of removed validators (e.g., `enforce-evidence-locations.ps1` old lines 145-166) vs module source |
| Info | `.codex/state/` | n/a | The untracked runtime state directory observed pre-review was deleted as environment hygiene; `.codex/state` is not gitignored, so recurrence is possible. | Consider a follow-up `.gitignore` entry for `.codex/state/`. | Spec requires untracked session state never be committed; an ignore rule makes that structural instead of manual. | `Test-Path .codex/state` = false at review time; spec.md:120 |
| Info | `.codex/hooks/enforce-evidence-locations.ps1` | `Invoke-EvidenceLocationEntryPoint` param block | Latent defect fixed in passing: empty stdin previously produced exit 0 (silent allow — a Mandatory-parameter binding failure skipped the exit path); it now reaches the shared parser and exits 2. | None — this is spec AC 4 behavior, with fail-before/pass-after evidence. | Executor self-reported deviation 3; the change tightens fail-closed behavior and is covered by the integration suite's empty-stdin case across all 17 registered handlers. | `evidence/other/phase5-poshqc-loop.2026-07-25T20-16.md`; `evidence/regression-testing/fail-before.2026-07-25T19-30.md` |
| Info | `.codex/hooks/codex-pretooluse-file-mapping.ps1` | module header (lines 25-30) | Executor self-reported deviation 2: the module defines 3 internal helpers beyond the 2 specified public functions. | None — acceptable. | The spec's "two functions" describes the public surface; the general code-change policy requires long branching logic to be factored into small focused functions. The header documents the public/internal split and no hook calls the internals (verified by grep). | Module docstring; `grep -r 'ConvertTo-CodexAddedLineText\|Test-CodexGovernedPath\|Resolve-CodexUpdatedFileContent' .codex/hooks` returns only the module and the two test suites |
| Info | `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | lines 182-202 | Executor self-reported deviation 1: plan Interpretation I4 expected the checkpoint hook to allow a partial `Edit`; measurement showed the preserved policy denies (missing content treated as deletion, `enforce-checkpoint-monotonic.ps1:230-239`), and the tests assert the measured deny. | None — asserting measured preserved-policy behavior is correct. | Hard Constraint 3 preserves policy exactly; a new deny on `Edit` is the existing policy finally being applied (spec.md:203), not a policy change. The sentinel `old_string` makes the case deterministic regardless of checkpoint state. | Test source; `enforce-checkpoint-monotonic.ps1:230-239` (policy function unchanged in diff) |

No Major findings. The two Blockers are coverage-evidence gaps, not behavioral defects.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **Single-responsibility extraction with byte-preserved policy.** All eight diffs follow the same shape: dot-source insertion, deletion of the per-hook validator/mapper, and a minimal entrypoint rewrite. Per-hunk inspection confirms no policy function body changed; the four pre-existing deny-path/fail-closed parity cases pass without assertion changes.
- **Correct allow/deny/exit-2 partitioning.** Exit 2 is now reserved for genuinely unprocessable stdin (empty, invalid JSON, missing `tool_input`, and missing `session_id` for the two state-keyed budget hooks); unmapped well-formed input allows. This closes both halves of the defect plus the latent ungoverned-Update defect (reconstruction now runs only for the governed checkpoint path; governed reconstruction failure yields empty content, which routes into the existing fail-closed deny instead of exit 2 — a careful piece of design documented in the module's `.NOTES`).
- **Both-sides rename semantics preserved per consumer.** The record carries `file_path` and `source_path` because evidence-location and budget policies evaluated both sides of a `*** Move to:` rename pre-fix while purity/checkpoint policies evaluated only the result; the mapping keeps each consumer's inputs identical (documented in the function docstring, asserted by the retargeted parity case).
- **Preimplementation gate rewired with explicit path preservation:** `Bash`/`apply_patch` traverse the pre-fix raw-`tool_input` path unchanged; only `Edit`/`Write` route through mapping.

#### API and safety notes

- Advanced functions throughout with `[CmdletBinding()]`, `[OutputType()]`, mandatory/validated parameters. The deliberate `[AllowEmptyString()]`/`[AllowNull()]` relaxations carry comments explaining why binding failures must not preempt the hook-named exit-2 path — the exact mechanism behind the old silent-allow latent defect.
- Script-scoped constants are read-only in practice (admitted names, regexes, governed path); no mutable global state introduced.
- Approved verbs; analyzer clean at zero findings.

#### Error handling and logging

- Every thrown transport message begins with the caller-supplied `-HookName`, fixing the misattributed `enforce-completion-consistency` stderr (asserted by a dedicated regression case).
- `Resolve-CodexUpdatedFileContent` never throws by design; failures return empty content with a `Write-Verbose` trace, converting governed reconstruction failures into policy denies rather than transport errors. The rationale is documented; this is intentional, not a swallowed error.
- Hooks communicate only via exit code, stdout envelope, and stderr; no new logging channels.

### Python implementation audit

#### What changed well

- The only Python change removes the now-stale `enforce-pr-author-skill.ps1` entry from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` in the manifest-completeness contract test — exactly the cleanup the orphan deletion requires, keeping the exception list honest.

#### Typing and API notes

- No new public Python API surface was added. Pyright clean (re-verified: 0 errors).

#### Error handling and logging

- Not applicable; no Python runtime code changed.

---

## Test Quality Audit

The verification model is process-level contract testing: ~130 real hook-process spawns per full run, with stdin fed via `ProcessStartInfo` + `RedirectStandardInput` (no temporary files, satisfying Hard Constraint 5) and poisoned `CLAUDE_*` environment variables baked into every spawn so each case doubles as an environment-independence proof. Coverage, regression, and parity evidence are all present; the one gap is numeric per-file line coverage for the rewired surface (Blocker B1).

### Reviewed test and QA artifacts

- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` — 27 tests: safe-payload allows (8 handlers × 3 tool names), unmapped-input allows, session_id fail-closed, latent-defect regression, 15 native-deny-envelope cases (asserting the exact envelope and absence of the legacy `decision` key), preimplementation-gate mapped denies (unit-level, injected checkpoint), missing/null `tool_input` fail-closed. Re-run by this review: pass.
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — 6 tests: config-driven matrix (59 spawns derived from `.codex/config.toml` registrations and matcher regexes, with a guard test preventing a vacuous parse), empty-stdin/invalid-JSON fail-closed across all 17 registered handlers, self-naming stderr regression, batch-budget state hygiene. Re-run by this review: pass.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — parity/static gates extended to the shared module (parse, 500-line cap, hash parity, no-`$env:CLAUDE_`, core-manifest listing); mapping-unit assertions retargeted at the shared module with identical expected values; deny-path and fail-closed assertions untouched. Re-run: pass.
- `evidence/regression-testing/fail-before.2026-07-25T19-30.md` / `pass-after.2026-07-25T20-46.md` — 32-row measured fail-before table reproducing the spec's stderr messages against pre-fix hooks; matching pass-after run all-zero. Canonical fail-before/pass-after pair per evidence conventions.
- `evidence/qa-gates/*` — final PoshQC loop (format/analyze/test exit 0, 1391 tests), Black/Ruff/Pyright, pytest parity, coverage comparison with honest per-package deltas.

### Quality assessment prompts

- **Determinism:** No clocks, randomness, sleeps, or network. Checkpoint-dependent deny cases use a sentinel `old_string` that cannot occur in any real checkpoint, so outcomes are independent of on-disk state. Batch-budget safe payloads target `README.md` so no state is written (asserted).
- **Isolation:** Each `It` targets one contract facet; process spawns share no state; the one dot-sourcing unit case injects `-CheckpointRaw`.
- **Speed:** 63s + 13s for the affected suites in this review's environment — driven by deliberate process spawning, which is the unit under test.
- **Diagnostics:** `-Because` annotations name the handler and case; the integration matrix reports every failing combination in one aggregated message.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` content anywhere in the 59-file diff. |
| No unsafe subprocess or command construction | ✅ PASS | Tests spawn `pwsh` via `ProcessStartInfo` with `ArgumentList` (no shell interpolation); hooks spawn nothing. The poisoned `CLAUDE_TOOL_INPUT` value (`git reset --hard`) is proven inert by ~130 spawns. |
| Input validation at boundaries | ✅ PASS | Stdin is the only input; empty/invalid/missing-`tool_input` fail closed with exit 2; admission is matcher-scoped tool names; unmapped input allows by documented contract. |
| Error handling remains explicit | ✅ PASS | All throws are specific and hook-named; the single never-throw function documents why (fail-closed-by-empty-content is the governed policy signal). |
| Configuration / path handling is safe | ✅ PASS | Governed-path matching uses `[regex]::Escape` with segment anchoring (`(^|/)<path>$`), backslash normalization, and empty-governs-nothing semantics; no path concatenation into commands. |

---

## Research Log

No external research was required. All conclusions derive from repository sources: the branch diff, `.codex/config.toml`, the spec/plan/research artifacts, the executor's evidence tree, `artifacts/pester/powershell-coverage.xml`, and independent local re-execution of the toolchain suites named above.

---

## Verdict

The implementation is a disciplined transport-layer repair: policy functions are byte-preserved (independently verified), the exit-code contract now matches the native Codex PreToolUse specification, root/bundle parity is restored and quadruple-gated, and the new tests are self-updating against `.codex/config.toml` rather than hand-maintained lists. All six hard constraints hold, and all five affected test suites plus the Python toolchain were re-executed green by this review.

The change is **not ready for normal PR flow yet** solely because of the two Blocking coverage-evidence findings: the changed PowerShell production surface sits outside the coverage instrument (B1), and the Python per-language coverage artifact is absent (B2). Both are remediable without behavioral change and are enumerated with verification commands in `remediation-inputs.2026-07-25T21-03.md`. After remediation and a re-audit showing per-file numbers, this branch is a Go.
