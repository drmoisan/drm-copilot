# Task check: RC2 P1-T2 (null ci_gate and pr_gate rows)

Timestamp: 2026-11-24T18-39
Command: sh SCRATCH/issue-1233-rc2-ts-check.sh rc2-p1t2-ts test/lib/validate/orchestrator-state-core.completion.test.ts (in extensions/drm-copilot: npx prettier --check <file> ; npx eslint <file> ; npx tsc -p ./ --noEmit ; npx tsc -p tsconfig.jest.json --noEmit)
EXIT_CODE: 0
Output Summary:
- Changed file: extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts (two rows inserted after "rejects a ci_gate head_sha that does not match pr_gate": "rejects a ci_gate whose required fields are null" and "rejects a pr_gate whose required fields are null").
- Expected strings equal the Python forms: _validate_completion_ci_gate (CI_GATE_KEYS order conclusion, head_sha, verified_at) gives "ci_gate missing required fields: head_sha, verified_at."; validate_completion_pr_gate (PR_GATE_KEYS order pr_number, pr_url, head_branch, head_sha) gives "pr_gate missing required fields: pr_url, head_sha.".
- Prettier check exit 0 ("All matched files use Prettier code style!"); ESLint exit 0, 0 findings; tsc -p ./ exit 0, 0 errors; tsc -p tsconfig.jest.json exit 0, 0 errors; git status --porcelain unchanged by the checks.
- File length 279 lines (below 500).
- Selection: per the task text, the Jest selection runs as the P1-T3 fail-before record (the two rows fail by design until P1-T4); this check records the static steps only.
