# Code Review: Codex PreToolUse Hook Transport Repair (#415) — Cycle-1 Re-Audit (R4)

**Review Date:** 2026-07-26
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415`
**Base Branch:** `main` (merge-base `fb483b8468204e4385b5583c3b3ec4c0a987eede`; the branch was rebased onto current `main` after the cycle-1 audit, moving the merge-base from `00980851`)
**Head Branch:** `bug/codex-pretooluse-hook-transport-415` (`fa198b008984c77f6ca1a4cfdbdcc801372c0a1f`)
**Review Type:** Re-review after remediation of cycle-1 Blockers B1 and B2
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `code-review-template` resolves; the MCP resolver tool was unavailable in this session).

---

## Executive Summary

The cycle-1 review (`code-review.2026-07-25T21-03.md`) found the implementation sound and independently re-verified, gated solely by two Blocking coverage-evidence findings: the changed PowerShell production surface was outside `CodeCoverage.Path` (B1) and no Python coverage artifact existed (B2). This re-review examined the remediation commit (`fa198b00`, on top of the rebase) with the same full feature-vs-base scope and confirms both Blockers are resolved without any production-behavior change.

**Remediation shape (verified by diff inspection):** the only production-file change is the additive 13-line `CodeCoverage.Path` extension applied identically to both `pester.runsettings.psd1` copies (byte parity reviewer-verified); everything else is additive tests (5 new Pester suites, 2 extended), one `.gitignore` line, and evidence. Nothing under `.codex/` or `.claude/` changed during remediation. No entry was removed from the measured set, `CoveragePercentTarget` stays 0, no assertion was weakened (the one restructured static check in `legacy-codex-hook-contracts.Tests.ps1` was split into two strictly wider checks that now also cover the shared module), and no analyzer suppression was added.

**Independent verification performed by this review at HEAD:**
- Parsed `artifacts/pester/powershell-coverage.xml` directly: 39 measured files, repo-wide 2869/3042 = 94.31%, and per-file numbers matching every executor claim exactly (shared module 101/101; the 8 rewired hooks 96.55%–100.00%; changed-surface 776/783 = 99.11%).
- Summed `artifacts/python/lcov.info`: 11175/12280 = 91.00% lines, 3642/4450 = 81.84% branches — exact match with the executor's derivation.
- Re-ran all 16 Pester suites under `tests/scripts/codex-hooks/`: 433 tests, 0 failures (including the 59-spawn config-driven matrix and the ~130 poisoned-environment process spawns).
- Re-ran Black (clean), Ruff (clean), and the 8-test pytest parity subset (pass).
- Verified the caller-flagged measurement deviation (see Findings Table, Info row 1): CI's test step (`.github/workflows/_poshqc.yml:38-42`) imports the repo-checkout PoshQC module, and `PoshQC.psm1:3` resolves runsettings relative to that module — so the executor's `Invoke-PoshQCTest -Root <repo>` invocation is command-for-command the CI path and the coverage measurement is CI-reproducible. The MCP tool's inability to see the edit is a packaging lag of the published v1.0.19 server, not a property of the repository.
- Verified the two residual-line justifications against source: the `-not`/`-contains` precedence dead branch at `enforce-checkpoint-monotonic.ps1:260-261` is real (constant-false condition; pre-existing policy code protected by Hard Constraint 3), and the batch-budget deny-serialization lines genuinely require prohibited on-disk session state, with the deny logic fully unit-covered through injected seams.

**Test-quality assessment of the new remediation suites:** high. The 28 in-process entrypoint cases use `[System.Console]::SetIn([System.IO.StringReader]::new(...))` with both console readers restored in `finally` — a clean no-temp-file stdin seam consistent with the repository's determinism rules — and the suites verify their own hygiene (`Test-Path .codex/state` false after the run).

**PR readiness recommendation:** **Go.** Zero Blockers, zero Majors. Three informational items remain, all recorded as deferred follow-ups with rationale.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` | Resolution of cycle-1 Blocker B1, with a caller-flagged deviation: the MCP `run_poshqc_test` tool executes the PoshQC module bundled in the npx-cached `@danmoisan/drm-copilot-mcp` v1.0.19 whose packaged runsettings predates this edit, so the authoritative coverage XML was produced via `Invoke-PoshQCTest -Root <repo>`. | None required now. At the next extension/MCP release, confirm the republished bundle carries the corrected measured set (the runsettings parity contract already enforces this at build time). | Reviewer verified CI runs exactly the executor's invocation (`_poshqc.yml:38-42` imports the workspace module; `PoshQC.psm1:3` binds settings to the module directory), so the measurement is trustworthy and CI-reproducible — B1 is genuinely resolved, not merely locally resolved. Both paths were run and both are green (1668/0 and 1659+9/0). | `.github/workflows/_poshqc.yml:38-42`; `scripts/powershell/PoshQC/PoshQC.psm1:1-3`; `evidence/qa-gates/remediation-final-poshqc-test.2026-07-26T11-41.md`; independent XML parse by this review |
| Info | `artifacts/python/lcov.info` | n/a | Resolution of cycle-1 Blocker B2: the artifact now exists (344174 bytes) with repo-wide 91.00% lines / 81.84% branches, unchanged from baseline as expected for a branch whose only Python change is one deleted test line. | None. | Coverage verification is mandatory for every language with changed files; the evidence gap is closed with numbers the reviewer reproduced independently from the lcov records. | `evidence/qa-gates/python-coverage.2026-07-26T11-41.md`; independent lcov summation by this review |
| Info | `.codex/hooks/enforce-checkpoint-monotonic.ps1` | lines 260-261 | Pre-existing dead branch discovered during coverage closure: `if (-not $payload.PSObject.Properties.Name -contains 'completed_steps')` evaluates `-not` before `-contains`, so the condition is constant-false and line 261 is unreachable. Benign today: the fall-through path reaches the same allow outcome. | Fix the precedence (parenthesize the containment test) in a dedicated follow-up issue; it is a policy-function line and therefore untouchable in this remediation under Hard Constraint 3. | Reviewer confirmed the precedence analysis against source; the branch is the single uncovered line in the file and is correctly justified rather than papered over with a denominator adjustment. | `enforce-checkpoint-monotonic.ps1:260-261`; `evidence/qa-gates/per-file-coverage-final.2026-07-26T11-41.md` section (iv); `evidence/other/remediation-followups.2026-07-26T11-41.md` |
| Info | `.codex/hooks/codex-pretooluse-file-mapping.ps1` | `ConvertFrom-CodexPreToolUsePayload` | Carried forward from cycle 1 (Minor, now recorded as a deferred follow-up): the shared parser performs no `hook_event_name` assertion, so a mis-delivered non-PreToolUse envelope would be evaluated rather than rejected. | Optional hardening in a follow-up; must not change allow/deny semantics. | Registration controls delivery in practice; exposure is nil today. The item is tracked with rationale and binding constraints in the follow-up dossier, which is the appropriate disposition for a non-blocking hardening. | `evidence/other/remediation-followups.2026-07-26T11-41.md` |

