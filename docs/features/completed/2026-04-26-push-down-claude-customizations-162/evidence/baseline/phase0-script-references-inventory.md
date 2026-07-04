# Phase 0 — Script References Inventory (Pre-Edit Baseline)

Timestamp: 2026-04-26T14:05:00Z

Command: `git grep -n -E "poetry run python -m scripts|scripts/dev[_-]tools|scripts\.dev_tools|\$\{workspaceFolder\}/scripts" -- ".claude/**/*.md"`

EXIT_CODE: 0

Output Summary:
Occurrences (total on disk): 11
In-scope occurrences: 10
Out-of-scope occurrences: 1

In-scope files and matches (R1–R10):

**`.claude/skills/feature-promotion-lifecycle/SKILL.md`** (6 occurrences):
- Line 47: `` - feature: `${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1 -ShortName ${short-name}` ``
- Line 48: `` - bug: `${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py --short-name ${short-name}` ``
- Line 51: `` - `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path ...` ``
- Line 57: `` - `poetry run python -m scripts.dev_tools.new_active_feature_folder ...` ``
- Line 64: `` - `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path ... --work-mode minor-audit` ``
- Line 70: `` - `poetry run python -m scripts.dev_tools.new_active_feature_folder ... --work-mode minor-audit` ``

**`.claude/skills/pr-base-branch-merge-base/SKILL.md`** (3 occurrences):
- Line 3: description field references `scripts.dev_tools.pr_context.collector`
- Line 13: bullet references `scripts.dev_tools.pr_context.collector`
- Line 47: `` `poetry run python -m scripts.dev_tools.pr_context.collector --base <resolved-PRBaseBranch>` ``

**`.claude/skills/execute-hard-lock/SKILL.md`** (1 occurrence):
- Line 66: `` - Local task (development only): `poetry run python scripts/dev_tools/resolve_hard_lock_prompt.py --target ${file} --workspace ${workspaceFolder}` ``

Out-of-scope occurrence:

**`.claude/rules/powershell.md:57`** — matched text: `- Organize tests to mirror code structure (e.g., \`tests/scripts/dev-tools/ScriptName.Tests.ps1\`).`
Rationale: policy rule documentation example of test layout, not a script invocation; out-of-scope per spec.md Edge Cases; recorded for traceability only.
This file is read-only per the Implementation Strategy Notes ("`.claude/rules/*.md` are read-only in this plan") and is outside the spec.md "Out of Scope" boundary. Cross-referenced as the `EXCLUDED_DOCUMENTATION_PATHS` exclusion class enforced by P6-T1.
