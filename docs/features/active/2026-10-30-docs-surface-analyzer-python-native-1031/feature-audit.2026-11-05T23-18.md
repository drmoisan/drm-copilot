# Feature Audit: Python-native docs surface analyzer (#1031)

**Audit Date:** 2026-11-05
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial full-branch review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (tip `eb3436e62`)
- **Head branch/commit:** `feature/docs-surface-analyzer-python-native-1031-r2` (commit `e6e828de9476b6c4a776d3acf79e8bd3e77446a4`, equal to the remote branch; no PR yet)
- **Merge base:** `729ff55ef6b8fcfcf632d9d2220a674bb437bf7e` (`git merge-base origin/epic/documentation-estate-tooling-integration HEAD`)
- **Evidence sources:**
  - Primary: `git diff 729ff55ef...HEAD` (147 paths). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from the worktree and no collector tool is exposed to this agent; the direct diff is used instead (assumption).
  - Feature evidence: `evidence/**` in the feature folder, including `evidence/qa-gates/self-review.2026-11-05T23-10.md` and `evidence/qa-gates/ac-status.2026-11-05T23-05.md`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-05T23-18.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 13 reads `- Work Mode: full-feature`. The `issue.md` section `## Acceptance Criteria (early draft)` is not an AC source in this mode.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (22 checkbox items, lines 360-381, S1 to S22 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (22 checkbox items, lines 76-97, U1 to U22 in order; each Un pairs with Sn)

`spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted. The labels below abbreviate the criteria in source order; the full text was evaluated as written. Where a criterion names a shape that the plan replaced (`## Deviations from spec.md` items 1 to 5: registry row form, provider functions, element construction, diagnostic code, `parent` with `path`), the reviewer evaluated it against the adopted shape, which the spec's `## Upstream Dependencies` permits ("resolved ... by conforming to the delivered contract"); the stale specification text is finding F4.

### From spec.md

1. S1 (E1) Pytest exact parity rows; Pester adapter `element_id` and digest equal the scanner's for shared rows.
2. S2 (E1) Scanner-diagnostic constructs that `ast` resolves become elements; unresolvable dynamic forms keep the 1022 diagnostics.
3. S3 (E2) Pack absent: exit 0, `analysis_method: scanner`, no diagnostic, seam never called.
4. S4 (E2) Each process-level failure: exit 0, scanner elements, one non-blocking unavailability diagnostic with the reason token; later candidate success used.
5. S5 (E2, R) One parse-failed file falls back to scanner; other files stay native.
6. S6 (E2, R, OQ-C) `-AnalysisMethod native` exit 3 with one error finding and no snapshot; `scanner` never calls the seam; unknown value exit 2.
7. S7 (E3) Source-inspection and behavioral Pytest: no execution of analyzed code; `ast.parse` only.
8. S8 (E4) Helper only in python pack; core pack lists no `.py` and lists the adapter; Codex manifest unchanged; manifest tests pass.
9. S9 (E5) Python per-file line >= 85% and branch >= 75%; Pester line >= 85% for the new modules and edited registry; no exclusion; figures recorded.
10. S10 (E5, R) Black, Ruff, Pyright zero findings; config pins pass; tests pass on 3.11 via the CI matrix.
11. S11 (R) Every element carries `analysis_method`; `config-files` and non-`.py` always `scanner`; snapshot validates.
12. S12 (R) Single implementation of identifiers and digests.
13. S13 (R) Registry native rows under the 1031 anchor; no other row changed; membership assertion.
14. S14 (R) Bundle copies SHA-256 identical; push-down contract tests pass.
15. S15 (R) No bytecode under `.claude/`; `conftest.py` flag; `-I -B -X utf8` asserted.
16. S16 (R) Process access only through the command-context seam; no test starts a process.
17. S17 (R, OQ-A) Guard allowlist exactly one D3 entry matched by a detected finding; guard suite passes.
18. S18 (R, OQ-B) VSIX and npm carve-out; other `.py` and bytecode excluded; packaging test asserts both.
19. S19 (R) No test creates a temporary file.
20. S20 (R) Deterministic, ASCII-only helper output.
21. S21 (R) No production file above 500 logical lines; module convention and quality-tier checks pass.
22. S22 (CI-dependent) `poshqc / PowerShell QC` and `quality-checks` 3.11, 3.12, 3.13 pass on the PR head.

### From user-story.md

23. U1 to U22 restate S1 to S22 at story level in the same order (U9 coverage, U10 Black/Ruff/Pyright and 3.11 floor, U22 CI-dependent).

---

## Acceptance Criteria Evaluation

Reviewer command R1 is the Pester run at head `e6e828de9`, coverage off, over the four new and six edited or manifest docs suites, `enforcement-hooks-no-python-invocation.Tests.ps1` and `ClaudeLibModuleConvention.Tests.ps1`: 190 of 190 passed (suite list in `policy-audit.2026-11-05T23-18.md` Appendix A). R2 is the helper Pytest run with per-file coverage (208 passed). R3 is Black, Ruff and Pyright over the helper and its tests (0 findings each). R4 is the push-down and configuration-pin Pytest run (189 passed). R5 is the two packaging Jest suites (9 and 24 passed). R6 is SHA-256 parity over the 17 bundle pairs (0 mismatches) and the logical line counts. Phase evidence named `pN-*` is under `evidence/regression-testing/`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `test_docs_python_native_corpus.py`; `DocsAnalyzerPythonNative.Parity.Tests.ps1`; `p3-corpus`, `p4-parity` | R1, R2 | |
| 2 | S2 | PASS | per-analyzer Pytest modules; `native-corpus-census.2026-11-04T16-10.md` | R2 | |
| 3 | S3 | PASS | `DocsInventory.PythonNative.Tests.ps1`; `p4-inventory` | R1 | |
| 4 | S4 | PASS | `DocsAnalyzerPythonNative.Tests.ps1`, `DocsPythonNativeProtocol.Tests.ps1`; `p4-interpreter`, `p4-protocol` | R1 | Diagnostic emitted as `PYTHON_NATIVE_UNAVAILABLE`, severity `information` (plan deviation 4, consistent with the snapshot-diagnostic naming of sibling analyzers); spec text is F4. |
| 5 | S5 | PASS | `DocsInventory.PythonNative.Tests.ps1`; `p4-native-inventory` | R1 | |
| 6 | S6 | PASS | `DocsInventory.PythonNative.Tests.ps1`; `p4-inventory` | R1 | |
| 7 | S7 | PASS | `test_docs_python_native_safety.py`; reviewer token search (no call form in the helper) | R2 | |
| 8 | S8 | PASS | `manifests.2026-11-04T16-58.md`; `Docs.Manifest.Tests.ps1`; `test_push_down_claude_pack_manifest_completeness.py`; `claude-pack-manifest-completeness.test.ts` | R1, R4, R5 | |
| 9 | S9 | PARTIAL | Python per-file 96.90% to 100% line, 92.31% to 100% branch (R2, identical to `qa-python-per-file-coverage.2026-11-04T19-59.md`); Pester per-file 100.00% for both new modules and the edited registry and inventory modules, 87.82% for `Invoke-DocsCommand.ps1` (executor P6-T9; policy audit 1.2.1) | R1, R2 | The canonical artifacts are absent (F3), and F1/F2 change the measured files, so figures are re-recorded after remediation. Left unchecked. |
| 10 | S10 | UNVERIFIED | R3 0 findings; R4 config pins pass | R3, R4 | Local parts pass; the 3.11 floor is verified only by the CI matrix (pending-CI, `awaiting_ci`, F5). |
| 11 | S11 | PASS | `DocsInventory.PythonNative.Tests.ps1`, `DocsInventorySnapshot.Tests.ps1`; `p4-native-inventory` | R1 | |
| 12 | S12 | PASS | `p4-parity` token check; `test_docs_python_native_safety.py` (`hashlib` absent) | R1, R2 | Elements built by `New-DocsSurfaceElement` (plan deviation 3). |
| 13 | S13 | PASS | `DocsAnalyzerRegistry.Tests.ps1`; registry diff adds only four rows under `# --- 1031: Python-native analyzers ---` | R1 | Four 1020-form rows instead of one combined row (plan deviation 1). |
| 14 | S14 | PASS | 17 of 17 pairs equal; `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py` | R4, R6 | |
| 15 | S15 | PASS | No `__pycache__` or `.pyc` under the helper or its bundle copy after R2; `conftest.py`; `DocsAnalyzerPythonNative.Tests.ps1` argument assertion | R1, R2 | |
| 16 | S16 | PASS | Seam-only interpreter start; `qa-test-hygiene.2026-11-05T23-01.md` | R1, R2 | |
| 17 | S17 | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1`; `p4-guard` | R1 | |
| 18 | S18 | PASS | `discovery-resources.test.ts`; `p5-packaging` | R5 | |
| 19 | S19 | PASS | Reviewer token search over `tests/scripts/claude-lib/docs/` (no match); `qa-test-hygiene.2026-11-05T23-01.md` | search | |
| 20 | S20 | PASS | `test_docs_python_native_determinism.py` | R2 | |
| 21 | S21 | PASS | Largest production file 468 logical lines (`Invoke-DocsCommand.ps1`); `ClaudeLibModuleConvention.Tests.ps1`; `qa-tiers-and-size.2026-11-05T22-58.md` | R1, R6 | The F1 fix must keep this criterion true (split `routes.py`). |
| 22 | S22 | UNVERIFIED | No PR and no CI run for head `e6e828de9` | none possible before the PR | CI-dependent; pending-CI at S9 (`awaiting_ci`, F5). |
| 23 | U1 | PASS | As S1 | R1, R2 | |
| 24 | U2 | PASS | As S2 | R2 | |
| 25 | U3 | PASS | As S3 | R1 | |
| 26 | U4 | PASS | As S4 | R1 | Same diagnostic-code note as S4. |
| 27 | U5 | PASS | As S5 | R1 | |
| 28 | U6 | PASS | As S6 | R1 | |
| 29 | U7 | PASS | As S7 | R2 | |
| 30 | U8 | PASS | As S8 | R1, R4, R5 | |
| 31 | U9 | PARTIAL | As S9 | R1, R2 | Left unchecked (F3). |
| 32 | U10 | UNVERIFIED | As S10 | R3 | Pending-CI (F5). |
| 33 | U11 | PASS | As S11 | R1 | |
| 34 | U12 | PASS | As S12 | R1, R2 | |
| 35 | U13 | PASS | As S13 | R1 | |
| 36 | U14 | PASS | As S14 | R4, R6 | |
| 37 | U15 | PASS | As S15 | R1, R2 | |
| 38 | U16 | PASS | As S16 | R1, R2 | |
| 39 | U17 | PASS | As S17 | R1 | |
| 40 | U18 | PASS | As S18 | R5 | |
| 41 | U19 | PASS | As S19 | search | |
| 42 | U20 | PASS | As S20 | R2 | |
| 43 | U21 | PASS | As S21 | R1, R6 | |
| 44 | U22 | UNVERIFIED | As S22 | none possible before the PR | Pending-CI (F5). |

---

## Summary

**Overall Feature Readiness:** NOT READY (four autonomous findings, F1 to F4; S10, U10, S22 and U22 wait on CI)

**Criteria summary:**
- **PASS:** 38 criteria
- **PARTIAL:** 2 criteria (S9, U9)
- **UNVERIFIED:** 4 criteria (S10, U10, S22, U22; CI-dependent, pending-CI)
- **FAIL:** 0 criteria

The acceptance criteria do not encode the commenting policy or PSScriptAnalyzer over `.claude/lib`, so F1 and F2 block readiness through the policy audit rather than through a failed criterion.

**Top gaps preventing PASS:**

1. F1: the helper modules and six test files do not meet the Python commenting and docstring policy; the fix requires a `routes.py` split to keep S21 true.
2. F2: ten PSScriptAnalyzer warnings in the two new PowerShell modules (twenty with the bundle copies).
3. F3: canonical coverage artifacts are absent from the worktree, which also keeps S9 and U9 unchecked.
4. F4: the spec's normative text and `## Decisions Later Children Must Honor` name a diagnostic code, provider function, registry row and digest function that the code does not use.
5. F5: S10, U10, S22 and U22 and the zero-failure Pester gate require CI on the PR head.

**Recommended follow-up verification steps:**

1. Fix F1 to F4 in one remediation cycle, re-run the full Python and PowerShell toolchain loops inside the worktree, and record coverage from the canonical artifacts.
2. Re-verify S9, U9 and S21 after the split; check off S9 and U9 when the recorded figures meet the thresholds.
3. Open the PR into `epic/documentation-estate-tooling-integration`; dispatch `ci.yml` if no checks start. At S9, check off S10, U10, S22 and U22 after `poshqc / PowerShell QC` and the three `quality-checks7` entries conclude `success`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 38 PASS criteria were already checked (`- [x]`) in the source files by the executor ([P6-T19], `evidence/qa-gates/ac-status.2026-11-05T23-05.md`; reviewer count at head `e6e828de9`: 19 checked in `spec.md`, 19 in `user-story.md`). The re-evaluation confirms each, so no source-file change was needed. S9, U9, S10, U10, S22 and U22 were unchecked and remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md`, `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/user-story.md`
- Total AC items: 44
- Checked off (delivered): 38
- Remaining (unchecked): 6
- Items remaining: spec S9 "(E5) Python line coverage is at least 85% and branch coverage at least 75% for each file of the helper ..."; spec S10 "(E5, R) Black, Ruff and Pyright (strict ...) report zero findings ... verified by the CI matrix (3.11, 3.12 and 3.13)."; spec S22 "(CI-dependent) The required check `poshqc / PowerShell QC` and the `quality-checks` Python jobs ... pass on the pull request head."; user-story U9 "(E5) Python line coverage >= 85% and branch coverage >= 75% per helper file; Pester line coverage >= 85% per PowerShell production file this feature adds or edits."; user-story U10 "(E5) Black, Ruff and Pyright (strict) report no findings ... verified by the CI matrix (3.11, 3.12 and 3.13)."; user-story U22 "(CI-dependent) `poshqc / PowerShell QC` and the Python quality jobs on every matrix entry ... pass on the pull request head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 22 | 19 | 3 | S9 PARTIAL (F3); S10 and S22 CI-dependent |
| `user-story.md` | 22 | 19 | 3 | U9 PARTIAL (F3); U10 and U22 CI-dependent |
