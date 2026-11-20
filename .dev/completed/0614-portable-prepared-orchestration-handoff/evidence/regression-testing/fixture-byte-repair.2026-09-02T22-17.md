# Fixture Byte Repair

Timestamp: 2026-09-03T03-03

## [P1-T1] Exact-path attribute overrides

Command: `git check-attr -a -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: Both exact plan fixture paths resolve to `text: unset` and `eol: unset`. The repository-wide `* text=auto eol=lf` rule remains unchanged; only the two declared path-specific overrides were appended.

```text
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: text: unset
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: eol: unset
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: text: unset
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: eol: unset
```

Command: `git diff -- .gitattributes`
EXIT_CODE: 0

Output Summary: The attribute diff preserves line 1 and adds exactly two path-specific `-text -eol` lines; no other attribute rule changed.

## [P1-T2] Persistent CRLF conversion

Timestamp: 2026-09-03T03-04
Command: `node -e "const fs=require('node:fs');const crypto=require('node:crypto');const paths=['tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md'];const decoder=new TextDecoder('utf-8',{fatal:true});for(const p of paths){const before=fs.readFileSync(p);const value=decoder.decode(before);if(value.includes('\r'))throw new Error(p+': expected LF-only baseline');const after=Buffer.from(value.replace(/\n/g,'\r\n'),'utf8');fs.writeFileSync(p,after);const raw=fs.readFileSync(p);console.log(JSON.stringify({path:p,size:raw.length,sha256:crypto.createHash('sha256').update(raw).digest('hex')}));}"`
EXIT_CODE: 0

Output Summary: The one-time conversion succeeded from the verified LF-only baseline. Both persistent working fixtures are 101,998 bytes and have raw SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`.

```json
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md","size":101998,"sha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"}
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md","size":101998,"sha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"}
```

Command: `node -e "const fs=require('node:fs'),crypto=require('node:crypto');const paths=['tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md'];const values=paths.map(path=>fs.readFileSync(path));const inspect=(path,b)=>{let crlf=0,lfOnly=0,bareCr=0;for(let i=0;i<b.length;i++){if(b[i]===13){if(b[i+1]===10){crlf++;i++;}else bareCr++;}else if(b[i]===10)lfOnly++;}return {path,size:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex'),crlf,lfOnly,bareCr};};console.log(JSON.stringify({identical:values[0].equals(values[1]),files:paths.map((p,i)=>inspect(p,values[i]))}));"`
EXIT_CODE: 0

Output Summary: The post-write read-only verification proves both files are byte-identical, each contains 1,413 CRLF line endings, zero LF-only endings, and zero bare CR bytes.

```json
{"identical":true,"files":[{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md","size":101998,"sha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","crlf":1413,"lfOnly":0,"bareCr":0},{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md","size":101998,"sha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","crlf":1413,"lfOnly":0,"bareCr":0}]}
```

The conversion command ran once. It was not registered in or invoked by a setup hook, pre-test script, helper, or test.

## [P1-T3] Bounded implementation diff before staging

Timestamp: 2026-09-03T03-06

Command: `git diff --name-only -- .gitattributes tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: The implementation diff contains exactly the three owned files.

```text
.gitattributes
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
```

Command: `Get-FileHash -Algorithm SHA256 -LiteralPath 'tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md' | Format-List Path,Hash,Algorithm`
EXIT_CODE: 0

Output Summary: Both persistent working fixtures have the required raw SHA-256.

```text

Path      : C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\orchestration-handoff\taskmaster-469\claude-to-codex\plan.2026-08-29T12-22.md
Hash      : 54C9718097DE0A151947CA2E639856E67FE1B7ABFBF9EDC75ADAC80EA3C9BA2F
Algorithm : SHA256

Path      : C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\orchestration-handoff\taskmaster-469\codex-to-claude\plan.2026-08-29T12-22.md
Hash      : 54C9718097DE0A151947CA2E639856E67FE1B7ABFBF9EDC75ADAC80EA3C9BA2F
Algorithm : SHA256
```

Command: `git diff --quiet HEAD -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`
EXIT_CODE: 0

Output Summary: Both fixture manifests and the raw-byte fixture test are unchanged from HEAD.

Command: `node -e "const fs=require('node:fs');for(const p of ['tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json']){const j=JSON.parse(fs.readFileSync(p,'utf8'));console.log(JSON.stringify({path:p,planSha256:j.plan.sha256}));}"`
EXIT_CODE: 0

Output Summary: Both unchanged fixture manifests continue to pin the required CRLF raw-byte SHA-256.

```text
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json","planSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"}
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json","planSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"}
```

Command: `git diff -- .gitattributes`
EXIT_CODE: 0

Output Summary: The only attribute changes are the two exact-path `-text -eol` overrides; the repository-wide LF rule remains unchanged.

```text
diff --git a/.gitattributes b/.gitattributes
index 6313b56c..8c214a8a 100644
--- a/.gitattributes
+++ b/.gitattributes
@@ -1 +1,3 @@
 * text=auto eol=lf
+tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md -text -eol
+tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md -text -eol
```

Scope conclusion: the changed implementation is exactly `.gitattributes` plus the two plan fixtures. Neither manifest nor `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` changed. Because no setup hook, helper, test, production, or manifest file is in the implementation diff, the change introduces no normalized hashing or newline-hydration mechanism.
