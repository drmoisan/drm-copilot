# Guard CLI Before Fix (P1-T12) [expect-fail]

Timestamp: 2026-09-28T22-02
Command: poetry run python -m scripts.dev_tools.skill_bundle_contract_cli
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: exit 1; stderr carries exactly one line beginning `skill-bundle `:

```text
skill-bundle violation: cleanup-merged-worktrees | scripts/bash/cleanup-worktrees.sh | not-in-bundle
```
