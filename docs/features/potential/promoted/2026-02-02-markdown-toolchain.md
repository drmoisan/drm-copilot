# markdown-toolchain (Issue #5)

- Date captured: 2026-02-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/markdown-toolchain/ (Issue #5)

- Issue: #5
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/5
- Last Updated: 2026-02-02
## Problem / Why

The repo has strong, first-class QC toolchains for multiple asset types (Python, PowerShell, Shell, JSON, TypeScript), but Markdown is currently only partially supported.

Today we have a specialized Markdown formatter for chat transcripts (`scripts/dev_tools/markdown_label_formatter.py`) exposed as the VS Code task "Copilot MD: format current chat file". However, the broader documentation surface (e.g., `README.md`, `CHANGELOG.md`, `docs/**/*.md`, feature docs under `docs/features/**`) lacks a consistent, repo-wide formatting + linting toolchain.

This leads to avoidable review churn (style nits, inconsistent wrapping), subtle documentation quality issues (broken link patterns, inconsistent headings), and an uneven developer experience compared to code toolchains that are one-command reproducible.

## Proposed Behavior

Add a dedicated Markdown QC toolchain with the same "shape" as other repo toolchains:

- Formatting (auto-fix) for governed Markdown files.
- Linting (non-mutating verification) with clear, actionable output.
- Optional "test" equivalents where feasible (e.g., link checking), explicitly scoped to remain deterministic and offline.

Scope and integration points (aligned to current repo conventions):

1) Define the governed Markdown globs

- Include: `README.md`, `CHANGELOG.md`, `docs/**/*.md`, `.github/**/*.md` (if present)
- Exclude: `coverage/**`, `artifacts/**`, `node_modules/**` and other generated outputs

2) Provide CLI entry points

- Format:
	- Preferred approach: Prettier for Markdown, since the repo already uses Prettier for TypeScript/JS/JSON.
	- Example: `npm run format:md` (writes in place)
	- Example check mode: `npm run format:md:check`
- Lint:
	- Add a Markdown linter (e.g., `markdownlint-cli2`) configured for the repo.
	- Example: `npm run lint:md`

3) Provide VS Code tasks (developer workflow parity)

Add tasks similar to existing conventions:

- `MD: 1 Prettier: format`
- `MD: 2 Markdownlint: lint`
- (Optional) `MD: 3 Markdown: link check` (only if it can be deterministic/offline)

4) Optional: integrate into repo-wide orchestration

- Add Markdown steps to `QC: 5 Run All Checks` in `.vscode/tasks.json`.
- Add a `markdown` branch to the automated multi-language pipeline `scripts/dev_tools/fix_all.py` so it can run in parallel with `json`, `shell`, `python`, `powershell`.
	- Minimal branch: format → lint.
	- If a "test" step is added (link check), run it last.

5) Preserve the existing chat transcript formatter

- Keep `scripts/dev_tools/markdown_label_formatter.py` and the task "Copilot MD: format current chat file" as a specialized tool.
- Do not conflate chat transcript normalization with general Markdown formatting/linting; they serve different intents.

## Acceptance Criteria (early draft)

- [ ] The repo has a reproducible Markdown formatting command that rewrites governed Markdown files deterministically.
- [ ] The repo has a reproducible Markdown lint command that checks governed Markdown files and fails with actionable output on violations.
- [ ] VS Code tasks exist for Markdown format and Markdown lint using the same naming conventions as other toolchains.
- [ ] The Markdown toolchain is documented in `docs/developer-tooling.md` alongside other QC toolchains.
- [ ] (If integrated) `QC: 5 Run All Checks` includes the Markdown steps in a defined order and still runs deterministically.
- [ ] (If integrated) `scripts/dev_tools/fix_all.py` includes a `markdown` branch that runs the Markdown toolchain steps and reports PASS/FAIL/SKIP in the status output.
- [ ] The existing "Copilot MD: format current chat file" task remains available and continues to work unchanged.

## Constraints & Risks

- Tool choice and dependency policy: Markdown linting likely requires adding a Node dev dependency (e.g., `markdownlint-cli2`) unless an existing approved tool is reused.
- Windows compatibility: commands must run reliably on Windows (PowerShell/CMD) since the repo supports Windows development.
- Determinism and offline operation:
	- Markdown linting is local and deterministic.
	- Link checking is attractive as a "test" equivalent but can become flaky if it touches the network. If link checking is added, it should be limited to local relative links (or otherwise explicitly marked as an integration/CI-only check).
- Formatting churn: enabling Markdown formatting repo-wide can reflow many files. Rollout should be staged (start with `docs/features/**` or a subset) or done in a single explicit formatting PR.
- Markdown dialect differences: Prettier + markdownlint rules must be configured so they do not fight each other (rule alignment is important).

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] If a Python wrapper script is introduced (optional), unit test its file selection/glob logic and command invocation plan.
	- [ ] If the toolchain is integrated into `scripts/dev_tools/fix_all.py`, add unit tests that verify:
		- Markdown branch executes the correct commands in order
		- Branch status is reported correctly on success/failure
		- Branch can be skipped when no governed Markdown files exist (optional)
- [ ] Integration scenarios
	- [ ] A markdown-only change can be fully validated by running the Markdown toolchain tasks.
	- [ ] `QC: 5 Run All Checks` (if updated) runs Markdown steps and still completes successfully.
	- [ ] `QC: 0 Fix All` (if updated) runs Markdown in parallel without affecting existing branches.
- [ ] CLI/API examples
	- [ ] `npm run format:md`
	- [ ] `npm run format:md:check`
	- [ ] `npm run lint:md`
	- [ ] (If integrated) `poetry run python -m scripts.dev_tools.fix_all` includes a `markdown` branch and returns non-zero on Markdown failures.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/markdown-toolchain/` folder from the template
