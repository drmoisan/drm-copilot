# TypeScript Test-Tree Type-Check Baseline — [P0-T9]

Timestamp: 2026-09-07T11-10
Task: [P0-T9]
Head: fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1

Command: `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
EXIT_CODE: 2

## Why this configuration

The extension `typecheck` script is `tsc -p ./ --noEmit`, and `extensions/drm-copilot/tsconfig.json` carries `"include": ["src/**/*.ts"]`, so it never reads a file under `extensions/drm-copilot/test/`. `extensions/drm-copilot/tsconfig.jest.json` is the configuration that includes `test/**/*.ts`, so it is the program the Phase 1 type gates assert against.

## Observed result

`tsc` exited 2 and printed 463 output lines, of which 331 are `error TS` lines. No trailing `Found` count line was printed: this `tsc` invocation runs in non-pretty, non-watch mode, which emits diagnostics without a summary count. That is the observed success-case output shape of the command and is recorded here rather than inferred.

The 331 `error TS` lines span 69 distinct files. Every one of them pre-exists this plan: no source file has been modified at the time of this capture, and [P0-T2] recorded a worktree carrying only three untracked documentation and evidence paths.

## Consequence for the Phase 1 type gates — first clause is unsatisfiable as written

Tasks [P1-T1], [P1-T3], [P1-T7], [P1-T9], and [P1-T10] each state a two-clause type acceptance:

1. `tsc` "emits no `error TS` line naming any path this plan changes", and
2. `tsc` "emits no `error TS` line absent from the baseline diagnostic set recorded by P0-T9".

Clause 1 is already false at this baseline, before any edit. Sixteen baseline `error TS` lines name five of the seven TypeScript paths this plan changes:

```
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts(280,7): error TS2345: Argument of type '(targetPath: string) => string' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts(96,7): error TS2345: Argument of type '(targetPath: string) => string' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(276,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(279,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(282,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-server.test.ts(445,46): error TS2339: Property 'mockResolvedValue' does not exist on type '(input: TransitionPreparedOrchestrationRequest) => Promise<TransitionPreparedOrchestrationResult>'.
extensions/drm-copilot/test/mcp-server-test-service.ts(28,5): error TS2322: Type 'Mock<UnknownFunction>' is not assignable to type '(input: TransitionPreparedOrchestrationRequest) => Promise<TransitionPreparedOrchestrationResult>'.
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(156,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(190,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(191,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(208,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(234,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(259,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(283,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(308,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(385,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
```

Counts by changed path: `repo-automation-orchestration-validation.test.ts` 9; `mcp-handlers/orchestration-handoff-handlers.test.ts` 3; `orchestration-handoff-materializer-production.test.ts` 2; `mcp-server-test-service.ts` 1; `mcp-server.test.ts` 1. The two remaining changed paths, `orchestration-handoff-materializer-test-support.ts` and `orchestration-handoff-materializer.test.ts`, carry zero baseline diagnostics.

None of these sixteen diagnostics concerns a workspace-root literal. They are pre-existing structural typing gaps: a `VirtualFileSystem` class that does not implement three newer `FileSystem` members, index-signature property access under `noPropertyAccessFromIndexSignature`, and Jest mock-typing mismatches. This plan is test-only and changes no type surface, so nothing it does can clear them, and clearing them would be work the plan does not describe and does not authorize.

Clause 1 is therefore recorded as unsatisfiable at baseline for those five paths. It is not restated as satisfied at any Phase 1 task. Clause 2 is falsifiable and is the operative gate: each Phase 1 type check is evaluated against the baseline set below, and any diagnostic absent from that set is a regression introduced by this plan.

## Comparison basis for clause 2

Phase 1 tasks insert lines into the files they edit, so a diagnostic's reported line and column shift even when the diagnostic itself is unchanged. Comparing raw `error TS` lines would report such a shift as a new diagnostic, which it is not. The comparison basis is therefore the diagnostic normalized by removing the `(line,column)` span, leaving `<path>: error TS<code>: <message>`. The normalized baseline holds 331 entries, 170 of them distinct.

A Phase 1 type gate passes clause 2 when the normalized post-change set contains no entry absent from the normalized baseline set below, and it is additionally recorded whether the per-file `error TS` count for each changed path is unchanged.

## Baseline diagnostic set — all 331 `error TS` lines, sorted

```
extensions/drm-copilot/src/lib/codex-native-converter/index.ts(18,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/index.ts(21,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/index.ts(23,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/index.ts(32,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/models.ts(25,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/models.ts(26,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/models.ts(28,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/models.ts(30,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/src/lib/codex-native-converter/models.ts(32,3): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
extensions/drm-copilot/test/codex-native-converter-handlers.test.ts(37,66): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(148,46): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(186,46): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(214,46): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(248,46): error TS2345: Argument of type '"   "' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(271,40): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(284,44): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(298,44): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(315,46): error TS2345: Argument of type '"Implement issue 268"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(352,46): error TS2345: Argument of type '"Implement issue 306"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(378,44): error TS2345: Argument of type '"Implement issue 306"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(44,46): error TS2345: Argument of type '"Start the Codex session."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/codex-worktree-session-command.test.ts(52,33): error TS2352: Conversion of type '[] | undefined' to type '[{ name: string; cwd: string; shellPath: string; shellArgs: readonly string[]; }]' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.
extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts(90,5): error TS2345: Argument of type '(_executable: string, args: ReadonlyArray<string>) => { status: number; stdout: Buffer; }' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.collect-pr-context.test.ts(115,38): error TS2345: Argument of type '(filePath: string) => never' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.collect-pr-context.test.ts(121,42): error TS2345: Argument of type '(filePath: string) => string' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.collect-pr-context.test.ts(133,5): error TS2345: Argument of type '(filePath: string, content: string) => void' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.collect-pr-context.test.ts(247,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.collect-pr-context.test.ts(248,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.discovery-commands.test.ts(120,44): error TS2345: Argument of type '"discovery"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(233,30): error TS2345: Argument of type '"fc.yaml"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(234,30): error TS2345: Argument of type '"pm.yaml"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(235,30): error TS2345: Argument of type '"rc.yaml"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(263,45): error TS2345: Argument of type '"completion"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(265,30): error TS2345: Argument of type '"cov.json"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(266,30): error TS2345: Argument of type '"par.yaml"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(91,45): error TS2345: Argument of type '"all"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.discovery-commands.test.ts(92,44): error TS2345: Argument of type '"discovery/"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.integration.test.ts(121,5): error TS2345: Argument of type '(_executable: string, args: ReadonlyArray<string>) => { status: number; stdout: string; stderr: string; }' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.integration.test.ts(159,5): error TS2345: Argument of type '(items: ReadonlyArray<{ label: string; }>) => Promise<{ label: string; } | undefined>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension.integration.test.ts(401,44): error TS2345: Argument of type '"12"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.integration.test.ts(401,72): error TS2345: Argument of type '"34"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.integration.test.ts(437,40): error TS2345: Argument of type '"template-less-entry"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts(112,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts(113,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts(123,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts(124,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts(117,40): error TS2345: Argument of type '"blank-pr-context"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts(182,40): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts(199,40): error TS2345: Argument of type '"blank-pr-context"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts(216,40): error TS2345: Argument of type '"blank-pr-context"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts(231,40): error TS2345: Argument of type '"test-bug"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.potential-to-issue.test.ts(160,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.potential-to-issue.test.ts(161,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.potential-to-issue.test.ts(305,7): error TS2554: Expected 1 arguments, but got 3.
extensions/drm-copilot/test/extension.potential-to-issue.test.ts(327,7): error TS2554: Expected 1 arguments, but got 3.
extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts(155,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts(156,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts(155,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts(156,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension.resolve-policy-audit-template.test.ts(45,45): error TS2345: Argument of type '"agents"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(104,47): error TS2345: Argument of type '"Select folders to scan"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(105,48): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(136,30): error TS2345: Argument of type '"Select folders to scan"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(137,30): error TS2345: Argument of type '{ label: string; folder: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(169,30): error TS2345: Argument of type '"Select folders to scan"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(170,30): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(208,64): error TS2493: Tuple type '[]' of length '0' has no element at index '0'.
extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts(237,72): error TS2339: Property 'then' does not exist on type 'void | Promise<void>'.
extensions/drm-copilot/test/extension.run-poshqc-suite.test.ts(81,45): error TS2345: Argument of type '"Select folders to scan"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.run-poshqc-suite.test.ts(82,46): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.test.ts(327,9): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/extension.test.ts(358,46): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.test.ts(370,46): error TS2345: Argument of type '"Remove All"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(135,7): error TS2554: Expected 0 arguments, but got 2.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(169,40): error TS2345: Argument of type '"stale-cache"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(227,40): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(239,40): error TS2345: Argument of type '"stale-cache"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(252,40): error TS2345: Argument of type '"stale-cache"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(277,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(286,33): error TS2352: Conversion of type '[] | undefined' to type '[{ name: string; cwd: string; shellPath: string; shellArgs: readonly string[]; }]' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(370,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(420,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(448,46): error TS2345: Argument of type '"   "' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(481,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(517,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(553,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(595,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(60,30): error TS2345: Argument of type '"review"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(61,30): error TS2345: Argument of type '"github-copilot"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(62,30): error TS2345: Argument of type '"Yes"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(63,44): error TS2345: Argument of type '"C:/source-runtime"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(634,46): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(661,40): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(674,44): error TS2345: Argument of type '"Refactor the auth module."' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(688,44): error TS2345: Argument of type '"12"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(688,72): error TS2345: Argument of type '"34"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(739,40): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(751,30): error TS2345: Argument of type '"12"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(752,30): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(764,44): error TS2345: Argument of type '"12"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(764,72): error TS2345: Argument of type '"34"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(781,40): error TS2345: Argument of type '"test-entry"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(84,30): error TS2345: Argument of type '"apply"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(85,30): error TS2345: Argument of type '"claude"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(87,30): error TS2345: Argument of type '"C:/source-runtime"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension.workflow-commands.test.ts(88,30): error TS2345: Argument of type '"   "' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(158,44): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(164,44): error TS2345: Argument of type '"my-short-name"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(173,7): error TS2345: Argument of type '(options: { validateInput?: (v: string) => string | undefined; }) => Promise<string>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(191,44): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(200,7): error TS2345: Argument of type '(options: { validateInput?: (v: string) => string | undefined; }) => Promise<string>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(218,44): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(224,44): error TS2345: Argument of type '"   "' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(230,44): error TS2345: Argument of type '"42"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(239,7): error TS2345: Argument of type '(options: { validateInput?: (v: string) => string | undefined; }) => Promise<string>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(254,7): error TS2345: Argument of type '(options: { validateInput?: (v: string) => string | undefined; }) => Promise<string>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(285,46): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(295,46): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(321,46): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(334,46): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(353,46): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-command-helpers.test.ts(359,46): error TS2345: Argument of type '{ fsPath: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-test-harness.ts(346,15): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/extension-test-harness.ts(347,15): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/extension-test-harness.ts(381,43): error TS2345: Argument of type '(uri: { fsPath: string; }) => Promise<{ uri: { fsPath: string; }; }>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/extension-test-harness.ts(384,42): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/extension-test-harness.ts(433,17): error TS2323: Cannot redeclare exported variable 'resolveCodexExecutable'.
extensions/drm-copilot/test/extension-test-harness.ts(460,3): error TS2323: Cannot redeclare exported variable 'resolveCodexExecutable'.
extensions/drm-copilot/test/extension-test-harness.ts(460,3): error TS2484: Export declaration conflicts with exported declaration of 'resolveCodexExecutable'.
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(149,17): error TS4111: Property 'target_path' comes from an index signature, so it must be accessed with ['target_path'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(150,17): error TS4111: Property 'notes' comes from an index signature, so it must be accessed with ['notes'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(151,17): error TS4111: Property 'is_required' comes from an index signature, so it must be accessed with ['is_required'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(231,17): error TS4111: Property 'selected_paths' comes from an index signature, so it must be accessed with ['selected_paths'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(232,17): error TS4111: Property 'destination_root' comes from an index signature, so it must be accessed with ['destination_root'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(233,17): error TS4111: Property 'enable_repo_prompts' comes from an index signature, so it must be accessed with ['enable_repo_prompts'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(234,17): error TS4111: Property 'emit_intermediate_state' comes from an index signature, so it must be accessed with ['emit_intermediate_state'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(343,29): error TS4111: Property 'frontmatter' comes from an index signature, so it must be accessed with ['frontmatter'].
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts(347,17): error TS4111: Property 'sections' comes from an index signature, so it must be accessed with ['sections'].
extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts(106,30): error TS4111: Property 'applyTo' comes from an index signature, so it must be accessed with ['applyTo'].
extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts(107,30): error TS4111: Property 'name' comes from an index signature, so it must be accessed with ['name'].
extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts(75,33): error TS4111: Property 'agent' comes from an index signature, so it must be accessed with ['agent'].
extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts(76,33): error TS4111: Property 'description' comes from an index signature, so it must be accessed with ['description'].
extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts(19,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts(45,60): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts(59,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts(78,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(132,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(151,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(18,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(181,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(200,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(223,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(246,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(272,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(291,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(32,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(321,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(343,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test.ts(96,47): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/collect-commit-context.test-helpers.ts(58,14): error TS2420: Class 'InMemoryFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/file-system.test.ts(129,42): error TS2345: Argument of type '(dir: fs.PathLike) => fs.Dirent<NonSharedBuffer>[]' is not assignable to parameter of type '{ (path: PathLike, options?: BufferEncoding | { encoding: BufferEncoding | null; withFileTypes?: false | undefined; recursive?: boolean | undefined; } | null | undefined): string[]; (path: PathLike, options: { ...; } | "buffer"): NonSharedBuffer[]; (path: PathLike, options?: BufferEncoding | ... 2 more ... | undefin...'.
extensions/drm-copilot/test/lib/file-system.test.ts(170,42): error TS2345: Argument of type '(dir: fs.PathLike) => fs.Dirent<NonSharedBuffer>[]' is not assignable to parameter of type '{ (path: PathLike, options?: BufferEncoding | { encoding: BufferEncoding | null; withFileTypes?: false | undefined; recursive?: boolean | undefined; } | null | undefined): string[]; (path: PathLike, options: { ...; } | "buffer"): NonSharedBuffer[]; (path: PathLike, options?: BufferEncoding | ... 2 more ... | undefin...'.
extensions/drm-copilot/test/lib/json-config.test.ts(124,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(135,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(146,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(157,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(168,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(179,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(190,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(201,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(212,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(223,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(234,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(248,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(260,38): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/json-config.test.ts(51,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts(21,7): error TS2420: Class 'InMemoryFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts(249,32): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts(260,32): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts(273,17): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts(287,17): error TS2345: Argument of type 'InMemoryFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/new-active-feature-folder/models.test.ts(48,43): error TS2345: Argument of type '(dir: nodeFs.PathLike) => nodeFs.Dirent<NonSharedBuffer>[]' is not assignable to parameter of type '{ (path: PathLike, options?: BufferEncoding | { encoding: BufferEncoding | null; withFileTypes?: false | undefined; recursive?: boolean | undefined; } | null | undefined): string[]; (path: PathLike, options: { ...; } | "buffer"): NonSharedBuffer[]; (path: PathLike, options?: BufferEncoding | ... 2 more ... | undefin...'.
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(241,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(263,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(289,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(31,7): error TS2420: Class 'InMemoryFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(314,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(338,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(359,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(383,9): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts(401,9): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts(121,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts(150,9): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts(19,7): error TS2420: Class 'InMemoryFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts(74,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts(97,7): error TS2739: Type 'InMemoryFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts(30,21): error TS2379: Argument of type '{ args: readonly string[]; options: CommandRunOptions | undefined; }' is not assignable to parameter of type '{ args: readonly string[]; options?: CommandRunOptions; }' with 'exactOptionalPropertyTypes: true'. Consider adding 'undefined' to the types of the target's properties.
extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts(171,24): error TS2769: No overload matches this call.
extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts(199,12): error TS18048: 'routes' is possibly 'undefined'.
extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts(82,51): error TS2345: Argument of type 'number[]' is not assignable to parameter of type 'Record<string, unknown>'.
extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts(165,40): error TS2345: Argument of type 'Buffer<ArrayBufferLike>' is not assignable to parameter of type 'string | NonSharedBuffer'.
extensions/drm-copilot/test/lib/resolve/file-prompt-core.test.ts(19,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: () => undefined; ensureDir: () => undefined; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts(36,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: (path: string, content: string) => void; ensureDir: (path: string) => void; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/resolve/hard-lock-prompt.test.ts(26,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: (path: string, content: string) => void; ensureDir: (path: string) => void; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/resolve/resolve-prompts-service-call.test.ts(21,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: (path: string, content: string) => void; ensureDir: () => undefined; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts(11,7): error TS2739: Type '{ glob(): never; isFile(): never; readTextFile(): never; writeTextFile(): never; ensureDir(): never; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts(89,7): error TS2379: Argument of type '{ workspaceRoot: string; artifactType: string; artifactPath: string; requireComplete: undefined; requireModelRouting: undefined; requireCodexModelRouting: undefined; requireCodexTopology: undefined; requireReadyForExecution: undefined; }' is not assignable to parameter of type '{ readonly workspaceRoot: string; readonly artifactType: string; readonly artifactPath: string; readonly requireComplete?: boolean; readonly requireModelRouting?: boolean; readonly requireCodexModelRouting?: boolean; readonly requireCodexTopology?: boolean; readonly requireReadyForExecution?: boolean; }' with 'exactOptionalPropertyTypes: true'. Consider adding 'undefined' to the types of the target's properties.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(148,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(158,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(159,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(178,7): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(189,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(206,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(220,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(230,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(259,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(260,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(274,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(275,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(332,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(343,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(356,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts(369,5): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts(9,3): error TS2322: Type 'object' is not assignable to type 'Record<string, unknown>'.
extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts(10,3): error TS2322: Type 'object' is not assignable to type 'Record<string, unknown>'.
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(103,43): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(114,43): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(123,11): error TS2739: Type '{ glob: () => string[]; isFile: () => false; readTextFile: () => never; writeTextFile: () => never; ensureDir: () => never; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(146,11): error TS2739: Type '{ glob: () => string[]; isFile: () => true; readTextFile: () => never; writeTextFile: () => never; ensureDir: () => never; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(16,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(75,45): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts(92,43): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(154,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(166,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(178,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(190,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(202,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(216,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(231,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(250,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(270,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(288,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(305,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(319,36): error TS2345: Argument of type 'VirtualFileSystem' is not assignable to parameter of type 'FileSystem'.
extensions/drm-copilot/test/lib/validate/json-validator.test.ts(47,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts(150,28): error TS2345: Argument of type 'unknown' is not assignable to parameter of type 'string'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts(425,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts(439,71): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts(99,9): error TS2322: Type '{ expectedRepositoryId: string; expectedWorkspaceRoot: string; expectedBranch: string; expectedSourceHeadSha: string; allowedHeadRelationship: "equal" | "equal_or_descendant"; expectedIssueNumber: number; ... 7 more ...; destinationProvider: PortableHandoffProvider; }' is not assignable to type 'PortableHandoffReferenceRequest'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts(94,15): error TS7053: Element implicitly has an 'any' type because expression of type 'string | number' can't be used to index type 'any[] | Record<string, unknown>'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts(182,9): error TS2740: Type '{ workspaceRoot: string; sourceCheckpointPath: string; expectedSourceCheckpointSha256: string; handoffEnvelopePath: string; expectedHandoffEnvelopeSha256: string; destinationProvider: "codex"; mode: "materialize"; }' is missing the following properties from type 'TransitionPreparedOrchestrationRequest': expectedRepositoryId, expectedWorkspaceRoot, expectedBranch, expectedSourceHeadSha, and 6 more.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts(255,53): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts(280,7): error TS2345: Argument of type '(targetPath: string) => string' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts(96,7): error TS2345: Argument of type '(targetPath: string) => string' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts(103,3): error TS2322: Type 'string | undefined' is not assignable to type 'string'.
extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts(135,30): error TS2345: Argument of type '{ taskId: string; sourceLine: number; rawSpan: string; argv: string[]; kind: PlanCommandKind; }' is not assignable to parameter of type 'PlanCommand'.
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(101,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(117,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(137,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(157,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(18,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(61,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts(82,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(276,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(279,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts(282,7): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/mcp-provider.test.ts(182,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/mcp-server.test.ts(445,46): error TS2339: Property 'mockResolvedValue' does not exist on type '(input: TransitionPreparedOrchestrationRequest) => Promise<TransitionPreparedOrchestrationResult>'.
extensions/drm-copilot/test/mcp-server-test-service.ts(28,5): error TS2322: Type 'Mock<UnknownFunction>' is not assignable to type '(input: TransitionPreparedOrchestrationRequest) => Promise<TransitionPreparedOrchestrationResult>'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(131,45): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(161,45): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(180,45): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(198,45): error TS2345: Argument of type '{ label: string; folder: string; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(218,45): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/poshqc-folder-picker.test.ts(232,45): error TS2345: Argument of type 'never[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/push-down-claude-handler.test.ts(137,72): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/remove-worktrees.test.ts(114,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(115,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(130,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(131,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(132,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(159,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(28,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(29,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(30,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(31,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(69,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(70,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(83,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(84,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(98,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees.test.ts(99,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees-runner.test.ts(180,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees-runner.test.ts(181,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/remove-worktrees-runner.test.ts(217,12): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(122,30): error TS2345: Argument of type '{ label: string; pack: string; picked: boolean; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(123,30): error TS2345: Argument of type '"legacy"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(127,52): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(152,45): error TS2345: Argument of type '{ label: string; pack: string; picked: boolean; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(159,52): error TS2554: Expected 0 arguments, but got 1.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(183,45): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(207,30): error TS2345: Argument of type '{ label: string; pack: string; picked: boolean; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(208,30): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(88,30): error TS2345: Argument of type '{ label: string; pack: string; picked: boolean; }[]' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(89,30): error TS2345: Argument of type '"modern"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts(90,30): error TS2345: Argument of type '"overwrite"' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/repo-automation-dispatch.test.ts(151,7): error TS2739: Type '{ glob: () => never[]; isFile: () => false; readTextFile: () => string; writeTextFile: (p: string, c: string) => undefined; ensureDir: (d: string) => undefined; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-dispatch.test.ts(237,14): error TS2532: Object is possibly 'undefined'.
extensions/drm-copilot/test/repo-automation-dispatch.test.ts(74,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/repo-automation-dispatch.test.ts(75,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts(72,47): error TS2379: Argument of type '{ extensionRoot: string; output: { appendLine: () => undefined; }; fileSystem: FileSystem | undefined; runner: { run: (args: readonly string[]) => { stdout: string; stderr: string; code: number; }; }; }' is not assignable to parameter of type 'RepoAutomationServiceOptions' with 'exactOptionalPropertyTypes: true'. Consider adding 'undefined' to the types of the target's properties.
extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts(59,5): error TS2345: Argument of type '(executable: string, args: ReadonlyArray<string>, options: { cwd: string; }) => MockChildProcess' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts(84,5): error TS2345: Argument of type '(executable: string, args: ReadonlyArray<string>, options: { cwd: string; }) => MockChildProcess' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts(53,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: (path: string, content: string) => void; ensureDir: () => undefined; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(156,7): error TS2420: Class 'VirtualFileSystem' incorrectly implements interface 'FileSystem'.
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(190,17): error TS4111: Property 'PATH' comes from an index signature, so it must be accessed with ['PATH'].
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(191,17): error TS4111: Property 'PATHEXT' comes from an index signature, so it must be accessed with ['PATHEXT'].
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(208,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(234,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(259,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(283,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(308,7): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts(385,9): error TS2739: Type 'VirtualFileSystem' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/repo-automation-service.resolve-atomic-plan-prompt.test.ts(42,9): error TS2739: Type '{ glob: () => never[]; isFile: (path: string) => boolean; readTextFile: (path: string) => string; writeTextFile: () => undefined; ensureDir: () => undefined; }' is missing the following properties from type 'FileSystem': exists, isDirectory, listDirectory
extensions/drm-copilot/test/subagent-tree-command.test.ts(199,7): error TS2345: Argument of type '(items: ReadonlyArray<{ path: string; }>) => Promise<{ path: string; } | undefined>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/subagent-tree-command.test.ts(370,41): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/subagent-tree-command.test.ts(398,41): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/subagent-tree-command.test.ts(429,7): error TS2345: Argument of type '(items: ReadonlyArray<{ path: string; }>) => Promise<{ path: string; } | undefined>' is not assignable to parameter of type 'UnknownFunction'.
extensions/drm-copilot/test/subagent-tree-command.test.ts(475,41): error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'never'.
extensions/drm-copilot/test/subagent-tree-command.test.ts(54,66): error TS2556: A spread argument must either have a tuple type or be passed to a rest parameter.
extensions/drm-copilot/test/subagent-tree-command.test.ts(56,31): error TS2556: A spread argument must either have a tuple type or be passed to a rest parameter.
```

Output Summary: `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exited 2, printing 331 `error TS` lines across 69 files and no trailing `Found` count line, because the non-pretty invocation emits no summary. All 331 diagnostics pre-exist this plan and are reproduced in full above with their file paths. Sixteen of them name five of the seven TypeScript paths this plan changes, which makes the first clause of the Phase 1 type acceptance ("no `error TS` line naming any path this plan changes") false at baseline and unsatisfiable by any action this test-only plan is authorized to take; that clause is recorded as unsatisfiable rather than reported as passing. The second clause is the operative, falsifiable gate and is evaluated against the normalized 331-entry set (170 distinct) defined above.
