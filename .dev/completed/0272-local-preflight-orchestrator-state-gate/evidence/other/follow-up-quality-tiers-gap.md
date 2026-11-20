# Follow-up: Absent `quality-tiers.yml` at Repo Root — Issue #272

Timestamp: 2026-07-02T19-46

Per spec.md's Risks & Mitigations, `quality-tiers.yml` does not currently exist at the repository root, despite `.claude/rules/quality-tiers.md` (and its bundled mirror) stating "`quality-tiers.yml` at repo root maps every project to a tier" and "Adding a project without a tier classification fails CI." This is confirmed absent (via `Glob` for `quality-tiers.yml` and `*.yml` at repo root).

This is a **pre-existing, orthogonal gap**, not introduced by issue #272. No plan task in this feature added a tier classification for `scripts/dev_tools/validate_orchestration_artifacts` or any other module, because there is currently no `quality-tiers.yml` file to add an entry to.

Explicitly out of scope for issue #272 (per spec.md's Non-Goals: "Adding `quality-tiers.yml` at the repository root").

**Recommendation:** track introducing `quality-tiers.yml` at repo root, populated per the tier taxonomy in `.claude/rules/quality-tiers.md`, as a separate follow-up issue, since its absence means the tier-classification CI gate referenced by that rule file currently has nothing to enforce.
