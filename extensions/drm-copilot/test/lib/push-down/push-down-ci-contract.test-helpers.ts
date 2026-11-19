/**
 * Text checks of the destination CI contract (issue #1050).
 *
 * Every function is pure over the text it receives, so the contract test can
 * run it against the tracked files and against in-memory variants that must
 * fail.
 */

/** Text inputs of {@link findCiContractDivergences}. */
export interface CiContractInputs {
  /** Caller template text (`resources/ci-workflows/caller/...`). */
  readonly callerTemplate: string;
  /** Data file text. */
  readonly dataText: string;
  /** Bundled `enforce-epic-merge-gate-child-ci.ps1` text. */
  readonly mergeGateHookText: string;
  /** Bundled `validate-feature-review-coverage-metrics.ps1` text. */
  readonly coverageHookText: string;
}

/** Coverage artifact path per pack that the coverage hook reads. */
export const CI_COVERAGE_ARTIFACT_PATHS: ReadonlyArray<string> = [
  "artifacts/python/lcov.info",
  "artifacts/pester/powershell-coverage.xml",
  "coverage/lcov.info",
  "artifacts/csharp/coverage.xml",
];

/** Normalize line endings to LF. */
function lf(text: string): string {
  return text.replace(/\r\n?/g, "\n");
}

/**
 * Return the lines of a block that starts at a line and ends before the next
 * line indented at most as far as the start line.
 *
 * @param lines Text lines.
 * @param start Index of the block's first line.
 * @returns The block lines, the first line included.
 */
function blockFrom(lines: ReadonlyArray<string>, start: number): string[] {
  const first = lines[start] ?? "";
  const indent = first.length - first.trimStart().length;
  const block = [first];
  for (const line of lines.slice(start + 1)) {
    if (line.trim() !== "" && line.length - line.trimStart().length <= indent) {
      break;
    }
    block.push(line);
  }
  return block;
}

/**
 * Return the block of the first line that equals a given line exactly.
 *
 * @param text Workflow text.
 * @param line Exact line.
 * @returns The block lines, or an empty array when the line is absent.
 */
export function findBlock(text: string, line: string): string[] {
  const lines = lf(text).split("\n");
  const index = lines.indexOf(line);
  return index < 0 ? [] : blockFrom(lines, index);
}

/**
 * Parse the `workflow_call` inputs of a reusable workflow.
 *
 * @param text Workflow text.
 * @returns Input name to declared type.
 */
export function parseWorkflowCallInputs(text: string): Map<string, string> {
  const inputs = new Map<string, string>();
  const block = findBlock(text, "    inputs:");
  let current: string | undefined;
  for (const line of block.slice(1)) {
    const name = /^ {6}([A-Za-z0-9_-]+):\s*$/.exec(line);
    if (name?.[1] !== undefined) {
      current = name[1];
      inputs.set(current, "");
      continue;
    }
    const type = /^ {8}type:\s*(\S+)\s*$/.exec(line);
    if (current !== undefined && type?.[1] !== undefined) {
      inputs.set(current, type[1]);
    }
  }
  return inputs;
}

/**
 * Split a workflow into its steps (`- name:` items at six spaces).
 *
 * @param text Workflow text.
 * @returns The text of each step.
 */
export function workflowSteps(text: string): string[] {
  const steps: string[] = [];
  for (const line of lf(text).split("\n")) {
    if (/^ {6}- /.test(line)) {
      steps.push(line);
    } else if (steps.length > 0 && /^ {7,}\S/.test(line)) {
      steps[steps.length - 1] += `\n${line}`;
    }
  }
  return steps;
}

/**
 * Check that a harness workflow is destination-generic and writes the
 * artifacts of the template contract.
 *
 * @param stem Workflow stem (`python`, `powershell`, `typescript`, `dotnet`).
 * @param text Workflow text.
 * @returns One message per violation; empty when the workflow complies.
 */
