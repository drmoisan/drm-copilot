---
name: docs-validate
description: 'Validate the documentation estate artifacts for one mode and the head revision, read-only; receipt persistence is a root or CI step. Use to establish docs-complete before an integration merge.'
---

# Docs Validate

## When to Use This Skill

[docs-coverage-reviewer](../../../.claude/agents/docs-coverage-reviewer.md) or the
root session runs this skill to validate `docs-complete` for the head revision.

## Prerequisites

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Steps

1. Call `validate_docs_artifacts` with `workspace_root`, `profile`, `mode` set to
   `docs-complete` and `revision` set to the head revision (40 or 64 lowercase
   hexadecimal characters). The tool never persists a receipt.
2. Call `run_docs_check` with `workspace_root` and `profile` when the validation
   reports page findings.
3. Only the root session or CI persists the validation receipt, with the
   write-receipt switch; a documentation role never does.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate -Profile docs/documentation-estate/docs-profile.json -Mode docs-complete -Revision <head-revision> -WriteReceipt`

## Result

Report the validated mode, the revision, the exit code of
`validate_docs_artifacts` and the receipt id supplied by the root, or `none`.
