# npm-audit-gate-and-dependabot

- Work Mode: minor-audit

## Problem / Why

Follow-up to PR #209 (`fix(deps): eliminate npm audit vulnerabilities`). That work
revealed the repository has three independently installed npm manifests (root,
`extensions/drm-copilot`, `packages/mcp-server`), each with its own lockfile. The
sub-manifest lockfiles had drifted to stale, vulnerable transitive pins independently
of the root. Without an automated gate, that staleness can silently reintroduce
vulnerabilities, and newly disclosed advisories against the committed lockfiles would
go unnoticed between manual installs.

## Implementation Intent

Add two complementary, automated mechanisms:

1. A reusable `npm audit` gate (`_npm-audit-gate.yml`) that runs `npm ci` (verifying
   lockfile/manifest sync) and `npm audit --audit-level=moderate` across all three
   manifests via a matrix. A thin caller (`npm-audit-gate.yml`) runs it weekly on a
   schedule, on pull requests that touch any `package.json` / `package-lock.json` or
   the gate workflows, and on manual dispatch.
2. Dependabot configuration (`.github/dependabot.yml`) for weekly grouped npm version
   updates across the three manifest directories plus the `github-actions` ecosystem.
   This is the lockfile-refresh mechanism: Dependabot opens PRs to bump dependencies,
   which the audit gate then validates.

Follows the repository reusable-workflow convention: callee `_<name>.yml` declares
`workflow_call` + `workflow_dispatch`; the caller wires triggers and references the
callee via `uses: ./.github/workflows/_npm-audit-gate.yml`.

## Acceptance Criteria

- [x] `_npm-audit-gate.yml` declares both `workflow_call` and `workflow_dispatch` and audits all three manifests via matrix.
- [x] `npm-audit-gate.yml` triggers on `schedule`, path-filtered `pull_request`, and `workflow_dispatch`, and calls the reusable workflow.
- [x] The gate runs `npm ci` (lockfile sync check) before `npm audit` for each manifest.
- [x] `.github/dependabot.yml` configures weekly grouped npm updates for `/`, `/extensions/drm-copilot`, `/packages/mcp-server`, and github-actions.
- [x] All workflow YAML passes `actionlint` and parses as valid YAML.
- [x] The gate passes against the current (remediated) lockfiles: `npm audit --audit-level=moderate` exits 0 for all three manifests.
- [ ] A green run of the new gate is observed on the PR (satisfies `modified-workflow-needs-green-run`).

## Dependencies / Risks

- The PR's `pull_request` path filter includes the gate workflow files, so the PR that
  adds the gate triggers a real run, providing the required green workflow run.
- `audit-level` defaults to `moderate` (blocks moderate/high/critical — the severity
  classes from the PR #209 incident) and is exposed as a workflow input so it can be
  tightened to `low` if desired. This avoids excessive PR friction from frequently
  disclosed low-severity advisories in dev tooling.
- Dependabot will open grouped PRs weekly; `open-pull-requests-limit` is capped at 5
  per ecosystem to bound noise.

## Verification Steps

1. `python -c "import yaml; ..."` parses all three files.
2. `actionlint .github/workflows/_npm-audit-gate.yml .github/workflows/npm-audit-gate.yml` exits 0.
3. For each manifest: `npm audit --audit-level=moderate` exits 0.
4. Observe the `npm Audit Gate` checks pass on the PR.

## Evidence Checklist

- [x] baseline — PR #209 established 0 vulnerabilities across all three manifests.
- [x] targeted verification — YAML parse, actionlint exit 0, local audit exit 0 per manifest.
- [ ] end-state — green `npm Audit Gate` run observed on the PR.

## References

- Prior PR: https://github.com/drmoisan/drm-copilot/pull/209
- Reusable-workflow convention: `.claude/skills/orchestrate/SKILL.md` (GitHub Actions Reusable Workflows)
- CI workflow authoring rule: `.claude/rules/ci-workflows.md`
