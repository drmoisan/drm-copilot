Timestamp: 2026-11-03T23-03
Plan: docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/plan.2026-11-03T17-43.md

- DD1: added a constraint that the Describe-level AfterEach must not call commands mocked by the Install-Actionlint Context (Test-Path, Join-Path, Remove-Item, New-Item, Write-Information), because AfterEach runs while those mocks are active; restore uses variable assignment and Remove-Variable. Assertions unchanged.
