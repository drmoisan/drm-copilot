# `2026-02-17-devcontainer-to-host` — User Story

- Issue: #25
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-17T16-38

## Story Statement

- As a repository maintainer, I want a host dependency verification command that compares a machine against the devcontainer dependency baseline, so that I can quickly identify setup gaps before running repo workflows.
- As a new contributor on a fresh host, I want an installation command that installs missing prerequisites and reports anything it cannot install, so that I can reach a working local environment with minimal manual troubleshooting.

## Problem / Why

The repository currently defines a working dependency baseline inside the devcontainer, but developers setting up a fresh host machine must manually infer and install those dependencies. This leads to inconsistent local environments, onboarding delays, and failures that are hard to diagnose. We need a host-side bootstrap workflow that can both verify required dependencies and install missing ones in a repeatable way.


## Personas & Scenarios

- Persona: New contributor bootstrapping a host environment
  - Uses Windows, macOS, or Linux outside the devcontainer.
  - Cares about getting to first successful lint/test run quickly.
  - Has limited knowledge of all tools implied by the devcontainer image and settings.
  - May not have admin rights for every install step.
  - Wants actionable output when something cannot be installed automatically.
- Persona: Maintainer validating environment parity
  - Owns CI/local workflow consistency.
  - Cares that host setup matches the dependency intent defined in `.devcontainer/local/Dockerfile` and `.devcontainer/local/devcontainer.json`.
  - Needs deterministic verify/install behavior to reduce onboarding support time.
  - Wants machine-readable status output for automation and audits.
- Scenario: Fresh host bootstrap to parity-ready state
  - A contributor clones the repo on a new host and runs the host verifier.
  - The verifier reports missing tools (for example runtime/tooling and quality gate dependencies) and exits non-zero.
  - The contributor runs the installer in apply mode.
  - The installer installs auto-installable dependencies, skips already-present ones, and reports blocked items requiring manual action.
  - The contributor reruns the verifier and receives a passing report (or a reduced list of manual-only blockers).
  - Expected outcome: the contributor can execute repository quality workflows without devcontainer-only setup assumptions.


## Acceptance Criteria

- [ ] A host verification script is added and can be run on a fresh machine to report missing dependencies required by this repository.
- [ ] A host installation script is added and installs all auto-installable missing dependencies reported by the verifier.
- [ ] Running verifier before install reports missing prerequisites; running verifier after install reports no missing auto-installable prerequisites.
- [ ] Installer is idempotent: running it repeatedly does not reinstall already-satisfied dependencies.
- [ ] Verification/install output includes per-dependency status (`present`, `installed`, `missing`, `failed`, `skipped`) and clear next steps.
- [ ] Scripts handle OS differences gracefully and report unsupported platforms explicitly.


## Non-Goals

- Replacing devcontainer setup; this feature complements host setup and does not remove container workflows.
- Installing VS Code extensions from `devcontainer.json`; host bootstrap targets runtime/tool dependencies, not editor personalization.
- Managing unrelated global developer tooling not required by repository workflows.
- Silently escalating privileges; elevation-requiring steps must be explicit and user-confirmed.
- Guaranteeing identical package manager behavior across every OS/distribution; unsupported combinations must fail clearly with remediation guidance.
