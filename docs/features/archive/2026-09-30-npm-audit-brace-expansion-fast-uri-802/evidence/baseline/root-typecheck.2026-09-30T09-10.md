Timestamp: 2026-09-30T08-57
Command: (in /c/Users/DanMoisan/repos/drm-copilot-wt/2026-09-29T13-45) npx --yes npm@11 run typecheck
EXIT_CODE: 0
Output Summary:
    
    > drm-copilot@1.0.0 typecheck
    > node -e "const fs=require('node:fs');const path=require('node:path');const {buildToolEnvironment,resolveTool}=require('./run-node-tool.cjs');const hasTs=(dir)=>{if(!fs.existsSync(dir)) return false;const stack=[dir];while(stack.length){const cur=stack.pop();for(const ent of fs.readdirSync(cur,{withFileTypes:true})){if(ent.name==='node_modules'||ent.name==='out') continue;const full=path.join(cur,ent.name);if(ent.isDirectory()) stack.push(full);else if(/\.ts$/i.test(ent.name)) return true;}}return false;};if(!hasTs('src')&&!hasTs('tests')){console.log('Skipping typecheck: no TypeScript sources found under src/ or tests/.');process.exit(0);}const cp=require('node:child_process');const tsc=resolveTool('typescript/bin/tsc');const result=cp.spawnSync(process.execPath,[tsc,'-p','./','--noEmit'],{stdio:'inherit',env:buildToolEnvironment()});process.exit(result.status??1);"
    
