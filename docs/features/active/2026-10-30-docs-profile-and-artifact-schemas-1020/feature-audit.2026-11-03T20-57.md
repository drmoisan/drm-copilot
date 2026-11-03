# Feature Audit: Documentation profile and artifact schemas (#1020)

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-profile-and-artifact-schemas-1020-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1 (prior `feature-audit.2026-11-03T20-22.md`)

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `5e535f7a6`)
- **Head branch/commit:** `feature/docs-profile-and-artifact-schemas-1020-r2` (commit `a3ae4c51d`, pushed; no PR yet)
- **Merge base:** `01706c697` (also `340627583` via `--all`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-11-03 20:57 UTC against the epic base, head `a3ae4c51d`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/**` in the feature folder, including the 15 cycle files added by `19643663a`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-03T20-57.md` Appendix B; `artifacts/pester/powershell-coverage.xml` (written 20:49Z by the cycle P2-T3 run)
- **Cycle note:** the cycle changed `Invoke-DocsCommand.ps1` (ShouldProcess), its bundle mirror, `Invoke-DocsCommand.Tests.ps1` (+2 tests), and `DocsSchema.Tests.ps1` (mock output). Every criterion was re-evaluated against head `a3ae4c51d`; the rows below record the current evidence.
- **Feature folder used:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 11 reads `- Work Mode: full-feature`.
- **Scope note:** The item diff against the epic tip is 128 paths (the prior 108 plus 20 feature-folder files from the cycle), including the absence of `epic-status.md`, which HEAD never touched. Evaluation covers the full branch diff.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (32 checkbox items, S1 to S32 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (19 checkbox items, U1 to U19 in order)

The criteria are long; the labels below abbreviate them in source order. The full text is in the source files and was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions` are not acceptance-criteria sections and are not counted.

### From spec.md

1. S1 Examples validate (Test-Json True, no Test-DocsArtifactText finding), including the envelope example.
2. S2 Per-schema rejection of a deleted required field and an unknown kind or disposition, with pointer; `extensions` pattern acceptance and rejection.
3. S3 `validate-profile` on the example profile exits 0.
4. S4 `validate-profile` exits 1 naming the failing field (top-level, nested `$ref`, unknown element kind) via the structural walk.
5. S5 Exit 1 with `DOCS_JSON_DUPLICATE_KEY`, `DOCS_PROFILE_AUDIENCE_UNKNOWN`, `DOCS_PROFILE_MISSING`.
6. S6 `init` dry run, `-Write` create, existing-target refusal, `-Write -Force` overwrite.
7. S7 Identifier determinism, boundary distinctness, golden vectors, invalid input rejection.
8. S8 `DOCS_ELEMENT_ID_MISMATCH` and `cli-option` parent check.
9. S9 Neutrality suite (digest-only identifiers, positive control, non-empty digest list).
10. S10 Manifest suite (listing once, SHA-256 identity, python exclusion filter).
11. S11 Existing push-down contract tests pass unmodified.
12. S12 Runtime schema copies equal canonical files.
13. S13 Common definition parity with discovery v2; no discovery or file `$ref`.
14. S14 `Join-DocsSchemaText` composition rules and findings.
15. S15 Single `DOCS_SCHEMA_INVALID` with pointer `''`; walk findings precedence.
16. S16 Exit codes 0/1/2/3 for every 1020 subcommand.
17. S17 `-Json` envelope shape and determinism; text summary line.
18. S18 Dispatch table and anchors; `Test-DocsCommandTable` rejections.
19. S19 Analyzer registry anchors, tables, and validation behavior.
20. S20 Module convention suite passes; no production file above 500 lines.
21. S21 `quality-tiers.yml` T3 entry; tier check and two tests pass unmodified.
22. S22 No Python or TypeScript file added or modified; classification table complete.
23. S23 No discovery file changes.
24. S24 No test creates a temporary file; in-memory command contexts.
25. S25 Pester line coverage >= 85% per production file, none excluded, figures recorded under evidence.
26. S26 (CI-dependent) `poshqc / PowerShell QC` on `windows-latest` and `quality-checks7 / Code Quality & Tests` pass on the PR head.
27. S27 Analysis method (D3).
28. S28 Declaration-lines digest (D5).
29. S29 Envelope schema (D5).
30. S30 Audience identifiers.
31. S31 Diagnostic severity (1031 precondition).
32. S32 Process member (1031 precondition, thin seam).

### From user-story.md

33. U1 Examples validate; schemas reject missing required fields and unknown values.
34. U2 `validate-profile` exit 0 and exit 1 naming the field.
35. U3 `init` starter profile; no write without `-Write`; no overwrite without `-Force`.
36. U4 Identifier determinism and golden vectors.
37. U5 Neutrality test by digest.
38. U6 Push-down copy identity and manifest listing.
39. U7 Runtime schema copies identical.
40. U8 Exit codes and `-Json` envelope.
41. U9 Anchors for subcommands and analyzers.
42. U10 Tier T3 classification and tier check.
43. U11 No Python or TypeScript added.
44. U12 Discovery files unchanged.
45. U13 Coverage >= 85% per file; no temporary files.
46. U14 (CI-dependent) `poshqc / PowerShell QC` on `windows-latest` passes on the PR head.
47. U15 Analysis method visible and validated.
48. U16 Declaration digest locality.
49. U17 Published envelope contract.
50. U18 Audience identifier pattern.
51. U19 1031 preconditions (process member, diagnostics).

---

## Acceptance Criteria Evaluation

Reviewer command R1 is the docs Pester run at head `a3ae4c51d`: `Invoke-Pester` with `Run.Path = tests/scripts/claude-lib/docs` (385 of 385 passed). A suite named in a row passed inside R1. Non-R1 commands (pytest, gate suites, `cmp`, `diff -r`, coverage parse, diff filters) were also re-run at this head unless a row says the evidence is carried forward.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `DocsSchemaContract.Tests.ps1` (49 tests) | R1 | Real `Test-Json`. |
| 2 | S2 | PASS | `DocsSchemaContract.Tests.ps1` | R1 | |
| 3 | S3 | PASS | `Invoke-DocsCommand.Tests.ps1` line 115; `DocsProfileCommands.Tests.ps1` | R1 | |
| 4 | S4 | PASS | `DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1` | R1 | |
| 5 | S5 | PASS | `DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1` | R1 | |
| 6 | S6 | PASS | `DocsProfileCommands.Tests.ps1` (22 of 22, unchanged); `Invoke-DocsInitCommand` source unchanged by the cycle | R1 | The ShouldProcess gate returns true when no `-WhatIf` is passed, so the dry run, `-Write`, and `-Force` behavior is unchanged. |
| 7 | S7 | PASS | `DocsSurface.Tests.ps1`; `evidence/other/golden-identity-vectors.2026-11-03T11-51.md` | R1 | |
| 8 | S8 | PASS | `DocsSurface.Tests.ps1` | R1 | |
| 9 | S9 | PASS | `DocsNeutrality.Tests.ps1` (35 tests) | R1 | |
| 10 | S10 | PASS | `Docs.Manifest.Tests.ps1` (7 tests); reviewer `cmp` of `Invoke-DocsCommand.ps1` and `diff -r` of library and bundle copy: identical | R1; `cmp`; `diff -r .claude/lib/docs extensions/.../.claude/lib/docs` | Mirror re-synced by the cycle. |
| 11 | S11 | PASS | 34 passed; test files absent from the diff (unmodified) | `pytest test_push_down_claude_resource_contracts.py test_push_down_claude_pack_manifest_completeness.py test_push_down_pack_manifest_dependency_closure.py` | |
| 12 | S12 | PASS | Reviewer `cmp` of all eight runtime copies: identical | `cmp schemas/docs/v1/<f> .claude/lib/docs/schemas/v1/<f>` | |
| 13 | S13 | PASS | `DocsSchemaContract.Tests.ps1` | R1 | |
| 14 | S14 | PASS | `DocsSchema.Tests.ps1` (37 tests) | R1 | |
| 15 | S15 | PASS | `DocsSchema.Tests.ps1` | R1 | |
| 16 | S16 | PASS | `Invoke-DocsCommand.Tests.ps1` (46 tests) | R1 | |
| 17 | S17 | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsFinding.Tests.ps1` | R1 | |
| 18 | S18 | PASS | `Invoke-DocsCommand.Tests.ps1`; anchors at `Invoke-DocsCommand.ps1` lines 54-61 | R1 | |
| 19 | S19 | PASS | `DocsAnalyzerRegistry.Tests.ps1` (30 tests) | R1 | |
| 20 | S20 | PASS | Module convention 6 of 6 (inside the 52-test gate run); max 462 logical lines in production | `Invoke-Pester` gate suites; `@(Get-Content).Count` | |
| 21 | S21 | PASS | `quality-tiers.yml` not changed by the cycle; prior result `quality-tiers: OK (29 entries, 29 discovered projects)` and contract tests 16 passed stand | `git diff --name-only 71217a14e HEAD` | Evidence carried forward; the cycle touched no tier input. |
| 22 | S22 | PASS | No `.py/.ts/.tsx/.js/.mjs/.cjs` path in the diff; `evidence/qa-gates/qa-no-python-typescript.2026-11-03T20-07.md` | `git diff --name-status` filtered by extension | |
| 23 | S23 | PASS | No path under the three discovery roots in the diff | `git diff --name-status` filtered by prefix | |
| 24 | S24 | PASS | Token search under `tests/scripts/claude-lib/docs/`: no match | `grep -rlE` for the five tokens | |
| 25 | S25 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: 87.33% to 100% per file; none excluded | Python XML parse of sourcefile LINE counters | Figures recorded under `evidence/qa-gates/` instead of `evidence/coverage/`; the canonical evidence kinds have no `coverage` kind, so the plan's override is required by the evidence convention. |
| 26 | S26 | UNVERIFIED | No PR and no CI run for head `a3ae4c51d` | n/a | CI-dependent; pending S9 (`awaiting_ci`). |
| 27 | S27 | PASS | `DocsSchemaContract`, `DocsSurface`, `DocsAnalyzerRegistry` suites | R1 | |
| 28 | S28 | PASS | `DocsSurface`, `DocsSchemaContract`, `DocsAnalyzerRegistry` suites | R1 | |
| 29 | S29 | PASS | `Invoke-DocsCommand`, `DocsSchemaContract`, `Docs.Manifest` suites; `core.json` line present | R1 | |
| 30 | S30 | PASS | `DocsSchemaContract.Tests.ps1`, `DocsProfile.Tests.ps1` | R1 | |
| 31 | S31 | PASS | `DocsSurface.Tests.ps1` | R1 | |
| 32 | S32 | PASS | `Invoke-DocsCommand.Tests.ps1`; `Invoke-DocsProcess` unchanged by the cycle; no-Python-invocation suite passes inside the 52-test gate run | R1; gate suites | |
| 33 | U1 | PASS | As S1, S2 | R1 | |
| 34 | U2 | PASS | As S3, S4 | R1 | |
| 35 | U3 | PASS | As S6 | R1 | |
| 36 | U4 | PASS | As S7 | R1 | |
| 37 | U5 | PASS | As S9 | R1 | |
| 38 | U6 | PASS | As S10, S11 | R1; pytest | |
| 39 | U7 | PASS | As S12 | `cmp` | |
| 40 | U8 | PASS | As S16, S17 | R1 | |
| 41 | U9 | PASS | As S18, S19 | R1 | |
| 42 | U10 | PASS | As S21 | `check_quality_tiers` | |
| 43 | U11 | PASS | As S22 | diff filter | |
| 44 | U12 | PASS | As S23 | diff filter | |
| 45 | U13 | PASS | As S24, S25 | XML parse; token search | |
| 46 | U14 | UNVERIFIED | No CI run for the PR head | n/a | CI-dependent; pending S9 (`awaiting_ci`). |
| 47 | U15 | PASS | As S27 | R1 | |
| 48 | U16 | PASS | As S28 | R1 | |
| 49 | U17 | PASS | As S29 | R1 | |
| 50 | U18 | PASS | As S30 | R1 | |
| 51 | U19 | PASS | As S31, S32 | R1 | |

---

## Summary

**Overall Feature Readiness:** READY PENDING CI

**Criteria summary:**
- **PASS:** 49 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S26, U14; CI-dependent)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. S26 and U14 wait on CI for the PR head (F3, `awaiting_ci`).
2. Plan task P6-T6 (full `tests/scripts` single-process run) is unmet on this host for pre-existing reasons; its proof is the same `windows-latest` CI check (F2, `awaiting_ci`).

The prior policy finding outside the AC set (ShouldProcess, F1) is resolved; see `policy-audit.2026-11-03T20-57.md` section 3B.

**Recommended follow-up verification steps:**

1. Open the PR, then at S9 read `poshqc / PowerShell QC` (windows-latest) and `quality-checks7 / Code Quality & Tests` for the PR head, and check off S26 and U14 after a green conclusion.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 49 PASS criteria were already checked (`- [x]`) in the source files (reviewer count at head `a3ae4c51d`: 31 checked in the `spec.md` Acceptance Criteria section, 18 in `user-story.md`); the reviewer's re-evaluation confirms each, so no source-file change was needed. S26 and U14 remain unchecked as CI-dependent; the item's own orchestrator run checks them off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`, `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/user-story.md`
- Total AC items: 51
- Checked off (delivered): 49
- Remaining (unchecked): 2
- Items remaining: spec S26 "(CI-dependent) The required check `poshqc / PowerShell QC` on `windows-latest` and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head."; user-story U14 "(CI-dependent) The `poshqc / PowerShell QC` check on `windows-latest` passes on the pull request head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 32 | 31 | 1 | Checkbox-backed; S26 CI-dependent |
| `user-story.md` | 19 | 18 | 1 | Checkbox-backed; U14 CI-dependent |
