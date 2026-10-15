# Research — Issue #903 Part P7: Evidence Filename and `Timestamp:` Time Zone

- Issue: #903 (bug, work mode `minor-audit`), part P7
- Branch: `bug/round-2-review-nits-and-evidence-timestamps-903` (based on `origin/main` 2ef8d361e)
- Feature folder: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`
- Filename stamp time zone: UTC.
- Clock disclosure: this research agent had only Read, Grep, Glob, and Write tools and could not read the host clock. The filename stamp `2026-10-11T15-05` (UTC) is an estimate derived from the plan file stamp `plan.2026-10-11T10-39.md` (America/New_York, see Q3) plus elapsed session time. It is not a clock reading. The plan should not treat it as one.

All line numbers below were verified against the current worktree tree with Read/Grep during this session.

## Summary of Findings

1. The canonical rule in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:49` specifies that the internal `Timestamp` value is *local* time read from the host clock. It says nothing about the filename stamp. Because "local" depends on the host, `sh`/WSL commands (`date`, which defaults to UTC) and PowerShell `Get-Date` (Windows local, -04:00) produce different zones. #849 evidence shows both in one feature folder.
2. No skill, persona, or prompt tells planners to fix a plan-time stamp in evidence filenames. Planners do it on their own initiative, and many recent plans state it explicitly as a convention. Three rules push them toward it: the requirement for explicit file paths (`.claude/agents/atomic-planner.md:53`), "No placeholders in an asserted token" (`.claude/skills/atomic-plan-contract/SKILL.md:204`), and "Fix the evidence in the plan" (`.claude/skills/atomic-plan-contract/SKILL.md:213`). Executors then follow the paths verbatim because they "execute ... exactly as written" (`.claude/agents/atomic-executor.md:41`, `.github/codex/execute-hard-lock.prompt.md:5`).
3. No validator parses the internal `Timestamp:` value beyond requiring it to be non-empty. Two filename parsers require the exact `yyyy-MM-ddTHH-mm` shape with no zone suffix, so the filename shape must not change.
4. The blast-radius rationale that some plans give for fixed stamps is not needed. Every radius already contains `<feature-folder>/**` (`scripts/dev_tools/compute_blast_radius.py:327`, `:456-473`).
5. Scope exclusion: the review-artifact set (`policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`) must share one filename stamp, enforced by `.claude/hooks/validate-feature-review-coverage.ps1:412-425`. Plan files are stamped by tooling in America/New_York. The write-time rule must cover only `<FEATURE>/evidence/<kind>/` artifacts.

## Q1 — Canonical Rule, Mirrors, and Parity Enforcement

### Copies (six; see Numeric Derivation Evidence)

| Path | Lines | Rule line(s) |
|---|---|---|
| `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (canonical) | 180 | `## ISO-8601 Timestamp Format` at 44; format at 46-47; zone/source sentence at 49 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | 180 | 44, 46, 49 (byte mirror) |
| `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` (Codex counterpart) | 181 | 46, 48, 51 (has an extra research-output line at 35) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md` | 181 | 46, 48, 51 |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` (Copilot counterpart) | 152 | 17, 19, 22 (no `## Non-Overridable Authority` section) |
| `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md` | 152 | 17, 19, 22 |

The `## ISO-8601 Timestamp Format` section and its sentence are identical in all six. Verbatim current text:

> The `Timestamp` value is local time read from the host system clock when the recorded command runs (for example `Get-Date -Format yyyy-MM-ddTHH-mm`); the agent never composes or estimates it.

There is no `.codex/` copy of the skill. `.codex/agents/*.toml` personas reference `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` (for example `.codex/agents/atomic-planner.toml:90`, `.codex/agents/atomic-executor.toml:148`).

Policy documents: no `.claude/rules/*.md` or `.github/instructions/*.md` file states an evidence `Timestamp` zone (Grep for `yyyy-MM-ddTHH-mm|Timestamp:|time ?zone|UTC` across those trees found no evidence-timestamp rule). This change needs no policy-document edit and creates no operator follow-up. Both trees already lean toward UTC elsewhere: `.claude/rules/orchestrator-state.md:64` (`last_updated` is UTC) and `.github/instructions/python-suppressions.instructions.md:486-504` (UP017, `datetime.now(timezone.utc)`).

