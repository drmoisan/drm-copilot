# Quality Tier (P0-T4)

Timestamp: 2026-09-27T10-00
ExpectedExitCode: 1
Command: test -e quality-tiers.yml
EXIT_CODE: 1
Output Summary: No output; exit 1. `quality-tiers.yml` is absent from the repository root on this branch.

Tier: T4 (assumed per spec.md D5; dev tooling) for `scripts/bash/cleanup_worktrees_scan_helper.sh`.
Under T4 no property-test or mutation obligation applies; the uniform gates (format pass, zero lint findings, line coverage >= 85%, no regression on changed lines) apply.
