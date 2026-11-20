# Feature Audit: migrate_development_docs tool and the .dev move (#1016), re-audit after remediation cycle 1

**Audit Date:** 2026-11-20
**Feature Folder:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`)
- **Head branch/commit:** `feature/dev-docs-root-migration-phases-2-3-1016` (commit `7322bc6251aca5e9d2beb11e528f847da44b6764`)
- **Merge base:** `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-20 20:22:49 UTC for head `7322bc625`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/**`
  - Additional evidence: reviewer parse of the standing coverage and junit artifacts and of `evidence/other/dev-docs-migration-dry-run.2026-11-20T19-23.json`; `gh run view 44810698464` job conclusions; code reading of the cycle diff `f744ce9e0..7322bc625`
- **Feature folder used:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`) and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff. Criteria that the cycle did not touch keep the grade and evidence of `feature-audit.2026-11-20T18-20.md`; the reviewer re-graded every criterion that the prior review left PARTIAL and every criterion whose evidence the cycle changed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/spec.md` — primary (`## Acceptance Criteria`, 44 items)
- `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/user-story.md` — secondary (23 items)

### Acceptance criteria

The labels follow the prior feature audit: S-A1 to S-A20 stage A, S-O1 owner stop, S-B1 to S-B17 stage B, S-E1 to S-E6 epic, U-a1 to U-d9 user story by scenario. U-c1 is graded against its restated text: "The orchestrator decision step writes the decision file from A2 to A13 and the stage A dry-run JSON, and neither plan decides the owner questions."

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S-A1 to S-A5 | layout map, rename plan, rewrite, git seam, decisions suites | PASS | launcher Jest runs; CI extension tests success on both hosts | `run-test-suite.sh jest-extension` | `layout-map.test.ts` gains the F1 predicate block |
| S-A6 | `migration-plan.test.ts` refusal rules, merge planning, exclusions, three scopes, dry-run defaults | PASS | suite now also covers a post-move tree | same | prior note closed |
| S-A7 | `migration-apply.test.ts` in-memory apply, empty second plan, moves-then-rewrites | PASS | new second links-only apply case | same | failed before the fix (`fail-before-f1.2026-11-20T19-17.md`) |
| S-A8 to S-A18, S-A20 | report, service call, CLI, no temp file, registration, contract, packaging, no `vscode`, thresholds, READMEs, stage A dry run, no Python, Phase 0 artifact | PASS | prior grades; cycle edits keep `jest.development-docs-migration-coverage.json` thresholds met (100% lines, 98.64% branches for `migration-plan.ts`) | coverage parse | unchanged by the cycle |
| S-A19 | seven-stage toolchain for changed TypeScript; no file above 800 | PENDING-CI | stages 1 to 6 clean; CI TypeScript jobs success; stage 7 in CI | CI at S9 | pending-CI, not a finding |
| S-O1 | decision file exists, follows schema, names report, digest, held items, global answers | PASS | `folder-rename-decisions.2026-11-20T12-24.json` | artifact read | unchanged |
| S-B1 to S-B3 | stage B gate artifact; `.dev/` layout; renamed folders match | PASS | prior grades | artifact read | unchanged |
| S-B4 | second dry run after apply reports an empty plan, stored under `evidence/other/` | PASS | `post-apply-dry-run-check.2026-11-20T19-24.md`; reviewer read of `dev-docs-migration-dry-run.2026-11-20T19-23.json`: `moves` 0, `renames` 0, `rewrites_outside_moved_trees` 0, `rewrites_in_tree_links_only` 0, `refusals` 0; 4572 in-tree references-and-links entries all under `.dev/` with 0 links, which `links-only` does not rewrite | node read of the report JSON | F1 closed; executor checked, reviewer confirms |
| S-B5 to S-B14, S-B16, S-B17 | flip, path roots, template depth, manifests, frozen hashes, fixtures, write-scope checker, mirrors, production-root search, checkpoint path, no Python, implied answers | PASS | prior grades | artifact read | unchanged by the cycle |
| S-B15 | seven-stage toolchain for TypeScript, Python, PowerShell with key at `.dev` | PENDING-CI | stages 1 to 6 clean in final-loop pass 2 on the clean layout; stage 7 in CI | CI at S9 | pending-CI, not a finding |
| S-E1, S-E3, S-E5, S-E6 | `.dev/` records; no Python; fixtures frozen; mirrors and contract tests | PASS | prior grades | artifact read | unchanged |
| S-E2 | migration command moves with `git mv`, rewrites, second run changes nothing | PASS | second-apply Jest case (links-only, moved record with an old prefix); post-apply dry run as S-B4 | Jest; report read | F1 closed; executor checked, reviewer confirms |
| S-E4 | with key at `.dev`, the full toolchain passes | PENDING-CI | as S-B15 | CI at S9 | pending-CI, not a finding |
| U-a1 to U-a4, U-b1 to U-b6 | dry run, report categories, counts, alternatives, CLI, packaging, refusals, in-memory apply, no Python, README | PASS | prior grades; U-b4 additionally covered by the new links-only second-apply case | Jest | unchanged |
| U-c1 | the orchestrator decision step writes the decision file from A2 to A13 and the stage A dry-run JSON, and neither plan decides the owner questions | PASS | `folder-rename-decisions.2026-11-20T12-24.json`: `dry_run_report` names the stage A report `dev-docs-migration-dry-run.2026-11-20T07-40.json`, and its `source_digest` `2f33c965...6a75` equals that report's digest (reviewer read of both files); the twelve `global_decisions` equal the A2 to A13 values (`decision-file-check.2026-11-20T08-00.md`, every key PASS); 45 `decisions` follow the A13 held-item rule; the file was committed by the orchestrator (`677cd3f01`). Neither plan states an owner-question answer: the stage B plan reads the decision file and checks it against the decided values | artifact read; `git log --diff-filter=A` | restated by the F2 supersession; checked off by this review |
| U-c2 to U-c4 | decision file content; apply honors decisions; digest refusal | PASS | prior grades | artifact read | unchanged |
| U-d1 to U-d6, U-d9 | layout, key, names, template links, fixtures, checkers, no Python | PASS | prior grades | artifact read | unchanged |
| U-d7 | full seven-stage toolchain for three languages with key at `.dev` | PENDING-CI | as S-B15 | CI at S9 | pending-CI, not a finding |
| U-d8 | post-apply dry run reports an empty plan | PASS | as S-B4 | report read | F1 closed; executor checked, reviewer confirms |

### Remediation findings closure

| Finding | Status | Evidence |
|---|---|---|
| F1 | Closed | `isMappedTargetPath` in `layout-map.ts` used in `scanRewrites` (commit `e49111fac`); fail-before 2 of 2 expected failures; pass-after in the extension and root Jest runs and in CI; empty post-apply plan; four Stay rows in `excluded_files` |
| F2 | Closed | `user-story.md` note `Supersession (2026-11-20, A14, OD-1):` quoting the original text; restated criterion; `spec.md` A14 sentence `supersedes user-story criterion (c) 1`; checkbox counts unchanged (44 spec, 23 user-story); restated criterion PASS above |
| F3 | Closed locally; CI shards in progress | test change in commit `f331c32ca`; fail-before on the emulated clean layout with the CI error text; pass-after 7 of 7 and in the full Pester run (`pester-junit.xml`: Passed); static sweep of 65 files with 0 real-checkout reads; dynamic sweep in the [P1-T8] gate with `Sweep: none`; the four moved-root directories absent on disk at review time |

### Regression check of the cycle diff

- Production edits: two files, 28 added lines, all covered; no refusal, I/O or public-signature change other than the new export.
- Requirement documents: `spec.md` changes the A14 bullet and checks two criteria (S-B4, S-E2); `user-story.md` adds a non-checkbox note, restates one criterion and checks one criterion (U-d8). No criterion was added or removed.
- Evidence: every cycle artifact is new; `post-apply-dry-run-check.2026-11-20T16-11.md` and `self-review.2026-11-20T18-14.md` are unchanged.
- No regression found.

---

## Summary

**Overall Feature Readiness:** READY (pending CI for four CI-dependent criteria)

**Criteria summary:**
- **PASS:** 63 criteria
- **PARTIAL:** 0 criteria
- **PENDING-CI:** 4 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None blocking. S-A19, S-B15, S-E4 and U-d7 depend on stage 7 in CI and are checked off at S9 by the item's orchestrator.

**Recommended follow-up verification steps:**

1. At S9, confirm that CI run 44810698464 (or its successor on the final head) concludes `success`, including `poshqc / PowerShell QC` shard 1, which failed on the prior head, and `CI Required Gate`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

Newly checked off by this review:
- `user-story.md` `### (c) Owner decisions on held items`: "The orchestrator decision step writes the decision file from A2 to A13 and the stage A dry-run JSON, and neither plan decides the owner questions." (U-c1)

Checked by the executor in the cycle and confirmed PASS by this review: spec S-B4, spec S-E2, user-story U-d8.

### Acceptance Criteria Status

- Source: `spec.md`, `user-story.md`
- Total AC items: 67
- Checked off (delivered): 63
- Remaining (unchecked): 4
- Items remaining: spec stage A "The seven-stage toolchain passes in a single pass for the changed TypeScript, and no changed production file exceeds 800 lines."; spec stage B "The seven-stage toolchain passes in a single pass for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`, and no changed production file exceeds 800 lines."; spec epic "With `development_docs_root` set to `.dev`, the full toolchain passes."; user-story (d) "The full seven-stage toolchain passes for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`." All four are pending CI.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 44 | 41 | 3 | Checkbox-backed; the `## Definition of Done` checklist is outside the AC section |
| `user-story.md` | 23 | 22 | 1 | Checkbox-backed |
