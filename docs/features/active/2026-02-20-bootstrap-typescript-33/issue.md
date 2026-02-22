# bootstrap-typescript (Issue #33)

- Date captured: 2026-02-20
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-typescript/ (Issue #33)

- Issue: #33
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/33
- Last Updated: 2026-02-21

- Work Mode: minor-audit

## Problem / Why

The repo is a VS Code extension written in TypeScript, but the TypeScript toolchain needs to be treated as a first-class, deterministic quality gate (format, lint, type-check, unit tests) just like the Python and PowerShell gates.

Right now it is too easy for TypeScript quality checks to become “best-effort”: commands drift, tasks/commands may not match the repo’s scripts, and CI/local developer workflows may not consistently enforce the same baseline.

This feature aims to make TypeScript quality checks boring, reliable, and discoverable, so baseline tooling and VS Code tasks/commands work out-of-the-box.

## Proposed Behavior

Provide a deterministic TypeScript ecosystem in this repo with:

- Formatting (Prettier)
- Linting (ESLint)
- Type checking (tsc in strict mode)
- Unit testing (Jest + ts-jest)

And ensure these are wired consistently across:

- `npm run ...` scripts (source of truth)
- VS Code tasks/commands exposed by the extension (e.g., TS 1/2/3/4 tasks)
- Documentation in `docs/developer-tooling.md` (single place to learn how to run gates)

The outcome should be that a contributor can run the TypeScript gates in a clean checkout without global installs beyond Node.js, and get the same results locally and in CI.

## Acceptance Criteria (early draft)

- [ ] The repo defines a stable “TypeScript toolchain pass” consisting of:
	- `npm run format:check`
	- `npm run lint`
	- `npm run typecheck`
	- `npm run test:unit`
- [ ] The TypeScript toolchain pass runs successfully on Windows using only repo-managed devDependencies (no global Prettier/ESLint/Jest installs).
- [ ] VS Code commands exposed by the extension for TS quality checks execute the corresponding `npm run ...` scripts (or an explicitly documented equivalent) in a way that is:
	- workspace-rooted (correct cwd)
	- cross-platform (Windows/macOS/Linux)
	- consistent with the repo’s “toolchain loop” philosophy
- [ ] TypeScript unit tests exist for at least one non-trivial utility module (to verify the harness works, not just that it compiles).
- [ ] `docs/developer-tooling.md` documents the TypeScript commands alongside the existing Python/PowerShell quality gates.
- [ ] Any CI workflow that runs repository quality gates includes the TypeScript toolchain pass (or clearly documents why it is excluded).

## Constraints & Risks

- Cross-platform path/quoting risk:
	- Node/NPX commands and working directory assumptions must behave the same on Windows and POSIX shells.
- Avoid competing formatters:
	- Prettier should be the authoritative formatter for TS/JS/JSON in the TypeScript surface area; ESLint should not fight formatting rules.
- Keep dependencies minimal:
	- Prefer using the existing devDependencies already present in `package.json` unless a missing piece is clearly required.
- VS Code extension packaging risk:
	- Build outputs (`out/`) and test outputs must remain excluded from lint/test inputs where appropriate.
- Scope creep risk:
	- This feature should focus on baseline tooling + tasks/commands; avoid expanding into a full “monorepo build system” effort.

## Test Conditions to Consider

- [ ] Formatting:
	- `npm run format:check` fails when a file is intentionally misformatted, and passes after `npm run format`.
- [ ] Linting:
	- `npm run lint` flags a deliberate rule violation in a `.ts` file.
- [ ] Typing:
	- `npm run typecheck` fails on an intentional strictness violation and passes when corrected.
- [ ] Unit tests:
	- `npm run test:unit` runs at least one `.test.ts` under `tests/unit/`.
- [ ] VS Code command wiring:
	- Running “DRM Copilot: TS 1 - Prettier Format” (and TS 2/3/4 equivalents) executes the same underlying behavior as the `npm run ...` scripts.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/<YYYY-MM-DD>-bootstrap-typescript-<issue>/` folder from the template
- [ ] Decide initial work mode expectation when promoting:
	- Default to `full` unless the work ends up fitting the `minor-audit` eligibility rule (<=3 production files, low integration risk).