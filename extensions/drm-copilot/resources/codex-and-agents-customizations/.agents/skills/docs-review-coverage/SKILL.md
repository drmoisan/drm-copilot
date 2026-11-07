---
name: docs-review-coverage
description: 'Review documentation coverage, page accuracy and the surface delta of a branch, read-only. Use before docs-complete validation and during feature review of a change that alters the documented surface.'
---

# Docs Review Coverage

## When to Use This Skill

[docs-coverage-reviewer](../../../.codex/agents/docs-coverage-reviewer.toml) runs
this skill to judge whether the documentation covers the surface and describes it
accurately. The review changes no artifact.

## Prerequisites

Root steps run `Invoke-DocsCommand.ps1` from the docs helper library that the Claude customization push-down delivers, under PowerShell 7.4 or later. Without that library every root step in this skill is unavailable; the docs MCP tools stay available.

## Steps

1. For a branch change, the root session first runs the surface delta against the
   base branch and records it.
   Root step (unavailable without the docs helper library): `Invoke-DocsCommand.ps1 -Command surface-delta -Base <base-ref> -Profile docs/documentation-estate/docs-profile.json`
   The root writes the result to `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md`
   with the fields `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`.
2. Call `run_docs_coverage` with `workspace_root` and `profile`.
3. Call `run_docs_check` with `workspace_root`, `profile` and optionally `paths`.
4. Read each covered page against the surface elements it names in `surface_refs`
   and judge whether the page is accurate.
5. Call `validate_docs_artifacts` with `workspace_root`, `profile`, `mode`
   (`ledger` or `matrix`) and `revision` when the review needs the artifact state.

The review finding `surface-change-without-ledger-change` is owned by issue 1034
and is raised by `feature-review`; this skill reports the surface delta and the
coverage state that the finding reads.

## Result

Report the coverage findings, the page findings and each `accurate` judgment so
that `docs-reconciler` can record it with `set-dimension`.
