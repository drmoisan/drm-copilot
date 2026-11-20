# Hook Structure Baseline — Get-PrAuthorBypassReason (pre-fix)

Timestamp: 2026-06-24T15-59

Target finding: F-1 — inline `--body` on `gh pr edit` is allowed because the Case A inline-body guard is scoped to `$isPrCreate` only.

## File: root `.claude/hooks/enforce-pr-author-skill.ps1`

- `Get-PrAuthorBypassReason` function: lines 172-246.
- Subcommand match / early return: lines 201-207.
- Body-flag detection: lines 209-210
  - `$hasBodyFile = $CommandText -match '(?i)--body-file\b'`
  - `$hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'`
- Inline-body / no-body guard block (create-scoped): lines 212-222

```
    if ($isPrCreate) {
        # Case A: gh pr create with inline --body (not --body-file).
        if ($hasInlineBody -and -not $hasBodyFile) {
            return "PR_AUTHOR_SKILL_BLOCKED: ..."
        }

        # Case B: gh pr create with no body flag at all.
        if (-not $hasInlineBody -and -not $hasBodyFile) {
            return "PR_AUTHOR_SKILL_BLOCKED: New PRs require ``--body-file``. ..."
        }
    }
```

- `gh pr edit` no-body allow short-circuit: lines 224-229

```
    if ($isPrEdit) {
        # gh pr edit with no --body or --body-file (e.g., --title, --add-label, --reviewer) is allowed.
        if (-not $hasInlineBody -and -not $hasBodyFile) {
            return $null
        }
    }
```

- Case C (`--body-file` + context absent): lines 231-234.
- Cases D/E/F + Malformed sentinel path (`--body-file` + context present): lines 236-243.
- Fallthrough `return $null`: line 245.

Defect: an inline-body `gh pr edit` (`$isPrEdit -and $hasInlineBody -and -not $hasBodyFile`) is not matched by the create-scoped Case A block, is not matched by the `gh pr edit` no-body short-circuit (because `$hasInlineBody` is true), is not matched by Case C (no `--body-file`), and is not matched by the sentinel path (no `--body-file`). It reaches the fallthrough `return $null` and is therefore allowed.

## File: bundled `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`

- Byte-identical to root (same SHA-256). `Get-PrAuthorBypassReason` at lines 172-246; guard block at lines 212-229; same defect.

## File: Codex `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`

- Identical to root apart from a 3-line leading header (`# Converted hook`, `# Review the generated hook behavior before enabling it.`, and one blank line). All line references above are offset by +3.
- `Get-PrAuthorBypassReason` at lines 175-249; guard block at lines 215-232; same defect.