No Blocker, Major, or Minor findings remain. The cycle-1 Info items (`.codex/state/` not gitignored; latent evidence-locations silent-allow; helper-count deviation; measured-deny test deviation) are all either delivered (`.gitignore` now contains `.codex/state/`, reviewer-verified) or were closed as acceptable in the cycle-1 review.

---

## Implementation Audit

### Remediation delta (this cycle)

- **Measurement configuration:** the 13 added lines per runsettings copy consist of a five-line attribution comment (issue #415, R1) and the 8 paths, appended after the issue #392 block in the same additive style every prior remediation used (#275, #301, #305, #312, #334, #344, #357, #366, #392). No pre-existing entry was touched. Both copies byte-identical (reviewer diff of HEAD blobs).
- **New test suites:** `codex-test-purity-hooks.Tests.ps1` (304), `codex-batch-budget-hooks.Tests.ps1` (346), `codex-evidence-and-checkpoint-hooks.Tests.ps1` (400), `codex-completion-consistency-hook.Tests.ps1` (168), `codex-pretooluse-file-mapping.Tests.ps1` (411) — all ≤ 500 lines, all under `tests/scripts/codex-hooks/` mirroring production, all `*.Tests.ps1`.
- **In-process entrypoint technique:** `& $HookPath` after `[System.Console]::SetIn(...)`/`SetError(...)` with restoration in `finally`, plus `Push-Location`/`Pop-Location` where checkpoint lookup must be deterministic. This attributes coverage to the guarded entrypoint lines without temp files or process spawns, and is why the entrypoint arms reached 96.55%–100.00% raw.
- **No production behavior change:** `git diff abaa6d51 --name-only -- .codex/` is empty; the four parity gates and all pre-existing deny-path/fail-closed assertions pass unmodified.

### Delivery delta (re-verified at the new merge-base)

The rebase moved the merge-base to `fb483b84`; the hook rewiring, shared module, bundle parity, orphan deletion, and manifest entry re-verify at HEAD exactly as in cycle 1: policy functions byte-untouched (diff hunks confined to docstrings, dot-source insertions, deleted duplicated plumbing, and entrypoints), root/bundle byte-identity in both directions, config.toml absent from the diff with 5 / 5 / 8 handler blocks intact.

### Python implementation audit

Unchanged from cycle 1: the single Python change deletes the now-stale `enforce-pr-author-skill.ps1` exception entry. Pyright 0 errors; no typed-surface changes.

---

## Test Quality Audit

- **Determinism:** No clocks, randomness, sleeps, network, or temp files in any changed suite (reviewer grep). Budget entrypoint cases are restricted to payloads that cannot reach the state-writing path; the suite asserts `.codex/state` does not exist after the run — reviewer confirmed the same after its own 433-test re-run.
- **Isolation and independence:** In-process cases restore console readers and location in `finally`; unit cases inject all filesystem seams; process cases share nothing.
- **Assertion strength:** Deny cases assert the exact native envelope and the absence of the legacy `decision` key; exit-2 cases assert empty stdout, nonempty stderr, and hook-name prefixes; the integration matrix carries a guard test preventing a vacuously green parse.
- **Coverage honesty:** No RI-1 residual computation was used; every per-file verdict rests on the raw number, and the 7 residual lines are justified per-line rather than excluded. The reviewer checked both justifications against source and found them accurate.
- **Speed:** 69s for the 433-test subset, dominated by the process spawns that constitute the contract under test.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Remediation diff contains only settings paths, test code, and evidence; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | New in-process cases invoke script files directly (`& $HookPath`); process cases keep the `ProcessStartInfo`/`ArgumentList` pattern; no shell interpolation. |
| Input validation at boundaries | ✅ PASS | Unchanged from cycle 1; re-verified via the malformed-stdin sweep (34 spawns) in the reviewer re-run. |
| Error handling remains explicit | ✅ PASS | No catch-alls added; test helpers rethrow or assert. |
| Coverage-gate integrity | ✅ PASS | Additive-only measured-set change; thresholds and denominators untouched; parity contract binds the bundle copy. |

---

## Research Log

No external research was required. Conclusions derive from: the branch diff (`fb483b84..fa198b00`), `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`, direct parsing of both coverage artifacts, direct source inspection of the hooks and suites, `.github/workflows/_poshqc.yml`, `scripts/powershell/PoshQC/PoshQC.psm1`, the executor's remediation evidence tree, and reviewer re-execution of the Pester/pytest/Black/Ruff subset described above.

---

## Verdict

Both cycle-1 Blockers are resolved by a remediation that is exactly what the remediation inputs prescribed: a measurement-configuration change plus additive tests, with zero production-behavior movement. Every claimed number reproduced independently; every constraint re-verified at HEAD; the flagged measurement deviation is adjudicated as CI-equivalent and therefore sound. **Blocking findings: 0. Recommendation: Go for PR creation.**
