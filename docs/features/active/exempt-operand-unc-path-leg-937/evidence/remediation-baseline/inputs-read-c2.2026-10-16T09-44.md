# Remediation Inputs Read, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-44
Task: P0-T2 (remediation-plan.2026-10-16T08-40.md)

Files Read:

1. `FEATURE/remediation-inputs.2026-10-16T08-40.md` (entire file)
2. `FEATURE/code-review.2026-10-16T08-30.md`
3. `FEATURE/policy-audit.2026-10-16T08-30.md`
4. `FEATURE/feature-audit.2026-10-16T08-30.md`
5. `FEATURE/spec.md`
6. `FEATURE/remediation-plan.2026-10-16T03-39.md`

## Quoted bullets (verbatim from `remediation-inputs.2026-10-16T08-40.md`)

### RI-7 Required outcome

- Required outcome: generalize the `file:` alternative to a URI scheme of two or more characters (for example `[A-Za-z][A-Za-z0-9+.-]+:`), keep the drive-letter alternatives and the drive-root exception (`C:\`, `C:/`) unchanged, keep every currently passing row passing, and add expect-fail rows for at least `http`, `smb`, and `vscode-remote` spellings on both surfaces before the fix (CI fail-before, then pass-after). Re-copy the three mirrors byte-for-byte and re-run the Parity suite and the push-down contract tests. Add a spec.md acceptance criterion for this behavior (next free AC number); AC-1..AC-19 text unchanged.

### RI-8 Required outcome

- Required outcome: before adding RI-7 rows, move the #937 rows (U27 to U31) into a sibling test file under `tests/scripts/claude-hooks/` that runs on both surfaces the same way, with row names unchanged so existing JUnit filters still match; every test file stays at or below 500 lines.

### Do Not Do

- Do not edit `config/poshqc-coverage.json`, PoshQC settings, or coverage populations.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not widen the production change beyond the non-local pattern of the targets copies.
