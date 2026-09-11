# Monero — Agent Memory

## Current State

- Version: see `VERSION` file
- Image: `ghcr.io/kub0-ai/monero` (public, multi-arch amd64+arm64)
- Base: `debian:bookworm-slim`
- GPG key: binaryFate (`81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92`)

## Known Issues (Resolved)

- Dogecoin `onlynet=onion` caused stuck sync — same risk exists for Monero if misconfigured. Keep `proxy=127.0.0.1:9050` without `onlynet=onion`.

## Build Notes

- Multi-arch via `TARGETPLATFORM` ARG (not `TARGETARCH`) — Dockerfile uses `case` to map to Monero's archive naming (`linux-x64`, `linux-armv8`).
- GPG key bundled in `docker/keys.asc` — no keyserver dependency at build time.
- `GOODSIG` is REQUIRED; `EXPKEYSIG` alone is rejected. `gpg` exits 0 on an expired
  key, so the Dockerfile greps the status output for `GOODSIG` explicitly rather than
  trusting the exit code — see `docker/Dockerfile` ("expired-key status is not success").
  Key expiry is the most likely future build breakage; it fails closed, by design.