export function findHarnessWorkflowViolations(
  stem: string,
  text: string,
): string[] {
  const body = lf(text);
  const violations: string[] = [];
  const require = (token: string): void => {
    if (!body.includes(token)) {
      violations.push(`${stem}: missing ${token}`);
    }
  };
  const triggers = findBlock(body, "on:")
    .slice(1)
    .filter((line) => /^ {2}\S/.test(line))
    .map((line) => line.trim().replace(/:.*$/, ""));
  if (triggers.join(",") !== "workflow_call") {
    violations.push(`${stem}: triggers are ${triggers.join(",")}`);
  }
  for (const forbidden of [
    "extensions/drm-copilot",
    "packages/",
    "scripts.dev_tools",
    "NPM_TOKEN",
    "job.workflow_",
    "job_workflow_sha",
  ]) {
    if (body.includes(forbidden)) {
      violations.push(`${stem}: contains ${forbidden}`);
    }
  }
  if (/(?<!\.drm-copilot-harness\/)scripts\//.test(body)) {
    violations.push(`${stem}: names a scripts/ path outside the side folder`);
  }
  for (const match of body.matchAll(/node-version:\s*"?([^"\s]+)"?/g)) {
    if (match[1] !== "26.13.0") {
      violations.push(`${stem}: node-version ${match[1] ?? ""}`);
    }
  }
  if (body.includes("install-poetry") && !body.includes("version: 2.5.1")) {
    violations.push(`${stem}: Poetry is not pinned to 2.5.1`);
  }
  switch (stem) {
    case "python":
      require("--cov-report=lcov:artifacts/python/lcov.info");
      require("artifacts/python/coverage.json");
      require("default: 85");
      require("default: 75");
      break;
    case "powershell":
      violations.push(...findPowerShellHarnessViolations(body));
      break;
    case "typescript":
      for (const script of [
        "format",
        "lint",
        "typecheck",
        "test:unit:coverage",
      ]) {
        require(`npm run ${script}`);
      }
      require("coverage/lcov.info");
      break;
    case "dotnet":
      violations.push(...findDotnetHarnessViolations(body));
      break;
    default:
      violations.push(`${stem}: unknown stem`);
  }
  return violations;
}

/**
 * Check the PowerShell harness: inputs, side checkout, guards, and artifacts.
 *
 * @param body Workflow text with LF line endings.
 * @returns Violations.
 */
function findPowerShellHarnessViolations(body: string): string[] {
  const violations: string[] = [];
  const inputs = parseWorkflowCallInputs(body);
  for (const [name, type] of [
    ["poshqc", "boolean"],
    ["harness_repository", "string"],
    ["harness_ref", "string"],
  ] as const) {
    if (inputs.get(name) !== type) {
      violations.push(`powershell: input ${name} is not a ${type}`);
    }
  }
  const steps = workflowSteps(body);
  const checkout = steps.find((step) =>
    step.includes("path: .drm-copilot-harness"),
  );
  if (
    checkout === undefined ||
    !checkout.includes("repository: ${{ inputs.harness_repository }}") ||
    !checkout.includes("ref: ${{ inputs.harness_ref }}") ||
    !checkout.includes("if: ${{ inputs.poshqc }}")
  ) {
    violations.push(
      "powershell: the side checkout does not read inputs.harness_repository and inputs.harness_ref under inputs.poshqc",
    );
  }
  const guard = steps.find(
    (step) =>
      step.includes("if: ${{ inputs.poshqc }}") &&
      step.includes("inputs.harness_repository") &&
      step.includes("inputs.harness_ref") &&
      step.includes("exit 1"),
  );
  if (guard === undefined) {
    violations.push("powershell: no step fails on an empty harness input");
  }
  const importIndex = steps.findIndex((step) =>
    step.includes(".drm-copilot-harness/scripts/powershell/PoshQC/PoshQC.psd1"),
  );
  const checkoutIndex = checkout === undefined ? -1 : steps.indexOf(checkout);
  if (importIndex < 0 || checkoutIndex < 0 || importIndex < checkoutIndex) {
    violations.push(
      "powershell: PoshQC is not imported after the side checkout",
    );
  }
  const pester = steps.find(
    (step) =>
      step.includes("if: ${{ !inputs.poshqc }}") &&
      step.includes("Invoke-Pester"),
  );
  if (pester === undefined || pester.includes(".drm-copilot-harness")) {
    violations.push(
      "powershell: no direct Pester step guarded by !inputs.poshqc without the side folder",
    );
  }
  if (
    pester !== undefined &&
    (!pester.includes("Test-Path -LiteralPath tests") ||
      !pester.includes("exit 1"))
  ) {
    violations.push(
      "powershell: copy-mode Pester step does not fail when tests is absent",
    );
  }
  for (const token of [
    "artifacts/pester/powershell-coverage.xml",
    "artifacts/pester/pester-junit.xml",
  ]) {
    if (!body.includes(token)) {
      violations.push(`powershell: missing ${token}`);
    }
  }
  return violations;
}

/**
 * Check the .NET harness: JaCoCo counters and the runner per variant.
 *
 * @param body Workflow text with LF line endings.
 * @returns Violations.
 */
function findDotnetHarnessViolations(body: string): string[] {
  const violations: string[] = [];
  for (const token of [
    'counter type="LINE"',
    'counter type="BRANCH"',
    "artifacts/csharp/coverage.xml",
  ]) {
    if (!body.includes(token)) {
      violations.push(`dotnet: missing ${token}`);
    }
  }
  const lines = body.split("\n");
  const jobBlocks = lines
    .map((line, index) => (/^ {2}\S.*:$/.test(line) ? index : -1))
    .filter((index) => index >= 0)
    .map((index) => blockFrom(lines, index).join("\n"));
  const runnerOf = (variant: string): string | undefined =>
    jobBlocks
      .find((block) => block.includes(`inputs.variant == '${variant}'`))
      ?.match(/runs-on:\s*(\S+)/)?.[1];
  if (runnerOf("modern") !== "ubuntu-latest") {
    violations.push("dotnet: modern does not run on ubuntu-latest");
  }
  if (runnerOf("legacy") !== "windows-latest") {
    violations.push("dotnet: legacy does not run on windows-latest");
  }
  return violations;
}

