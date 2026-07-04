Timestamp: 2026-07-04T14-27
Command: & 'C:\Users\DanMoisan\.vscode-insiders\extensions\openai.chatgpt-26.5623.101652-win32-x64\bin\windows-x86_64\codex.exe' doctor --json
EXIT_CODE: 0
Output Summary:
- codex doctor process exit code: 0.
- No documented role-definition warning classes were found.

Raw Output:
{
  "schemaVersion": 1,
  "generatedAt": "1783189643s since unix epoch",
  "overallStatus": "ok",
  "codexVersion": "0.142.5",
  "checks": {
    "app_server.status": {
      "id": "app_server.status",
      "category": "app-server",
      "status": "ok",
      "summary": "background server is not running",
      "details": {
        "control socket": "C:\\Users\\DanMoisan\\.codex\\app-server-control\\app-server-control.sock",
        "daemon state dir": "C:\\Users\\DanMoisan\\.codex\\app-server-daemon",
        "mode": "ephemeral",
        "pid file": "C:\\Users\\DanMoisan\\.codex\\app-server-daemon\\app-server.pid (missing)",
        "settings": "C:\\Users\\DanMoisan\\.codex\\app-server-daemon\\settings.json (missing)",
        "status": "not running",
        "update-loop pid file": "C:\\Users\\DanMoisan\\.codex\\app-server-daemon\\app-server-updater.pid (missing)"
      },
      "remediation": null,
      "durationMs": 0
    },
    "auth.credentials": {
      "id": "auth.credentials",
      "category": "auth",
      "status": "ok",
      "summary": "auth is configured",
      "details": {
        "auth file": "C:\\Users\\DanMoisan\\.codex\\auth.json",
        "auth storage mode": "File",
        "stored API key": "false",
        "stored ChatGPT tokens": "true",
        "stored agent identity": "false",
        "stored auth mode": "chatgpt"
      },
      "remediation": null,
      "durationMs": 0
    },
    "config.load": {
      "id": "config.load",
      "category": "config",
      "status": "ok",
      "summary": "config loaded",
      "details": {
        "CODEX_HOME": "C:\\Users\\DanMoisan\\.codex",
        "config.toml": "C:\\Users\\DanMoisan\\.codex\\config.toml",
        "config.toml parse": "ok",
        "cwd": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt-2026-07-04-13-40",
        "enabled feature flags": "<redacted>",
        "feature flag overrides": "memories=true",
        "feature flags enabled": "34",
        "log dir": "C:\\Users\\DanMoisan\\.codex\\log",
        "mcp servers": "2",
        "model": "gpt-5.5",
        "model provider": "openai",
        "sqlite home": "C:\\Users\\DanMoisan\\.codex"
      },
      "remediation": null,
      "durationMs": 0
    },
    "git.environment": {
      "id": "git.environment",
      "category": "git",
      "status": "ok",
      "summary": "git version 2.53.0.windows.1",
      "details": {
        ".git entry": "file -> C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/drm-copilot-wt-2026-07-04-13-40",
        "PATH git #1": "C:\\Program Files\\Git\\cmd\\git.exe",
        "PATH git entries": "1",
        "git branch": "bug/codex-agent-role-config-306",
        "git build options": "git version 2.53.0.windows.1; cpu: x86_64; built from commit: a5512bdee37ed7142c233d21e2d347ffc4860ff3; sizeof-long: 4; sizeof-size_t: 8; shell-path: D:/git-sdk-64-build-installers/usr/bin/sh; rust: disabled; feature: fsmonitor--daemon; gettext: enabled; libcurl: 8.18.0; OpenSSL: OpenSSL 3.5.5 27 Jan 2026; zlib: 1.3.1; SHA-1: SHA1_DC; SHA-256: SHA256_BLK; default-ref-format: files; default-hash: sha1",
        "git exec path": "C:/Program Files/Git/mingw64/libexec/git-core",
        "git version": "git version 2.53.0.windows.1",
        "repo detected": "true",
        "repo root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt-2026-07-04-13-40",
        "selected git": "C:\\Program Files\\Git\\cmd\\git.exe"
      },
      "remediation": null,
      "durationMs": 60
    },
    "installation": {
      "id": "installation",
      "category": "install",
      "status": "ok",
      "summary": "installation looks consistent",
      "details": {
        "PATH codex #1": "c:\\Users\\DanMoisan\\.vscode-insiders\\extensions\\openai.chatgpt-26.5623.101652-win32-x64\\bin\\windows-x86_64\\codex.exe",
        "current executable": "C:\\Users\\DanMoisan\\.vscode-insiders\\extensions\\openai.chatgpt-26.5623.101652-win32-x64\\bin\\windows-x86_64\\codex.exe",
        "install context": "other",
        "managed by bun": "false",
        "managed by npm": "false",
        "managed package root": "not set"
      },
      "remediation": null,
      "durationMs": 36
    },
    "mcp.config": {
      "id": "mcp.config",
      "category": "mcp",
      "status": "ok",
      "summary": "MCP configuration is locally consistent",
      "details": {
        "configured servers": "2",
        "disabled servers": "0",
        "stdio servers": "2"
      },
      "remediation": null,
      "durationMs": 1
    },
    "network.env": {
      "id": "network.env",
      "category": "network",
      "status": "ok",
      "summary": "network-related environment looks readable",
      "details": {
        "proxy env vars": "none"
      },
      "remediation": null,
      "durationMs": 0
    },
    "network.provider_reachability": {
      "id": "network.provider_reachability",
      "category": "reachability",
      "status": "ok",
      "summary": "active provider endpoints are reachable over HTTP",
      "details": {
        "ChatGPT base URL": "https://chatgpt.com/backend-api/ reachable (HTTP 403)",
        "reachability mode": "ChatGPT auth"
      },
      "remediation": null,
      "durationMs": 121
    },
    "network.websocket_reachability": {
      "id": "network.websocket_reachability",
      "category": "websocket",
      "status": "ok",
      "summary": "Responses WebSocket handshake succeeded",
      "details": {
        "DNS": "2 IPv4, 2 IPv6, first IPv4",
        "auth mode": "chatgpt",
        "connect timeout": "15000 ms",
        "endpoint": "wss://chatgpt.com/backend-api/<redacted>",
        "handshake result": "HTTP 101 Switching Protocols",
        "model provider": "openai",
        "models etag present": "true",
        "provider name": "OpenAI",
        "proxy env vars": "none",
        "reasoning header": "false",
        "server model present": "false",
        "supports websockets": "true",
        "wire API": "responses"
      },
      "remediation": null,
      "durationMs": 545
    },
    "runtime.provenance": {
      "id": "runtime.provenance",
      "category": "runtime",
      "status": "ok",
      "summary": "running local build on windows-x86_64",
      "details": {
        "commit": "unknown",
        "current executable": "C:\\Users\\DanMoisan\\.vscode-insiders\\extensions\\openai.chatgpt-26.5623.101652-win32-x64\\bin\\windows-x86_64\\codex.exe",
        "install method": "other",
        "platform": "windows-x86_64",
        "version": "0.142.5"
      },
      "remediation": null,
      "durationMs": 0
    },
    "runtime.search": {
      "id": "runtime.search",
      "category": "search",
      "status": "ok",
      "summary": "search is OK (system)",
      "details": {
        "search command": "rg.exe",
        "search command readiness": "ripgrep 15.1.0 (rev af60c2de9d)",
        "search provider": "system"
      },
      "remediation": null,
      "durationMs": 10
    },
    "sandbox.helpers": {
      "id": "sandbox.helpers",
      "category": "sandbox",
      "status": "ok",
      "summary": "sandbox configuration is readable",
      "details": {
        "approval policy": "Never",
        "codex-linux-sandbox helper": "none",
        "execve wrapper helper": "none",
        "filesystem sandbox": "unrestricted",
        "network sandbox": "enabled"
      },
      "remediation": null,
      "durationMs": 0
    },
    "state.paths": {
      "id": "state.paths",
      "category": "state",
      "status": "ok",
      "summary": "state paths and databases are inspectable",
      "details": {
        "CODEX_HOME": "C:\\Users\\DanMoisan\\.codex (dir)",
        "active rollout files": "497 files, 403768892 total bytes, 812412 average bytes",
        "archived rollout files": "3 files, 745099 total bytes, 248366 average bytes",
        "goals DB": "C:\\Users\\DanMoisan\\.codex\\goals_1.sqlite (file)",
        "goals DB integrity": "ok",
        "log DB": "C:\\Users\\DanMoisan\\.codex\\logs_2.sqlite (file)",
        "log DB integrity": "ok",
        "log dir": "C:\\Users\\DanMoisan\\.codex\\log (missing)",
        "memories DB": "C:\\Users\\DanMoisan\\.codex\\memories_1.sqlite (file)",
        "memories DB integrity": "ok",
        "sqlite home": "C:\\Users\\DanMoisan\\.codex (dir)",
        "state DB": "C:\\Users\\DanMoisan\\.codex\\state_5.sqlite (file)",
        "state DB integrity": "ok"
      },
      "remediation": null,
      "durationMs": 1092
    },
    "state.rollout_db_parity": {
      "id": "state.rollout_db_parity",
      "category": "threads",
      "status": "ok",
      "summary": "rollout files and state DB thread inventory agree",
      "details": {
        "default model provider": "openai",
        "rollout DB active files": "497",
        "rollout DB active rows": "497",
        "rollout DB archive mismatches": "0",
        "rollout DB archived files": "3",
        "rollout DB archived rows": "3",
        "rollout DB duplicate DB paths": "0",
        "rollout DB duplicate rollout thread ids": "0",
        "rollout DB malformed file names": "0",
        "rollout DB missing active rows": "0",
        "rollout DB missing archived rows": "0",
        "rollout DB model providers": "openai=500",
        "rollout DB rows": "500",
        "rollout DB scan cap reached": "false",
        "rollout DB scan errors": "0",
        "rollout DB sources": "subagent:thread_spawn=322, vscode=157, exec=14, cli=7",
        "rollout DB stale rows": "0"
      },
      "remediation": null,
      "durationMs": 2560
    },
    "system.environment": {
      "id": "system.environment",
      "category": "system",
      "status": "ok",
      "summary": "OS language en-US",
      "details": {
        "EDITOR": "not set",
        "VISUAL": "not set",
        "os": "Windows 10.0.26200 (Windows 11 Professional) [64-bit]",
        "os language": "en-US",
        "os type": "Windows",
        "os version": "10.0.26200"
      },
      "remediation": null,
      "durationMs": 0
    },
    "terminal.env": {
      "id": "terminal.env",
      "category": "terminal",
      "status": "ok",
      "summary": "terminal metadata was detected",
      "details": {
        "color output": "disabled (stdout is not a terminal)",
        "console input code page": "437",
        "console output code page": "65001",
        "stderr console mode": "unavailable",
        "stderr is terminal": "false",
        "stdin is terminal": "false",
        "stdout console mode": "unavailable",
        "stdout is terminal": "false",
        "terminal": "unknown",
        "terminal size": "120x30"
      },
      "remediation": null,
      "durationMs": 0
    },
    "terminal.title": {
      "id": "terminal.title",
      "category": "title",
      "status": "ok",
      "summary": "terminal title default",
      "details": {
        "terminal title activity": "true",
        "terminal title items": "activity, project-name",
        "terminal title project source": "git repo root",
        "terminal title project value": "drm-copilot-wt-2026-0...",
        "terminal title source": "default"
      },
      "remediation": null,
      "durationMs": 0
    },
    "updates.status": {
      "id": "updates.status",
      "category": "updates",
      "status": "ok",
      "summary": "update configuration is locally consistent",
      "details": {
        "cached latest version": "0.142.5",
        "check for update on startup": "true",
        "last checked at": "2026-07-04T16:58:09.020055900Z",
        "latest version": "0.142.5",
        "latest version status": "current version is not older",
        "update action": "manual or unknown",
        "version cache": "C:\\Users\\DanMoisan\\.codex\\version.json"
      },
      "remediation": null,
      "durationMs": 247
    }
  }
}

