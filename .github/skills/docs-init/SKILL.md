---
name: docs-init
description: 'Create the documentation estate profile for a repository and validate it. Use from the root session before any other docs skill runs.'
---

# Docs Init

## When to Use This Skill

Use this skill once per repository, from the root session, to create
`docs/documentation-estate/docs-profile.json` and the empty estate artifacts it
names, or to validate an existing profile. No documentation role runs it.

## Prerequisites

Root steps run `Invoke-DocsCommand.ps1` from the docs helper library that the Claude customization push-down delivers, under PowerShell 7.4 or later. Without that library every root step in this skill is unavailable; the docs MCP tools stay available.

## Steps

1. Preview the initialization as a dry run.
   Root step (unavailable without the docs helper library): `Invoke-DocsCommand.ps1 -Command init -RepositoryId <repository-id> -Profile docs/documentation-estate/docs-profile.json`
2. Review the planned files, then apply the initialization.
   Root step (unavailable without the docs helper library): `Invoke-DocsCommand.ps1 -Command init -RepositoryId <repository-id> -Profile docs/documentation-estate/docs-profile.json -Write`
3. Replace existing estate files only when the operator asks for it explicitly; add
   `-Force` to the step 2 command in that case and in no other.
4. Validate the profile.
   Root step (unavailable without the docs helper library): `Invoke-DocsCommand.ps1 -Command validate-profile -Profile docs/documentation-estate/docs-profile.json -Json`

## Result

Report the profile path, the exit code of each step and, on failure, the findings
the command returned. Use `-Help` with any subcommand to list its options.
