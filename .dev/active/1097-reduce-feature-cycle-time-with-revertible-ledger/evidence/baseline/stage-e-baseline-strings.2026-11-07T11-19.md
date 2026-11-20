# Stage E Baseline-String Inventory

Timestamp: 2026-11-07T11-19
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-inventory.ps1 -Mode baseline -Reference SCRATCH/issue-1097-e-inventory-ref.json
EXIT_CODE: 0
Output Summary:
    STRING total=2 files=2 :: Plan must include Phase 0 with at least one baseline task.
    STRING total=2 files=2 :: Phase 0 must include a baseline task.
    STRING total=6 files=6 :: Phase 0 must also capture static baselines
    STRING total=6 files=6 :: one baseline artifact per baseline command step
    STRING total=6 files=6 :: each baseline step artifact MUST include:
    STRING total=10 files=6 :: baseline command-step artifacts with at least:
    STRING total=6 files=6 :: ### Baseline Evidence Output Summary (Required)
    STRING total=4 files=4 :: If any required QA artifact or post-change coverage metric is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
    STRING total=2 files=2 :: Do not mark the audit PASS, fully compliant, or ready for merge when any required QA artifact or post-change coverage metric is missing.
    STRING total=6 files=6 :: static baseline capture (format, lint, type check, and analyzer findings)
    STRING total=6 files=6 :: No earlier figure is compared.
    STRING total=24 files=10 :: N/A - no pre-change run
    STRING total=16 files=16 :: Include explicit static baseline tasks
    STRING total=10 files=10 :: canonical baseline location
    BASELINE-WORD files=57 total=422
    REPO-WIDE N/A files=43 total=230
    failures=0
    exit=0

Population: the 57 files that `## Baseline Adjacency` names (the six contract copies, the Claude planner agent and bundle, the six Codex planner TOMLs and their six bundles, the handoff skill and bundle, the hook, its bundle, and its test file, the four Copilot orchestrators, executors, and planners with bundles, both `execute-hard-lock` prompts with bundles, the review prompt and bundle, and the feature plan template and bundle), plus the six `evidence-and-timestamp-conventions` copies, the six `feature-review-workflow` copies, and `docs/features/templates/policy_audit/` with its bundle (21 files).

String counts are ordinal substring counts per file, summed above; per-file counts are held in the reference file under SCRATCH for the [P2-T4] hold check. The word count of `baseline` is a case-insensitive substring count over the 57 adjacency files. The repo-wide `N/A - no pre-change run` count covers tracked and untracked files outside this feature folder.

Strings checked: the `Checked` rows of `## Baseline String Register` (the two hook messages, the `## Phase 0 Requirements` baseline sentence, the three per-step artifact strings, `### Baseline Evidence Output Summary (Required)`, and the two fail-closed sentences of the policy-audit template) and the five hold strings of the paragraph below the register. Every count is above zero.
