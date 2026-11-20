/**
 * `npx` subcommand `migrate-development-docs` (issue #1016, spec "CLI").
 *
 *     npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace <path>
 *       --mode dry-run|apply [--decisions <path>] [--report-dir <path>]
 *
 * Exit codes: 0 success; 1 refusal or execution error (reason on stderr);
 * 2 usage error (unknown flag, missing `--workspace` or `--mode`, invalid mode).
 * Standard output carries the Markdown summary.
 */
import { RealFileSystem } from "./lib/file-system";
import { SubprocessRunner } from "./lib/subprocess-runner";
import {
  migrateDevelopmentDocsServiceCall,
  type MigrateDevelopmentDocsInput,
  type MigrateDevelopmentDocsResult,
} from "./lib/development-docs-migration/migrate-development-docs-service-call";

/** First argument that selects this subcommand on the package bin. */
export const MIGRATE_DEVELOPMENT_DOCS_SUBCOMMAND = "migrate-development-docs";

/** Injectable dependencies of {@link runMigrateDevelopmentDocsCli}. */
export interface MigrateDevelopmentDocsCliDependencies {
  readonly execute: (
    input: MigrateDevelopmentDocsInput,
  ) => MigrateDevelopmentDocsResult;
  readonly stdout: (text: string) => void;
  readonly stderr: (text: string) => void;
}

/** Production wiring: real file system, real git runner and the UTC system clock. */
export const DEFAULT_CLI_DEPENDENCIES: MigrateDevelopmentDocsCliDependencies = {
  execute: (input) =>
    migrateDevelopmentDocsServiceCall({
      fileSystem: new RealFileSystem(),
      runner: new SubprocessRunner(),
      now: () => new Date(),
      input,
    }),
  stdout: (text) => process.stdout.write(text),
  stderr: (text) => process.stderr.write(text),
};

const FLAG_KEYS: Readonly<Record<string, keyof MigrateDevelopmentDocsInput>> = {
  "--workspace": "workspaceRoot",
  "--mode": "mode",
  "--decisions": "renameDecisionsPath",
  "--report-dir": "reportDirectory",
};

const USAGE =
  "usage: migrate-development-docs --workspace <path> --mode dry-run|apply [--decisions <path>] [--report-dir <path>]";

/**
 * Parse the subcommand flags.
 *
 * @param argv Arguments after the subcommand name.
 * @returns The input, or a usage error message.
 */
export function parseMigrateDevelopmentDocsArgs(
  argv: ReadonlyArray<string>,
): { input: MigrateDevelopmentDocsInput } | { error: string } {
  const values: Partial<Record<keyof MigrateDevelopmentDocsInput, string>> = {};
  for (let index = 0; index < argv.length; index += 1) {
    const word = argv[index] ?? "";
    const equals = word.indexOf("=");
    const flag = equals > 0 ? word.slice(0, equals) : word;
    const key = FLAG_KEYS[flag];
    if (key === undefined) {
      return { error: `unknown argument: ${word}` };
    }
    const value = equals > 0 ? word.slice(equals + 1) : argv[(index += 1)];
    if (value === undefined || value === "") {
      return { error: `missing value for ${flag}` };
    }
    values[key] = value;
  }
  if (values.workspaceRoot === undefined) {
    return { error: "missing --workspace" };
  }
  if (values.mode === undefined) {
    return { error: "missing --mode" };
  }
  if (values.mode !== "dry-run" && values.mode !== "apply") {
    return { error: `invalid --mode: ${values.mode}` };
  }
  return {
    input: {
      workspaceRoot: values.workspaceRoot,
      mode: values.mode,
      ...(values.renameDecisionsPath === undefined
        ? {}
        : { renameDecisionsPath: values.renameDecisionsPath }),
      ...(values.reportDirectory === undefined
        ? {}
        : { reportDirectory: values.reportDirectory }),
    },
  };
}

/**
 * Render the result summary as Markdown.
 *
 * @param result Service result.
 * @returns Markdown text ending with a newline.
 */
function renderMarkdown(result: MigrateDevelopmentDocsResult): string {
  const [title, ...lines] = result.summary.split("\n");
  const body = lines.map((line) => `- ${line}`);
  const artifacts = result.artifacts.map((artifact) => `- report: ${artifact}`);
  return [
    `# ${title ?? "migrate_development_docs"}`,
    "",
    ...body,
    ...artifacts,
    "",
  ].join("\n");
}

/**
 * Run the subcommand.
 *
 * @param argv Arguments after the subcommand name.
 * @param deps Injectable execute function and output streams.
 * @returns The process exit code.
 */
export function runMigrateDevelopmentDocsCli(
  argv: ReadonlyArray<string>,
  deps: MigrateDevelopmentDocsCliDependencies = DEFAULT_CLI_DEPENDENCIES,
): number {
  const parsed = parseMigrateDevelopmentDocsArgs(argv);
  if ("error" in parsed) {
    deps.stderr(`${parsed.error}\n${USAGE}\n`);
    return 2;
  }
  try {
    deps.stdout(renderMarkdown(deps.execute(parsed.input)));
    return 0;
  } catch (error: unknown) {
    deps.stderr(`${error instanceof Error ? error.message : String(error)}\n`);
    return 1;
  }
}
