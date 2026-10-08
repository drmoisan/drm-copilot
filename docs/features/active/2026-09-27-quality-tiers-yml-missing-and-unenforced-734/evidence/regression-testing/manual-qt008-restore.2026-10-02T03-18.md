# P4-T9 Restore quality-tiers.yml After the Manual Check

Timestamp: 2026-10-02T03-18
Command: git restore --source=HEAD -- quality-tiers.yml
EXIT_CODE: 0
Command: git diff --exit-code HEAD -- quality-tiers.yml
EXIT_CODE: 0
Command: git status --porcelain -- quality-tiers.yml
EXIT_CODE: 0
Output Summary: The restore exited 0. The anchored diff against HEAD printed nothing and exited 0, and porcelain status printed nothing: quality-tiers.yml matches its committed content (a6d2afa6) with the scripts/bash entry present.
