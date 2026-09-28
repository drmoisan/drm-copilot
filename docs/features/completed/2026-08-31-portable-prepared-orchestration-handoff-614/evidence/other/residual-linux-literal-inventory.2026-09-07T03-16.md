# Residual Drive-Letter Literal Inventory — [P2-T15]

Timestamp: 2026-09-07T12-22
Task: [P2-T15]

Command: search 1, `Get-ChildItem -LiteralPath extensions/drm-copilot/test -Recurse -Include *.ts | Select-String -Pattern '"[A-Za-z]:/' -CaseSensitive`; search 2, the same enumeration piped to `Select-String -Pattern 'transition_prepared_orchestration|resolve_orchestration_topology|resolve_provider_routing|resolvePortableHandoffAuthority|handlePortableHandoffTool|OrchestrationHandoffMaterializer|createNodeHandoffPathBoundary|createSyntacticHandoffPathBoundary|createProductionHandoffMaterializer' -CaseSensitive`; search 3, the intersection of the path sets those two searches produce
EXIT_CODE: 0

**No file was modified by this task.** A `git status --porcelain=v1 --untracked-files=all` capture taken before and after this task differs only by the two evidence artifacts written by [P2-T13] and [P2-T14]; no source file appears in the delta.

## Search 1 — residual literal inventory

```
LITERAL_MATCHES=654
LITERAL_FILES=77
```

## Search 2 — reachability filter

```
REACH_MATCHES=64
REACH_FILES=11
```

## Search 3 — the intersection

```
INTERSECTION_FILES=5
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts
extensions/drm-copilot/test/mcp-server.test.ts
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts
```

Three of the five are among the seven paths this plan authorizes. Subtracting the authorized seven leaves exactly two files, which is the count the acceptance requires.

The three authorized files remain in the literal inventory because the pattern matches any drive letter, not only the workspace root that Phase 1 removed. Their residual literals are: `orchestration-handoff-materializer.test.ts` line 109, the deliberate `"C:/other"` mismatch value [P1-T4] preserved; `mcp-server.test.ts` lines 405, 409, and 433; and `repo-automation-orchestration-validation.test.ts` lines 202, 218, 244, 269, 293, 318, and 395, which are `"C:/extension"` extension-root values. None is a workspace root and none reaches an absolute-path predicate. The [P1-T13] gate confirms all seven authorized files carry 0 occurrences of the workspace-root literal.

## The four production predicates the intersection is judged against

- `orchestration-handoff-materializer-support.ts` lines 19 and 36
- `orchestration-handoff-path-boundary.ts` line 110
- `orchestration-handoff-handlers.ts` lines 107 and 154
- `orchestration-handoff-authority-service.ts` line 59

## Out-of-scope file 1 — `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`

Seven drive-letter literals, at lines 56, 277, 278, 344, 354, 380, and 466. The observed line numbers match the plan's citation exactly.

They never reach `orchestration-handoff-authority-service.ts` line 59. `createScenario` injects a `pathBoundary` object at lines 147 through 156, read from the current tree:

```
  const pathBoundary: HandoffPathBoundary = {
    resolveWorkspaceRoot: jest.fn(() => canonicalWorkspaceRoot),
    resolveExistingTarget: jest.fn((_root, repositoryPath) => {
      if (blockedPaths.has(repositoryPath)) return null;
      if (repositoryPath === handoffEnvelopePath) return canonicalEnvelopePath;
      if (repositoryPath === expectedPlanPath) return canonicalPlanPath;
      return null;
    }),
    resolveCreatableTarget: jest.fn(() => null),
  };
```

Its `resolveWorkspaceRoot` at line 148 returns `canonicalWorkspaceRoot` unconditionally, and its `resolveExistingTarget` at lines 149 through 154 returns the canonical constants declared at lines 57 and 58:

```
const canonicalWorkspaceRoot = "C:/canonical-workspace";
const canonicalEnvelopePath = `${canonicalWorkspaceRoot}/handoff.json`;
const canonicalPlanPath = `${canonicalWorkspaceRoot}/plan.md`;
```

`resolvePortableHandoffAuthority` selects the injected boundary at line 271:

```
    pathBoundary ?? createDefaultPathBoundary(fileSystem);
```

so `createDefaultPathBoundary` is never constructed and its `path.isAbsolute` call at line 59 is never evaluated. Every remaining literal in that test file flows only into string comparisons performed by the production module, in `collectObservationFailures` (declared at line 183, comparisons at lines 189 through 200) and `collectPrePlanFailures` (declared at line 209, comparisons at lines 215 through 230). Both declaration lines were re-read from the current tree and confirmed. A string comparison is platform-independent, so these literals are platform-neutral in effect.

## Out-of-scope file 2 — `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`

Three drive-letter literals, at lines 19, 40, and 183, matching the plan's citation.

The reason is the one recorded in the CI-614-002 finding. Its mocked `resolveWorkspaceRoot` at lines 119 through 121, read from the current tree:

```
  const pathBoundary = {
    resolveWorkspaceRoot: jest.fn(() => canonicalWorkspaceRoot),
    resolveExistingTarget: jest.fn(
```

returns `canonicalWorkspaceRoot` unconditionally, and `binding.workspaceRoot` at line 40 and `request.workspaceRoot` at line 183 are compared to each other by string equality at `orchestration-handoff-materializer.ts` line 210:

```
    if (envelope.binding.workspaceRoot !== request.workspaceRoot) {
```

They are never resolved, so the literals are platform-neutral in effect.

Output Summary: `EXIT_CODE: 0`, and no file was modified by this task. Search 1 records 654 matches across 77 files, search 2 records 64 matches across 11 files, and the intersection contains 5 files. Subtracting the seven paths this plan authorizes leaves exactly two files, and each was verified against the current tree to reach none of the four production absolute-path predicates on a success path: `orchestration-handoff-authority-service.test.ts` because `resolvePortableHandoffAuthority` selects an injected boundary and never constructs the default one, and `orchestration-handoff-materializer-path-boundary.test.ts` because its boundary is mocked and its two workspace roots are compared by string equality rather than resolved. The residual drive-letter literals in the extension test tree therefore carry no platform dependence on the handoff success path.
