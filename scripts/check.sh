#!/usr/bin/env bash
# Security & policy checks for the static site. Run from repo root: bash scripts/check.sh
# Scans git-tracked/working files and the deploy dir (public/). Exits non-zero on any finding.
set -u
cd "$(dirname "$0")/.."
fail=0
bad() { echo "FAIL: $*"; fail=1; }

# 1. Only allow-listed file types in public/
while IFS= read -r f; do
  case "$f" in
    *.html|*.css|*.svg|*.txt|_headers|_redirects) ;;
    *) bad "unapproved file in public/: $f" ;;
  esac
done < <(find public -type f | sed 's#^public/##')

# 2. Secret / credential patterns anywhere (excluding .git and this script)
secret_re='(AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|ya29\.[0-9A-Za-z_-]+|1//[0-9A-Za-z_-]{20,}|GOCSPX-[0-9A-Za-z_-]+|[0-9]+-[0-9a-z]{20,}\.apps\.googleusercontent\.com|gh[pousr]_[0-9A-Za-z]{30,}|sk-[0-9A-Za-z]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(secret|token|password|api[_-]?key)["'"'"' ]*[:=]["'"'"' ]*[0-9A-Za-z/+_-]{16,})'
if grep -rIEn --exclude-dir=.git --exclude=check.sh "$secret_re" . ; then bad "possible secret found"; fi

# 3. Private/operational references
priv_re='(127\.0\.0\.1|localhost|api/social/youtube|\.env|prisma|refresh_token|client_secret)'
if grep -rIEn --exclude-dir=.git --exclude=check.sh --exclude=SECURITY.md --exclude=README.md --exclude=DEPLOYMENT.md --exclude=.gitignore . | grep -E "$priv_re"; then bad "private reference in tracked content"; fi
if grep -rIEn "$priv_re" public ; then bad "private reference inside public/"; fi

# 4. No third-party URLs loaded as resources; no scripts; no inline handlers
if grep -rIEn '<script|<iframe|<img[^>]+src="https?:|<link[^>]+href="https?://[^"]*\.(css|js)|@import|url\(https?:|on(click|load|error)=' public ; then bad "script/remote resource/inline handler"; fi
if grep -rIEn 'google-analytics|googletagmanager|fbq\(|gtag|hotjar|plausible|fonts\.googleapis' public ; then bad "tracker reference"; fi

# 5. External links must have rel=noopener noreferrer
while IFS= read -r line; do
  echo "$line" | grep -q 'rel="noopener noreferrer"' || bad "external link missing rel: $line"
done < <(grep -rIhoE '<a [^>]*href="https?://[^"]*"[^>]*>' public)

# 6. Source maps / hidden files
find public -name '*.map' -o -name '.*' -type f | grep . && bad "map/hidden file in public/"

# 7. Required headers present
for h in "Content-Security-Policy" "X-Content-Type-Options: nosniff" "Referrer-Policy: no-referrer" "Permissions-Policy" "Strict-Transport-Security" "frame-ancestors 'none'"; do
  grep -q "$h" public/_headers || bad "missing header: $h"
done

# 8. Required pages and cross-links
for p in public/index.html public/privacy/index.html public/terms/index.html public/404.html; do [ -f "$p" ] || bad "missing $p"; done
grep -q 'href="/privacy"' public/index.html || bad "homepage lacks /privacy link"
grep -q 'href="/terms"' public/index.html || bad "homepage lacks /terms link"

# 9. Env files must not exist
if find . -path ./.git -prune -o \( -name '.env*' -o -name '*.sqlite*' -o -name '*.db' \) -print | grep .; then bad "env/db file present"; fi

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASSED" || { echo "CHECKS FAILED"; exit 1; }
