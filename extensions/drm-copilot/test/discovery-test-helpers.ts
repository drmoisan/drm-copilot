import type {
  DiscoveryProcessLauncher,
  DiscoveryProcessOutcome,
} from "../src/discovery-runtime";
import type { DiscoveryServiceResult } from "../src/discovery-service-types";

export const SHA_A =
  "1111111111111111111111111111111111111111111111111111111111111111";
export const SHA_B =
  "2222222222222222222222222222222222222222222222222222222222222222";

/** A complete, valid v2 service-result document for a successful operation. */
export function buildServiceResult(
  overrides: Partial<DiscoveryServiceResult> = {},
): DiscoveryServiceResult {
  return {
    result_version: "2.0.0",
    operation: "validate-profile",
    mode: "structural",
    ok: true,
    exit_code: 0,
    findings: [],
    artifacts: [],
    summary: {
      message: "Validation passed.",
      counts: [{ name: "findings", value: 0 }],
      validation_result: "pass",
      receipt_ref: null,
      invocation_ref: null,
    },
    input_manifest: {
      entries: [],
      missing_paths: [],
      source_repositories: [],
      target_repositories: [],
      sha256: SHA_A,
    },
    runtime: {
      package_version: "2.0.0",
      schema_version: "2.0.0",
      build_sha256: SHA_A,
      policy_version: 2,
      policy_sha256: SHA_B,
    },
    ...overrides,
  };
}

/** A valid blocking (exit 1) result with one error finding. */
export function buildBlockingResult(
  overrides: Partial<DiscoveryServiceResult> = {},
): DiscoveryServiceResult {
  return buildServiceResult({
    ok: false,
    exit_code: 1,
    findings: [
      {
        code: "COVERAGE_INCOMPLETE",
        severity: "error",
        artifact_path: "discovery/coverage-ledger.json",
        pointer: "/components/0",
        related_ids: ["component.alpha"],
        related_paths: [],
        message: "Component alpha has no disposition.",
        next_action: "Record a disposition for the component.",
      },
    ],
    summary: {
      message: "Discovery completion failed.",
      counts: [{ name: "findings", value: 1 }],
      validation_result: "fail",
      receipt_ref: null,
      invocation_ref: null,
    },
    ...overrides,
  });
}

/** One captured launch: executable, argv, working directory and stdin text. */
export interface LaunchCapture {
  readonly executable: string;
  readonly args: ReadonlyArray<string>;
  readonly cwd: string;
  readonly stdin: string;
}

/** In-memory launcher that records launches and replays a scripted outcome. */
export class FakeLauncher implements DiscoveryProcessLauncher {
  readonly captures: LaunchCapture[] = [];

  constructor(private readonly outcome: DiscoveryProcessOutcome) {}

  launch(
    executable: string,
    args: ReadonlyArray<string>,
    options: { readonly cwd: string; readonly stdin: string },
  ): Promise<DiscoveryProcessOutcome> {
    this.captures.push({
      executable,
      args,
      cwd: options.cwd,
      stdin: options.stdin,
    });
    return Promise.resolve(this.outcome);
  }

  /** The single recorded launch, or an error when none or several happened. */
  single(): LaunchCapture {
    const [capture, ...rest] = this.captures;
    if (capture === undefined || rest.length > 0) {
      throw new Error(
        `expected one launch, saw ${String(this.captures.length)}`,
      );
    }
    return capture;
  }

  /** The request document written to stdin of the single launch. */
  request(): Record<string, unknown> {
    return JSON.parse(this.single().stdin) as Record<string, unknown>;
  }
}

/** A launcher outcome carrying a successful result document on stdout. */
export function successOutcome(
  result: DiscoveryServiceResult = buildServiceResult(),
): DiscoveryProcessOutcome {
  return {
    exitCode: result.exit_code,
    stdout: JSON.stringify(result),
    stderr: "",
  };
}

/** The interpreter resolution injected into every runtime test. */
export const FAKE_INTERPRETER = {
  executable: "C:/tools/python/python.exe",
  argsPrefix: [],
} as const;
