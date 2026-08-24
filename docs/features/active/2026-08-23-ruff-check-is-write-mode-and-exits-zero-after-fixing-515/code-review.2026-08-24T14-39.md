# Code Review: Ruff check write-mode removal (#515)

---

**Review Date:** 2026-08-24
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515`
**Feature Folder Selection Rule:** Single active feature folder whose suffix matches the canonical issue number (#515) in the branch name; supplied by the caller and confirmed against the branch diff.
**Base Branch:** `main` (merge-base `80b65d2ed843d2dd72d722f3b6d88b8b84634227`)
**Head Branch:** `bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515-r2` (head `4a926a0383e3c18aea475de1edad461d0f95998b`)
**Review Type:** Initial review

**Template source note:** Created from the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the file the MCP `code-review-template` selector resolves); the MCP tool surface was unavailable in this session.

---

## Executive Summary

The branch delivers the fix for issue #515: `poetry run ruff check` was a write-mode command that rewrote fixable violations in place and exited 0, because `pyproject.toml` set `fix = true` under `[tool.ruff]`. The production change is a one-line deletion of that key, which makes the bare invocation read-only for all 31 inventoried call sites and for the CI lint step simultaneously, with no edit to any of them. A new 117-line regression module, `tests/scripts/dev_tools/test_ruff_config_alignment.py`, guards the fix against its three reintroduction routes: re-adding the key, adding a standalone root Ruff config, and deleting the CI lint gate.

The implementation quality is high. The test module follows the established `test_pyright_config_alignment.py` precedent, is fully typed, subprocess-free, deterministic, and its primary guard is proven discriminating by fail-before evidence. The reviewer independently re-ran the module (4 passed), re-ran the bare lint command bracketed by working-tree status snapshots (exit 0, tree unchanged), and re-parsed the coverage artifact. Executor evidence covers the full seven-stage loop, the no-write snapshot pair, and a scratch-input differential that confirms the lint stage now fails loudly on both fixable and unfixable violations while leaving inputs byte-identical.

**What changed:**
- `pyproject.toml`: deleted `fix = true` from `[tool.ruff]` (line 91 pre-change); `show-fixes = true` retained.
- `tests/scripts/dev_tools/test_ruff_config_alignment.py`: new, 4 tests.
- 24 documentation/evidence files under the feature folder.

**Top 3 risks:**
1. Open branches carrying a fixable violation will now fail the CI `Lint with Ruff` step instead of silently passing after a discarded in-runner rewrite. This is the intended correction; the spec calls it out and the remedy (explicit `--fix`) exists.
2. The guard is textual, not behavioral: a future writing-linter route the configuration test does not observe (for example `--config` at a call site) would be undetectable until the deferred follow-up (executor lint-step diff snapshot, research direction (d)) lands. Accepted and recorded in the spec.
3. Interactive developers who relied on the bare command auto-fixing must switch to `QC: 2 Ruff: fix` or `--fix`. Low impact; both paths pre-exist.

**PR readiness recommendation:** **Go** — the diff matches the spec-authorized write set exactly, all toolchain gates pass, and the evidence chain is complete and independently corroborated.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `artifacts/python/coverage.json` | totals block | The on-disk coverage artifact at review time reports 4677 covered branches (85.1913%), one branch below the 4678 (85.2095%) quoted in the P4-T4 evidence artifact, indicating a local re-run after P4-T4. | No action required. Both readings exceed the 75% threshold and line coverage is identical in both. | The one-branch difference is the run-to-run variation the executor's own delta artifact anticipates; it does not change any verdict. | Reviewer parse of `artifacts/python/coverage.json`; `evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md` |
| Info | `tests/scripts/dev_tools/test_ruff_config_alignment.py` | lines 28-29 | `_FIX_ENABLED` and `_SHOW_FIXES_ENABLED` use `re.IGNORECASE`, though TOML booleans are case-sensitive lowercase; a quoted-key form (`"fix" = true`) would also evade the regex. | No action required. The IGNORECASE broadening fails toward stricter guarding (it would flag `Fix = True`, which Ruff itself would reject), and a quoted-key evasion would be a deliberate act that the CI behavior change would surface immediately. | Residual textual-assertion limits are already acknowledged in spec Risks item 5; the chosen tolerance direction is safe. | Diff inspection of the new module |
| Nit | `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/issue.md` | line 5 | The promotion status line names the target folder as `docs/features/active/ruff-check-is-write-mode-and-exits-zero-after-fixing/` without the date/issue-number prefix the actual folder carries. | Optional cosmetic correction in a future docs pass; not worth a remediation cycle. | The discrepancy is cosmetic and cannot mislead tooling — the folder reference used by automation (branch name, PR context, evidence paths) is the real, suffixed folder. | Read of `issue.md:5` vs. actual folder path |

No Blockers or Major findings. No Minor findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The production fix is the minimum possible diff: one deleted configuration line. Every path that intends to auto-fix already passes `--fix` explicitly, so no capability is lost — the spec verifies this with a call-site inventory rather than asserting it.
- The regression module guards the fix and its bypass routes, not just the current byte sequence: `_tool_ruff_table_lines` scopes assertions to the `[tool.ruff]` table body, strips trailing comments before matching, and tolerates whitespace variation, so an unrelated `pyproject.toml` reformat cannot false-fail it — directly addressing the brittleness risk the spec identified (Risks item 5).
- `test_quality_checks_workflow_still_runs_a_ruff_lint_step` filters out YAML `name:` lines and matches the `ruff check` invocation itself, so renaming the CI step cannot false-pass the guard and deleting the command cannot survive it. This closes the "satisfy the tests by deleting the gate" loophole explicitly.
- Assertion messages are diagnostic: each names the file, explains the defect mechanism, cites issue #515, and interpolates the offending content — the fail-before artifact shows exactly this output in practice.

#### Typing and API notes

- All functions carry precise annotations (`-> None`, `-> str`, `-> list[str]`); `from __future__ import annotations` is used; module constants are typed by inference from literals. No `Any`, no `# type: ignore`, no suppression of any kind. No new public Python API surface was added — all helpers are underscore-private to the test module.

