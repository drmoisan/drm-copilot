# Gold Standard: policy-audit-template-usage

## Objective

Policy audit template usage and output requirements. Use when creating timestamped policy-audit artifacts from the repository templates. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Template Source: The resolved MCP asset is authoritative even when a matching repo file also exists.
- **OB-2** Required Steps: The skill resolves the policy-audit template asset from the packaged template source and copies it to the target location under an ISO-8601 timestamp, replaces the placeholders with actual values (component, date, files under test and commits), removes the template usage instructions, marks each section PASS, FAIL or N/A by the template's conventions, preserves the thirteen canonical major sections in order (Executive Summary, 1. General Unit Test Policy Compliance, 2. General Code Change Policy Compliance, 3. Language-Specific Code Change Policy Compliance, 4. Language-Specific Unit Test Policy Compliance, 5. Test Coverage Detail, 6. Test Execution Metrics, 7. Code Quality Checks, 8. Gaps and Exceptions, 9. Summary of Changes, 10. Compliance Verdict, Appendix A: Test Inventory and Appendix B: Toolchain Commands Reference), and validates the result as a `policy-audit` orchestration artifact, failing closed on any non-zero result.
- **OB-3** Invalid Outputs: A freeform summary note is invalid.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Template Source, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Required Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Invalid Outputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
