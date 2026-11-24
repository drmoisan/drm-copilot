# Feature Audit: documentation-workflow epic-scale routing (#1223)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1223-docs-epic-scale-routing`
**Base Branch:** `epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-epic-scale-routing-1223`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/documentation-estate-families-integration` (commit `5267cb8294cb933c28ace89647d8283b3ba81404`)
- **Head branch/commit:** `feature/docs-epic-scale-routing-1223` (commit `95a4563de1d33e524a57cc836f8e34ff1b11667e`)
- **Merge base:** `5267cb8294cb933c28ace89647d8283b3ba81404`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1223-docs-epic-scale-routing/evidence/**`
  - Additional evidence: direct diff inspection of the branch against the merge base, `cmp` and SHA-256 comparison of the generated and bundle copies
- **Feature folder used:** `.dev/active/1223-docs-epic-scale-routing`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** the caller named the feature `full-feature`; `spec.md` and `user-story.md` are the authoritative AC sources.
- **Scope note:** the audit covers the full branch diff from the merge base. The owner test-scope instruction dated 2026-11-23 (full suites at Phase 0 and final QA only; phase gates targeted with a recorded waiver) is an accepted waiver. The review ran no format, lint, or type check; it read the final-QC static artifacts.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1223-docs-epic-scale-routing/spec.md` - primary
- `.dev/active/1223-docs-epic-scale-routing/user-story.md` - secondary

### From spec.md

1. Placement: `## Epic-Scale Routing` after `## Rules` and before `## Commit, Receipt and Pull Request` in all four copies; the contract test fails when missing, duplicated, or out of order.
2. Routing condition: first full estate or more than the D2 page threshold routes through `epic-plan` from the main session; otherwise single-run; the epic-worthiness verdict can return the work; deviation is a recorded decision.
3. Wave order: foundation, then `architecture`, `adr`, `reference`, `product-overview`, `getting-started`; then `user-guides`, `administration`, `security`; then `operations`, `service-management`; each default id once, in its own segment.
4. Ownership: ids owned by docs-family-profile-model; profile family list authoritative; none of the six family-record field names appear.
5. Dispatch: each child runs the `## Dispatch Order` for its families only; `docs-init` and the root inventory step run in the foundation child.
6. Receipt: written on the integration branch at its head by the final integration step only, before the integration pull request; no wave child writes or commits a receipt; family semantics owned by docs-family-gate-and-ia.
7. Qualifications: When to Use, Commit/Receipt/Pull Request, docs path set rule, and Refresh qualified in every copy.
8. Standard: new behavior and new check citing it; `AC-6` citation list extended; no contract violation; Codex bundle copy byte-identical.
9. Contract test: suite exists, pins criteria in every copy, runs in the parallel gate, no temporary files, no clock, single threshold variable, helpers removed in `AfterAll`.
10. Generator parity: `-Surface skills -Check` clean; generated copies from the generator; substitutions file unchanged.
11. Bundle contracts: push-down Claude resource, push-down Codex and agents resource, and pack-manifest completeness tests pass.
12. Brief listing: suite name under `## Contract Tests That Pin Mirrored Files` in the four brief copies; brief contract tests and `copilot-layer-retirement.Tests.ps1` pass.
13. Scope guard: no Python, no PowerShell library change, no MCP change, and no edit to `epic-orchestrator.md`, `epic-orchestrate/SKILL.md`, `docs-plan-ia`, or the substitutions file.

### From user-story.md

