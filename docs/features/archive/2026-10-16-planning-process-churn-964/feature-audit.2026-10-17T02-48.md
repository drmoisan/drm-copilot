# Feature Audit: Planning-Process Churn (#964)

---

**Audit Date:** 2026-10-17
**Feature Folder:** `docs/features/active/2026-10-16-planning-process-churn-964`
**Base Branch:** `main`
**Head Branch:** `bug/planning-process-churn-964`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `b8fcd7790`)
- **Head branch/commit:** `bug/planning-process-churn-964` (commit `1f017bd4b`)
- **Merge base:** `b8fcd7790` (equal to the `origin/main` tip; the branch is current with `main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-17 02:37 UTC at head `1f017bd4b`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-16-planning-process-churn-964/evidence/**` (61 files)
  - Additional evidence: check-only re-runs by this review at head (generator `--check`, 280 Python tests, three Jest suites with 36 tests, tier check, coverage-threshold check, plan validator, evidence-location validator, 82-pair byte-parity check) and a re-parse of `artifacts/python/coverage-964-qa.json`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`
- **Feature folder used:** `docs/features/active/2026-10-16-planning-process-churn-964`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the sole acceptance-criteria source.
- **Scope note:** full branch diff from the merge base (260 added or modified files). AC-33 is orchestrator-owned and in progress (`evidence/other/replan-962/` holds an untracked `spec.md` and `plan.md`, no `summary.<timestamp>.md` yet). AC-34 is CI-dependent and is checked off by the item's orchestrator at S9. Both are classified as pending and are not evaluated as FAIL. Pester could not be executed by this review agent; Pester-verified criteria rely on the on-disk JUnit and coverage XML, both written after the last commit that touched `.claude/hooks/` or `tests/scripts/claude-hooks/`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-16-planning-process-churn-964/spec.md` — only source

### Acceptance criteria

1. AC-1: `.claude/skills/execution-environment/SKILL.md` exists with every required heading listed in Design scope item 1, and the `plan_gate_document` G11 and G12 evaluators report no finding on its text. Verified by `test_execution_environment_brief_contracts.py`.
2. AC-2: The brief states the worktree isolation guard as Claude Code runtime behavior separate from repository hooks, states that `atomic-executor` has no PowerShell tool and names the PoshQC MCP and `sh` launcher routes, and states that PoshQC MCP results carry no output and where counts come from. Verified by `test_execution_environment_brief_contracts.py`.
3. AC-3: The brief's `## Batch Budget` section states the direct-mode cap, the denial codes, the large/remediation/preparation exemption, that bundle copies count, that in-root scratch `.ps1` files count and `SCRATCH` files do not, and that Bash- or generator-written files are not seen. Verified by `test_execution_environment_brief_contracts.py`.
4. AC-4: The brief's `## CI Shape and Required Checks` names the Linux hook-suite job, the PoshQC shard jobs with the `poshqc / PowerShell QC` aggregator, `merge_group`, and each ruleset 15241672 required context listed in Design scope item 1. Verified by `test_execution_environment_brief_contracts.py`.
5. AC-5: All copies listed under Mirror and Parity Obligations are byte-identical, both pack manifests list the skill, and `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` and both pack-manifest completeness tests pass.
6. AC-6: `task-researcher`, `atomic-planner`, `atomic-executor` and `orchestrator` preload `execution-environment` through `skills:`; the Codex base agents named in the File Inventory list it; the Copilot base agents named in the File Inventory reference it; orchestrate `## Prerequisites` references it; `docs/engineering/claude-code-architecture.md` has a mirror-table row; `.claude/agents/epic-orchestrator.md` is unchanged. Verified by `test_execution_environment_brief_contracts.py` and the generator `--check`.
7. AC-7: `.claude/agents/task-researcher.md` declares `skills:` containing `evidence-and-timestamp-conventions` and `execution-environment`, and its `tools:` no longer lists a skill name; `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` passes.
8. AC-8: G11 reports one Blocking finding per prose, path and anchor form match, and none for `500 lines`, inline-code quotations in prose form, URLs with ports, or fenced blocks. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
9. AC-9: G12 reports full and abbreviated SHAs in prose and inline code, and none for decimal IDs, all-letter hex words, UUID segments, `-`/`_`-joined suffixes, SHA-256 digests, or fenced blocks. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
10. AC-10: G13 fires above 40 tasks or above 400 lines without a non-empty `## Size Justification`, does not fire at the thresholds, and does not fire above them when a non-empty justification is present; an empty justification section does not exonerate. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
11. AC-11: `evaluate_plan_gates` and `evaluatePlanGates` run G11 to G13 after G10; Python and TypeScript produce byte-identical messages for the parity rows, `G11_SEVERITY`, `G12_SEVERITY` and `G13_SEVERITY` are Blocking in both, and the new modules contain no `repr(`, `!r` or `pythonRepr(`. Verified by `test_plan_gate_document_parity.py` and `plan-gate-document-parity.test.ts`; all existing plan-gate tests pass unchanged.
12. AC-12: `.claude/rules/plan-acceptance-gates.md` and its bundle copy state G1 through G13 with severity sections, false-positive classes and the corpus-measurement note, and are byte-identical. Verified by `test_plan_gate_document_docs.py` and the updated `test_plan_gate_scratch_docs.py`.
13. AC-13: `atomic-plan-contract` (Claude, `.agents`, `.github` and bundle copies) contains `## Design-Level Plan Contract (Mandatory)`, uses symbol, heading or test locators in the self-review and internal-review record, and states G1 through G13 under `## Validator Gate (Mandatory)`. Verified by `test_plan_gate_document_docs.py`.
14. AC-14: `validate-planner-output.ps1` issues a repairable block for a plan without a valid `## Pre-Mortem` section and for a `CITATION:` line-reference locator, and passes a plan with both correct. Verified by `validate-planner-output.PreMortem.Tests.ps1`; the modified planner suites pass.
15. AC-15: A corpus measurement of G11, G12 and G13 finding counts over committed plans under `docs/`, with observed false-positive classes, is recorded under `evidence/other/`.
16. AC-16: `plan_gate_document.py` and `plan-gate-document.ts` each reach at least 85% line and 75% branch coverage, with a `jest.config.cjs` per-file threshold entry for the TypeScript module, recorded under `evidence/qa-gates/`.
17. AC-17: `Test-IsPreflightRun` classifies a run as preflight when the transcript's first user entry carries the directive, as execution when it does not even if the plan file carries the directive (completion checks then enforced), and falls back to the plan-file or single `PREFLIGHT:` signal check when the transcript is absent or unparseable. Verified by `validate-executor-output.Preflight.Tests.ps1` with in-memory transcript content.
18. AC-18: In a preflight run the executor hook blocks (repairably) zero or multiple `PREFLIGHT:` signals, `ALL CLEAR` with a `PREFLIGHT-DEFECT:` line, `REVISIONS REQUIRED` without one, and `PREFLIGHT-FIX:` without an existing `preflight-fix-record:` path under `docs/features/`. Verified by `validate-executor-output.Preflight.Tests.ps1`.
19. AC-19: `atomic-plan-contract`, `atomic-executor.md` and `atomic-planner.md` (and their mirrors) state one-pass review (keeping "Review the entire plan in one pass"), the trivial/substantive classes, the `PREFLIGHT-FIX:`, `PREFLIGHT-DEFECT:` and `preflight-fix-record:` formats, task-text-only fixes, and that the directive belongs in the delegation prompt and not in plan files. Verified by `test_single_pass_preflight_contracts.py`.
20. AC-20: The at-most-one-return rule and the `validator_failed` halt are stated in orchestrate (preparation and S4 planning) and `atomic-planner.md`; `remediation-handoff-atomic-planner` keeps `preflight.iterations > 1`; `epic-plan` references the single-pass rule. Verified by `test_single_pass_preflight_contracts.py`.
21. AC-21: `.codex/agents/atomic-executor.toml` and `.github/agents/atomic_executor.agent.md` no longer contain loop-until-clear or automatic re-handoff mandates and state the single-pass rules; `test_codex_agent_wrapper_contracts.py` (updated) and `test_codex_handoff_contract_parity.py` pass.
22. AC-22: `atomic-planner` and `atomic-executor` list `mcp__drm-copilot__validate_orchestration_artifacts` in `tools:`, the executor keeps its existing `mcp__drm-copilot__run_poshqc_*` entries and `## Scratch Location` text, and `claude-architecture-doc.Tests.ps1` and `test_scratch_location_contracts.py` pass.
23. AC-23: `Test-PreMortemSection` rejects a missing heading and each missing label, accepts case-insensitive labels and "not applicable" with a reason; both hooks load it with the guarded pattern; the helper and its bundle copy are listed in the Claude pack manifest. Verified by `premortem-section.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1`.
24. AC-24: `validate-task-researcher-output.ps1` requires the section for research under `docs/features/` and not under `docs/research/`; `task-researcher.md` and `research-issue` require the section in feature research. Verified by `validate-task-researcher-output.PreMortem.Tests.ps1` and `test_single_pass_preflight_contracts.py`.
25. AC-25: The bug, feature and refactor plan templates contain a `## Pre-Mortem` skeleton with each label, and `atomic-plan-contract` requires a final-phase self-review task. Verified by `test_single_pass_preflight_contracts.py`.
26. AC-26: Orchestrate `## Pre-Feature-Review Commit` begins with the self-review check (newest `self-review.*.md` exists with no FAIL row, else a proportionate correction). Verified by `test_single_pass_preflight_contracts.py`.
27. AC-27: Orchestrate remediation sections, `remediation-handoff-atomic-planner`, `orchestrator.md`, `feature-review-remediate.md` and their mirrors define `Remediation-Mode: proportionate|design`, the classification rule, the proportionate cycle shape and the conversion to design mode. Verified by `test_single_pass_preflight_contracts.py`.
28. AC-28: The executor hook allows an execution run carrying `BLOCKED at preflight (before [P0-T1])`, a plan delta and no checked task, and keeps every other non-preflight `BLOCKED` non-repairable. Verified by `validate-executor-output.Preflight.Tests.ps1`.
29. AC-29: The full toolchain (format, lint, type-check, architecture, unit, contract, integration) passes for Python, TypeScript and PowerShell in one pass, including the generator `--check`, `test_push_down_issue_824_follow_ups.py` and `test_typescript_toolchain_instruction_contracts.py`, recorded under `evidence/qa-gates/`.
30. AC-30: The seeded shuffled Jest run (seed recorded), reversed-order Python run and single-process Pester run over `tests/scripts` pass, recorded under `evidence/regression-testing/`.
31. AC-31: Every touched non-Markdown file is at or below 500 physical lines, recorded under `evidence/qa-gates/`.
32. AC-32: `evidence/qa-gates/self-review.<timestamp>.md` for this item covers the policy-audit, code-review and feature-audit templates and records no FAIL row before the first review push.
33. AC-33 (orchestrator-owned): `evidence/other/replan-962/spec.md` and `summary.<timestamp>.md` exist; the summary records the source ref, the original and re-plan line and task counts, no G11 or G12 finding, G13 within guideline or a justification present, a passing Python CLI validation, a first preflight of `PREFLIGHT: ALL CLEAR` (in-place fixes permitted), and a re-plan smaller than the original in both lines and tasks. #962's folder is unmodified.
34. AC-34 (pending-CI, orchestrator-owned at S9): every ruleset 15241672 required context succeeds on the final PR head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 brief exists, headings, no G11/G12 | PASS | `.claude/skills/execution-environment/SKILL.md` carries the fourteen headings in order; `test_brief_has_required_headings` and `test_brief_has_no_g11_or_g12_findings` pass at head | `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | 16 tests pass |
| 2 | AC-2 isolation guard, executor route, PoshQC output limits | PASS | `## Command-Text Restrictions` separates the runtime guard from `validate-bash.ps1` and `enforce-parallel-worktree-removal-gate.ps1`; `## Tool Routes by Agent` and `## PowerShell Route and PoshQC MCP Limits` state the route and the JUnit/XML sources | same suite | Brief facts spot-checked against the tree (function names, files) |
| 3 | AC-3 batch budget | PASS | `## Batch Budget` states the three-file cap, both denial codes, route exemption, bundle copies, in-root scratch, `SCRATCH`, and `Write|Edit` matcher | same suite | |
| 4 | AC-4 CI shape and required contexts | PASS | Section names `poshqc / PowerShell hook suites (Linux)`, shard jobs, aggregator, `merge_group`, and the eleven contexts; job names match `.github/workflows/ci.yml` and `_poshqc.yml` at head | same suite; `grep` of workflow files | |
| 5 | AC-5 byte identity and pack manifests | PASS | Six brief copies share one SHA-256; 82 canonical-to-bundle pairs identical; resource-contract and both pack-manifest completeness suites pass | parity script over the diff list; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | |
| 6 | AC-6 preload and references | PASS | Four Claude agents list `execution-environment` under `skills:`; four Codex base TOMLs and four Copilot base agents reference it; orchestrate `## Prerequisites` step 4; architecture doc row; `.claude/agents/epic-orchestrator.md` not in the diff | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` (exit 0); brief contract suite | |
| 7 | AC-7 task-researcher frontmatter | PASS | `skills:` lists both skills; `tools:` holds Read, Grep, Glob, WebFetch and two `Write(...)` entries only | `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file"` | |
| 8 | AC-8 G11 | PASS | `test_g11_reports_prose_path_and_anchor_forms` and `test_g11_ignores_count_phrases_inline_code_prose_url_ports_and_fences` pass in both runtimes | `poetry run pytest tests/scripts/dev_tools/test_plan_gate_document.py`; `npx jest test/lib/validate/plan-gate-document` | Scheme-less host:port class undocumented (code review CR-3, non-blocking) |
| 9 | AC-9 G12 | PASS | Report and ignore cases pass in both runtimes (test renamed to fit the Ruff line limit, recorded in the plan) | same | |
| 10 | AC-10 G13 | PASS | Five G13 cases pass in both runtimes, including thresholds and empty justification | same | |
| 11 | AC-11 ordering, parity, severities, no repr | PASS | Discrimination modules call the document gates after G10; parity suites pass (4 Python, 7 Jest); existing plan-gate tests pass | `poetry run pytest tests/scripts/dev_tools/test_plan_gate_document_parity.py`; `npx jest test/lib/validate/plan-gate-document-parity` | |
| 12 | AC-12 rule file G1 to G13 | PASS | Title, table rows, three severity sections, false-positive classes and the corpus note present; bundle copy identical | `poetry run pytest tests/scripts/dev_tools/test_plan_gate_document_docs.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` | |
| 13 | AC-13 contract design-level section | PASS | `## Design-Level Plan Contract (Mandatory)` in all copies; `CITATION:` locator is symbol, heading or test name; Validator Gate states G1 through G13 | same | Stale Pester job sentence in the same file (CR-2, non-blocking) |
| 14 | AC-14 planner hook | PASS | `validate-planner-output.PreMortem.Tests.ps1` 12 tests, 0 failures; planner Tests 25, Coverage 12, Reentry 9, all 0 failures | JUnit read: `artifacts/pester/pester-junit.xml` | Not re-run by this review (Pester unavailable to the agent) |
| 15 | AC-15 corpus measurement | PASS | `evidence/other/g11-g13-corpus-measurement.2026-10-16T23-46.md` records files scanned, counts per rule, samples, and false-positive classes | file inspection | |
| 16 | AC-16 coverage of new modules | PASS | `plan_gate_document.py` 100.00% / 100.00%; `plan-gate-document.ts` 100.00% / 95.08%; `jest.config.cjs` per-file entry `lines: 85, branches: 75` | re-parse of `artifacts/python/coverage-964-qa.json` and `extensions/drm-copilot/coverage/lcov.info`; `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md` | |
| 17 | AC-17 transcript classification | PASS | Preflight suite cases for directive, text blocks, no directive with stale plan directive (completion checks enforced), absent, unparseable, throwing reader, single-signal fallback; 29 tests, 0 failures | JUnit read | Code inspection of `Test-IsPreflightRun` agrees |
| 18 | AC-18 single-pass output rules | PASS | Cases for zero and two signals, ALL CLEAR with a defect, REVISIONS REQUIRED without one, fix line without an existing record; 0 failures | JUnit read | |
| 19 | AC-19 single-pass contract text | PASS | `test_contract_and_agents_state_single_pass_preflight` passes at head | `poetry run pytest tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | Residual plural "revision iterations" wording elsewhere (CR-1, non-blocking) |
| 20 | AC-20 at-most-one-return | PASS | `test_at_most_one_return_is_stated` passes | same | |
| 21 | AC-21 Codex and Copilot executors | PASS | Loop and auto-handoff fragments absent; wrapper-contract and handoff-parity suites pass | `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` | |
| 22 | AC-22 tools lists | PASS | Planner and executor list `mcp__drm-copilot__validate_orchestration_artifacts`; four `run_poshqc_*` entries kept; `test_scratch_location_contracts.py` passes; `claude-architecture-doc.Tests.ps1` 6 tests, 0 failures | pytest at head; JUnit read | |
| 23 | AC-23 Pre-Mortem helper | PASS | `premortem-section.Tests.ps1` 17 tests and `hook-dependency-guard-completeness.Tests.ps1` 598 tests, 0 failures; helper listed in the Claude `core.json` | JUnit read; manifest inspection | |
| 24 | AC-24 researcher hook | PASS | `validate-task-researcher-output.PreMortem.Tests.ps1` 8 tests, 0 failures; `test_feature_research_requires_premortem` passes | JUnit read; pytest at head | |
| 25 | AC-25 templates and self-review task | PASS | Three templates and bundle copies carry the skeleton; contract requires the final-phase self-review | `poetry run pytest tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | |
| 26 | AC-26 Pre-Feature-Review Commit | PASS | Step 1 of `## Pre-Feature-Review Commit` is the self-review check | same | |
| 27 | AC-27 Remediation-Mode | PASS | `test_remediation_surfaces_define_remediation_mode` passes | same | |
| 28 | AC-28 combined-run allowance | PASS | Cases for allowed block with no checked task, non-repairable with a checked task, other execution BLOCKED non-repairable; 0 failures | JUnit read; code inspection | Case-sensitive BLOCKED match undocumented (CR-5, Nit) |
| 29 | AC-29 full toolchain single pass | PASS | `evidence/qa-gates/toolchain-rerun.2026-10-17T02-28.md` and `contract-and-integration.2026-10-17T02-04.md`; reviewer re-ran generator check and contract suites at head | commands listed in the policy audit Appendix B | Re-run Pester figures not traceable to on-disk JUnit (CR-4); the canonical JUnit shows 0 failures |
| 30 | AC-30 isolation runs | PASS | `evidence/regression-testing/isolation-final.2026-10-17T02-04.md` plus the per-run artifacts: Jest seeds recorded, reversed Python, single-process Pester over `tests/scripts`, three Pester file-order seeds | file inspection | |
| 31 | AC-31 file size | PASS | `evidence/qa-gates/file-sizes.2026-10-17T01-41.md`; re-measured at head, maximum 500 (`repo-automation-dispatch.test.ts`) | Python newline count over the changed non-Markdown files | At the limit (CR-7, Info) |
| 32 | AC-32 self-review | PASS | `evidence/qa-gates/self-review.2026-10-17T02-30.md` walks all three templates, no FAIL row, AC table present | `Grep` for FAIL rows (none) | |
| 33 | AC-33 #962 re-plan (orchestrator-owned) | UNVERIFIED | `evidence/other/replan-962/spec.md` and `plan.md` exist untracked; no `summary.<timestamp>.md` yet | `ls evidence/other/replan-962/` | Pending orchestrator-owned; in progress; not a blocking finding for this review |
| 34 | AC-34 required contexts on final head (pending-CI) | UNVERIFIED | No PR exists yet; CI has not run on the final head | n/a | Pending-CI, orchestrator-owned at S9; not a blocking finding for this review |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (AC-33 pending orchestrator-owned re-plan; AC-34 pending CI at S9)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None for the executor-owned criteria. AC-33 and AC-34 are owned by the orchestrator and are expected to close at O1 and S9.

**Recommended follow-up verification steps:**

1. Orchestrator: complete O1 (`summary.<timestamp>.md` under `evidence/other/replan-962/`), then check off AC-33 if every listed condition holds.
2. Orchestrator at S9: confirm all eleven ruleset 15241672 contexts succeed on the final PR head, then check off AC-34 and re-run the gate on the new head.
3. Apply the non-blocking code-review findings CR-1 to CR-6 in the same pass, re-run the mirror copy, the generator `--check`, and the contract suites.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-16-planning-process-churn-964/spec.md`
- Total AC items: 34
- Checked off (delivered): 32
- Remaining (unchecked): 2
- Items remaining: AC-33 (orchestrator-owned #962 re-plan); AC-34 (pending-CI, orchestrator-owned at S9)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-16-planning-process-churn-964/spec.md` | 34 | 32 | 2 | Checkbox-backed; AC-1 to AC-32 were already checked by the executor and each was confirmed PASS by this review |

No source-file checkbox change was made: every criterion evaluated PASS (AC-1 to AC-32) was already checked, and AC-33 and AC-34 remain unchecked as pending orchestrator-owned items.
