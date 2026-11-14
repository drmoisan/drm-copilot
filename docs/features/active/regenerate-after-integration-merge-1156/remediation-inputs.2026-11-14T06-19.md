# Remediation Inputs — Issue 1156 (cycle 2, related non-blocking findings)

Timestamp: 2026-11-14T06-19
Review-Verdict: PASS
Remediation-Path: full
Remediation-Mode: proportionate
Issue: 1156
Base: main
Opened-By: orchestrator, under owner directive OD-6 (fix related findings inside this item before merge)
Source review artifacts:
- `docs/features/active/regenerate-after-integration-merge-1156/policy-audit.2026-11-14T05-56.md`
- `docs/features/active/regenerate-after-integration-merge-1156/code-review.2026-11-14T05-56.md`
- `docs/features/active/regenerate-after-integration-merge-1156/feature-audit.2026-11-14T05-56.md`

## Disposition

The cycle 1 re-audit passed with no blocking finding. Its code review records three related Minor findings in this item's own code and documentation. Under OD-6 they are fixed inside this item before merge rather than deferred. The cycle is full (not light) because the opening review is a PASS and names no remediation review; it is proportionate because no spec acceptance criterion, public interface, or file outside the branch diff and its tests and mirrors changes.

## Finding C2-1 (code review CR-3)

Severity: Minor
Remediability: autonomous
Finding-Scope: contained

- Location: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`, `Get-RegenerationProcessStartSpec`, and its bundle copy.
- Observed: the cmd.exe metacharacter screen applies to each batch argument but not to the resolved batch path; a path holding `&` or `%` makes cmd.exe run a different command line (`evidence/other/process-start-probe.2026-11-14T05-56.md`).
- Required: apply the same refusal to the resolved batch path for the double quote, `&`, the pipe and redirection characters, `^`, and `%` (whitespace and parentheses stay allowed because the path is quoted), so the function's contract (input reaches the batch file unchanged or the start is refused) holds for the path too. Keep the file at or below 800 logical lines.

## Finding C2-2 (code review CR-4)

Severity: Minor
Remediability: autonomous
Finding-Scope: contained

- Location: `.claude/skills/orchestrate/SKILL.md` `## Merge-Conflict Remediation` item 2, the regeneration config paragraph of `.claude/rules/orchestrator-state.md`, and their bundle copies.
- Required: one sentence in each stating that `argv[0]` resolves through PATH (and PATHEXT on Windows), that a `.cmd` or `.bat` runs through `ComSpec /d /c`, and that a batch path or argument holding whitespace (arguments only), a double quote, or a cmd.exe metacharacter is refused before the start; pin the sentence in `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.

## Finding C2-3 (code review refusal-table gap)

Severity: Minor
Remediability: autonomous
Finding-Scope: contained

- Location: `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1`, `throws for a batch argument holding <Label>`.
- Required: one table row per refused character (`%`, `^`, `(`, `)`, `<`, `>`, the pipe, and a tab) in addition to the space, double quote, and `&` rows, plus the path rows for C2-1.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt`.
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
