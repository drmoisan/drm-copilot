Timestamp: 2026-09-30T08-59
Command: (in /c/Users/DanMoisan/repos/drm-copilot-wt/2026-09-29T13-45) npx --yes npm@11 audit --audit-level=moderate; echo AUDIT_EXIT=$?; npx --yes npm@11 ls brace-expansion fast-uri --all; echo LS_EXIT=$?
EXIT_CODE: 0
Output Summary:
    [key] found 0 vulnerabilities
    found 0 vulnerabilities
    AUDIT_EXIT=0
    drm-copilot@1.0.0 C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-29T13-45
    ├─┬ @modelcontextprotocol/sdk@1.30.1
    │ ├─┬ ajv-formats@3.0.1
    │ │ └─┬ ajv@8.18.0
    │ │   └── fast-uri@3.1.8 deduped
    │ └─┬ ajv@8.18.0
    │   └── fast-uri@3.1.8
    └─┬ @vscode/test-cli@0.0.15
      └─┬ minimatch@10.2.5
        └── brace-expansion@5.0.12
    
    LS_EXIT=0
