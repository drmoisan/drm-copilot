Timestamp: 2026-08-25T22-35
Command: SHA-256/byte-length comparison of the three P6-T2 TypeScript baseline paths; `git diff --name-only`; `git diff --cached --name-only`; `git status --porcelain=v1 --untracked-files=all`; routing SHA-256 equality check.
EXIT_CODE: 0
Output Summary: The only new source/test paths after P6-T2 are the three plan-authorized TypeScript files. The previously staged P0-P5 remediation paths remain staged, with plan checklist updates and all new artifacts under the feature's canonical `evidence/` hierarchy. Root/bundled routing parity remains true. No command outcome was skipped, no publication or external release occurred, and no evidence claims that `@danmoisan/drm-copilot-mcp@1.1.2` was updated. The P8-T4 coverage gate remains failed and unchecked because of an unrelated existing root/bundle carriage test failure.

Post-change TypeScript paths:
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | SHA-256 `84703B940503CFBAE5FB41C2F7155BC0AD6768E51C82CD05B2121CBE5CB5BE55` | 14305 bytes
- `extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts` | SHA-256 `E662A580CCBD97E440CC9A43F82CF2E7E4CB0C42FB4B65770C17127C927DE07E` | 5561 bytes
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts` | SHA-256 `0AEB3642136DE79C95E6DC7DFCE27EC74B13D743BA6D3DC15D5E16ED2E023D9D` | 11386 bytes

Scope comparison:
- New non-evidence source/test paths since P6-T2: exactly the three paths above.
- The existing remediation plan path was already present at P6-T2; its only post-baseline changes are required task checkbox updates.
- All newly added evidence is beneath `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/`.
- The pre-existing staged P0-P5 paths remain in the staged index; this revision did not change their recorded routing/profile surfaces. Root/bundled routing configuration SHA-256 values remain equal.
- No package publication, customization publication, external release, or installed-runtime bootstrap command was invoked.

QA outcome inventory:
- Format: passed.
- Lint: passed.
- Typecheck: passed.
- Coverage: failed on unrelated `claude-config-carriage` root/bundle assertion; recorded and not skipped.
- Build: passed.
