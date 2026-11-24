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

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Steps

1. Preview the initialization as a dry run.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command init -RepositoryId <repository-id> -Profile docs/documentation-estate/docs-profile.json`
2. Review the planned files, then apply the initialization.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command init -RepositoryId <repository-id> -Profile docs/documentation-estate/docs-profile.json -Write`
   Init adds the CI workflow `.github/workflows/_docs-quality.yml` and reports it on a
   `ci-workflow <path>` line and in the `ci_workflow` result field. The starter profile sets
   the documentation root to `docs/guide` (root id `guide`) and detects the source root:
   `src` when it holds files, else the package directory named by `pyproject.toml`, else
   `src`. A source root that lists no file is reported as `DOCS_PROFILE_SOURCE_ROOT_MISSING`
   with exit code 1; the files are still written, so edit the profile and validate it again.
3. Replace existing estate files only when the operator asks for it explicitly; add
   `-Force` to the step 2 command in that case and in no other.
4. Validate the profile.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate-profile -Profile docs/documentation-estate/docs-profile.json -Json`

## Documentation Families

The starter profile declares the default documentation families in `required_families`, one
record per family, each under the documentation root (`docs/guide/<family id>` by default). A
record names the family `id`, its `directory`, its `diataxis_mode`, its page `template` id (the
template file name without `.md`), its `audience` ids, its `review_interval_days`, and whether it
is `required`. The family `diataxis_mode` is the default mode of the family's pages; a page whose
own mode differs, such as a reference page inside a how-to family, is not constrained by it.

| Family id | Template id | Mode | Review interval (days) |
| --- | --- | --- | --- |
| `product-overview` | `product-overview` | `explanation` | 90 |
| `getting-started` | `onboarding` | `how-to` | 90 |
| `user-guides` | `how-to` | `how-to` | 90 |
| `administration` | `how-to` | `how-to` | 90 |
| `security` | `security` | `explanation` | 90 |
| `operations` | `runbook` | `how-to` | 90 |
| `service-management` | `service-management` | `explanation` | 90 |
| `architecture` | `architecture-overview` | `explanation` | 180 |
| `adr` | `adr` | `explanation` | 180 |
| `reference` | `api-reference` | `reference` | 90 |

The starter also declares the audiences `maintainers`, `end-users`, `operators`,
`security-reviewers`, and `product-owners` that the families name.

To record that a family does not apply to the repository, keep its record and add an
`exclusion` object with a non-empty `reason` and a UTC `recorded_at` time, for example
`"exclusion": {"reason": "No managed service is offered.", "recorded_at": "2026-11-23T00:00:00Z"}`.
Profile validation accepts an `exclusion` whatever the value of `required`.

To tolerate existing pages while they are migrated into the family layout, list each page in
`legacy_exclusions` with its repository-relative `path` and a `reason`. The starter writes an
empty `legacy_exclusions` list; each path may appear once.

Validation reports a repeated family `id` or `directory` (`DOCS_PROFILE_FAMILY_DUPLICATE`), an
audience that `audiences` does not declare (`DOCS_PROFILE_AUDIENCE_UNKNOWN`), a mode that
`diataxis_policy.modes` does not list (`DOCS_PROFILE_MODE_NOT_IN_POLICY`), a directory outside
every documentation root (`DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT`), and a repeated legacy
path (`DOCS_PROFILE_LEGACY_DUPLICATE`), each with the JSON pointer of the field.

## Linter Configuration

`init -Write` writes the Vale configuration to `docs/documentation-estate/.vale.ini`, the Vale
styles (`DocsBase` and the tonality style `DocsTonality`) and vocabulary under
`docs/documentation-estate/.vale/styles/`, and the markdownlint configuration to
`docs/documentation-estate/.markdownlint.json`. The written workflow runs markdownlint after the
documentation commands: the written `.github/workflows/_docs-quality.yml` runs the pinned
markdownlint-cli2 action with `docs/documentation-estate/.markdownlint.json` over the Markdown
pages of the profile `documentation_roots`, then installs the pinned, checksum-verified Vale
release and runs it with `--config docs/documentation-estate/.vale.ini`, which loads the
`DocsTonality` style. An error-level Vale alert fails the Vale step. To lint locally, pass
`--config docs/documentation-estate/.vale.ini` to Vale, or set `VALE_CONFIG_PATH` to that path,
and pass `docs/documentation-estate/.markdownlint.json` to markdownlint as its configuration file.
Vale resolves `StylesPath = .vale/styles` relative to the `.vale.ini` that sets it. An estate
initialized earlier receives the new workflow, `.vale.ini`, and `DocsTonality` files only through
`init -Write -Force` or by copying them; it is not migrated, and it keeps its root-level linter
files.

The docs-only exemptions of the pull-request and merge gates admit
`.github/workflows/_docs-quality.yml` as their one path outside `docs/`. The admission applies to
every pull request: a pull request that edits only that workflow passes the docs-only exemptions,
while CI still runs in full for it and the required CI gate still applies. It is a
policy-level control.

## Result

Report the profile path, the CI workflow `.github/workflows/_docs-quality.yml` that init adds
(its `ci-workflow` line), the exit code of each step and, on failure, the findings the command
returned. Use `-Help` with any subcommand to list its options.
