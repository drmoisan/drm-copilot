# Codex-native converter

The Codex-native converter reviews or applies a deterministic migration from a supported source runtime surface into the Codex-native layout used by this repository.

This package is the authoritative Python implementation behind the repository CLI, the VS Code wrapper, and the MCP wrapper.

## What it does

The converter reads one supported source tree, classifies the source artifacts, plans the native destination paths, validates the generated output, and then writes a stable artifact set for review.

It supports two modes:

- `review`: generate reports and a `proposed-tree/` snapshot without writing destination files
- `apply`: generate the same reports and write destination files only when validation has no blocking findings

## How to run it

You can invoke the converter through the installed Poetry script or through the module entry point.

### Review mode

Use review mode when you want to inspect the proposed conversion before allowing destination writes.

- `poetry run codex-native-converter review --source-root <source-root> --source-ecosystem <github-copilot|claude> [--emit-intermediate-state]`
- `python -m scripts.dev_tools.codex_native_converter review --source-root <source-root> --source-ecosystem <github-copilot|claude> [--emit-intermediate-state]`

Example:

- `poetry run codex-native-converter review --source-root tests/fixtures/codex_native_converter/github_copilot --source-ecosystem github-copilot --emit-intermediate-state`
- `poetry run codex-native-converter review --source-root . --source-ecosystem claude --emit-intermediate-state`

### Apply mode

Use apply mode when you want the converter to write native output after validation passes.

- `poetry run codex-native-converter apply --source-root <source-root> --source-ecosystem <github-copilot|claude> --destination-root <destination-root> [--emit-intermediate-state]`
- `python -m scripts.dev_tools.codex_native_converter apply --source-root <source-root> --source-ecosystem <github-copilot|claude> --destination-root <destination-root> [--emit-intermediate-state]`

Example:

- `poetry run codex-native-converter apply --source-root tests/fixtures/codex_native_converter/github_copilot --source-ecosystem github-copilot --destination-root virtual/codex-native-output --emit-intermediate-state`
- `poetry run codex-native-converter apply --source-root . --source-ecosystem claude --destination-root virtual/codex-native-output-from-claude --emit-intermediate-state`

## Options

Both commands accept these options:

| Option | Meaning |
| --- | --- |
| `--source-root` | Root directory that contains the source runtime surface to convert. This must be an existing directory. |
| `--source-ecosystem` | Source runtime type. Supported values are `github-copilot` and `claude`. |
| `--selected-path` | Optional source-root-relative path filter. Repeat this option to limit conversion to specific files or directories beneath the source root. |
| `--artifact-root` | Optional output directory for converter reports. When omitted, the default is `<source-root>/artifacts/codex-native-converter`. |
| `--enable-repo-prompts` | Enables repository-convention `.codex/prompts/**` output when prompt generation is intentionally required. |
| `--emit-intermediate-state` | Writes compiler-like intermediate state JSON artifacts under `<artifact-root>/intermediate/`. |
| `--destination-root` | Required in `apply` mode only. Native output root for generated files. |

## Supported input surfaces

The converter does not scan an entire repository indiscriminately. It only reads the supported top-level source surfaces for the declared ecosystem.

### GitHub Copilot sources

When `--source-ecosystem github-copilot` is selected, the converter scans these locations when they exist:

- `.github/copilot-instructions.md`
- `.github/instructions/`
- `.github/skills/`
- `.github/agents/`
- `.github/prompts/`

### Claude sources

When `--source-ecosystem claude` is selected, the converter scans these locations when they exist:

- `CLAUDE.md`
- `.claude/skills/`
- `.claude/agents/`
- `.claude/hooks/`
- `.claude/settings.json`
- `.claude/rules/`

## What gets written

Every run writes a deterministic report set beneath the artifact root:

- `conversion-report.md`
- `mapping-catalog.json`
- `validation-results.json`
- `proposed-tree/`

The Markdown report summarizes run settings, mapping topology, mapping records, section-level traces, and validation findings.

The CLI also prints two summary lines to stdout:

- the resolved artifact root
- the final validation outcome

## Validation behavior

The converter uses a fail-closed validation model.

- `review` mode always writes the report set so you can inspect findings without mutating a destination tree
- `apply` mode exits with a non-zero status when blocking findings remain and destination output was not written
- `apply` mode requires `--destination-root`

Use the generated `validation-results.json` and `conversion-report.md` artifacts to review blocking findings before rerunning in `apply` mode.

## When to use selected-path filters

Use `--selected-path` when you want to review or apply only a subset of a large source tree.

Examples:

- `--selected-path .github/instructions`
- `--selected-path .github/skills/review-workflow`
- `--selected-path .claude/agents/orchestrator.md`

If you select a directory, the converter includes files beneath that directory. If you select a file, the converter includes that file only.

## Related repository surfaces

- Root overview: `README.md`
- Extension wrapper: `extensions/drm-copilot/README.md`
- CLI implementation: `scripts/dev_tools/codex_native_converter/cli.py`
- Engine implementation: `scripts/dev_tools/codex_native_converter/engine.py`