### Parity enforcement

No generator or sync script copies skills into the bundle. `extensions/drm-copilot/package.json:101-118` exposes push-down commands that deliver the bundle *to* destinations, not commands that refresh it. Mirrors are copied by hand and enforced by tests:

- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:44-48` (`EVIDENCE_SKILLS`) and `:84-86` (`MIRROR_PAIRS`) with `test_edited_surface_matches_bundled_mirror` at `:409-423`: byte identity for all three evidence-skill source/bundle pairs.
- The same file pins the current zone sentence: `TIMESTAMP_SOURCE_BLOCK` at `:89-93`, asserted by `test_evidence_skill_states_timestamp_system_clock_source` at `:395-406`. **This test fails as soon as the sentence changes, so it must be updated in the same change.**
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`): every distributable `.claude/**` file must be byte-identical in the Claude bundle.
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:24-61`: `.agents` shared skills (both target skills listed at `:26`, `:29`) must equal the Codex bundle. It is guarded by a `skipif` at `:11-15` whose reason ("gitignored and unavailable in CI") is out of date: `.gitignore:64-71` no longer ignores `.agents`/`.codex`.
- `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py:9-40, 64-69`: `.github/skills/atomic-plan-contract/SKILL.md` must equal its bundle mirror.

What a skill change requires: edit each root copy, copy it byte-for-byte to its bundle mirror, and update the pinned `TIMESTAMP_SOURCE_BLOCK`. No hash or manifest regeneration is needed. `pack-manifests/core.json` files list paths only (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:89,112`; `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json:9,16`), and those paths do not change.

## Q2 — Source of Plan-Time Evidence Filenames

### Guidance surfaces (none mandates a plan-time stamp)

- `.claude/agents/atomic-planner.md` (74 lines): preloads `atomic-plan-contract` and `evidence-and-timestamp-conventions` (`:15-16`). It requires "explicit file paths" (`:53`) and says nothing about filename timestamps.
- `.claude/skills/atomic-plan-contract/SKILL.md` (247 lines): evidence location clause at `:92-98`, with no filename-stamp rule. `:204` forbids placeholders in *asserted tokens* ("Substitute the concrete value"), and `:213` says "Fix the evidence in the plan; never leave the executor to select it." Planners read these two rules as a reason to bake a literal stamp into every evidence path.
- `.claude/agents/atomic-executor.md` (136 lines): "execute an implementation plan ... exactly as written" (`:41`) and "Execute tasks in the exact order written" (`:47`). Preloads both skills (`:27-28`).
- `.github/codex/execute-hard-lock.prompt.md:5` ("Execute an atomic_planner plan exactly as written"). This is the template resolved by `scripts/dev_tools/resolve_hard_lock_prompt.py:48` (searched under `.github/codex/` at `:81`). `.claude/skills/execute-hard-lock/SKILL.md:74` defers artifact paths to `evidence-and-timestamp-conventions`.
- `.github/prompts/generate-atomic-plan.prompt.md` (the atomic-plan prompt) contains no `timestamp` or `evidence` text.
- `docs/features/templates/{bug,feature,refactor}/plan.yyyy-MM-ddTHH-mm.md` contain no `timestamp` or `evidence` text.
- `.github/agents/atomic_planning.agent.md:166` lists `Timestamp: <ISO-8601>` only. `.github/agents/atomic_executor.agent.md:3` says "Execute ... verbatim".

### Plan samples showing the pattern

