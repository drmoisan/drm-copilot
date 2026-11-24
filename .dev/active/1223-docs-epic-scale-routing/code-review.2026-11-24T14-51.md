# Code Review: documentation-workflow epic-scale routing (#1223)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1223-docs-epic-scale-routing`
**Base Branch:** `epic/documentation-estate-families-integration` (merge base `5267cb8294cb933c28ace89647d8283b3ba81404`)
**Head Branch:** `feature/docs-epic-scale-routing-1223` (`95a4563de1d33e524a57cc836f8e34ff1b11667e`)
**Review Type:** Initial review

---

## Executive Summary

The change adds guidance text and one contract suite. The `documentation-workflow` skill gains `## Epic-Scale Routing` (waves, ownership, dispatch, receipt), four qualifications of single-run statements, standard behavior `OB-6` with check `AC-7`, and one line in each of four execution-environment brief copies. One Pester suite of 207 lines pins the text in four skill copies, two standard copies, and four brief copies. Evidence reviewed: the full branch diff, the generated-copy comparison, SHA-256 pairs for the Codex bundle copies, and the final-QC artifacts.

**What changed:**
Eleven files outside the feature folder: the `.agents` skill and standard, the generated `.claude` copy, the Claude bundle copy, the Codex bundle copies of the skill and standard, four brief copies, and `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1`.

**Top 3 risks:**
1. The receipt commit mechanics on the integration branch are not covered; the spec records this as an open risk owned by preflight and the epic final step.
2. The pinned tokens are literal English phrases, so a legitimate rewording of the section fails the suite; this is the intended contract behavior.
3. Standard behavior `OB-4` still reads "The root session runs this stage itself after the dispatch order." without the single-run qualification that the skill text now carries.

**PR readiness recommendation:** **Go** - no blocking findings; all 13 spec criteria are met on the evidence, with three non-blocking observations.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.agents/skills/documentation-workflow/SKILL.md` | `## Commit, Receipt and Pull Request`, first paragraph | After the inserted sentence "Epic children use the orchestrator pull request stages instead.", the next sentence begins "It is not a dispatch row", and the pronoun now reads as referring to the epic-child stages rather than to this stage. | In a later wording pass, restate the subject ("This stage is not a dispatch row ..."). | Reader clarity; the meaning is recoverable from context and no criterion requires the wording. | Diff of the `.agents` skill, hunk at `## Commit, Receipt and Pull Request`. |
| Minor | `.agents/skills/documentation-workflow/references/standard.md` | `OB-4` | `OB-4` is unchanged and states the root session runs the stage after the dispatch order, while the skill now limits that to the single-run route. `AC-6` requires no contradiction. | Qualify `OB-4` with "on the single-run route" at the next standard edit. | The standard and the skill differ in scope; `Get-HarnessSkillContractViolation` reports no violation, so it is not a defect of record. | Diff of the standard; `evidence/other/standard-contract.2026-11-24T13-35.md` (exit 0). |
| Nit | `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1` | qualification rows, lines 166-183 | The `## When to Use This Skill` check pins only `epic-plan`; spec AC-7 also asks that the section names the docs skills for a single run, and the orchestrated-child wording for `SECURITY.md` and `CODEOWNERS` is pinned only through the token `SECURITY.md` and `CODEOWNERS`. | Optionally add `single run` to the When-to-Use tokens and `orchestrated child` to the stage tokens. | Tighter pin of AC-7; the text is present in all four copies today. | Test lines 166-183 against the skill diff. |
| Nit | `.agents/skills/documentation-workflow/SKILL.md` | `## Commit, Receipt and Pull Request`, docs path set rule | A hard line break splits "the docs-init workflow file. Any / other path is denied" at a short line. | Reflow the bullet in a later pass. | Formatting only; Markdown renders identically. | Diff of the `.agents` skill. |

No Blockers or Major findings. No file is at or above 700 logical lines (test file 207, skill 122), so no `Warning` rows apply.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The suite reads committed files only, defines the threshold once in `$script:DefaultPageThreshold`, uses `Join-Path` with forward-slash relative paths, and removes its four helpers in `AfterAll`. It does not write a file, read a clock, or start a process.
- The section extractor is a pure function over text with ordinal token checks; it collapses whitespace so a hard line wrap cannot break a pin.
- The wave check pins marker order, each id once in the whole section, each id inside its own wave segment, and no id in the foundation segment.
- The ownership check pins the six family-record field names as absent, which enforces the rule that the skill does not restate the family record.

