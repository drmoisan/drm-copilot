# Remediation Inputs — #1221 docs-family-gate-and-ia (cycle 1)

Timestamp: 2026-11-24T08-32
Remediation-Mode: proportionate
Source: code-review.2026-11-24T07-55.md, Minor row for `.claude/lib/docs/DocsFamilyCheck.psm1` (`Read-DocsFamilyEvidence`). The review verdict was PASS with no blocking finding. This cycle is opened under the owner rule that related review findings are fixed inside the item before merge, so it carries no opening-review reference and no finding marked blocking.

## Finding R-1 (related, non-blocking in the review)

- Remediability: autonomous
- Finding-Scope: contained
- Location: `.claude/lib/docs/DocsFamilyCheck.psm1`, `Read-DocsFamilyEvidence` (root-file evidence for `SECURITY.md` and `CODEOWNERS`).
- Defect: the root-file rule asks the `TestFile` seam whether `SECURITY.md` and `CODEOWNERS` exist at the repository root. The production seam `Test-DocsContextFile` in `.claude/lib/docs/Invoke-DocsCommand.ps1` uses `[System.IO.File]::Exists`, which is case-insensitive on Windows and default macOS file systems and case-sensitive on Linux. A root `security.md` therefore satisfies the rule on Windows and fails it on Linux, so the docs-complete result for the same tree depends on the host. Elsewhere the module compares names ordinally.
- Required outcome (orchestrator decision, autonomous mode, recommended option of the review): the root-file rule accepts only the exact names `SECURITY.md` and `CODEOWNERS`, compared ordinally (case-sensitive) on every host. Derive the evidence from an exact-name match of the repository-root entries (for example through the existing `ListFile` seam, matching with `-ceq`), or from an equivalent host-independent mechanism that uses only the existing seams. No new seam and no change to `Invoke-DocsCommand.ps1` unless the plan shows it is required. `.github/CODEOWNERS` and `docs/CODEOWNERS` still do not satisfy the rule (spec D7).
- Tests: add Pester cases in `tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1` proving that a root `security.md` and a root `codeowners` (wrong case) do not satisfy the rule, and that the exact names do, independent of the seam's case behavior (the fake seam must model a case-insensitive file system to make the test fail before the fix). Update every existing test that asserts the current `TestFile`-based root-file behavior, naming each with its disposition.
- Mirrors: refresh the byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`. Add one sentence to spec D7 stating that the names are compared ordinally on every host.

## Constraints

- Targeted tests only (owner instruction dated 2026-11-23): the task's test selection plus the push-down contract suites; no full-suite run in this cycle.
- No new Python. Evidence is append-only. 800-line hard limit. No temp files in tests.
