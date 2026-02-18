# devcontainer-to-host (Issue #25)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/devcontainer-to-host/ (Issue #25)

- Issue: #25
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/25
- Last Updated: 2026-02-17
## Problem / Why

The repository currently defines a working dependency baseline inside the devcontainer, but developers setting up a fresh host machine must manually infer and install those dependencies. This leads to inconsistent local environments, onboarding delays, and failures that are hard to diagnose. We need a host-side bootstrap workflow that can both verify required dependencies and install missing ones in a repeatable way.

## Proposed Behavior

Deliver host bootstrap tooling that maps devcontainer dependencies to host prerequisites and automates setup.

Required outputs:
- A verification script that checks whether required host dependencies are present and usable.
- An installation script that installs any missing dependencies identified by the verifier.

Required verification scope:
- Core CLI/runtime prerequisites used by this repo workflows (for example: `git`, `python`, `poetry`, `pwsh`, `node`, `npm`, and required PowerShell modules/tooling).
- Repository-specific tooling expected by local quality workflows (for example: action linting/toolchain commands, shell quality dependencies, and PowerShell test/analyzer modules).
- Version/compatibility checks where minimum versions are required by repo policy or devcontainer baseline.

Required installation behavior:
- Detect host OS and run platform-appropriate installation steps.
- Install only missing dependencies (idempotent behavior).
- Support a preview mode (no changes) and an apply mode (perform installs).
- Produce a machine-readable and human-readable summary of installed, already-present, failed, and skipped items.

Required script UX:
- `verify` command exits non-zero when required dependencies are missing.
- `install` command can optionally run verification before and after installation.
- Clear remediation hints are printed for any dependency that cannot be auto-installed.

## Acceptance Criteria (early draft)

- [ ] A host verification script is added and can be run on a fresh machine to report missing dependencies required by this repository.
- [ ] A host installation script is added and installs all auto-installable missing dependencies reported by the verifier.
- [ ] Running verifier before install reports missing prerequisites; running verifier after install reports no missing auto-installable prerequisites.
- [ ] Installer is idempotent: running it repeatedly does not reinstall already-satisfied dependencies.
- [ ] Verification/install output includes per-dependency status (`present`, `installed`, `missing`, `failed`, `skipped`) and clear next steps.
- [ ] Scripts handle OS differences gracefully and report unsupported platforms explicitly.

## Constraints & Risks

- Do not assume administrator privileges; document when elevation is required and continue with best-effort installs for the rest.
- Keep host bootstrap scoped to dependencies required for repository workflows; avoid installing unrelated tools.
- Preserve deterministic behavior by pinning versions where the repo requires known-good versions.
- Risk: package manager differences across Windows/macOS/Linux may make full automation uneven.
- Risk: some dependencies (or versions) may be unavailable on certain hosts; scripts must provide manual fallback instructions.
- Risk: host environment drift over time if devcontainer dependency updates are not reflected in bootstrap requirements.

## Test Conditions to Consider

- [ ] Unit coverage areas: dependency detection functions, version parsing, OS/package-manager routing, and status aggregation.
- [ ] Unit coverage areas: installer decision logic (install vs skip vs fail) and idempotency checks.
- [ ] Integration scenarios: run verifier on a host with missing tools; confirm expected missing list and non-zero exit code.
- [ ] Integration scenarios: run installer, then verifier; confirm missing auto-installable dependencies are resolved.
- [ ] Integration scenarios: simulate partial install failures and verify actionable failure summary is emitted.
- [ ] CLI/API examples: `verify --format json` for machine-readable output and `install --dry-run` for preview.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/devcontainer-to-host/` folder from the template
- [ ] Add `spec.md` defining required dependency matrix by OS, minimum versions, and command contracts.
- [ ] Add `user-story.md` acceptance criteria for first-time host setup success and repeatable re-runs.
