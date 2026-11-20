# Resumed Windows correction: work-in-progress checkpoint

The user resumed the feature and requested frequent progress commits. This checkpoint preserves the corrected Windows directory access and completed task-level test evidence before the remaining coverage assertion is changed.

- Branch: feature/legacy-discovery-and-parity-980; issue #980.
- Accepted progress remains 24 of 84 atomic tasks and 6 of 66 acceptance criteria.
- P3-T1 is not accepted or checked off. P3-T2 has not started.
- The Windows provider now requests directory-read/list access plus attributes (0x81). The real six-case diagnostic and the independent three-case provider checks pass.
- Pass12 completed 89 focused tests and 89 reversed-order tests successfully. Coverage is 483 of 489 executable lines and 134 of 142 arcs.
- The callable audit remains blocking: CapturedWorkspace.inspect covers 14 of 16 lines (87.5%), below the required 90%. The missing ancestor error-path fixture correction has not been saved at this checkpoint.
- Failed and incomplete attempts are retained. The early native diagnostic is not the final ordered integration gate.
- Remaining P3-T1 work: correct the bounded test fixture, restart the required ordered gates, establish passing callable coverage, complete compatibility and final real Windows integration checks, obtain executor acceptance, then commit the accepted task before releasing P3-T2.
- The complete feature, remaining phases, final repository QA, independent review, publishing evidence and exact-head CI remain pending.

The canonical live checkpoint remains artifacts/orchestration/orchestrator-state.json. User pause history is preserved, current execution is resumed, and no hook bypass is authorized. Each independently accepted atomic task must be committed before the next task; stable substantive milestones receive WIP commits when needed, with pushes at phase checkpoints and final delivery.
