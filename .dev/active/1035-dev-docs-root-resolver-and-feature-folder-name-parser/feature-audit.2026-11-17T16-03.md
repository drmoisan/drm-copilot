# Feature Audit: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

---

**Audit Date:** 2026-11-17
**Feature Folder:** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`)
**Head:** `8ef56f9c7082bfdc79e2bb1c69e2f1bf10aabdef`
**Work Mode:** full-feature (`issue.md` marker `- Work Mode: full-feature`); AC sources `spec.md` and `user-story.md`.
**Review Type:** S7 re-audit after remediation cycle 1 (prior `feature-audit.2026-11-17T11-41.md`)

---

## Scope and Baseline

- Scope: the full two-dot diff `7ebf1347d..8ef56f9c7` (496 files). Phase 1 of #1016 only; Phases 2 and 3 belong to epic child 7 (spec `## Scope Boundary`).
- Baseline: Phase 0 artifacts under `evidence/baseline/` (pytest 9200 passed, 96.11% line, 91.86% branch; Jest 5681 passed, 97.19% line, 94.00% branch; Pester 27341 tests, 96.04% line) and cycle baselines under `evidence/remediation-baseline/`.
- Final (cycle 1): pytest 17111 passed (`--cov=scripts`, 96.60% line, 92.38% branch); Jest 5898 (root) and 5881 (extension) passed; Pester 27974 tests with 0 failures (96.69% line).
- Cycle changes: tests for nine modified production files; testability seams in `.codex/hooks/authorize-root-epic-invocation.ps1` and `.codex/scripts/epic-child-launch-runtime.ps1` with byte-identical bundle copies. No change to spec or user-story criteria text; the only `spec.md` change since the prior head is the prior review's DoD check-off.
- #1016 is referenced and not closed: no Closes, Fixes or Resolves line for #1016 in commit messages or added text. OD-P4 stands and is not a finding.
- Evaluation method: executor evidence read and cross-checked against the reviewer's parse of the four coverage artifacts, a full sweep of changed production files, byte comparison of bundle copies, and a real-process probe of the refactored hook. The reviewer ran no test suite (owner rule).

---

## Acceptance Criteria Inventory

### From spec.md

| # | Criterion (abridged) |
|---|---|
| S1 | Routing key in the three configuration copies; parity test passes |
| S2 to S4 | Resolver tests R-1 to R-8 in TypeScript, Python and Pester |
| S5, S6 | Area-path and known-root prefix functions per runtime |
| S7 | No `vscode` import under `src/lib/development-docs/`, asserted by a test |
| S8 | Python additions in `json_config.py` only |
| S9 | Full suites pass with the default key; only folder-naming and status-line expectations changed |
| S10 | Recorded residual search with allowlist |
| S11 to S16 | `.dev` writers, validators, gates, template script, fail-closed hook, refresh consumers |
| S17 to S20 | CI docs-only prefixes, change-scope suites, docs-only diff helper, brief and README |
| S21 to S24 | `GOVERNED_GLOBS`, `compileGlob` include-dot, glob consumers, excluded directory |
| S25 to S30 | Parser tests, delegation, folder creation, epic folders, status lines |
| S31 to S35 | Write-scope contract, checker, literals, generator, frozen-surface hashes |
| S36 to S40 | Module copies, Codex virtual path, pack manifests, bundle parity, scope boundary |
| S41 | Per-file `coverageThreshold` entries; changed-code coverage thresholds |
| S42 | Seven-stage toolchain single pass; no changed production file above 800 lines |
| DoD-1 to DoD-7 | Definition of Done items |
| STC-1 to STC-3 | Seeded test conditions |

### From user-story.md

