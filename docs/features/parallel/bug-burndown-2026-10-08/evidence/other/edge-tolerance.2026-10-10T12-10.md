# Edge tolerance decisions - bug-burndown-2026-10-08

Timestamp: 2026-10-10T12-10
Basis: operator policy change relayed by the coordinator on 2026-10-10. Conflict edges no longer
block automatically: an edge is tolerated when the time saved by running the pair concurrently
exceeds the expected time to resolve the conflict, and is kept hard only when it is class (c) with
a cost comparable to the time saved.
Scope: the 16 path_overlap edges among the remaining items 543, 790, 791, 824, 841, 842, 849,
including the widened #824 scope (scripts/bash/shell_qc_lib.sh, .claude/rules/shell.md and its
bundled copy, .codex/**/*.sh, .github/workflows/_shell-coverage.yml, tests/shell/**).
Method: overlapping paths computed from the checkpoint blast radii (feature-folder paths excluded);
read or write intent for each side taken from each item's committed plan on its pushed branch, and
for #824 from its actual diff against main (origin/main...origin/bug/issue-823-tier-rule-adoption-follow-ups-824).
Time saved per pair: about one item wall-clock duration, 1-3 hours (recent items 0.4-2.7 hours).

Classes: (a) read-only for at least one side, cost 0; (b) both sides write separable regions or
append-style/mirror files, cost of a few minutes because the later item merges main and resolves;
(c) both sides edit the same logic, cost of a remediation pass.

| Edge | Overlapping paths and intent | Class | Cost estimate | Decision |
| --- | --- | --- | --- | --- |
| 543-790 | enforce-python-batch-budget.ps1 (both cite only); extensions/drm-copilot/package.json (both run scripts); test_push_down_claude_resource_contracts.py (both run) | a | 0 | tolerated |
| 543-824 | same three paths; 824 diff writes none of them | a | 0 | tolerated |
| 543-841 | test_push_down_claude_resource_contracts.py (both run) | a | 0 | tolerated |
| 543-842 | test_push_down_claude_resource_contracts.py (both run) | a | 0 | tolerated |
| 790-824 | batch-budget hook, package.json, resource-contracts test (all read on both sides) | a | 0 | tolerated |
| 790-841 | resource-contracts test (both run) | a | 0 | tolerated |
| 790-842 | resource-contracts test (both run) | a | 0 | tolerated |
| 791-824 | _shell-coverage.yml (791 cites as CI source only); pack-manifests/core.json (both append one entry, different blocks); claude-pack-manifest-completeness.test.ts (824 runs; 791 optional edit not taken); tests/shell/** (different files: 824 writes test_codex_web_setup_codex_copy.bats, 791 writes parallel_*.bats) | b | about 10 min (core.json list merge) | tolerated |
| 791-841 | core.json (841 reads); test_skill_bundle_contract_repo.py (791 adds a test; 841 runs it) | a | 0 | tolerated |
| 791-842 | _shell-coverage.yml (both cite as CI source) | a | 0 | tolerated |
| 791-849 | parallel-add and parallel-orchestrate SKILL.md (791 cites in follow-ups.md only; 849 edits); parallel-plan SKILL.md (791 bash-fence fix; 849 edits Item Intake and Preparation Fan-Out sections) plus byte-copy mirror | b | about 15 min (separate sections, mirror recopy, parity test rerun) | tolerated |
| 824-841 | feature-review-workflow/SKILL.md and Claude mirror (824 edits step 5 fallback and step 8 trigger; 841 edits Policy Rules qualifying-run definition); core.json, codex-and-agents contracts test, tier-rule-adoption test (841 reads/runs) | b | about 20-30 min (separate sections, mirror recopy, parity suites rerun) | tolerated |
| 824-842 | _shell-coverage.yml (842 reads; 824 scope change lives in shell_qc_lib.sh); resource-contracts test (both run); tests/shell/** (different files) | a | 0 | tolerated |
| 824-849 | config/poshqc-coverage.json and PoshQC/settings/pester.runsettings.psd1 (recorded as shared surface; both sides read only; 824 diff writes neither) | a | 0 | tolerated (operator-directed; shared-surface marker came from cited paths, not writes) |
| 841-842 | resource-contracts test (both run) | a | 0 | tolerated |
| 841-849 | orchestrate/SKILL.md and Claude mirror (841 edits S9 step 2/3 and head_sha bullet; 849 edits the existing-issue waiver paragraph O1) | b | about 15 min (separate paragraphs, mirror recopy) | tolerated |

Totals: 12 class (a), 4 class (b), 0 class (c). No edge is kept hard.

Recolor: recolor_unstarted(unstarted=[543,790,791,841,842,849], edges=[], pinned={824},
current_generation=0, current_cohort=1, highest_pinned_cohort=1) returned all six at absolute
index 1, generation 1. Parity: bash .claude/lib/bash/compute-cohorts.sh and Python
compute_cohorts both returned [[543,790,791,841,842,849]] (EXIT_CODE 0 each). Generation-1
cohort written verbatim: index 1, item_keys [543,790,791,824,841,842,849]. Both the MCP validator
and validate_parallel_orchestrator_state_text report 0 errors.

Mutation log: the F3 mutation `op` enum is fixed at add, remove, close and requeue, and none of them
describes an edge-tolerance recolor, so no mutations[] entry was appended; the decision is
recorded here, in tolerated_overlaps, and in completed_steps.

Merge-conflict handling for tolerated pairs: the later-merging item merges origin/main (no rebase),
resolves the conflict, re-runs the affected tests, pushes, and re-passes all checks before merge.
