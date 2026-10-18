# P3-T2 projection work-in-progress checkpoint

This checkpoint preserves the deterministic initialization projection, six domain-neutral v2 templates and their resource manifest. P3-T2 remains unchecked. Accepted progress is 25 of 84 tasks and 6 of 66 acceptance criteria.

Bounded projection formatting, lint and type checks pass. The template/schema/resource probe passes 38 checks across six templates and 39 resources. The existing initialization baseline passed 27 tests with 36/36 flow lines covered. Earlier format/lint/type attempts remain in the evidence inventory.

These checks do not establish the complete initialization behavior, per-unit coverage, installed runtime or native mutation integration. They do not import the incomplete init_flow.py or init_io.py drafts. Those two files remain untracked and unstaged for this commit.

The exact eight stageable paths, hashes, command receipts, raw baseline and limitations are recorded in p3t2-projection-wip.2026-10-18T12-58.json in this directory. Remaining work includes the guarded physical bootstrap and empty-directory handling, public flow/compatibility adapter, behavior tests, ordered complete task checks and independent acceptance.

The task-entry baseline remains a74cb240a7698c1454a8e6018ac23862cd91dab0 so the eventual audit includes all P3-T2 work across this progress commit. Execution resumes on the same task after commit. P3-T3 is not released. The live state remains artifacts/orchestration/orchestrator-state.json; the full feature, final repository gates, native proof, review and CI remain incomplete.

The baseline command also overwrote the pre-existing ignored generated report artifacts/python/lcov.info through inherited pytest options. Its prior contents were not captured. No deletion or restoration is claimed. Subsequent task commands will explicitly override those options and select canonical or SCRATCH reports; the canonical raw baseline is included in this checkpoint.
