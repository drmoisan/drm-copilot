# Final QC workflows: actionlint and bundle byte comparison

Timestamp: 2026-11-19T14-32
Command: actionlint (1.7.12, no ignore flag, no suppression comment) over .github/workflows/harness-python.yml, harness-powershell.yml, harness-typescript.yml, harness-dotnet.yml; cmp of .github/workflows/harness-python.yml and extensions/drm-copilot/resources/ci-workflows/workflows/harness-python.yml
EXIT_CODE: 0
Output Summary: actionlint exit 0 with 0 findings over the four harness workflows; cmp exit 0, the source workflow and its bundle copy are identical.
