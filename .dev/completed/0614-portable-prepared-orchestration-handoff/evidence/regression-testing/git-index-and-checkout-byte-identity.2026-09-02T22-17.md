# Git Index and Checkout Byte Identity

Timestamp: 2026-09-03T03-08

Command: `git add -- .gitattributes tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: Staged only the three owned implementation paths.

Command: `git diff --name-only --cached`
EXIT_CODE: 0

Output Summary: The index contains exactly `.gitattributes` and the two plan fixtures.

```text
.gitattributes
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
```

Command: `git diff --quiet -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: Both working fixture files are identical to their staged index bytes.

Command: `git check-attr --cached -a -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: Cached attributes resolve `text` and `eol` as unset for both exact fixture paths.

```text
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: text: unset
tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md: eol: unset
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: text: unset
tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md: eol: unset
```

Command: `node -e "const cp=require('node:child_process');const crypto=require('node:crypto');const expected='54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f';const paths=['tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md','tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md'];const run=args=>{const r=cp.spawnSync('git',args,{encoding:null});if(r.status!==0)throw new Error(args.join(' ')+' exited '+r.status+': '+r.stderr.toString());return r.stdout;};const hash=value=>crypto.createHash('sha256').update(value).digest('hex');for(const p of paths){const index=run(['show',':'+p]);const windowsCheckout=run(['-c','core.autocrlf=true','cat-file','--filters','--path='+p,':'+p]);const linuxCheckout=run(['-c','core.autocrlf=false','cat-file','--filters','--path='+p,':'+p]);const result={path:p,indexSize:index.length,windowsCheckoutSize:windowsCheckout.length,linuxCheckoutSize:linuxCheckout.length,indexSha256:hash(index),windowsCheckoutSha256:hash(windowsCheckout),linuxCheckoutSha256:hash(linuxCheckout),allEqual:index.equals(windowsCheckout)&&index.equals(linuxCheckout)};console.log(JSON.stringify(result));if(!result.allEqual||result.indexSize!==101998||result.indexSha256!==expected)process.exitCode=1;}"`
EXIT_CODE: 0

Output Summary: For both fixture directions, the index and simulated Windows/Linux checkout-filter outputs are byte-identical at 101,998 bytes and the required raw SHA-256.

```text
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md","indexSize":101998,"windowsCheckoutSize":101998,"linuxCheckoutSize":101998,"indexSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","windowsCheckoutSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","linuxCheckoutSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","allEqual":true}
{"path":"tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md","indexSize":101998,"windowsCheckoutSize":101998,"linuxCheckoutSize":101998,"indexSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","windowsCheckoutSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","linuxCheckoutSha256":"54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","allEqual":true}
```

Command: `git ls-files --stage -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Output Summary: Both staged plan paths use the same expected Git blob ID `e61a4d981720be758d3d31d1649e191891cd0092`.

```text
100644 e61a4d981720be758d3d31d1649e191891cd0092 0	tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
100644 e61a4d981720be758d3d31d1649e191891cd0092 0	tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
```

## Identity conclusion

Both fixture directions have index, working-tree, `core.autocrlf=true` checkout-filter, and `core.autocrlf=false` checkout-filter representations of exactly 101,998 bytes and SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`. The verification was read-only after staging and did not alter the working fixtures.
