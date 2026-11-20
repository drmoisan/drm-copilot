Timestamp: 2026-11-04T02-56
Command: docker build --progress=plain -f .devcontainer/codespaces/Dockerfile -t issue-1069-codespaces-base .
EXIT_CODE: 0
Output Summary: #28 [stage-2 22/22] RUN wget -qO- https://gh.io/copilot-install     | VERSION="0.0.377" PREFIX="/usr/local" bash
#28 0.301 Installing GitHub Copilot CLI...
#28 0.303 Downloading from: https://github.com/github/copilot-cli/releases/download/v0.0.377/copilot-linux-x64.tar.gz
#28 5.026 ✓ Checksum validated
#28 6.100 ✓ GitHub Copilot CLI installed to /usr/local/bin/copilot
#28 6.101
#28 6.101 Installation complete! Run 'copilot help' to get started.
#28 DONE 6.1s

#29 exporting to image
#29 exporting layers
#29 exporting layers 10.0s done
#29 exporting manifest sha256:b6fd97aa3ca2547217879553908983bd01e1670172326202724b2fccffd4ada0 0.0s done
#29 exporting config sha256:2e118ae0fb206c98f012b43bab01fc83c2e7181ce0b6e7de1f8e0426e346f571 0.0s done
#29 exporting attestation manifest sha256:de12228fc51a22ae2bf4f06499af614202192f55b81789722e0f58d13f08ccf6 0.0s done
#29 exporting manifest list sha256:e9d3ceae96ff6dc8eb3a1a575341d6c1bbd1a2c88be745755d0fbace77a8f74b 0.0s done
#29 naming to docker.io/library/issue-1069-codespaces-base:latest done
#29 unpacking to docker.io/library/issue-1069-codespaces-base:latest
#29 unpacking to docker.io/library/issue-1069-codespaces-base:latest 5.6s done
#29 DONE 15.8s
