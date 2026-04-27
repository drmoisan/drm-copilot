import * as vscode from "vscode";

import type { RepoAutomationService } from "./repo-automation-service";

export interface RepoAutomationCommandRegistrationOptions {
  readonly context: vscode.ExtensionContext;
  readonly output: vscode.OutputChannel;
  readonly service: RepoAutomationService;
}
