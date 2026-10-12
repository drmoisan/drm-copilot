# Code-Point Order Tests - Red Run Against Unconverted Sources (P1-T16 step 2) [expect-fail]

Timestamp: 2026-10-12T15-03
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/push-down/claude-pack-selection.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/subagent-tree/tree-assembler.test.ts test/lib/subagent-tree/tree-formatter.test.ts test/lib/resolve/file-prompt-transforms.test.ts test/lib/validate/codex-topology-resolver.test.ts test/lib/validate/epic-orchestrator-state-core.ordering.test.ts test/lib/validate/epic-planner-git-integrity.test.ts test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-core.test.ts test/lib/validate/orchestrator-state-model-routing-existence.test.ts -t "889-cp-order"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Test Suites: 11 failed, 11 total`
- `Tests:       14 failed, 127 skipped, 141 total`
- No suite reported `Test suite failed to run`. The `Tests:` line contains `14 failed` and no `passed`.
- Per-test received (default UTF-16 order) output. In every case U+1F600 (😀) appeared before U+FF5E (～):
  1. claude-pack-selection.test.ts `loadPackManifests > 889-cp-order: loads missing manifests in code-point order (U+FF5E before U+1F600)`: received message `Pack manifest is missing for pack '😀': /bundle/pack-manifests/😀.json` (expected pattern `/^Pack manifest is missing for pack '～'/u`).
  2. codex-pack-selection.test.ts `Codex loadPackManifests > 889-cp-order: lists unknown pack names in code-point order (U+FF5E before U+1F600)`: received `Unknown Codex pack name(s): 😀,～`; expected `Unknown Codex pack name(s): ～,😀`.
  3. codex-pack-selection.test.ts `Codex resolveManifestPackNames > 889-cp-order: lists unknown public pack names in code-point order (U+FF5E before U+1F600)`: received `Unknown Codex pack name(s): 😀,～`; expected `Unknown Codex pack name(s): ～,😀`.
  4. tree-assembler.test.ts `assembleTree > 889-cp-order: sorts root models in code-point order (U+FF5E before U+1F600)`: received `["😀", "～"]`; expected `["～", "😀"]`.
  5. tree-formatter.test.ts `formatTree > 889-cp-order: renders models in code-point order (U+FF5E before U+1F600)`: received `root · [😀,～] · 0 · `; expected `root · [～,😀] · 0 · `.
  6. file-prompt-transforms.test.ts `replaceAllVariables code-point ordering > 889-cp-order: reports missing variables in code-point order (U+FF5E before U+1F600)`: received `Unresolved template variables: 😀, ～`; expected `Unresolved template variables: ～, 😀`.
  7. file-prompt-transforms.test.ts `replaceAllVariables code-point ordering > 889-cp-order: substitutes keys in code-point order (U+FF5E before U+1F600)`: threw `Template resolution failed: unresolved placeholders remain` (U+1F600 key substituted first, leaving `${😀}`); expected return value `donedone`.
  8. codex-topology-resolver.test.ts `resolveCodexTopology > 889-cp-order: normalizes languages in code-point order (U+FF5E before U+1F600)`: received languages `["😀", "～"]`; expected `["～", "😀"]`.
  9. epic-orchestrator-state-core.ordering.test.ts `validateEpicOrchestratorStateText duplicate-folder ordering > 889-cp-order: reports duplicate feature folders in code-point order (U+FF5E before U+1F600)`: received duplicate-folder messages ending `😀` then `～`; expected `～` then `😀`.
  10. epic-planner-git-integrity.test.ts `validatePlanningGitIntegrity > 889-cp-order: reports unknown planner paths in code-point order (U+FF5E before U+1F600)`: received `'😀'` message before `'～'` message; expected the reverse.
  11. orchestrator-state-codex-model-routing.test.ts `Codex model-routing checkpoint receipts > 889-cp-order: reports missing receipts in code-point order (U+FF5E before U+1F600)`: received the `😀.` message before the `～.` message; expected the reverse.
  12. orchestrator-state-core.test.ts `validateOrchestratorStateText delegation receipts > 889-cp-order: reports unsupported top-level keys in code-point order (U+FF5E before U+1F600)`: received `...unsupported key: 😀` before `...unsupported key: ～`; expected the reverse.
  13. orchestrator-state-core.test.ts `validateOrchestratorStateText delegation receipts > 889-cp-order: reports unsupported promotion keys in code-point order (U+FF5E before U+1F600)`: received `...promotion contains unsupported key: 😀` before `...: ～`; expected the reverse.
  14. orchestrator-state-model-routing-existence.test.ts `validateModelRoutingExistence ordering > 889-cp-order: reports missing receipts in code-point order (U+FF5E before U+1F600)`: received the `😀.` message before the `～.` message; expected the reverse.
- Raw output was captured to a scratch file outside the repository (session scratchpad `889/issue-889-p1t16-red.txt`, not committed).
