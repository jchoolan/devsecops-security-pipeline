#!/usr/bin/env bash
# Run the same security checks as the CI pipeline, locally.
# Usage: ./scripts/security-scan.sh [all|sca|sast|secrets|container]
# Requires: Node/npm and Docker. Results are written to ./scan-results/
set -u
cd "$(dirname "$0")/.."
OUT=scan-results
mkdir -p "$OUT"
STAGE="${1:-all}"
FAILED=0

run() { # name, command...
  local name="$1"; shift
  echo; echo "=== $name ==="
  if "$@"; then echo "[PASS] $name"; else echo "[FAIL] $name"; FAILED=1; fi
}

sca()       { npm audit --audit-level=high 2>&1 | tee "$OUT/npm-audit.txt"; return "${PIPESTATUS[0]}"; }
sast()      { docker run --rm -v "$PWD:/src" semgrep/semgrep semgrep scan \
                --config p/security-audit --config p/nodejs --config p/owasp-top-ten \
                --exclude node_modules --exclude app/assets/vendor --error /src 2>&1 | tee "$OUT/semgrep.txt"; return "${PIPESTATUS[0]}"; }
secrets()   { docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:latest detect --source /repo --verbose 2>&1 | tee "$OUT/gitleaks.txt"; return "${PIPESTATUS[0]}"; }
container() { docker build -t nodegoat-devsecops:local . \
              && docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image \
                   --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 nodegoat-devsecops:local 2>&1 | tee "$OUT/trivy.txt"; return "${PIPESTATUS[0]}"; }

case "$STAGE" in
  sca) run "SCA - npm audit" sca ;;
  sast) run "SAST - Semgrep" sast ;;
  secrets) run "Secrets - Gitleaks" secrets ;;
  container) run "Container - Trivy" container ;;
  all) run "SCA - npm audit" sca; run "SAST - Semgrep" sast
       run "Secrets - Gitleaks" secrets; run "Container - Trivy" container ;;
  *) echo "Unknown stage: $STAGE"; exit 2 ;;
esac

echo; [ "$FAILED" -eq 0 ] && echo "ALL CHECKS PASSED" || echo "SOME CHECKS FAILED - see $OUT/"
exit "$FAILED"
