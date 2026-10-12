# Shell CI Baseline (Issue #890)

Timestamp: 2026-10-12T20-10
Task: P0-T12
Command: (1) `gh run list --workflow ci.yml --branch main --status completed --limit 1 --json databaseId,headSha,conclusion`; (2) `gh run view 38299364773 --json jobs --jq '.jobs[] | select(.name|test("shell-coverage")) | [.name,.conclusion] | @tsv'`; (3) `gh run view 38299364773 --log | grep -F 'Bash coverage (lines):'`
EXIT_CODE: 0
Output Summary:
- Run ID: 38299364773; head SHA: 85ffd5aaecd9004b7d82e9db6ab0f18a4add02f6 (equals the P0-T3 merge base); run conclusion: success.
- Job `shell-coverage / Shell Coverage (Bats + kcov)` conclusion: success.
- Log line: `Bash coverage (lines): 94.8%` (timestamp 2026-10-12T19:49:11Z). Other matches of the grep were the help-text template `"Bash coverage (lines): NN.N%" summary.`, not results.
- No bats, kcov, or shell wrapper was run locally.
