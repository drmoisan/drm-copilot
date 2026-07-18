# Code Review: legacy-discovery-init-templates (#362) — R4 Re-Review, Remediation Cycle 3

**Template source note:** MCP template resolution is unavailable in this session; the canonical repository template `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` was used as the authoritative structure source.

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (independent verification, not accepted from executor self-report)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/`
**Feature Folder Selection Rule:** Only active feature folder whose suffix (`-362`) matches the branch name's issue number.
**Base Branch:** `epic/legacy-discovery-and-parity-integration` (merge-base `85e7bea2bd2695114c9feffb2a4963da9f37c9ad`)
**Head Branch:** `feature/legacy-discovery-init-templates-362` (HEAD `f17f1af08c67568fbc14140a25882c068a50d2b0`)
**Review Type:** Post-remediation re-review (R4, remediation cycle 3 — bundled-resources push-down fix)

---

## Executive Summary

This cycle-3 re-review covers a single commit (`f17f1af0`) that copies four `.claude/agents/*.md` persona files (`legacy-parity-analyst.md`, `migration-coverage-reviewer.md`, `requirements-reconciler.md`, `runtime-characterization-analyst.md`) — originally added to the repo root by sibling feature #365 on the integration branch's own tip — into the bundled extension payload at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`. This closes the Blocking finding recorded in `code-review.2026-07-18T17-57.md` (cycle-2 re-review) against `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. No other file changed. This feature's own production code (`init_cli.py`, `init_flow.py`, `init_models.py`) remains byte-identical to the code reviewed in cycle 1 and cycle 2.

**What changed:** Four new Markdown files added under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`, each a byte-for-byte copy of an existing repo-root `.claude/agents/*.md` file. No Python, JSON, YAML, or `pyproject.toml` content changed.

**Top risks:**
1. A byte-for-byte copy carries essentially no code-review risk of its own (no logic, no new naming, no new API), but a copy that silently diverges from its source (e.g. partial copy, line-ending change) would defeat the purpose of the fix — independently checked below via SHA-256 comparison, not accepted from the executor's report.
2. `scripts/dev_tools/discovery/init_models.py`'s branch coverage (50%, 6/12) remains below the uniform 75% new-file threshold; unchanged since cycle 2, not introduced or affected by this cycle.
3. The integration branch's current remote tip has advanced past this feature's merge-base since cycle 2, reintroducing a `pyproject.toml` conflict against that current tip (see policy-audit for detail). This is explicitly out of this cycle's review scope per the caller's instruction and does not affect this review's verdict.

**PR readiness recommendation:** **Go, for this feature's own remediation loop.** The cycle-3 fix is minimal, correct, and independently verified byte-identical. The full toolchain (black, ruff, pyright, pytest with coverage) now completes clean in a single pass with zero test failures, for the first time in this feature's remediation history. Recommend the orchestrator proceed to the separately-scoped cycle 4 (the reintroduced upstream merge conflict) before final PR merge, per the caller's sequencing.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (positive confirmation) | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/*.md` (4 files) | New files | The four copied files are independently confirmed byte-identical (SHA-256) to their repo-root `.claude/agents/` counterparts. | No action needed. | A copy that silently diverged from its source would defeat the purpose of the bundled-mirror contract test; independent hash comparison rules this out. | `sha256sum` on both copies of each of the four files (see policy-audit "Cycle-3 Fix Verification" for full hash table); all four pairs match. |
| Info (positive confirmation) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | The previously-failing test now passes, along with the other 6 tests in the same file. | No action needed. | Independently re-run, not accepted from the executor's report alone. | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` → `7 passed in 0.11s`. |
| Minor (carried forward, unchanged) | `scripts/dev_tools/discovery/init_models.py` | Lines 13-23 (`FileSystem` `Protocol` stub methods) | Branch coverage for this file remains 50% (6/12), below the uniform 75% new-file threshold. All six uncovered branches are coverage.py's synthetic "exit" branch for a `...`-bodied `Protocol` stub method. | Optional cleanup: extract the `FileSystem` `Protocol` into its own type-only module. Not required before merge; not affected by this cycle's change. | The concrete implementation of the same contract (`RealFileSystem`) is 100% line-covered; no real behavior is untested. Unchanged since cycle 2 because this cycle touched no Python file. | `artifacts/python/lcov.info` (this review's independent regeneration at HEAD `f17f1af0`): `init_models.py` LF 32 LH 32 (100% line), BRF 12 BRH 6 (50% branch) — identical figures to cycle 2. |
| Info (out of this cycle's scope) | `pyproject.toml` | `[tool.poetry.scripts]` | A `git merge-tree` three-way test against the integration branch's *current remote tip* (`c4ec9a2b`, which has advanced past this feature's merge-base via sibling feature #363) independently reproduces a content conflict. | Track as a separately-scoped remediation cycle 4, per the caller's explicit instruction. Not evaluated here. | The merge-base for this audit's diff scope (`85e7bea2`) is unaffected; `pyproject.toml` at HEAD `f17f1af0` still parses cleanly and contains no residual conflict markers relative to that merge-base. | `git merge-tree --write-tree HEAD origin/epic/legacy-discovery-and-parity-integration` → `CONFLICT (content): Merge conflict in pyproject.toml`; `grep -rn "^<<<<<<<\|^=======$\|^>>>>>>>" pyproject.toml` at HEAD → no matches (confirms the conflict is only against the current remote tip, not present in the committed file). |

No Blocker findings remain in this feature's own scope after this cycle's fix.

---

## Implementation Audit

### Bundled-resources push-down audit

#### What changed well

- The fix is exactly scoped to the identified defect: `git diff --name-only 48939e3e HEAD` shows precisely the four missing files added, nothing else touched.
- The copy method (byte-for-byte, independently verified via SHA-256 rather than a line-count or diff-based check alone) leaves no room for a partial or line-ending-altered copy to pass undetected.
- The fix required no code change, no new abstraction, and no new test — the existing contract test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) already fully specifies the expected invariant; the fix simply satisfies it.

#### Scope discipline

- The fix does not touch any file this feature's plan does not name for cycle 3 (`remediation-plan.2026-07-18T17-57.md` names exactly these four destination paths). No opportunistic changes to unrelated files were introduced.

### Python implementation audit (unchanged by this cycle)

- `init_cli.py`, `init_flow.py`, `init_models.py` are byte-identical to the versions reviewed in `code-review.2026-07-18T12-56.md` (cycle 1) and `code-review.2026-07-18T17-57.md` (cycle 2). All prior findings (thin CLI wiring, fail-fast validation ordering, specific exception types, no broad catch-all) carry forward unchanged and are independently re-confirmed by this cycle's clean `black`/`ruff`/`pyright`/`pytest` re-runs.

### JSON/YAML template review (unchanged by this cycle)

- The seven `docs/discovery/templates/artifacts/*.template.json` files and the domain-profile YAML template are unchanged; domain-neutrality and schema-conformance tests continue to pass as part of the 1783-passing suite.

---

## Test Quality Audit

This review independently re-ran the target regression test and the full suite, rather than accepting the executor's self-reported evidence (`evidence/qa-gates/r3c1-qa-test-suite.md`, `evidence/qa-gates/r3c1-qa-full-suite.md`) at face value.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — 7 tests, all passing at HEAD `f17f1af0` (previously 6 passing / 1 failing at cycle-2 HEAD `48939e3e`).
- `tests/scripts/dev_tools/discovery/*` — unchanged from cycle 2; re-verified passing as part of the 1783-passing full-suite run.
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-copy-*.md` (executor's self-reported hash evidence for each of the four files) — independently reproduced by this review via a fresh `sha256sum` invocation, not merely re-read; hashes matched exactly.

### Quality assessment prompts

- **Determinism:** The bundled-payload contract test performs pure filesystem enumeration and comparison with no network, clock, or randomness dependency; re-run twice with identical results.
- **Isolation:** The test targets a single contract (bundled payload mirrors repo `.claude/**`, excluding the documented exclusions); it does not depend on or interact with the discovery module's own tests.
- **Speed:** The single-file test run completes in 0.11s; the full 1783-test suite completes in 8.09s.
- **Diagnostics:** The test's own assertion message names only the first missing file it encounters; this review independently confirmed via the file-count diff (`git diff --stat 48939e3e..HEAD`, exactly 4 files added, 255 insertions, 0 deletions) that no other bundled-payload gap exists and none was newly introduced by this cycle.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | The four new files are agent-persona Markdown documents (frontmatter + prose); no credentials, tokens, or connection strings. |
| No unsafe subprocess or command construction | PASS | No code file was touched by this cycle. |
| Input validation at boundaries | PASS | Unchanged from prior cycles (not affected by this cycle's change). |
| Error handling remains explicit | PASS | Unchanged from prior cycles. |
| Configuration / path handling is safe | PASS | Unchanged from prior cycles. |
| Byte-for-byte copy correctness | PASS | Independently verified via SHA-256 comparison of all four file pairs (see policy-audit "Cycle-3 Fix Verification"). |
| No unintended file changes | PASS | `git diff --name-only 48939e3e HEAD` shows exactly the four new files, nothing else. |

---

## Research Log

No external research was required. All findings were derived from direct repository inspection (`git diff --stat`, `git diff --name-only`, `git log`), independent SHA-256 hash comparison, independent toolchain re-execution (`black`, `ruff`, `pyright`, `pytest --cov`), and an independent `git merge-tree` reproduction of the out-of-scope upstream conflict.

---

## Verdict

The cycle-3 fix is minimal, correctly scoped, and independently verified byte-identical to its source files. The previously-failing bundled-payload contract test now passes, and the full Python toolchain completes clean in a single pass with zero test failures — the first time this has occurred in this feature's remediation history. No Blocker or Major finding remains in this feature's own scope. The `init_models.py` branch-coverage observation is unchanged and non-blocking. The reintroduced `pyproject.toml` conflict against the integration branch's current remote tip is out of this cycle's scope per the caller's explicit instruction and is recorded for a planned cycle 4; it does not affect this review's verdict on cycle 3's own fix.