| # | Criterion (abridged) |
|---|---|
| U1 to U3 | Routing key; resolver tests; Python additions in `json_config.py` only |
| U4 | Full suites pass with the default key; only expected test changes |
| U5 to U11 | Residual search, validators, CI prefixes, consumers, governed globs, glob consumers, module copies |
| U12 | Seven-stage toolchain; changed-code coverage thresholds; no file above 800 lines |
| U13 to U21 | Default resolution, explicit errors, folder creation, parser tests, scope boundary, write-scope contract, checker, literal forms, generator |

---

## Acceptance Criteria Evaluation

| # | Status | Evidence |
|---|---|---|
| S1 to S8, U1 to U3, U13 | PASS | Unchanged since the prior review (cycle changed no production code these criteria cover); evidence in `feature-audit.2026-11-17T11-41.md` and the task checks. |
| S9, U4 | PENDING-CI | Local: pytest, Jest and Pester pass with the default key at the cycle gates; the cycle removed no test expectation. The integration lane runs in CI only. |
| S10 to S40, U5 to U11, U14 to U21 | PASS | Unchanged since the prior review; the cycle's seams keep default behavior (real-process probe; bundle copies byte-identical, so S39 parity holds). |
| S41 | PASS | `jest.config.cjs` per-file entries; changed-code coverage 100.00% line (Python, TypeScript), 98.17% line (PowerShell), 100.00% and 98.00% branch (Python, TypeScript). |
| S42 | PENDING-CI | Local seven-stage loops pass in a single pass per language after the last fix commits; stage 7 runs in CI; no changed production file above 800 lines. |
| U12 | PENDING-CI | As S42; changed-code coverage meets the thresholds. |
| DoD-1, DoD-3 to DoD-7 | PASS | Already checked; confirmed. |
| DoD-2 (all documented environments) | PENDING-CI | Needs CI on the pull request head. |
| STC-1, STC-2 | PASS | Already checked. |
| STC-3 (CLI/API examples) | NOT EVALUATED | Seeded test condition outside the `## Acceptance Criteria` heading; Phase 1 adds no CLI. No finding. |

Prior findings: F1 (modified-file coverage) closed; F2 (Python report freshness) closed. Details in `policy-audit.2026-11-17T16-03.md` section 1.2.1 and the coverage evidence checklist.

---

## Summary

- 40 of 42 spec acceptance criteria and 19 of 21 user-story acceptance criteria evaluate PASS; S9, S42, U4 and U12 are CI-dependent and pending CI on the pull request head, with local evidence consistent with PASS.
- No acceptance criterion evaluates FAIL, and no blocking finding remains.
- Review verdict: PASS (`remediation-inputs.2026-11-17T16-03.md` records `Review-Verdict: PASS`, superseding the cycle 1 inputs).

---

## Acceptance Criteria Check-off

- Newly checked off by this review: none (every PASS item was already checked).
- Left unchecked as pending CI (the item's own orchestrator checks them off at S9): spec "With the default key, the full Python, PowerShell and TypeScript test suites pass...", spec "The seven-stage toolchain passes in a single pass...", spec DoD "Behavior matches acceptance criteria in all documented environments", user-story items at lines 63 and 71.
- Left unchecked, not evaluated: spec seeded test condition "CLI/API examples".

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md`, `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/user-story.md`
- Total AC items: 63 (spec 42, user story 21)
- Checked off (delivered): 59 (spec 40, user story 19)
- Remaining (unchecked): 4
- Items remaining: spec "With the default key, the full Python, PowerShell and TypeScript test suites pass, and the only changed expectations in existing tests are the folder-naming and status-line expectations for supplied issue numbers." (pending CI); spec "The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript, and no changed production file exceeds 800 lines." (pending CI); user story "With the default key, the full Python, PowerShell and TypeScript test suites pass..." (pending CI); user story "The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript; coverage of changed code meets 85% line coverage...; no changed production file exceeds 800 lines." (pending CI)
- Outside the AC headings: spec DoD "Behavior matches acceptance criteria in all documented environments" (pending CI) and seeded condition "CLI/API examples" (not evaluated) remain unchecked.
