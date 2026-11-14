# Feature Audit: Python-native docs surface analyzer (#1031)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation re-audit (cycle 2; prior set 2026-11-07T00-58)

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (tip `e3e4aa551`)
- **Head branch/commit:** `feature/docs-surface-analyzer-python-native-1031-r2` (commit `4aca595d03329a807a2b907bfc859d89384153a3`; no PR yet)
- **Merge base:** `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated for this head
  - Feature evidence: `evidence/**`, including `evidence/qa-gates/self-review.2026-11-07T02-50.md` and `evidence/qa-gates/c2-ac-status.2026-11-07T02-48.md`
  - Additional evidence: reviewer runs in `policy-audit.2026-11-07T03-20.md` section 6 and Appendix B
- **Feature folder used:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` reads `- Work Mode: full-feature`. The `issue.md` section `## Acceptance Criteria (early draft)` is not an AC source in this mode.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (22 checkbox items, S1 to S22 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (22 checkbox items, U1 to U22 in order; each Un pairs with Sn)

`spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted. S4, U4, S13 and U13 were evaluated against their amended texts (owner decision `1031-ac-text-s4-s13` option (a), recorded in `docs/features/epics/documentation-estate-tooling/epic-status.md`).

### From spec.md

1. S1 (E1) Pytest exact parity rows; Pester adapter `element_id` and digest equal the scanner's.
2. S2 (E1) Scanner-diagnostic constructs that `ast` resolves become elements; dynamic forms keep the 1022 diagnostics.
3. S3 (E2) Pack absent: exit 0, `analysis_method: scanner`, no diagnostic, seam never called.
4. S4 (E2) Each process-level failure: exit 0, scanner elements, one `information` `PYTHON_NATIVE_UNAVAILABLE` diagnostic with the reason token; later candidate success used.
5. S5 (E2, R) One parse-failed file falls back to scanner; other files stay native.
6. S6 (E2, R, OQ-C) `native` exit 3 with one error finding and no snapshot; `scanner` never calls the seam; unknown value exit 2.
7. S7 (E3) No execution of analyzed code; `ast.parse` only.
8. S8 (E4) Helper only in the python pack; core pack lists no `.py` and lists the adapter.
9. S9 (E5) Python per-file line >= 85% and branch >= 75%; Pester line >= 85%; no exclusion; figures recorded.
10. S10 (E5, R) Black, Ruff, Pyright zero findings; config pins pass; tests pass on 3.11 via the CI matrix.
11. S11 (R) Every element carries `analysis_method`; snapshot validates.
12. S12 (R) Single implementation of identifiers and digests.
13. S13 (R) Four 1020-form native rows under the 1031 anchor; no other row changed.
14. S14 (R) Bundle copies SHA-256 identical; push-down contract tests pass.
15. S15 (R) No bytecode under `.claude/`; `-I -B -X utf8` asserted.
16. S16 (R) Process access only through the command-context seam.
17. S17 (R, OQ-A) Guard allowlist exactly one D3 entry matched by a detected finding.
18. S18 (R, OQ-B) VSIX and npm carve-out; other `.py` and bytecode excluded.
19. S19 (R) No test creates a temporary file.
20. S20 (R) Deterministic, ASCII-only helper output.
21. S21 (R) No production file above 500 logical lines; convention and tier checks pass.
22. S22 (CI-dependent) `poshqc / PowerShell QC` and `quality-checks` 3.11, 3.12, 3.13 pass on the PR head.

### From user-story.md

23. U1 to U22 restate S1 to S22 at story level in the same order.

---

## Acceptance Criteria Evaluation

Reviewer commands at head `4aca595d0`: P is the Pester run over the docs folder, guard and convention suites (2178 of 2178). H is the helper Pytest run with coverage (251 passed). X is `pytest -n auto` over the full tree (16350 passed, 6 skipped). C is the push-down and configuration-pin Pytest run (189 passed). J is the two packaging Jest suites (33 passed). T is Black, Ruff and Pyright (0 findings each). M is the SHA-256 mirror check (101 of 101 tracked files). E is the set of real-process inventory probes, and L is the 366-file `scanner` against `native` comparison.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `test_docs_python_native_corpus.py`; `DocsAnalyzerPythonNative.Parity.Tests.ps1`; `digest-recheck.2026-11-07T02-47.md` | P, H, E, L | Probe L: 3636 elements with 0 differences in identifier or digest. |
| 2 | S2 | PASS | per-analyzer Pytest modules | H | |
| 3 | S3 | PASS | `DocsInventory.PythonNative.Tests.ps1` | P, E | Probe: pack absent exits 0 with no diagnostic, from another directory as well. |
| 4 | S4 | PASS | `DocsAnalyzerPythonNative.Tests.ps1`, `DocsInventory.PythonNative.Tests.ps1` | P | Amended text. |
| 5 | S5 | PASS | `DocsInventory.PythonNative.Tests.ps1` | P, E | |
| 6 | S6 | PASS | `DocsInventory.PythonNative.Tests.ps1` | P, E | The false exit 3 of F6 no longer occurs; `pack-absent` still exits 3. |
| 7 | S7 | PASS | `test_docs_python_native_safety.py` over eighteen files | H | |
| 8 | S8 | PASS | Manifest suites; `c2-bundle-mirror.2026-11-07T01-40.md` | P, C, J | |
| 9 | S9 | PASS | Python minimum 97.35% line, 90.00% branch; Pester 100.00% for both new modules and the registry; `Invoke-DocsCommand.ps1` 87.97%; helper in `[tool.coverage.run] source` | H, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml` | Re-verified after F6, as the previous review required. Figures are in `evidence/qa-gates/` under the recorded location override. |
| 10 | S10 | UNVERIFIED | T 0 findings; C config pins pass | T, C | Pending-CI: the 3.11 floor is verified only by the CI matrix. |
| 11 | S11 | PASS | `DocsInventory.PythonNative.Tests.ps1`, `DocsInventorySnapshot.Tests.ps1` | P, E, L | Probe L: 1069 `config-files` rows carry `scanner`, and no `.py` row does under `native`. |
| 12 | S12 | PASS | `test_docs_python_native_safety.py`; parity token check | P, H | |
| 13 | S13 | PASS | `DocsAnalyzerRegistry.Tests.ps1`; registry diff adds exactly four rows | P | Amended text. |
| 14 | S14 | PASS | 101 of 101 tracked files equal, including the 23 changed; push-down modules pass | C, M | |
| 15 | S15 | PASS | 0 `__pycache__` or `.pyc`; `conftest.py`; argument assertion | P, H | |
| 16 | S16 | PASS | Seam-only start; only the adapter calls `Context.InvokeProcess`; `c2-test-hygiene.2026-11-07T02-47.md` | P, H | |
| 17 | S17 | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` | P | The new closure adds no finding and no allowlist entry. |
| 18 | S18 | PASS | `discovery-resources.test.ts` | J | |
| 19 | S19 | PASS | `c2-test-hygiene.2026-11-07T02-47.md` | P | |
| 20 | S20 | PASS | `test_docs_python_native_determinism.py` | H | |
| 21 | S21 | PASS | Largest production file 485 logical lines; `ClaudeLibModuleConvention.Tests.ps1`; `check_quality_tiers` OK | P | |
| 22 | S22 | UNVERIFIED | No PR and no CI run for this branch | none possible before the PR | CI-dependent; pending-CI at S9. |
| 23 | U1 | PASS | As S1 | P, H, E, L | |
| 24 | U2 | PASS | As S2 | H | |
| 25 | U3 | PASS | As S3 | P, E | |
| 26 | U4 | PASS | As S4 | P | Amended text. |
| 27 | U5 | PASS | As S5 | P, E | |
| 28 | U6 | PASS | As S6 | P, E | |
| 29 | U7 | PASS | As S7 | H | |
| 30 | U8 | PASS | As S8 | P, C, J | |
| 31 | U9 | PASS | As S9 | H | Every PowerShell production file this feature adds or edits is at or above 85%. |
| 32 | U10 | UNVERIFIED | As S10 | T | Pending-CI. |
| 33 | U11 | PASS | As S11 | P, E, L | |
| 34 | U12 | PASS | As S12 | P, H | |
| 35 | U13 | PASS | As S13 | P | Amended text. |
| 36 | U14 | PASS | As S14 | C, M | |
| 37 | U15 | PASS | As S15 | P, H | |
| 38 | U16 | PASS | As S16 | P, H | |
| 39 | U17 | PASS | As S17 | P | |
| 40 | U18 | PASS | As S18 | J | |
| 41 | U19 | PASS | As S19 | P | |
| 42 | U20 | PASS | As S20 | H | |
| 43 | U21 | PASS | As S21 | P | |
| 44 | U22 | UNVERIFIED | As S22 | none possible before the PR | Pending-CI. |

---

## Summary

**Overall Feature Readiness:** READY for the PR creation gate; S10, U10, S22 and U22 are pending-CI.

**Criteria summary:**
- **PASS:** 40 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 4 criteria (S10, U10, S22, U22; CI-dependent, pending-CI)
- **FAIL:** 0 criteria

The behavior defect F6, which no criterion encoded, is closed and was re-verified by real-process probes.

**Top gaps preventing PASS:**

1. S10, U10, S22 and U22 require CI on the PR head. No blocking finding remains.

**Recommended follow-up verification steps:**

1. Open the PR into `epic/documentation-estate-tooling-integration`; dispatch `ci.yml` against the branch head if no checks start.
2. At S9, check off S10, U10, S22 and U22 after `poshqc / PowerShell QC` and the three `quality-checks7` entries conclude `success`, push, and re-run the CI gate on the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

Newly checked off in this review: none. The 40 PASS criteria were already checked, and each was re-evaluated at this head. S9 and U9, checked off by the previous review, were re-verified after the F6 change. No acceptance-criteria file was edited in this review.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md`, `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/user-story.md`
- Total AC items: 44
- Checked off (delivered): 40
- Remaining (unchecked): 4
- Items remaining: spec S10 "(E5, R) Black, Ruff and Pyright (strict ...) report zero findings ... verified by the CI matrix (3.11, 3.12 and 3.13)."; spec S22 "(CI-dependent) The required check `poshqc / PowerShell QC` and the `quality-checks` Python jobs ... pass on the pull request head."; user-story U10 "(E5) Black, Ruff and Pyright (strict) report no findings ... verified by the CI matrix (3.11, 3.12 and 3.13)."; user-story U22 "(CI-dependent) `poshqc / PowerShell QC` and the Python quality jobs on every matrix entry ... pass on the pull request head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 22 | 20 | 2 | S10 and S22 pending-CI |
| `user-story.md` | 22 | 20 | 2 | U10 and U22 pending-CI |
