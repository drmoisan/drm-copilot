# documentation-estate Epic Template

This folder holds an epic manifest that plans a documentation estate with the documentation-estate
tooling. `epic.md` is a complete epic home: its frontmatter is a parseable epic dependency manifest
and its body states the goal, scope, shared design, one section per child and the planned waves.

## Using the Template

1. Choose an epic slug, for example `documentation-estate`.
2. Copy `epic.md` to `docs/features/epics/<slug>/epic.md`. That is the path the `/epic-plan`
   readiness check expects.
3. If the slug differs from `documentation-estate`, change `epic` and `integration_branch`
   together: `integration_branch` must stay `epic/<slug>-integration`.
4. Replace `created_at` with the UTC time at which the epic is created, in the form
   `yyyy-MM-ddTHH:mm:ssZ`.
5. Adjust the child sections and their acceptance criteria to the repository. Keep the
   `features` entries and the `## Planned Waves` list consistent with each other.
6. Run `/epic-plan docs/features/epics/<slug>/epic.md`. It promotes the children and back-fills the
   `9000NN` placeholder `issue_num` values, and the `depends_on` lists, with the real issue numbers.

No command copies the template: the copy is manual, and no `epic-status.md` is shipped because that
file is generated from the manifest.

## Prerequisites

The children of this epic use the documentation-estate subcommands, which require PowerShell 7.4 or
later on PATH as `pwsh`. The onboarding pages under `docs/engineering/documentation-estate/` in the
repository that ships this template describe every subcommand and docs MCP tool.
