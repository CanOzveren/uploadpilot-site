# Security

## Goal
Publish **no sensitive operational data**. The site is public by design and can be inspected by anyone. Hosting on Cloudflare and source control on GitHub necessarily involve those providers processing some data (e.g. request metadata, repository contents) under their own policies.

## Isolation rules
- This repo is separate from the private panel. Never copy files, config, history or schemas from it.
- Never expose the private panel: no tunnels, reverse proxies, port forwarding, or links to internal URLs.
- Never commit: `.env*`, OAuth client IDs/secrets, access/refresh tokens, API keys, databases, logs, videos, personal data, channel names/IDs/statistics.
- Do not store secrets in Cloudflare Pages variables for this project; none are needed.

## Controls implemented
- Static HTML/CSS only; no JavaScript, cookies, local storage, analytics or third-party requests.
- `public/_headers`: strict CSP (`default-src 'none'`, `frame-ancestors 'none'`), HSTS, `nosniff`, `Referrer-Policy: no-referrer`, restrictive `Permissions-Policy`, COOP/CORP, `X-Frame-Options`.
- Only `public/` is deployed; `scripts/check.sh` enforces a file-type allow-list there.
- External links carry `rel="noopener noreferrer"`.
- `.gitignore` blocks common secret/db/map files.

## Before each commit
1. `bash scripts/check.sh` must pass.
2. Review `git status` and `git diff --staged` for every file.

## Reporting
Report issues privately to the owner: the contact address listed on the Privacy page.
