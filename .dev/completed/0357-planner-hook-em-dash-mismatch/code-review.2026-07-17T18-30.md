# Code Review: planner-hook-em-dash-mismatch-357 (#357)

**Review Date:** 2026-07-17T18-30
**Reviewer:** feature-review (Claude Code subagent)
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3da03a242641fcef1f6e1c0892be7fe6fa14489`
**Review Type:** Re-review following remediation cycle 3 (triggered by a required-CI-check failure, not a local review finding)

---

## Executive Summary

This is a re-review of the full branch diff versus `main`, following remediation cycle 3 (commit `f3da03a2`, `fix(bundled-hooks): sync validate-planner-output with canonical fixes`). Cycle 3 was triggered by a required CI check failure on PR #358 (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`), not by a finding from this review chain — it surfaced a scoping error in the prior two remediation cycles and the prior code-review (`code-review.2026-07-17T17-15.md`), which had classified the bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` as an out-of-scope, Informational-only finding. That classification was incorrect: a repo-hygiene test enforces byte-identical parity between `.claude/` and its bundled mirror, and the mirror had drifted from the canonical file across the S5 em-dash fix and remediation cycle 2's PSObject strict-mode fix and BOM addition.

**What cycle 3 changed:** Exactly one production-tree file — the bundled mirror — via a raw byte-for-byte `Copy-Item` from the canonical source, per the remediation plan's explicit instruction to avoid a text-editing tool (which could silently drop the leading UTF-8 BOM the sync needed to preserve).

**What this review independently verified:**
- SHA-256 of `.claude/hooks/validate-planner-output.ps1` and its bundled mirror are identical (`614d88a79e7f9da7e8954fbdcc0f7ce8748af63de04e217760eab1f1e6c3851b`, 9829 bytes each).
- `git diff` of the bundled mirror shows exactly the five expected content deltas: leading BOM, em-dash phase-heading regex, em-dash error message, em-dash `.DESCRIPTION` docstring reference, and the strict-mode-safe `$null -ne $payload.PSObject.Properties['output']` check — nothing else changed.
- The previously-failing test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) now passes (1 passed).
- The full Python test suite passes with zero regressions (1533 passed, 0 failed).
- The canonical hook file and its test file are unchanged since the prior (17-15) review's approval — confirmed via `git log --oneline -- .claude/hooks/validate-planner-output.ps1`, whose most recent entry remains `67cd49a6` (remediation cycle 2).

**PR readiness recommendation:** **Go.** The functional fix and its test coverage remain correct and unchanged since the prior review's approval; the newly-fixed bundled-mirror parity closes the specific defect that caused this cycle's CI failure, with no unrelated drift introduced.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was the cycle-3 trigger) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` | whole file | The bundled mirror is now byte-identical to the canonical `.claude/hooks/validate-planner-output.ps1` (SHA-256 match, 9829 bytes both). | None — resolved. | Repo-hygiene contract (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires byte-identical parity between the two trees. | This review's own SHA-256 comparison and `git diff` inspection; `evidence/qa-gates/hash-diff-post-fix-remediation3.md`, `evidence/qa-gates/hash-diff-post-toolchain-remediation3.md`. |
| Superseded finding (from `code-review.2026-07-17T17-15.md`) | same file | same | The prior review's finding "Info (unchanged from cycle 0): distinct vendored copy, correctly out of scope per the remediation plans' explicit declarations" is now known to have been an incorrect scoping call — this file IS covered by a repo-enforced parity contract, and the "out of scope" framing is what caused the CI failure that triggered cycle 3. | None further — the underlying file-content defect is fixed; noting the process correction for the record. | `remediation-inputs.2026-07-17T18-00.md` documents this correction transparently rather than silently reversing course, consistent with the repository's "fail fast and explicitly" principle. | `remediation-inputs.2026-07-17T18-00.md` Section "Trigger condition met". |
| Info (unresolved, unchanged, genuinely out of scope for #357) | `.mcp.json` / MCP server resolution | `npx -y @danmoisan/drm-copilot-mcp` | The MCP-served `run_poshqc_test`/`run_poshqc_format`/`run_poshqc_analyze` tools still resolve a separately npm-published, npx-cached package independent of this workspace's source tree, so their own coverage artifact still omits `.claude/hooks/validate-planner-output.ps1`. This is a distinct defect from the bundled-mirror parity issue cycle 3 fixed — the two coincidentally involve overlapping-sounding "bundled resource" concepts but have unrelated root causes and unrelated fixes. | File as a separate, new issue; do not treat as blocking for #357. | Unchanged from prior cycles' disposition; this review re-confirms it remains genuinely out of scope (unlike the mirror-parity finding, which was wrongly deemed out of scope). | `evidence/qa-gates/ci-equivalent-coverage-verification.md` (carried forward, unchanged this cycle). |
| Info (unchanged, resolved in cycle 2) | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` | whole file | No duplicate tests; 21-test suite unchanged this cycle. | None — resolved. | N/A | Direct read; file unchanged since commit `67cd49a6` (confirmed via `git log`). |

No Blocker findings.

---

## Implementation Audit

### Cycle-3 delta only (the functional fix and its test coverage were already reviewed and approved in prior cycles; unchanged since)

#### What changed well

- The fix mechanism matches the risk it was designed to avoid: the remediation plan explicitly mandated a raw binary `Copy-Item` rather than a text-editing tool, specifically because a text-editing tool could re-encode the file and silently drop the leading UTF-8 BOM the sync needed to preserve (the BOM was itself introduced by the PoshQC formatter once the canonical file gained a non-ASCII em-dash character in an earlier cycle). This review confirmed the resulting mirror does carry the same leading BOM as the canonical file (both files' SHA-256 hashes match byte-for-byte, which would not be possible if the BOM had been dropped on one side).
- The change budget was honored exactly: `git diff --stat` for cycle 3 (commit `f3da03a2`) shows the only non-evidence, non-doc production file touched is the one declared bundled-mirror file. No other file under `extensions/drm-copilot/resources/claude-customizations/` was touched, consistent with the remediation plan's explicit "Do Not Do" list.
- No formatter or analyzer autofix step was run against the bundled mirror at any point in this cycle (per the remediation plan's explicit prohibition, since either could rewrite the file's bytes and break the byte-identity the cycle was establishing) — confirmed by this review's own SHA-256 comparison remaining stable across the "post-fix" and "post-toolchain" checkpoints recorded in `evidence/qa-gates/hash-diff-post-fix-remediation3.md` and `evidence/qa-gates/hash-diff-post-toolchain-remediation3.md`.

#### Root-cause investigation quality

- `remediation-inputs.2026-07-17T18-00.md` correctly identifies this as "the same class of dual-copy-drift defect this feature has already fixed twice for the PoshQC Pester settings files ... now surfacing for a third paired-copy location." This is an accurate pattern match, and the remediation input explicitly and transparently corrects the prior cycles' scoping error rather than silently absorbing the fix without explanation — this is the behavior this repository's "fail fast and explicitly" principle calls for.
- The remediation plan's Phase 0 baseline capture (`evidence/remediation-baseline/pytest-bundle-parity-baseline-remediation3.md`, `hash-diff-baseline-remediation3.md`) establishes the pre-fix failure state before applying the fix, giving a clean before/after comparison this review was able to independently re-verify.

#### API and safety notes

No public function signature, parameter validation, or `ShouldProcess` consideration is affected by this cycle — it is a resource-file content sync, not a code change to any function body beyond what was already reviewed and approved in prior cycles.

---

## Test Quality Audit

No test code was added or modified in cycle 3. The existing 21-test PowerShell suite and the Python `test_push_down_claude_resource_contracts.py` suite (pre-existing, unmodified) are unchanged. This review re-ran both:

- `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` — 1 passed (was the specific failing test on PR #358).
- `python -m pytest -q` (full suite) — 1533 passed, 0 failed, confirming no regression anywhere else in the repository from this cycle's change.

### Reviewed QA artifacts

- `evidence/qa-gates/pytest-bundle-parity-final-remediation3.md`, `evidence/qa-gates/pytest-full-suite-remediation3.md`, `evidence/qa-gates/pytest-resource-contracts-file-remediation3.md` — all confirm passing state; this review independently reproduced each.
- `evidence/qa-gates/hash-diff-post-fix-remediation3.md`, `evidence/qa-gates/hash-diff-post-toolchain-remediation3.md` — confirm the two files remain byte-identical both immediately after the fix and after the (canonical-file-only) toolchain re-run; this review independently reproduced the SHA-256 comparison.
- `evidence/qa-gates/change-scope-check-remediation3.md` — confirms change-budget discipline; this review independently re-ran `git diff --stat 67c871eb..HEAD` and confirms the same scope.

### Quality assessment prompts

- **Determinism:** A raw byte-copy operation and hash comparisons are inherently deterministic; no wall-clock, RNG, or sleep dependency introduced.
- **Isolation:** The fix touches exactly one file with no shared-state interaction with any other test or production file.
- **Speed:** The targeted pytest test and the full suite both complete in well under 3 seconds combined (this review's own run: 0.07s targeted, 2.25s full suite).
- **Diagnostics:** The originally-failing test's assertion message (`AssertionError: Bundle content differs from repo for: <path>`) directly names the drifted file, giving unambiguous diagnostic signal; this review confirmed that message is exactly what was resolved.

---

## Security / Correctness Checks

Unchanged from prior cycles: no secrets, no unsafe subprocess construction, no boundary-validation changes. This cycle introduces no new logic — it is a content sync of an already-reviewed file. No new attack surface or trust boundary is affected.

---

## Research Log

This review did not accept the remediation cycle's own evidence files at face value. It independently:

1. Ran `git show --stat f3da03a2` to confirm the exact set of files touched by the fix commit.
2. Computed SHA-256 of both `.claude/hooks/validate-planner-output.ps1` and its bundled mirror directly (via Python `hashlib`, since `Get-FileHash` was not available in the review's shell) and confirmed identical hashes and byte lengths.
3. Ran `git diff 67c871eb..HEAD -- extensions/.../validate-planner-output.ps1` directly and confirmed the diff contains exactly the five expected content deltas (BOM, em-dash regex, em-dash message, em-dash docstring, strict-mode-safe property check) and nothing else.
4. Ran `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` and the full suite `python -m pytest -q` directly, confirming 1 passed and 1533 passed / 0 failed respectively.
5. Ran `python scripts/dev_tools/validate_evidence_locations.py --root .` directly (exit 0) and `git diff --name-only 67c871eb..HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` (no matches) to confirm evidence-location compliance.
6. Ran `git log --oneline -- .claude/hooks/validate-planner-output.ps1` to confirm the canonical file's content — and therefore its 93.86% line-coverage measurement from the prior (17-15) review — has not changed since remediation cycle 2.

---

## Verdict

Cycle 3's fix is a minimal, correctly-scoped, mechanically-verified resolution of the specific CI-check failure that triggered it. This review found no new defects and confirmed no regression to the functional fix, its test coverage, or any other file in the branch diff. The prior review's incorrect "out of scope" classification of the bundled mirror is now corrected in the historical record via `remediation-inputs.2026-07-17T18-00.md`; this review does not re-litigate that correction, only confirms the resulting fix is complete and correct. This feature is ready to merge.

---

**Review Completed By:** feature-review (Claude Code subagent)
**Review Date:** 2026-07-17T18-30
