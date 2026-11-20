# Scope, Size and Decisions ([P5-T6], stage B)

Timestamp: 2026-11-20T18-12
Command: sh SCRATCH/issue-1016-p5t6.sh (git diff -M --name-status BASE HEAD, BASE = merge base of INTEGRATION and HEAD; git status --porcelain; physical line count of every changed .py, .ps1, .psm1, .ts, .cjs, .mjs, .js, .sh and .bats file; git diff --numstat BASE HEAD -- config/file-size-baseline.json)
EXIT_CODE: 0
Output Summary: 0 added .py files in the branch diff and 0 .py paths in git status --porcelain (10 porcelain lines, all this item's plan, spec and new evidence files); 364 changed code files, 0 above 800 lines (largest 699, tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1); config/file-size-baseline.json unchanged, so no entry grew. Diff status counts: 35183 R, 514 M, 164 A, 1 D (the plan's old path; its new path is an A line). Every decision row below names its implementing task or `no change` and its test or evidence; no row is blank.

## Open questions and autonomous decisions

| Item | Implementing task or `no change` | Test or evidence |
| --- | --- | --- |
| OQ-1 / A2 discovery templates at `.dev/discovery/templates` | [P2-T2] apply; [P3-T7] build and initializer reads | `layout-check.2026-11-20T16-07.md`; `test_resolve_default_template_root_returns_expected_path`; `test_canonical_template_inputs_read_from_moved_source_directory` |
| OQ-2 / A3 `links-only`, evidence and ledger excluded | [P1-T4], [P2-T2] | `exclusion-integrity.2026-11-20T16-09.md`; `post-apply-dry-run-check.2026-11-20T16-11.md` (0 link candidates) |
| OQ-3 / A4 absent key resolves `docs/features` | no change (child 2 resolver) | `BlastRadius.Tests.ps1`, `test_compute_blast_radius.py`, `test_new_potential_bug_entry.py` fallback case, passing in `py-test-coverage` and `ps-test-coverage` 2026-11-20T18-10 |
| OQ-4 / A5 discovery resource key unchanged (with the A5 amendment) | [P3-T7] | `task-check.P3-T7.2026-11-20T15-23.md` (build check exit 0, `changed_paths` empty, 0 package diff lines) |
| OQ-5 / A6 rules and instructions not edited | no change | exclusion member 5; no diff line under `.claude/rules`, `.github/instructions` (`exclusion-integrity`) |
| OQ-6 / A7 fallback kept | no change | historical fixtures unchanged and passing (`exclusion-integrity`, `phase-gate.P3.2026-11-20T16-04.md`) |
| OQ-7 / A8 branch build, no publish | [P1-T1], [P2-T2], [P4-T3] | `digest-comparison.2026-11-20T12-28.md`; `post-apply-dry-run-check.2026-11-20T16-11.md`; `packages/mcp-server/package.json` unchanged |
| OQ-8, OQ-9 / A9 no permissions, `enabled_tools` or extension command change | no change | no diff line for `.claude/settings.json`, `.codex/config.toml` or `extensions/drm-copilot/package.json` |
| OQ-10 / A10 no FileSizePolicy segment change | no change | `FileSizePolicy.Tests.ps1`, `tests/scripts/codex-hooks/file-size-policy.Tests.ps1` pass; no diff under `.claude/lib/file-size-policy` |
| OQ-11 / A11 plan-template link depth | [P2-T2] (source), [P3-T4] (bundle copy) | `template-link-check.2026-11-20T15-10.md`; `test_plan_templates_carry_premortem_skeleton` |
| OQ-12 / A12 `commit_split` `single` | [P2-T3] | `apply-commit.2026-11-20T13-33.md` (R100 35222) |
| OQ-13 / A13 held items by mechanical rule | [P0-T2] (check), orchestrator decision file | `decision-file-check` baseline; `layout-check.2026-11-20T16-07.md` (0 mismatches) |
| A1 docs-estate coexistence | no change | [P0-T3] tree re-check; `production-root-search.2026-11-20T16-13.md` (`DocsProfile.psm1` comment is a STAY row) |
| A14 orchestrator decision step | orchestrator-owned `DECISIONS` | `folder-rename-decisions.2026-11-20T12-24.json`; [P0-T2] decision-file check |
| A15 ledger moves byte-identical | [P2-T2] with exclusion member 2; [P1-T5] read fallback | `PRC-READ-FALLBACK-*` cases; `exclusion-integrity` (ledger R100 except four patches) |
| A16 stage B scope confirmations | [P1-T4] | `rewrite-exclusion-coverage` evidence |
| A17 ledger entries that cite moved paths | [P3-T9] | `ledger-regeneration.2026-11-20T15-35.md`; `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS` |
| A18 ledger applicability bullet | [P3-T9] (`0008` commit) | `PCW-STANDING-RULE-<Copy>`, `PRL-RULE-STATED-IN-EVERY-COPY` |
| A19 production occurrences the tool cannot rewrite | [P1-T3], [P3-T7], [P3-T8], [P4-T4] | `production-root-search.2026-11-20T16-13.md` (0 unclassified) |
| A20 run split at [P3-T1] | [P3-T1] | `checkpoint-path-verified.2026-11-20T14-11.md`; `hook-root-precondition.2026-11-20T14-10.md` |
| A21 four copies per skill, two byte pairs | [P0-T3], [P3-T9] | `ledger-regeneration` (byte pairs hold); `test_push_down_claude_resource_contracts.py` |
| A22 generated surfaces | [P3-T10] | `brief-fact-check.2026-11-20T15-39.md` (`harness-generation: no drift`, Codex check exit 0) |
| A23 child 2 already satisfies two A19 rows | [P3-T8] | `a19-child2-rows.2026-11-20T15-27.md` |
| A24 A1 premise and ledger-pinned exclusions | [P0-T3], [P1-T4] | `production-root-search` (STAY row); `exclusion-integrity` |
| A25 migration tool excluded from its own rewrite | exclusion member 12 | `exclusion-integrity` (stage A files unchanged since the pre-apply commit); stage A suites pass in `ts-test-coverage.2026-11-20T18-10.md` |
| A26 child 2 files excluded as a set | exclusion member 4 | `exclusion-integrity` |
| A27 cleanup allowlist stays on `docs/` | no change | the five cleanup-leg suites pass; the two unresolved-target suites added in Phase 5 (`final-qa-loop.2026-11-20T18-10.md`) |
| A28 ReviewVerdictEligibility engineering case | no change | "refuses the listing engineering path" passes in `ps-test-coverage.2026-11-20T18-10.md` |
| A29 mechanical waiver from a rehearsal | [P1-T6], [P2-T4] | `apply-rehearsal.2026-11-20T13-04.md`; `phase-gate.P2.2026-11-20T14-05.md` |
| A30 excluded tests pinning rewritten skill text | [P3-T6] | `manual-literal-edits.2026-11-20T15-19.md`; all four tests of `test_epic_run_kickoff_discovery_contract.py`; `codex-epic-runtime-contracts.Tests.ps1` |