- #849, `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md:23`: "Evidence file names carry the fixed artifact-set stamp `2026-10-09T01-33` (this plan cycle's identifier) so every written path is enumerable in advance for the run planner's blast-radius extraction." Task `:376` (`[P9-T5]`) hard-codes `evidence/qa-gates/diff-scope.2026-10-09T01-33.md`. The written evidence files carry internal `Timestamp:` values `2026-10-10T09-49` … `2026-10-10T10-45` (local -04:00) alongside `2026-10-10T14-26` … `2026-10-10T15-17` (UTC; the commit was 11:07-04:00 = 15:07 UTC). For example `evidence/baseline/ps-format.2026-10-09T01-33.md:3` (`09-57`) versus `evidence/other/follow-up-parallel-add.2026-10-09T01-33.md:3` (`15-17`).
- #841, `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md:103`: "Evidence filenames carry the plan-time timestamp `2026-10-08T22-17` so every name is fixed before execution".
- #846, `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md`: the composed stamp `2026-10-09T09-00` occurs 189 times, for example `:855` (`evidence/qa-gates/ac-status.2026-10-09T09-00.md`). The stamp matches neither the plan stamp nor any write time (internal values run `2026-10-09T20-57` … `22-04`).
- Counter-example and precedent for the fix: #847, `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md:35`: "**TS** = the execution timestamp ... at the moment an artifact is written. Evidence file names below carry `<ts>` in that position." Its evidence filenames carry distinct write-time stamps (for example `evidence/qa-gates/targeted-hosttooling.2026-10-09T23-51.md`, `targeted-publish.2026-10-10T00-41.md`). The placeholder form already works end to end.

Other plans with the fixed-stamp convention (Grep on `docs/features/**/plan*.md`): #744 `plan.2026-09-30T03-18.md:22`, #519 `plan.2026-08-23T23-22.md:18`, #675 `plan.2026-09-13T20-49.md:40`, #670 `plan.2026-09-13T20-46.md:21`, #559 `plan.2026-08-25T22-07.md:35`. #744 also documents the zone source as `date +%Y-%m-%dT%H-%M`, which reads UTC under WSL/sh. That is the mechanism that produces the mixed zones.

### Why the fixed-stamp rationale no longer holds

- Blast radius: `scripts/dev_tools/compute_blast_radius.py:327` always adds `_feature_folder_glob(...)`, which returns `docs/features/active/<folder>/**` (`:456-473`). Evidence paths under the item's own feature folder are therefore covered whatever their filenames are. Placeholder tokens are ignored by extraction (`scripts/dev_tools/_blast_radius_token_shapes.py:76`, `scripts/dev_tools/_blast_radius_extraction.py:293`).
- Plan gates: `scripts/dev_tools/plan_gate_coverage.py:45-68,165` and `scripts/dev_tools/plan_gate_discrimination.py:228` skip placeholder-bearing values. A `<timestamp>` path in task prose is not a blocking finding.
- `atomic-plan-contract` `:204` applies to *asserted search tokens*, not to artifact paths. `:213` is satisfied by a mechanical derivation ("state the mechanical derivation that produces them"). With UTC stamps, "the lexicographically greatest file matching `<name>.*.md`" is such a derivation, because the fixed-width UTC shape sorts in chronological order.

## Q3 — Time-Zone Choice and Parser Impact

### Consumers of the internal `Timestamp:` value

- Python: `scripts/dev_tools/pr_context/verification_evidence.py:22` (`REQUIRED_FIELDS`). The value is parsed with `split(":", 1)` (`:128`), so a value containing colons is kept intact. The only check is non-empty (`:140`). The value is echoed verbatim at `scripts/dev_tools/pr_context/collector_documents.py:105`.
- TypeScript: `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:27,153`, echoed at `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:124`.
- No `scripts/dev_tools/validate*.py` file references `Timestamp`. No hook parses an evidence `Timestamp:` line.

Conclusion: any zone, with or without a suffix, parses. Historical artifacts already use `2026-10-01T23:25:00-04:00` (for example `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/regression-testing/repro-python.2026-09-29T18-45.md:3`) and still render.

### Parsers of filename stamps (must keep the bare `yyyy-MM-ddTHH-mm` shape)

- `.claude/hooks/validate-feature-review-coverage.ps1:118`: `(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}-\d{2})\.md$` for review artifacts. `:412-425` requires `code-review`, `feature-audit`, and `remediation-inputs` to share the policy-audit stamp.
- `.claude/hooks/validate-task-researcher-output.ps1:97`: research filename pattern.
- `.claude/hooks/enforce-feature-folder-order.ps1:55,148`: plan filename pattern.
- `scripts/dev_tools/_parallel_drift_shape.py:47` and `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1:57`: checkpoint values in the same canonical shape.
- `scripts/dev_tools/pr_context/feature_docs.py:88,187`: lexicographic ordering of `plan.<timestamp>.md`.
- `.claude/hooks/enforce-evidence-locations.ps1` checks only the folder (`:107`), not the filename stamp.

