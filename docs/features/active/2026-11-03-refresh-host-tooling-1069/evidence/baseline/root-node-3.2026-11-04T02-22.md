Timestamp: 2026-11-04T02-22
Command: npm run test:unit:coverage -- --runInBand
EXIT_CODE: 1
Output Summary:     at resolveTool (WORKSPACE\run-node-tool.cjs:62:20)
    at runNodeTool (WORKSPACE\run-node-tool.cjs:109:6)
    at Object.<anonymous> (WORKSPACE\run-jest.cjs:26:3)
    at Module._compile (node:internal/modules/cjs/loader:1968:14)
    at Object..js (node:internal/modules/cjs/loader:2108:10)
    at Module.load (node:internal/modules/cjs/loader:1690:32) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [
    'WORKSPACE\\run-node-tool.cjs',
    'WORKSPACE\\run-jest.cjs'
  ]
}

Node.js v26.13.0
