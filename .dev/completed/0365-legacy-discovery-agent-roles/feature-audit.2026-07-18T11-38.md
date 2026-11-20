# Feature Audit: legacy-discovery-agent-roles (#365)

**Audit Date:** 2026-07-18
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365`
**Base Branch:** `origin/epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-agent-roles-365`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

Template source: bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`, the asset resolved by the `feature-audit-template` selector; read directly from the bundled source path because the MCP server surface was unavailable in this session.

---

## Scope and Baseline

- **Base branch:** `origin/epic/legacy-discovery-and-parity-integration` (commit `8d8456536e40b40675159fc57555a55cd38e04b9`)
- **Head branch/commit:** `feature/legacy-discovery-agent-roles-365` (commit `5335075ceb3e84b0e4a13a221be159cb54d45274`)
- **Merge base:** `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated in this session against the resolved base)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/{baseline,qa-gates}/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, and an independent reviewer re-run of the new Pester suite at HEAD (15/15 pass)
- **Feature folder used:** `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365`
- **Requirements source:** `spec.md` and `user-story.md` (multiple files)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are both authoritative AC sources per the acceptance-criteria-tracking contract.
- **Scope note:** The PR-context artifacts were absent at review start and were regenerated with the repo collector against the supplied base branch before evaluation. The feature is single-version (no `v1/`/`v2/` folders), so audit artifacts live at the feature root. The audit scope is the full branch diff (16 files), not any plan subset.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/spec.md` — primary source (8 checkbox criteria)
- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/user-story.md` — co-authoritative source (6 checkbox criteria)

### From spec.md

1. Four domain-neutral agent `.md` personas exist under `.claude/agents/` (`legacy-parity-analyst.md`, `runtime-characterization-analyst.md`, `requirements-reconciler.md`, `migration-coverage-reviewer.md`), each with valid YAML frontmatter containing `name`, `description`, `model`, `tools`, and `memory`.
2. Each persona's `name` equals its slug and file basename; `model` is one of `haiku|sonnet|opus` (specifically `sonnet` per Decision 2); `tools` is exactly `Read`, `Grep`, `Glob`, `"Write(discovery/**)"`; `memory` is `project`.
3. No persona carries a `skills:` field or a `hooks:` field (Decisions 3 and 4).
4. The four slugs do not collide with the `code-modernization` plugin agent names (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`, `test-engineer`, `version-delta-analyst`) or with existing `.claude/agents/` basenames.
5. Each persona is domain-neutral: the case-insensitive banned-substring scan (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`) finds no match in any persona's frontmatter or body.
6. Each persona body explicitly names its consumed discovery schema(s), its produced discovery artifact/schema, and the domain profile, per the confirmed mapping in the per-persona design (machine-checked by the AC4 body-content assertion).
7. A PowerShell Pester structural test exists at `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` with in-memory positive and negative fixtures, covering existence, frontmatter validity, name-equals-slug, model membership, naming non-collision, banned-substring domain-neutrality scan, and the AC4 body-content assertion; the test passes.
8. No discovery-workflow skills (#9008), completion-gate validators/hooks (#9003/#9004), or `resources/` mirror copies (#9012) are added by this feature.

### From user-story.md

9. Four domain-neutral agent `.md` personas exist under `.claude/agents/` (the same four files), each with valid YAML frontmatter containing `name`, `description`, `model`, `tools`, and `memory`.
10. Each persona uses `model: sonnet`, `tools` of exactly `Read`, `Grep`, `Glob`, and `"Write(discovery/**)"`, `memory: project`, and carries no `skills:` field and no `hooks:` field.
11. Persona names do not collide with the installed `code-modernization` plugin agents or with existing `.claude/agents/` basenames.
12. Each persona is domain-neutral: no `taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, or `task management` identifiers appear in the persona body or frontmatter (case-insensitive).
13. Each persona documents which discovery schemas (#9002) and which domain-profile fields (#9001) it consumes and which discovery artifact it produces, per the confirmed mapping; this is machine-checked by the AC4 body-content assertion in the structural test.
14. A PowerShell Pester structural test at `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` validates the four persona definitions (existence, frontmatter validity, name-equals-slug, model membership, naming non-collision, banned-substring domain-neutrality scan, and the AC4 body-content assertion) using in-memory positive and negative fixtures, and passes.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Four personas exist with valid frontmatter (spec) | PASS | All four files present in the diff and read by the reviewer; each has `---`-delimited frontmatter with `name`, `description`, `model`, `tools`, `memory`. Structural-test assertions 1-2 green. | `git diff --name-status f18c1c16...HEAD`; `Invoke-Pester -Path tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` (15/15 pass, reviewer re-run at HEAD) | |
| 2 | name=slug=basename; model `sonnet`; tools exactly the four; memory `project` (spec) | PASS | Reviewer read all four files: `name` equals basename; `model: sonnet`; `tools` lists exactly `Read`, `Grep`, `Glob`, `"Write(discovery/**)"`; `memory: project`. Assertions 3-4 green. | Reviewer file reads of all four personas; Pester re-run | Tools-exactness and memory value verified by inspection; the suite machine-checks name/model (see code-review Info finding). |
| 3 | No `skills:` or `hooks:` field (spec) | PASS | Independent grep over the four personas returned zero matches. | `grep -nE '^(skills\|hooks):' .claude/agents/<four personas>.md` (exit 1, zero matches) | Corroborates executor evidence in `evidence/qa-gates/ac-closure-summary.md`. |
| 4 | Slugs disjoint from plugin names and existing agent basenames (spec) | PASS | Structural-test assertion 5 green; reviewer listed `.claude/agents/` — 22 basenames, no overlap between the four new slugs and the 18 pre-existing agents or the seven plugin names. | `ls .claude/agents/`; Pester re-run | `legacy-parity-analyst` is distinct from plugin `legacy-analyst` by the `parity` discriminator per spec. |
| 5 | Domain-neutral banned-substring scan clean (spec) | PASS | Independent case-insensitive grep for all seven banned terms over the four files: zero matches. Assertion 6 green. | `grep -riE 'taskmaster\|tmw\|outlook\|vsto\|email\|task-management\|task management' <four personas>` (exit 1) | Epic-wide invariant verified two ways. |
| 6 | Body names consumed schema(s), produced schema, and domain profile per confirmed mapping (spec) | PASS | Reviewer verified each persona's Schemas Consumed / Schema Produced / Domain Profile sections against the spec Per-Persona Design mapping line by line; all four match. Assertion 7 (per-persona required-reference sets) green. | Reviewer file reads; Pester re-run | Evidence Reference is consumed by all four as the cross-cutting linkage schema, matching the spec. |
| 7 | Structural test exists with fixtures across the seven assertions and passes (spec) | PASS | File present (485 lines): 8 in-memory fixture tests (1 positive, 4 negative scenarios) + 7 real-file assertions. Executor run 35/35; reviewer re-run at HEAD 15/15 in 565 ms. | `Invoke-Pester -Path tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 -Output Normal` | JUnit artifact `artifacts/pester/pester-junit.xml` reports tests=35 failures=0 errors=0. |
| 8 | No #9008 skills, #9003/#9004 validators/hooks, #9012 mirror copies added (spec) | PASS | Full branch diff (16 files) contains no `.claude/skills/` additions, no validator/hook scripts, no `settings.json` change, and no files under `extensions/drm-copilot/resources/claude-customizations/`. | `git diff --name-status f18c1c16...HEAD` | Negative-scope criterion verified against the complete diff, not a subset. |
| 9 | Four personas exist with valid frontmatter (user-story) | PASS | Same evidence as #1. | Same as #1 | Duplicate of spec AC1 across co-authoritative sources. |
| 10 | model/tools/memory exact; no skills/hooks (user-story) | PASS | Same evidence as #2 and #3 combined. | Same as #2, #3 | |
| 11 | Naming non-collision (user-story) | PASS | Same evidence as #4. | Same as #4 | |
| 12 | Domain neutrality (user-story) | PASS | Same evidence as #5. | Same as #5 | |
| 13 | Schema/domain-profile documentation per mapping (user-story) | PASS | Same evidence as #6; domain-profile fields per persona also match the spec (e.g., `legacy_source`, `target`, `technology_stack`, `artifacts.root` for legacy-parity-analyst; `artifacts.conventions` added for migration-coverage-reviewer). | Same as #6 | |
| 14 | Structural test validates and passes (user-story) | PASS | Same evidence as #7. | Same as #7 | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 14 criteria (8 from spec.md, 6 from user-story.md)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. When feature #9008 (discovery-workflow skills) lands, re-verify that the personas' documented schema mappings still match the delivered #9002 schema set.
2. Optional, non-blocking: extend the structural test with tools-exactness, `memory` value, and `skills:`/`hooks:`-absence assertions (code-review Info finding) to machine-check spec AC2/AC3 against future drift.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 14 criteria evaluated PASS.
- All checkboxes in both authoritative source files were already checked (`[x]`) by the executor at completion, with per-criterion verification recorded in `evidence/qa-gates/ac-closure-summary.md`. The reviewer confirmed each check-off against independent evidence; no source-file changes were required in this review, and none were made.
- No criteria remain unchecked, so no new check-offs were performed.

### AC Status Summary

- Source: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/user-story.md`
- Total AC items: 14 (8 spec + 6 user-story)
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed; check-offs performed by executor, confirmed by reviewer |
| `user-story.md` | 6 | 6 | 0 | Checkbox-backed; check-offs performed by executor, confirmed by reviewer |

No source-file checkbox change was made in this review because every PASS criterion was already checked; the reviewer's role here was confirmation, not check-off.