/**
 * Check that a rendered caller's PowerShell job passes only declared inputs
 * and, in reference mode, both harness inputs.
 *
 * @param harnessText `harness-powershell.yml` text.
 * @param callerText Rendered caller text.
 * @returns Violations.
 */
export function findPowerShellInputDivergences(
  harnessText: string,
  callerText: string,
): string[] {
  const declared = parseWorkflowCallInputs(harnessText);
  const job = findBlock(callerText, "  powershell:");
  const withBlock = findBlock(job.join("\n"), "    with:");
  const passed = withBlock
    .slice(1)
    .map((line) => /^ {6}([A-Za-z0-9_-]+):/.exec(line)?.[1])
    .filter((name): name is string => name !== undefined);
  const violations = passed
    .filter((name) => !declared.has(name))
    .map((name) => `caller passes undeclared input ${name}`);
  if (job.join("\n").includes("harness-powershell.yml@")) {
    for (const name of ["harness_repository", "harness_ref"]) {
      if (!passed.includes(name)) {
        violations.push(`reference caller does not pass ${name}`);
      }
    }
  }
  // The side checkout must read both inputs through its own keys; another
  // step that merely references an input (the empty-input guard) does not count.
  const checkout = workflowSteps(harnessText).find((step) =>
    step.includes("path: .drm-copilot-harness"),
  );
  for (const [key, name] of [
    ["repository", "harness_repository"],
    ["ref", "harness_ref"],
  ] as const) {
    if (!(checkout ?? "").includes(`${key}: \${{ inputs.${name} }}`)) {
      violations.push(`harness checkout does not read inputs.${name}`);
    }
  }
  return violations;
}

/**
 * Compare the caller template, the data file, and the consumer literals.
 *
 * @param inputs Template, data file, and hook texts.
 * @returns One message per divergence; empty when they agree.
 */
export function findCiContractDivergences(inputs: CiContractInputs): string[] {
  const template = lf(inputs.callerTemplate);
  const divergences: string[] = [];
  let data: Record<string, unknown> = {};
  try {
    const parsed: unknown = JSON.parse(inputs.dataText);
    if (parsed !== null && typeof parsed === "object") {
      data = parsed as Record<string, unknown>;
    }
  } catch {
    divergences.push("data file is not JSON");
  }
  const callerName = /^name:\s*(.+?)\s*$/m.exec(template)?.[1];
  const hookName = /workflowName'\)\)?\s*-cne\s*'([^']+)'/.exec(
    inputs.mergeGateHookText,
  )?.[1];
  if (callerName === undefined || callerName !== hookName) {
    divergences.push(
      `caller name ${String(callerName)} differs from the merge-gate literal ${String(hookName)}`,
    );
  }
  if (callerName !== data["workflow"]) {
    divergences.push(
      `caller name ${String(callerName)} differs from the data file workflow`,
    );
  }
  const gateName = /^ {2}ci-required-gate:\n {4}name:\s*(.+?)\s*$/m.exec(
    template,
  )?.[1];
  const contexts = data["required_contexts"];
  if (
    !Array.isArray(contexts) ||
    contexts.length !== 1 ||
    contexts[0] !== gateName
  ) {
    divergences.push(
      `gate job name ${String(gateName)} differs from required_contexts`,
    );
  }
  if (data["workflow_file"] !== ".github/workflows/drm-copilot-ci.yml") {
    divergences.push("data file workflow_file is not the caller path");
  }
  for (const [label, pattern] of [
    [
      "pull_request on epic/**",
      /^ {2}pull_request:\n {4}branches:\n {6}- main\n {6}- "epic\/\*\*"$/m,
    ],
    ["push on main", /^ {2}push:\n {4}branches:\n {6}- main$/m],
    ["workflow_dispatch", /^ {2}workflow_dispatch:\s*$/m],
    ["merge_group", /^ {2}merge_group:\s*$/m],
    ["if: always()", /^ {4}if: always\(\)\s*$/m],
    ["NEEDS_JSON step", /NEEDS_JSON: \$\{\{ toJSON\(needs\) \}\}/],
    ["success comparison", /-ne 'success'/],
  ] as const) {
    if (!pattern.test(template)) {
      divergences.push(`caller template lacks ${label}`);
    }
  }
  for (const path of CI_COVERAGE_ARTIFACT_PATHS) {
    if (!inputs.coverageHookText.includes(path)) {
      divergences.push(`coverage hook does not read ${path}`);
    }
  }
  return divergences;
}
