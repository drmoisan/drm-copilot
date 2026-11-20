# Fixture Byte Baseline

Timestamp: 2026-09-03T02-50

Command: `git check-attr -a -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`

EXIT_CODE: 0

Output Summary: Both fixture plans resolve through `text=auto eol=lf`.

```text
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: text: auto
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: eol: lf
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: text: auto
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: eol: lf
```

Command: `git diff --quiet HEAD -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`

EXIT_CODE: 0

Output Summary: Both fixture plan working files are byte-equivalent to their HEAD representations for Git diff purposes; no fixture mutation is present.

Command: `Get-FileHash -Algorithm SHA256 -LiteralPath 'tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md' | Format-List Path,Hash,Algorithm`

EXIT_CODE: 0

Output Summary: Both untouched raw fixture files hash to `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`.

```text

Path      : C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\orchestration-handoff\taskmaster-469\claude-to-codex\plan.2026-08-29T12-22.md
Hash      : 089467FCB70EBC8B3FD999B1426D41DFBF40016C062D560E76948558B3927864
Algorithm : SHA256

Path      : C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\orchestration-handoff\taskmaster-469\codex-to-claude\plan.2026-08-29T12-22.md
Hash      : 089467FCB70EBC8B3FD999B1426D41DFBF40016C062D560E76948558B3927864
Algorithm : SHA256
```

Command: `node -e "const fs=require('node:fs');const paths=['tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md'];for(const p of paths){const b=fs.readFileSync(p);let crlf=0,lfOnly=0,bareCr=0;for(let i=0;i<b.length;i++){if(b[i]===13){if(i+1<b.length&&b[i+1]===10){crlf++;i++;}else bareCr++;}else if(b[i]===10)lfOnly++;}console.log(JSON.stringify({path:p,size:b.length,crlf,lfOnly,bareCr}));}"`

EXIT_CODE: 0

Output Summary: Each untouched fixture is 100,585 bytes with 1,413 LF-only endings, zero CRLF endings, and zero bare CR bytes.

```text
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md","size":100585,"crlf":0,"lfOnly":1413,"bareCr":0}
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md","size":100585,"crlf":0,"lfOnly":1413,"bareCr":0}
```

Command: `Get-Content -LiteralPath 'docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md' -Raw`

EXIT_CODE: 0

Output Summary: The previously captured causal evidence was read and confirms the same committed-head raw-byte defect and expected pinned hash.

```text
# TaskMaster #469 Committed Fixture Byte Verification

Timestamp: 2026-09-02T22-17-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -k fixture_hashes_and_source_history_are_pinned --no-cov -q
EXIT_CODE: 1

Output Summary: Both parameterized fixture directions failed at test_orchestration_handoff_taskmaster_469.py:77. Each committed plan file hashes to 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864, while each fixture.json pins 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f. The run reported 2 failed and 54 deselected in 0.10 seconds.

## Supporting read-only checks

Command: Get-FileHash -Algorithm SHA256 for both plan fixtures; git diff --quiet HEAD for both paths; git check-attr -a for both paths; read fixture.json plan.sha256
EXIT_CODE: 0

- claude-to-codex plan: working-tree SHA-256 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864; pinned SHA-256 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f; git diff exit 0.
- codex-to-claude plan: working-tree SHA-256 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864; pinned SHA-256 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f; git diff exit 0.
- Git attributes for both paths: text=auto and eol=lf, inherited from repository .gitattributes line 1.

The working-tree files are identical to HEAD according to git diff. This is therefore a committed-head defect, not an uncommitted local change. The earlier accepted Python and integration evidence explicitly depended on temporary CRLF hydration and does not supersede this result.
```

## Causal evidence citation

The read-only baseline corroborates `evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md`: the untouched files are identical to HEAD, inherit `text=auto eol=lf`, and have raw SHA-256 `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`. No command in this task wrote, normalized, or hydrated either fixture.
