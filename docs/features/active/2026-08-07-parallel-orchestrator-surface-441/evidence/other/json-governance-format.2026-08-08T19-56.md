# JSON Governance — Format Check on `core.json`

Timestamp: 2026-08-08T19-56

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

Argument form resolved from `poetry run python -m scripts.dev_tools.format_json --help` before running:

```
usage: format_json.py [-h] [--check] [--verbose] [paths ...]
Format governed JSON files with sorted keys
positional arguments:
  paths       Optional specific files/dirs; defaults to governed globs
options:
  --check     Only check; exit non-zero if changes needed
  --verbose   Print per-file status
```

## Command 1 — `core.json` unmodified by this cycle

Command: `git diff --name-only -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

EXIT_CODE: 0

Output Summary: empty output. `core.json` is byte-identical to its state at HEAD
`41633ad5e867070853e3e4501c3457b6641d1efc`; this remediation cycle adds no `.claude` file and therefore
adds, removes, and reorders no manifest entry. This half of the `[P4-T7]` acceptance is met.

## Command 2 — explicit-path format check

Command: `poetry run python -m scripts.dev_tools.format_json --check --verbose extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

EXIT_CODE: **1**

Output Summary:

```
extensions\drm-copilot\resources\claude-customizations\pack-manifests\core.json: would reformat
```

The `[P4-T7]` acceptance condition "the format check exits 0 reporting no change needed" is **NOT
met**. The cause is pre-existing and is not attributable to this cycle. Two independent measurements
establish that:

1. **`core.json` is outside the repository's governed JSON set.** `scripts/dev_tools/json_config.py`
   defines `GOVERNED_GLOBS` as exactly `("scripts/**/*.json", "docs/**/*.json", "examples/**/*.json")`.
   `extensions/**` is not among them, so `core.json` is not a governed JSON file and the repository's
   own governance run never applies the sorted-key convention to it. Supplying the path explicitly
   bypasses the governed-glob filter and forces that convention onto an ungoverned file.
2. **The same result holds at the merge base.** The merge-base version of the file
   (`git show ee0626e838109fe8d3fe3904fb4631c71879baa3:extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`)
   reports `would reformat` and exits 1 under the identical explicit-path invocation. The condition
   therefore predates this branch, let alone this remediation cycle.

## Command 3 — repository-governed default run (context)

Command: `poetry run python -m scripts.dev_tools.format_json --check`

EXIT_CODE: **1**

Output Summary: 9 files reported `would reformat`, none of which is `core.json` and none of which is
touched by this cycle. They are pre-existing evidence artifacts and templates belonging to other
features (for example
`docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json`
and the seven `docs/discovery/templates/artifacts/*.template.json` files). This repo-wide condition is
pre-existing and out of this cycle's scope.

## Disposition

`core.json` was NOT reformatted. Reformatting it would contradict this plan's hard constraint that
source files and their bundled mirrors must not diverge from the state under review, this plan's
`## Exit Criteria` item 5 ("`core.json` remains unmodified"), and the directive's scope of four items.
The non-zero exit is recorded here as a pre-existing, out-of-scope condition and is escalated in the
execution report rather than remediated silently.