#### API and safety notes

- Helper names use the approved verb `Get`. `#Requires -Version 7.0` and the Pester module requirement are present. No `Invoke-Expression`, no global state beyond `$script:` rows.
- Standard check includes a byte-identity assertion between the source and the Codex bundle copy.

#### Error handling and logging

- Helpers return `$null` for a missing section, and every row asserts the section exists before token checks, so a missing heading fails with a reason and not with a null-reference error.

### Skill text audit (Markdown)

- Routing, wave order, dispatch, and receipt statements match `spec.md` "Required content of `## Epic-Scale Routing`" items 1 to 5 in order and content. Waves: Wave 0 foundation owns no family id; Wave 1 `architecture`, `adr`, `reference`, `product-overview`, `getting-started`; Wave 2 `user-guides`, `administration`, `security`; Wave 3 `operations`, `service-management`. All ten default family ids appear once.
- The section contains none of the six family-record field names; ownership names docs-family-profile-model, and docs-complete family semantics are cited to docs-family-gate-and-ia. Wording is neutral and literal; tonality is compliant.
- Generated copies: the `.claude` skill differs from the `.agents` source only in the pre-existing substitution spans (the prerequisites sentence and the agent-link lines), and `documentation-workflow.substitutions.json` is not in the diff. The Claude bundle copy is byte-equal to the `.claude` copy. The Codex bundle copies of the skill, the standard, and the brief have SHA-256 values equal to their `.agents` sources.

---

## Test Quality Audit

The contract suite fails before the skill edit (`evidence/regression-testing/epic-routing-fail-before.2026-11-24T13-04.md`, EXIT_CODE 1) and passes after (`phase-gate.P2.2026-11-24T14-03.md`, 34 of 34 rows). The final parallel Pester gate is clean at the head (29966 testcase elements, 0 failures) and the pytest gate is unchanged (17104 passed).

### Reviewed test and QA artifacts

- `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1` - pins AC-1 to AC-9 and AC-12 in every copy; no gap that blocks.
- `.dev/active/1223-docs-epic-scale-routing/evidence/qa-gates/final-qc-pester.2026-11-24T14-33.md` - full suite at 8 workers, exit 0.
- `.dev/active/1223-docs-epic-scale-routing/evidence/qa-gates/final-qc-pytest.2026-11-24T14-45.md` - full pytest including the push-down and pack-manifest contract tests and the brief contract tests.
- `.dev/active/1223-docs-epic-scale-routing/evidence/qa-gates/final-qc-parity.2026-11-24T14-50.md` - generator `-Check` clean and a diff-name listing paired with `git status --porcelain`.
- `.dev/active/1223-docs-epic-scale-routing/evidence/qa-gates/phase-gate.P1.2026-11-24T13-16.md` and `phase-gate.P2.2026-11-24T14-03.md` - targeted phase gates with the recorded owner waiver of 2026-11-23, accepted.

### Quality assessment prompts

- **Determinism:** committed-file reads only; no clock, process, or network.
- **Isolation:** one behavior per `It`, expanded over the copy rows.
- **Speed:** a text-only suite; the 798 s figure belongs to the full gate.
- **Diagnostics:** `-Because` messages name the token and the copy.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected; text and test only. |
| No unsafe subprocess or command construction | PASS | The suite starts no process. |
| Input validation at boundaries | N/A | No runtime input. |
| Error handling remains explicit | PASS | Null-section guard in every row. |
| Configuration / path handling is safe | PASS | Paths resolve from `$PSScriptRoot` with `Join-Path`; no absolute path is encoded. |

---

## Research Log

No external research was required. The research record `research/research.2026-11-23T05-50.md` of the feature folder supplied decisions D1 to D4.

---

## Verdict

The change is ready for normal pull request flow into the integration branch. All 13 spec acceptance criteria and all 8 user-story criteria are satisfied on inspected evidence; the generated and Codex bundle copies match generator output and the `.agents` sources; no scope-guard file changed. The two Minor findings and two Nits are optional wording and pin-tightening items and do not block.
