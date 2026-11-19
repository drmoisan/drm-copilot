---
name: push-down-integration
description: 'Integrate a push-down into a destination that already has workflows, a different version matrix, existing hooks or a different layout. Use after a push-down writes .push-down-integration-needed.json: read the file, call detect_push_down_integration, resolve each item with ordinary edits, and call validate_push_down_integration until the verdict is pass.'
---

# Push-Down Integration

A push-down copies the harness into a destination mechanically. When it meets a decision it cannot make mechanically, it records an item in `.push-down-integration-needed.json` at the destination root and does not guess. This skill tells an agent session how to make those decisions with ordinary edits and how to prove the result with a deterministic check.

The two MCP tools are read-only and deterministic, and neither calls a model:

- `detect_push_down_integration` reports the harness ecosystems and language packs, every workflow under `.github/workflows/` with its jobs, the structured conflicts, and a summary of `.push-down-integration-needed.json`.
- `validate_push_down_integration` returns `integration.verdict` (`pass` or `fail`), the result of rules V1 to V5, and the fixed `not_checked` list.

Both tools take only `workspace_root`. A completed run returns `ok: true`, including a validate run whose verdict is `fail`; `ok: false` means the input or the host failed, not the integration.

## Integration Loop

Work through these steps in this order:

1. Read `.push-down-integration-needed.json` at the destination root and note each item's `id`, `kind`, `path`, `detail` and `resolution_options`.
2. Call `detect_push_down_integration` for the current facts; its `conflicts` use the same item ids, with `source: detect`.
3. Resolve each item by kind with ordinary edits under the destination's hooks and review, choosing one of the item's `resolution_options` (see the per-kind table).
4. Call `validate_push_down_integration`.
5. On `verdict: fail`, read the failing rules and return to step 3 to resolve them.
6. Stop only when `integration.verdict` is `pass`.
7. Quote the `not_checked` list in the hand-off, so the reader knows what the verdict does not cover.
8. Re-run the push-down and report each item that remains in `.push-down-integration-needed.json` with the decision taken for it.

The stop condition is the validate verdict, not an empty file. A decision that keeps a condition in place (for example `keep-both-workflows`) leaves its item in the file on every run; report that item with its decision.

A path the destination owns from now on is declared destination-owned by listing it in `.push-down-exclusions`. Validate then treats a modified or missing manifest entry for that path as destination-owned instead of as a failure.

## Resolution by Kind

| Kind | Resolution options | Guidance |
|---|---|---|
| `workflow-name-collision` | `rename-existing-workflow`, `retire-existing-workflow` | Another workflow already has the top-level name of the pushed caller. Rename it, or retire it when the pushed caller replaces it. |
| `existing-ci-workflow` | `keep-both-workflows`, `retire-existing-workflow` | The destination has its own `ci.yml` or `ci.yaml`. Keep both when the existing workflow still has a purpose; otherwise retire it. |
| `job-name-overlap` | `rename-existing-job`, `keep-overlapping-job` | A destination job id or name equals a pushed job or required check. Rename the destination job, or keep it when the overlap is intended. |
| `missing-required-check` | `add-producing-job`, `restore-pushed-caller` | No job in the data file's workflow produces a required check. Add a producing job, or restore the pushed caller and its gate job. |
| `version-matrix-difference` | `align-to-harness-version`, `keep-destination-version` | A destination job pins a tool version other than the harness workflow's version. Align it, or keep the destination version on purpose. |
| `destination-edited-file` | `revert-to-payload`, `declare-destination-owned` | The destination edited a managed file; `detail.is_hook` marks a hook. Revert it to the payload, or declare it destination-owned. |
| `unmanaged-conflict` | `adopt-payload`, `declare-destination-owned` | A destination file the push-down does not manage differs from the payload. Adopt the payload, or declare the file destination-owned. |
| `deleted-locally` | `restore-from-payload`, `declare-destination-owned` | The destination deleted a managed file. Restore it from the payload, or declare the path destination-owned. |
| `yaml-unsupported` | `rewrite-in-supported-subset` | A workflow uses a construct outside the reader subset (`detail.construct` at `detail.line`). Rewrite it without anchors, aliases, tags, tab indentation, extra documents or complex keys. |

## What Validate Does Not Check

- whether CI runs or passes
- GitHub expression syntax and context names
- action versions and their availability
- secrets and permissions
- runner labels
- rulesets and branch protection
- YAML outside the reader subset
- coverage values and thresholds
- hook behavior
- symlinks and reparse points
- files the manifest does not list
- integration choices that are correct but unusual