U1. Placement in every copy with a failing contract test otherwise.
U2. Routing condition, main-session start, verdict return path, recorded deviation.
U3. Default waves in order, ownership by docs-family-profile-model, no family-record field names.
U4. Dispatch for the child's families only; receipt on the integration branch at its head by the final integration step before the integration pull request; no wave-child receipt.
U5. Qualification of the existing single-run statements so none contradicts the epic route.
U6. Standard gains a behavior and check and passes the contract shape rules.
U7. Parallel Pester contract suite pins the statements, creates no temporary files, reads no clock.
U8. Copies in parity, generator check passes, push-down and pack-manifest tests pass, suite listed in the brief copies.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Placement | PASS | `.agents` skill diff places the section between `## Rules` and `## Commit, Receipt and Pull Request`; the other three copies are equal to or generated from it; the suite row 1 pins count equal to 1 and order in four copies | `git diff 5267cb829..HEAD -- .agents/skills/documentation-workflow/SKILL.md`; `cmp` of the copies | Fail-before run exit 1, pass in `phase-gate.P2` |
| 2 | Routing condition | PASS | Section bullet "Routing": first full estate or more than 40 planned pages, `epic-plan` from the main session, single-run otherwise, epic-worthiness verdict, recorded decision; matches D2 | suite row 2 (4 copies) | Threshold held in `$script:DefaultPageThreshold` |
| 3 | Wave order | PASS | Waves 0 to 3 listed in the required order; ten ids appear once in backticks, each in its own segment; Wave 0 holds no id | suite row 3 (4 copies) | Verified by reading the section |
| 4 | Ownership | PASS | "family ids are owned by docs-family-profile-model, and the family list of the profile is authoritative"; section has no `required_families`, `diataxis_mode`, `review_interval_days`, `audience`, `exclusion`, or `legacy_exclusions` | suite row 4 (4 copies) | Focus point confirmed: the skill does not restate the family record |
| 5 | Dispatch | PASS | "each child runs the `## Dispatch Order` for its families only. `docs-init` and the root inventory step run in the foundation child." | suite row 5 | Pins `for its families only`, `root inventory step`, `foundation child` |
| 6 | Receipt | PASS | "written once on the integration branch at its head, by the final integration step only, before the integration pull request; no wave child writes or commits a receipt" and the docs-family-gate-and-ia citation | suite row 6 | Mechanism not stated, per D1 |
| 7 | Qualifications | PASS | When to Use names the seven skills for a single run and `epic-plan` for the estate route; the stage states the single-run route and orchestrator pull request stages; the path set rule states "checkpoint-free single run" and the security-wave child may carry `SECURITY.md` and `CODEOWNERS` as an orchestrated child; Refresh states the integration-branch refresh before the final receipt | suite row 7 | Two optional pin-tightening nits recorded in the code review |
| 8 | Standard | PASS | `OB-6` added, `AC-7 (OB-6)` added, `AC-6` list extended to `OB-6`; `evidence/other/standard-contract.2026-11-24T13-35.md` EXIT_CODE 0; SHA-256 of the Codex bundle copy equals the source | `sha256sum` of the pair; suite standard rows (2 copies) | The `uncited-behavior` rule is satisfied by the `AC-7` citation |
| 9 | Contract test | PASS | File exists at the required path; 207 lines; four helpers removed in `AfterAll`; no `New-TemporaryFile`, `Get-Date`, or process start; one `DefaultPageThreshold` variable; 34 rows in the 29966-testcase parallel gate | `final-qc-pester.2026-11-24T14-33.md` | Header declares no file write, clock read, or process |
| 10 | Generator parity | PASS | `.claude` copy differs from `.agents` only in the pre-existing substitution spans; the Claude bundle copy is byte-equal to `.claude`; substitutions file absent from the diff; `-Check` exit 0 | `cmp`; `final-qc-parity.2026-11-24T14-50.md` | Hand edit would show as drift; none reported |
| 11 | Bundle contracts | PASS | Full pytest 17104 passed includes both push-down resource contract tests and both pack-manifest completeness tests; P2 targeted run 81 passed | `final-qc-pytest.2026-11-24T14-45.md`; `phase-gate.P2.2026-11-24T14-03.md` | Pass count equals the Phase 0 baseline |
| 12 | Brief listing | PASS | The one-line addition under `## Contract Tests That Pin Mirrored Files` is present in the `.agents`, `.claude`, Claude bundle, and Codex bundle copies; the `.agents` and Codex copies, and the `.claude` and Claude bundle copies, are byte-equal; brief contract tests and `copilot-layer-retirement.Tests.ps1` ran in the P2 and final gates | `cmp`; `sha256sum`; suite brief rows (4 copies) | |
| 13 | Scope guard | PASS | Branch diff lists no `.py`, no `scripts/**` library, no MCP source, and none of `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `docs-plan-ia`, or the substitutions file | `git diff --name-only 5267cb829..HEAD` | 11 files outside the feature folder |
| U1 | Placement (story) | PASS | Same evidence as 1 | | |
| U2 | Routing (story) | PASS | Same evidence as 2 | | |
| U3 | Waves and ownership (story) | PASS | Same evidence as 3 and 4 | | |
| U4 | Dispatch and receipt (story) | PASS | Same evidence as 5 and 6 | | |
| U5 | Qualifications (story) | PASS | Same evidence as 7; the single-run statements are qualified and the epic route is stated | | See the Minor `OB-4` observation |
| U6 | Standard (story) | PASS | Same evidence as 8 | | |
| U7 | Contract suite (story) | PASS | Same evidence as 9 | | |
| U8 | Parity and bundles (story) | PASS | Same evidence as 10, 11, and 12 | | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 21 criteria (13 spec, 8 user-story; the story items restate the spec items)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm CI on the pull request into the integration branch (no CI result is available at the reviewed head; no pull request exists yet).
2. At the epic final step, confirm that the receipt commit under `docs/documentation-estate/` is admitted from the integration worktree (the open risk recorded in `spec.md`; the skill states the requirement and not the mechanism by design).

---

## Acceptance Criteria Check-off

All spec and user-story checkboxes are already `[x]`, set by the executor in `evidence/other/ac-checkoff.2026-11-24T14-55.md` after the evidence passed. The review confirms each as PASS and makes no change to either file. Unchecked items in the source files outside the acceptance criteria (the spec `## Definition of Done` and `## Seeded Test Conditions` checkboxes) are not acceptance criteria and were left unchanged.

### AC Status Summary

- Source: `.dev/active/1223-docs-epic-scale-routing/spec.md`, `.dev/active/1223-docs-epic-scale-routing/user-story.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1223-docs-epic-scale-routing/spec.md` | 13 | 13 | 0 | Checkbox-backed |
| `.dev/active/1223-docs-epic-scale-routing/user-story.md` | 8 | 8 | 0 | Checkbox-backed |

No source-file checkbox change was made by this review because every item was already checked and verified.