No parser reads an evidence filename's stamp. A zone suffix (for example `Z`) in filenames would break the shared shape, so the zone must be stated by rule, not encoded in the filename.

### Existing zone conventions in tooling

- UTC: `scripts/dev_tools/parallel_drift_detection_cli.py:151` ("UTC is used rather than local time so two machines evaluating the same commit produce comparable values"), `scripts/dev_tools/pr_context/summary_helpers.py:407`, `.claude/rules/orchestrator-state.md:64`.
- America/New_York: feature-folder and plan stamps (`scripts/dev_tools/new_active_feature_folder_models.py:112-121`, `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts:324-347`).

### Recommendation

Use UTC for both the evidence filename stamp and the internal `Timestamp:` value, in the unchanged `yyyy-MM-ddTHH-mm` shape with no suffix, and state the zone in the skill. Reasons:
- It does not depend on the host. The mixing comes from `sh`/WSL `date` reading UTC while Windows `Get-Date` reads local time, and only an explicit UTC read gives the same value on both.
- The fixed-width UTC shape sorts lexicographically in chronological order, which supports the "greatest match" derivation.
- No parser changes are needed.

Clock commands to name in the skill:
- PowerShell 7: `Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`
- Windows PowerShell 5.1 fallback: `(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm')`
- POSIX: `date -u +%Y-%m-%dT%H-%M`
- Python: `datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M")`

Rejected alternative: America/New_York, to match plan stamps. Expressing it requires zone-database names that differ between Windows and IANA, and an unset `TZ` in sh falls back to UTC, which recreates the mixing. Plan and feature-folder stamps are out of scope and stay America/New_York. The skill should say so explicitly so that readers do not compare the two.

## Q4 — Contract-Test Patterns and Placement

