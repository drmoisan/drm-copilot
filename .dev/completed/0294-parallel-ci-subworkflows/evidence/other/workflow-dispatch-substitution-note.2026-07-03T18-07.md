# P4-T1..P4-T7 Substitution Note (Orchestrator)

- Timestamp: 2026-07-03T22:40:00Z
- Owner: orchestrator (direct `gh` invocation)

## What the plan asked for

P4-T1 through P4-T7 asked for a standalone `gh workflow run _<name>.yml --ref <feature-branch>`
dispatch of each of the 7 newly-created reusable workflow files, individually, with a per-file
evidence artifact.

## What actually happened (verified, not assumed)

```
$ gh workflow run _quality-checks.yml --ref feature/parallel-ci-subworkflows-294
Exit code 1
HTTP 404: workflow _quality-checks.yml not found on the default branch
(https://api.github.com/repos/drmoisan/drm-copilot/actions/workflows/_quality-checks.yml)
```

This confirms a real, documented GitHub Actions platform constraint that the research pass did not
directly test: a workflow file must exist on the repository's **default branch** before it can be
manually dispatched by filename via `gh workflow run <file> --ref <any-branch>`, even when the file
already exists (with a valid `workflow_dispatch` trigger) on the target `--ref` branch itself. Since
all 7 new `_<name>.yml` files exist only on `feature/parallel-ci-subworkflows-294` at this point
(pre-merge), none of them can be individually dispatched by name yet. This is expected to resolve
automatically once this branch merges to `main`.

## Substitution performed

`ci.yml` **does** already exist on the default branch (`main`) with a `workflow_dispatch` trigger
predating this feature, so it is already a registered, dispatchable workflow. Dispatching `ci.yml`
itself against this feature branch's ref executes the **modified version of `ci.yml`** present on
that branch -- the thin orchestrator that invokes all 7 reusable workflows via
`uses: ./.github/workflows/_<name>.yml` (a local relative-path reference, which resolves at the
same ref as the calling workflow and requires no separate default-branch registration for the
callee). This single dispatch therefore exercises all 7 extracted reusable workflows end-to-end,
providing equivalent verification coverage to the 7 individual per-file dispatches the plan
originally specified, without requiring a pre-merge registration step that GitHub does not support.

Command executed:

```
gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294
```

Result: run id `28686408104`, conclusion `success` -- see
`green-run-branch-head.2026-07-03T18-07.md` for the full per-job breakdown, which includes a
successful run of every one of the 7 extracted jobs (11 job runs counting the two matrices).

## Disposition of P4-T1..P4-T7

Each of P4-T1 through P4-T7's individual per-file evidence artifacts is superseded by this single
substitution artifact plus `green-run-branch-head.2026-07-03T18-07.md`, which together demonstrate
that every one of the 7 extracted jobs executed successfully via the rewritten `ci.yml`. Once this
branch merges to `main`, each `_<name>.yml` file becomes individually dispatchable
(`gh workflow run _<name>.yml`) for future standalone re-runs, which is the operational capability
the extraction was designed to provide going forward -- this pre-merge branch state is simply not
able to exercise that specific capability yet, by GitHub's own platform design.
