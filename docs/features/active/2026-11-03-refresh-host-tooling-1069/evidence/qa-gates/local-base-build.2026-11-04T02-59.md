Timestamp: 2026-11-04T02-59
Command: docker build --progress=plain -f .devcontainer/local/Dockerfile -t issue-1069-local-base .
EXIT_CODE: 0
Output Summary: #27 CACHED

#28 [stage-2 22/22] RUN wget -qO- https://gh.io/copilot-install     | VERSION="0.0.377" PREFIX="/usr/local" bash
#28 CACHED

#29 exporting to image
#29 exporting layers 0.0s done
#29 exporting manifest sha256:b6fd97aa3ca2547217879553908983bd01e1670172326202724b2fccffd4ada0 done
#29 exporting config sha256:2e118ae0fb206c98f012b43bab01fc83c2e7181ce0b6e7de1f8e0426e346f571 done
#29 exporting attestation manifest sha256:7af7db32b190edd4892ac855e0c8f34b6e82bf39d4924e67ce20080dbb4c97e7 0.0s done
#29 exporting manifest list sha256:c13f630523753bd0b81cf4d0de0325c2260b99cd72ea7e20986ca626221b3420 0.0s done
#29 naming to docker.io/library/issue-1069-local-base:latest done
#29 unpacking to docker.io/library/issue-1069-local-base:latest done
#29 DONE 0.1s


