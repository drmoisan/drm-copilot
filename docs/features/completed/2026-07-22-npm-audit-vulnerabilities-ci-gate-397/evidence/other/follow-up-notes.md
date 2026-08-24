# Follow-up Notes — Issue #397

## [P9-T1] Residual-Risk Follow-up

npm `overrides` only apply at this repository's install root; they do not protect downstream consumers of the published `@danmoisan/drm-copilot-mcp` package, since `overrides` are not propagated through the npm dependency resolution of a package's own consumers. Per `spec.md` (`Risks & Mitigations`): the shipped `out/mcp-server.js` is a self-contained esbuild bundle that never loads `@hono/node-server` at runtime, so this risk does not apply to the published artifact itself — but any consumer who installs `@modelcontextprotocol/sdk` transitively through this package without their own override would still see the underlying advisory in their own `npm audit` output.

**Follow-up action:** Track `modelcontextprotocol/typescript-sdk` upstream for a release that removes or bumps its unused `@hono/node-server`/`hono` dependencies, then drop the local `overrides` pins added by this fix (`@hono/node-server`, and the raised `fast-uri`/`hono`/`brace-expansion` floors, once the SDK's own declared ranges make them redundant). Per `spec.md` (`Rollout & Follow-up`): "track `modelcontextprotocol/typescript-sdk` upstream for a release that removes or bumps its unused `@hono/node-server`/`hono` dependencies, then drop the local `overrides` pins."

## [P9-T2] Traceability Links

- **Issue:** [#397](https://github.com/drmoisan/drm-copilot/issues/397)
- **Issue update comment:** https://github.com/drmoisan/drm-copilot/issues/397#issuecomment-5045794889
- **PR:** not yet created — deferred to the orchestrator per the explicit "do not commit or push" execution directive for this session (see `evidence/other/pr-prep-notes.2026-07-22T12-15.md` for prepared PR title/body).
- **Spec:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md`
- **Research artifact:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/research/2026-07-22-npm-audit-fix-strategy.md`
- **Plan:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/plan.2026-07-22T07-54.md`
