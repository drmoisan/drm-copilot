# Remediation Inputs — issue #620

Canonical issue number: 620

## Source

CI-failure remediation trigger (Step S9 CI Green Gate), per `.claude/skills/orchestrate/SKILL.md`
"Remediation Loop — CI-Failure Handling".

- PR: https://github.com/drmoisan/drm-copilot/pull/624
- Head SHA: `7e74ed77b68695eae2b8de2a4179fc97c576e655`
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/33626953902
- Failing required check: `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`
  - Job URL: https://github.com/drmoisan/drm-copilot/actions/runs/33626953902/job/100236843700
  - Sibling job `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` was CANCELLED
    (matrix fail-fast), not independently failing.

## Finding — Severity: Blocking

**Failing test:** `test/lib/push-down/claude-config-carriage.test.ts`
> issue #462 AC6: the Claude push-down publishes the config tree › keeps SOURCE_BLAST_RADIUS in
> step with the committed bundled blast-radius resource

**Failure:**

```
expect(received).toEqual(expected) // deep equality
- Expected  - 1
+ Received  + 0
@@ -8,11 +8,10 @@
      "quality-tiers.yml",
      ".claude/skills/acceptance-criteria-tracking/SKILL.md",
      ".claude/skills/policy-compliance-order/SKILL.md",
      ".claude/agent-memory/**",
      ".agents/skills/**",
-     "scripts/vscode/**",
    ],
    "modules": Object {
      "config": Array [
        "config/**",
      ],
```

**Root cause:** `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` exports a
`SOURCE_BLAST_RADIUS` constant that is a hand-maintained JavaScript object literal intended to
mirror `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` "key for
key" (per the constant's own docstring). Issue #620's fix added `"scripts/vscode/**"` to the real
committed bundled file's `mandate_reads` array but did not update this test fixture literal, so the
drift-guard test `claude-config-carriage.test.ts` correctly detected the fixture is now out of sync
with the real file.

**Required change:** Add `"scripts/vscode/**"` as the eleventh entry in the `mandate_reads` array of
the `SOURCE_BLAST_RADIUS` constant in
`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, immediately after
`".agents/skills/**"`, matching the real committed bundled file exactly (same entry, same position).
This is a test-fixture-only change; no production TypeScript source is affected.

**Scope constraint:** Do not touch `config/blast-radius.json` or
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` again — those are
already correct and reviewed. Do not touch any other part of `config-carriage.test-helpers.ts` or
`claude-config-carriage.test.ts` beyond the one added array entry.
