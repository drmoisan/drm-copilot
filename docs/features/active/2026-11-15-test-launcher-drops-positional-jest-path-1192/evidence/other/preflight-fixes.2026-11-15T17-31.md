Timestamp: 2026-11-15T17-31
Plan: docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/plan.2026-11-15T11-44.md

Fix 1: [P1-T2] carries one test that fails by design (the pester -TestPath ordering test, listed among the five expected failures of P1-T4) but lacked the `[expect-fail]` tag that P1-T1 and P1-T3 carry. The tag was added to the task heading text. No assertion, task, or ordering changed.

Validation: Python CLI plan subcommand (module form) exit 0; MCP plan validator ok true.
