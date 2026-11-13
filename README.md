# UploadPilot website

Static public website for **UploadPilot** (uploadpilot.pages.dev): homepage, `/privacy`, `/terms`, 404.

This repository is **fully independent** of the private UploadPilot automation panel. It contains no application code, credentials, databases, tokens or personal data, and must never be connected to the private panel.

## Layout

```
public/            <- the ONLY directory deployed (Cloudflare Pages build output)
  index.html  privacy/index.html  terms/index.html  404.html
  assets/  favicon.svg  robots.txt  _headers
scripts/check.sh   <- security/policy checks
SECURITY.md
```

Plain HTML + CSS, no JavaScript, no build step, no dependencies, no cookies/local storage, no third-party requests.

## Local preview

```
cd public
python -m http.server 8080
```
Open http://localhost:8080 (note: `_headers` is applied only by Cloudflare, not by this server).

## Checks

```
bash scripts/check.sh
```
Run before every commit. It scans for secrets, private references, trackers, remote resources, missing headers and unapproved files in `public/`.

