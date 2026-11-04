# Preflight Fixes - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-37
Plan: docs/features/active/2026-10-30-docs-page-quality-checker-1021/remediation-plan.2026-11-04T00-25.md
Directive: proportionate remediation cycle (single-pass preflight, then execution)
Validator: MCP `validate_orchestration_artifacts` (plan) ok; `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0.

## Fixes

1. [P1-T1] | unsatisfiable per-case wording, assertion unchanged | The acceptance stated that both escaped-backslash cases fail before P1-T2. A probe of `ConvertFrom-DocsPageYamlScalar` on the unmodified module (script under SCRATCH) gave: `["a\\", b]` resolves to Ok False, Construct `unclosed flow sequence`; `["a\\\"", b]` resolves to Ok True with items `a\"` and `b`, because the one-character look-back keeps the item open at the escaped quote and closes it at the next quote; `["a\", b]` resolves to Ok False, Construct `unclosed flow sequence`. Both escaped-backslash cases are assertions inside the one new `It` block, so that test still fails before P1-T2 and passes after it. The test content and the post-fix assertions are unchanged. The acceptance text now states that the new test fails on the `["a\\", b]` case, that the `["a\\\"", b]` case already passes and is kept as a regression guard, and that the unterminated case passes.

## Checks with no defect

- Citations re-checked against the tree: `ConvertFrom-DocsPageFlowSequence` and `ConvertFrom-DocsPageYamlScalar` in `.claude/lib/docs/DocsPageFrontMatter.psm1`; `Get-DocsPageLinkMap` (private), `Get-DocsPageCheckFinding` and `Invoke-DocsCheckCommand` in `.claude/lib/docs/DocsPageCheck.psm1`; the Describe and test names in `DocsPageFrontMatter.Tests.ps1` and `DocsPageCheck.Tests.ps1`; `ConvertFrom-TestBlock` and `Get-TestCode`; `New-DocsTestContext` in `Docs.TestSupport.psm1`; `ships byte-identical bundled counterparts` in `Docs.Manifest.Tests.ps1`; the three templates under `docs/features/templates/policy_audit/`.
- Tests that reference the edited modules: `DocsPageFrontMatter.Tests.ps1`, `DocsPageCheck.Tests.ps1`, `DocsPageImportIsolation.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1`; all are named in the plan with a disposition.
- File sizes: `DocsPageFrontMatter.psm1` 422, `DocsPageCheck.psm1` 428, `DocsPageFrontMatter.Tests.ps1` 522, `DocsPageCheck.Tests.ps1` 696 lines, matching the plan.