Existing patterns (pytest, documentation contracts under `tests/scripts/dev_tools/`):
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: section-scoped fragments via `extract_section` + `collapse_whitespace` (`:114-136`), parametrized over the three skill copies (`:370-406`), and byte-identity mirror pairs (`:409-423`).
- Shared helpers: `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` (`read_repo_text` `:73`, `collapse_whitespace` `:114`, `extract_section` `:278`). `extract_section` ends a section only at the next `## ` line (`:305-307`), so a `###` subsection is included in its parent section.
- Pester and TypeScript tests reference the skill paths only as blast-radius fixtures (`tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:392`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts:107`). None pins the skill text.

Placement: create `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py`. Documentation-contract tests in this repo live in `tests/scripts/dev_tools/` (for example `test_completion_gate_documentation_contracts.py`, `test_minor_audit_acceptance_criteria_contracts.py`). A new module avoids pushing the existing 423-line file toward the 500-line limit and avoids widening same-file overlap with #899 (see Q6).

Proposed tests (Arrange–Act–Assert, no temp files, no processes):
1. `test_evidence_skill_states_utc_timestamp_source`, parametrized over the three `EVIDENCE_SKILLS`. The `## ISO-8601 Timestamp Format` section contains the new UTC sentence.
2. `test_evidence_skill_omits_local_time_wording`, parametrized. The same section does not contain `local time`. This is the negative assertion that keeps the old rule from coming back.
3. `test_evidence_skill_requires_write_time_filename_stamp`, parametrized. The section contains the filename-rule fragments, including the scope exclusions (review set and plan files) and the "not renamed" statement.
4. `test_atomic_plan_contract_forbids_plan_time_evidence_stamp`, parametrized over the three `atomic-plan-contract` copies. The new section contains the planner rule fragments.
5. `test_atomic_plan_contract_matches_bundled_mirror`, parametrized over the three `atomic-plan-contract` source/bundle pairs. Byte identity is asserted unconditionally, which closes the gap left by the `skipif` in `test_codex_handoff_contract_parity.py:11-15` for the `.agents` copy.

Update in place: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:89-93` (`TIMESTAMP_SOURCE_BLOCK`) to the new UTC sentence. Alternatively, move that constant and its test (`:395-406`) into the new module. The plan should choose one option, not both.

Single-line tokens for plan acceptance greps (short, no placeholder markers, no `%`, no backslash):
- `### Evidence Filename Timestamp` (a heading line, which cannot wrap)
- `` `Timestamp` value is UTC ``
- `never a plan-time stamp`
- `are not renamed`

Do not grep for the `date -u +%Y-%m-%dT%H-%M` example. It contains `%`, so the plan gate treats it as a placeholder and the grep gates nothing (`.claude/skills/atomic-plan-contract/SKILL.md:204`). Pytest fragment assertions with `collapse_whitespace` are wrap-tolerant and should carry the full sentences.

## Q5 — Line Counts (500-line limit)

| File | Current lines | Expected delta | Within limit |
|---|---|---|---|
| `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (+ bundle) | 180 | about +12 | yes |
| `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` (+ bundle) | 181 | about +12 | yes |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` (+ bundle) | 152 | about +12 | yes |
| `.claude/skills/atomic-plan-contract/SKILL.md` (+ bundle) | 247 | about +6 | yes |
| `.agents/skills/atomic-plan-contract/SKILL.md` (+ bundle) | 202 | about +6 | yes |
| `.github/skills/atomic-plan-contract/SKILL.md` (+ bundle) | 187 | about +6 | yes |
| `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` | 423 | 0 to +2 | yes |
| `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` (new) | 0 | about 150-200 | yes |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` (imported, unchanged) | 465 | 0 | yes |

The Markdown files are exempt from the limit in any case, but all of them stay below it.

## Q6 — Overlap Guard

- #900 (scratch-file guidance in orchestration skills and the `atomic-planner` persona): no scratch-file text exists today in `.claude/agents/*.md` or any `SKILL.md` (Grep `(?i)scratch` returned no matches). P7 recommends **no** edit to `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.codex/agents/*.toml`, or any orchestrate skill. Personas preload both target skills (`.claude/agents/atomic-planner.md:15-16`, `.claude/agents/atomic-executor.md:27-28`, `.codex/agents/atomic-planner.toml:29`, `.codex/agents/atomic-executor.toml:41`), so a skill-only change reaches them. There is no adjacency.
- #899 (CI-gate passages): the P7 edits are in `## ISO-8601 Timestamp Format` (evidence skill) and in a new section after `## Non-Overridable Evidence Path Clause` (atomic-plan-contract). Neither is next to a CI-gate passage. The one shared file is `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: P7 touches only `:89-93` (or `:395-406` if moved), while the CI-gate tests are at `:139-239`. The hunks are separate, but blast radius will report `same_file`. The plan should sequence or flag it.
- #901 (pr-author hook family): no overlap. P7 touches no hook.

Insertion points:
- Evidence skill: replace the zone sentence (`.claude` `:49`, `.agents` `:51`, `.github` `:22`) and add `### Evidence Filename Timestamp` immediately after it, inside `## ISO-8601 Timestamp Format` and before `## Canonical Evidence Locations` (`.claude` `:51`, `.agents` `:53`, `.github` `:24`).
- atomic-plan-contract: add `## Evidence Filename Timestamps in Plans`. In `.claude` it goes after `:105`, before `## Coverage Evidence Contract` at `:107`. In `.agents` it goes before `:120`. `.github` has no evidence-path clause, so it goes before `## Coverage Evidence Contract` at `:105`.

## Q7 — Verification Commands

Python (test files only; no production Python changes):
- `poetry run black --check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
- `poetry run ruff check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
- `poetry run pyright tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
- Targeted: `poetry run pytest tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py -q`
- Full suite for the toolchain loop: `poetry run pytest -q`
- Expect-fail evidence: run test 1-4 of the new module before the skill edits (`ExpectedExitCode: 1`), then after (`EXIT_CODE: 0`).

TypeScript: no TypeScript file changes. As an optional regression check that the bundle remains loadable, run from `extensions/drm-copilot`: `npx jest test/lib/push-down`. `npx prettier`/`eslint`/`tsc` are not needed.

PowerShell/bats: no `.ps1` or `.sh` changes are recommended, so `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test` do not apply. If the plan chooses to touch a hook (not recommended), verify only through the PoshQC MCP tools plus CI evidence, never through sh/bash/pwsh wrappers.

Markdown: there is no Markdown formatter in the seven-stage loop for these files. Byte identity of source and bundle is checked by the pytest mirror tests above.

## Automation Feasibility

The change is fully automatable. Every change is a text edit plus a byte copy to a bundle mirror, verified by deterministic pytest contract tests that read committed files. No human-only step, external service, clock-dependent assertion, or manual rename is involved (existing misdated files are explicitly not renamed). The executor's own evidence for this item will follow the new rule. That requires a UTC clock read through a tool on the executor's allowlist: `Bash(pwsh *)` at `.claude/agents/atomic-executor.md:19` with `pwsh -NoProfile -Command "Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm"`. Per repository memory, a worktree text guard may refuse `pwsh` strings. In that case `sh -c 'date -u +%Y-%m-%dT%H-%M'` is the alternative. The plan should name both.

## Numeric Derivation Evidence

### Claim N1: the evidence skill has exactly 6 copies to edit

- Complete Family: every `SKILL.md` whose frontmatter name is `evidence-and-timestamp-conventions`, across root runtime surfaces and extension bundles.
- Exhaustive Search Scope: whole worktree excluding `docs/**`, `virtual/**`, `node_modules/**`.
- Inclusion Rules: file named `SKILL.md` under an `evidence-and-timestamp-conventions/` directory, or a file whose frontmatter line is exactly `name: evidence-and-timestamp-conventions`.
- Exclusion Rules: feature-folder evidence, historical fixtures, debug artifacts under `virtual/`.
- Primary Search Strategy or Query Expression: Glob `**/evidence-and-timestamp-conventions/**`.
- Primary Member Set: `.agents/skills/…/SKILL.md`; `.claude/skills/…/SKILL.md`; `.github/skills/…/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/…/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/…/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/…/SKILL.md`.
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: Grep `^name: evidence-and-timestamp-conventions$` (files_with_matches) with the scope exclusions above.
- Cross-check Member Set: the same six paths.
- Cross-check Count: 6
- Member-set Comparison: identical after normalizing path separators. A third independent signal agrees: Grep `local time` listed exactly these six `SKILL.md` files among its 10 matches (the other four are non-skill files).

### Claim N2: atomic-plan-contract has exactly 6 copies to edit

- Complete Family: every `SKILL.md` whose frontmatter name is `atomic-plan-contract`.
- Exhaustive Search Scope: as N1.
- Inclusion Rules: as N1 with `atomic-plan-contract`.
- Exclusion Rules: as N1.
- Primary Search Strategy or Query Expression: Glob `**/atomic-plan-contract/SKILL.md`.
- Primary Member Set: `.agents/skills/atomic-plan-contract/SKILL.md`; `.claude/skills/atomic-plan-contract/SKILL.md`; `.github/skills/atomic-plan-contract/SKILL.md`; the three bundle mirrors under `claude-customizations/.claude`, `codex-and-agents-customizations/.agents`, `customizations/.github`.
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: Grep `^name: atomic-plan-contract$` (files_with_matches).
- Cross-check Member Set: the same six paths.
- Cross-check Count: 6
- Member-set Comparison: identical.

Both counts may be used in acceptance criteria as "six copies" with the listed member sets.

## Recommended Approach

Make the rule in the skills the authority, scoped to `<FEATURE>/evidence/<kind>/` artifacts, with UTC as the single stated zone. Tell planners to write `<name>.<timestamp>.md` (placeholder) and to identify consumed evidence by the mechanical "greatest `<name>.*.md`" derivation. Pin all of this with a new pytest contract module.

Draft text for the evidence skill (`## ISO-8601 Timestamp Format`, replacing the zone sentence):

> The `Timestamp` value is UTC read from the host system clock when the recorded command runs (for example `Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`, `(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm')`, or `date -u +%Y-%m-%dT%H-%M`); the agent never composes or estimates it. No zone suffix is written.
>
> ### Evidence Filename Timestamp
>
> The stamp in the filename of every artifact under `<FEATURE>/evidence/<kind>/` is the UTC time at which that file is written, read from the host clock immediately before the write. It is never a plan-time stamp, a plan-cycle identifier, or any other value fixed in advance. A plan names such an artifact `<name>.<timestamp>.md`; the executor substitutes the write time. A later loop pass writes a new file with a new stamp. A task that consumes an evidence artifact selects the lexicographically greatest file matching `<name>.*.md`. Plan files (`plan.<timestamp>.md`, stamped by the feature-folder tooling in America/New_York) and the review artifact set (`policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`, which share one stamp) are outside this rule. Existing evidence files whose names carry a plan-time stamp are not renamed.

Draft text for atomic-plan-contract (new `## Evidence Filename Timestamps in Plans`):

> Plans name evidence artifacts as `<name>.<timestamp>.md` and never fix a plan-time stamp in an evidence filename. Acceptance conditions identify a consumed artifact by the derivation in `evidence-and-timestamp-conventions` (`### Evidence Filename Timestamp`), not by a pre-stamped literal path. This does not relax the single-line token rule: asserted search tokens remain concrete.

### Rejected alternatives

- Keep the plan-cycle stamp and only document it as an identifier: rejected because the issue requires write-time filenames.
- Stamp-free evidence filenames: rejected because it conflicts with the skill's `yyyy-MM-ddTHH-mm` rule at `:46` and loses loop-pass history.
- Encode the zone in the filename (`…T15-05Z`): rejected because it breaks the shared filename shape parsed at `.claude/hooks/validate-feature-review-coverage.ps1:118` and related patterns.
- Edit planner/executor personas (Claude, six Codex planner variants, six executor variants, Copilot agents): rejected because the personas already preload both skills, the edit would fan out to many files, and it would overlap #900.

## Recommended Change List

| # | File | Change | Test |
|---|---|---|---|
| 1 | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Replace `:49` with the UTC sentence; add `### Evidence Filename Timestamp` before `:51` | new module tests 1-3; existing mirror test |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Byte copy of #1 | `test_edited_surface_matches_bundled_mirror[claude-evidence]`; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| 3 | `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` | Same edit at `:51` / before `:53` | new module tests 1-3 |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md` | Byte copy of #3 | `[agents-evidence]` mirror test |
| 5 | `.github/skills/evidence-and-timestamp-conventions/SKILL.md` | Same edit at `:22` / before `:24` | new module tests 1-3 |
| 6 | `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md` | Byte copy of #5 | `[github-evidence]` mirror test |
| 7 | `.claude/skills/atomic-plan-contract/SKILL.md` | Add `## Evidence Filename Timestamps in Plans` before `:107` | new module tests 4-5; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| 8 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | Byte copy of #7 | new module test 5 |
| 9 | `.agents/skills/atomic-plan-contract/SKILL.md` | Same section before `:120` | new module tests 4-5 |
| 10 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | Byte copy of #9 | new module test 5; `test_shared_codex_skills_match_repo_agent_skill_sources` |
| 11 | `.github/skills/atomic-plan-contract/SKILL.md` | Same section before `:105` | new module tests 4-5 |
| 12 | `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | Byte copy of #11 | new module test 5; `test_minor_audit_customization_mirrors_match_root_contracts` |
| 13 | `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` | Update `TIMESTAMP_SOURCE_BLOCK` (`:89-93`) to the UTC sentence | itself |
| 14 | `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` (new) | Tests 1-5 above | itself (expect-fail before #1-#12) |

## Files That Must Not Be Touched

- `.claude/rules/**` and `.github/instructions/**` (policy documents; no change required).
- `.github/copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`.
- Existing evidence files under any `docs/features/**/evidence/**` (no renames, per the issue).
- Existing plans `docs/features/**/plan*.md` of other items.
- `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.codex/agents/*.toml`, `.github/agents/*.agent.md` and their bundle mirrors (persona fan-out; #900 overlap).
- Orchestration skills (`.claude/skills/orchestrate/**`, `.claude/skills/parallel-orchestrate/**`, `.agents/skills/orchestrate/**`) and their CI-gate passages (#899/#900).
- `.claude/hooks/**`, `.codex/hooks/**`, including `validate-feature-review-coverage.ps1` and the pr-author hook family (#901).
- `scripts/dev_tools/pr_context/**`, `extensions/drm-copilot/src/lib/pr-context/**` (parsers need no change).
- `scripts/dev_tools/new_active_feature_folder_models.py`, `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts` (plan stamps stay America/New_York; out of scope).
- `config/blast-radius.json`, `pack-manifests/*.json` (paths unchanged).
- `.github/codex/execute-hard-lock.prompt.md`, `.github/prompts/generate-atomic-plan.prompt.md`, `docs/features/templates/**` (no change required).
