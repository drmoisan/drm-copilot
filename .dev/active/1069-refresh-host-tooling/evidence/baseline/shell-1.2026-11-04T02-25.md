Timestamp: 2026-11-04T02-25
Command: wsl -d Ubuntu -- bash -lc 'SCRATCH/issue-1069-shfmt -d .devcontainer/post-create.sh .devcontainer/verify-container.sh'
EXIT_CODE: 1
Output Summary: +	if [ "$ENV_TYPE" = "codespaces" ]; then
+		echo ""
+		echo "For Codespaces:"
+		echo "  - Try deleting and recreating the Codespace"
+		echo "  - Ensure .devcontainer/devcontainer.json exists"
+	else
+		echo ""
+		echo "For Local Docker:"
+		echo "  - Try rebuilding the container: F1 → Dev Containers: Rebuild Container"
+		echo "  - Ensure you selected .devcontainer/local/devcontainer.json"
+		echo "  - See .devcontainer/CONFIG-GUIDE.md for help"
+	fi
+	echo ""
+	echo "See .devcontainer/TROUBLESHOOTING.md for more help."
+	exit 1
 fi