#### Error handling and logging

- The module adds no error handling, correctly: a missing `pyproject.toml` or workflow file raises `FileNotFoundError` from `Path.read_text`, which fails the test loudly and identifies the missing input. Swallowing that would have violated fail-fast policy. No logging or `print` is present; pytest assertion output carries all diagnostics.

---

## Test Quality Audit

The verification evidence is unusually complete for a one-line change, and appropriately so, because the defect being fixed was precisely an observability gap.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_ruff_config_alignment.py` — the committed guard; 4 tests, re-run by the reviewer at review time: 4 passed in 0.06s.
- `evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T13-57.md` — proves the primary guard discriminates: 1 failed / 3 passed against the pre-change tree with `EXIT_CODE: 1` = `ExpectedExitCode: 1`, then 4 passed post-change. Verbatim failure output included.
- `evidence/qa-gates/lint-stage-no-write.2026-08-24T14-06.md` — before/after `git status --porcelain` snapshot pair around the bare lint command, byte-identity proven by `cmp` exit 0 and matching SHA-256 digests. The artifact also honestly documents that this pair is non-discriminating in isolation on a clean tree and points to the differential artifact — a notable quality marker.
- `evidence/qa-gates/lint-stage-manual-differential.2026-08-24T14-09.md` — scratch-input differential outside the repo: unfixable violation (F821) exits 1 with no `[*]` marker; fixable violation (F401) exits 1 with the `[*]` marker and a fixable-count (not fixed-count) summary; both inputs byte-identical by SHA-256 before/after; `ruff check --show-settings` confirms resolution to the repository `pyproject.toml` with `fix = false`, ruling out a built-in-defaults false pass.
- `evidence/qa-gates/final-python-{format,lint,typecheck,test-coverage}.2026-08-24T14-1x.md` and `final-qa-loop-single-pass.2026-08-24T14-18.md` — full toolchain pass 2 clean after a documented restart caused by pre-existing, filed issue #510 (gitignored `.claude/state/` file breaking an unrelated parity test); non-attribution to this diff is argued with timestamps and gitignore evidence.
- `evidence/qa-gates/coverage-delta-verification.2026-08-24T14-17.md` — like-for-like line and branch deltas computed from the same JSON fields as baseline: line +0.0000pp, branch +0.0182pp.

### Quality assessment prompts

- **Determinism:** Committed-text assertions only; no clock, RNG, network, subprocess, or temp file. The manual differential deliberately lives in QA-gate evidence rather than the suite to preserve this.
- **Isolation:** Each test asserts one invariant with an independent read; no shared mutable state.
- **Speed:** 0.06s standalone; 21.15s for the full 4116-test suite.
- **Diagnostics:** Failure output names the guarded invariant, the mechanism, and the offending content (demonstrated in the fail-before artifact, not just claimed).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: configuration deletion, test module, and Markdown docs only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | PASS | The new module spawns no process; no `subprocess`, `os.system`, or shell string construction anywhere in the diff. |
| Input validation at boundaries | PASS | The module reads two fixed repo-relative paths resolved from `__file__`; no external input is accepted. |
| Error handling remains explicit | PASS | Natural exceptions propagate; no broad catch, no silent fallback. |
| Configuration / path handling is safe | PASS | `Path(__file__).resolve().parents[3]` matches the established precedent module in the same directory; paths are static constants, no user-controlled path joins. |

---

## Research Log

No external research was required for this review. All evidence was drawn from the branch diff, the feature folder artifacts, the regenerated PR-context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`), and reviewer-executed check-only commands. The feature's own research artifact (`research/2026-08-23T21-05-ruff-write-mode-research.md`) was consulted as scope evidence.

---

## Verdict

The change is ready for normal PR flow. The diff matches the spec's authorized write set exactly (`git diff --name-only` against the merge base lists only `pyproject.toml`, the new test module, and feature-folder paths), all quality gates pass with independent reviewer corroboration, and the two Info findings and one Nit require no action before merge. The single behavior change visible outside this repository — fixable violations now fail CI instead of being silently rewritten and discarded — is the correction the issue demands and is documented with a rollout check in the spec.
