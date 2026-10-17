# Remediation Inputs: pr-author docs-only exemption hardening (#927), remediation cycle 3

Review-Verdict: PASS

- Branch: `bug/pr-author-docs-only-exemption-hardening-927`
- Source review set: timestamp 2026-10-16T11-19 (R4 re-audit after remediation cycle 2), verdict PASS:
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/policy-audit.2026-10-16T11-19.md`
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/code-review.2026-10-16T11-19.md` (findings table rows CR-N1 and CR-N2)
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/feature-audit.2026-10-16T11-19.md`
- Scope decision: orchestrator decision D-RUN-10 limits this cycle to CR-N1 and CR-N2.
- Carry-forward basis: CR-N1 and CR-N2 are carried from the PASS review 2026-10-16T11-19 under the coordinator's related-findings rule, which requires related non-blocking findings to be fixed inside the item before merge.

## Findings for this cycle

### CR-N1: pending output reads at disposal on the expiry path

Severity: Non-blocking (review severity Info)
Remediability: autonomous
Remediability-Evidence: The change is confined to the bounded runner in one helper file, copied byte-identically to three paths, and is verifiable with the existing test-local fake process; it needs no external service and no operator decision.

- File and lines: `.claude/hooks/hook-docs-only-diff.ps1:200-228` (`Invoke-DocsOnlyBoundedNative`; reads started at lines 202-203, expiry branch at lines 204-213, `finally { $process.Dispose() }` at lines 226-228). Byte-identical copies: `.codex/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`.
- Finding: on the expiry path, and on the path where `Kill` throws, the asynchronous `ReadToEndAsync` tasks for standard output and standard error may still be pending when `Dispose()` runs. The standard error task is discarded at creation (`$null = ...`), so the runner holds no reference to it.
- Required action: before `Dispose()` on the expiry path, handle each pending read at a fixed point in a fixed order, with no change to the deny-on-expiry result (exit code 124, no output), the wait limits (3000 ms, 7000 ms, and the 1000 ms output wait), or the `[scriptblock] $ProcessStarter` seam that `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` relies on. Keep the four helper copies byte-identical (`cp`, then `cmp`). Prove the ordering with test rows that use the test-local fake process (no `Start-Process`, no `Start-Sleep`, no real wait, no `Mock git` or `Mock gh`, no temporary file), run expect-fail before the helper edit.

### CR-N2: Codex-copy trailing line-feed trim not executed

Severity: Non-blocking (review severity Info)
Remediability: autonomous
Remediability-Evidence: One additional data row in an existing Pester suite executes the statement; no production change is needed.

- File and line: `.codex/hooks/hook-docs-only-diff.ps1:217` (`$text = $text.Substring(0, $text.Length - 1)`), `ci=0 mi=1` in the cycle 2 local route B coverage (`evidence/qa-gates/r2-coverage-delta.2026-10-16T10-53.md`, `CHANGED_CODE_INFO` line). The Claude copy covers the same statement.
- Test file: `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:198-216` (the `runs the bounded runner when <Name> (codex copy, issue #927)` rows, whose output text has no trailing line feed).
- Required action: add a Codex-copy row whose fake output ends with a line feed, so the statement at the line above is executed by the Codex-copy suite.

## Recorded without action (orchestrator decision D-RUN-10)

CR-R2, CR-R3, CR-R4, CR-R5, CR-R6, and CR-N3 of `code-review.2026-10-16T11-19.md` are recorded by the orchestrator without action in this cycle.

## Pending CI (not findings)

- AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24: CI-dependent; checked off at S9 by the item's orchestrator run from the PR-head CI run.

## Do Not Do

- Do not change the deny-on-expiry result, the wait limits, or the `-ProcessStarter` seam.
- Do not write a helper copy other than by `cp` from `.claude/hooks/hook-docs-only-diff.ps1`.
- Do not edit `artifacts/pester/*.xml` by hand, copy it, or commit it.
- Do not edit files under `.claude/rules/` or `.github/instructions/`.
- Do not delete files, rename evidence files, or edit prior review artifacts or prior plans.
