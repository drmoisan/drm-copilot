# CI Gate — Issue #1153, PR #1154

Timestamp: 2026-11-09T19-12
Command: gh pr checks 1154 --json bucket,name,state,link,workflow, parsed with .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha eed38ac75c867e31565b854d8e200c22c3234594
EXIT_CODE: 0
Output Summary: conclusion success on head eed38ac75c867e31565b854d8e200c22c3234594; 24 checks pass, 1 skipped (Publish to Marketplace), 0 failed, 0 pending. CI workflow run 42671447611 attempt 2 completed with success, including CI Required Gate, the three PowerShell QC shards, PowerShell hook suites (Linux), quality-checks7 on 3.11/3.12/3.13 (push-down contract tests), and the extension tests on ubuntu-latest and windows-latest.

## Attempt history

- Attempt 1 (created 2026-11-09T18:09:09Z) completed as failure with only 7 jobs created, all 7 success. GitHub status listed an unresolved critical incident, "Incident with Actions and Checks API", started 2026-11-09T18:12:37Z.
- Attempt 2 (re-run 2026-11-09T18:49:32Z, after GitHub reported the Actions degradation mitigated) completed with success.

## Non-required workflow

The "Publish Extension to VS Code Marketplace" run 42671447839 completed as failure on both attempts with its two `Extension Tests` matrix jobs never created and its publish job skipped; no step ran and no log exists. It is not a required context (ruleset 15241672 requires only `CI Required Gate`). The same extension test suites passed in the CI run on this head.

## Acceptance criterion

AC-58 (CI-dependent) is checked off in spec.md on the basis of this run.
