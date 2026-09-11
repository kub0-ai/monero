# monero

Parameterized Monero (monerod) Docker image and Kubernetes deployment.

## Structure

```
docker/Dockerfile           — multi-arch Monero build (debian:bookworm-slim)
docker/docker-entrypoint.sh — entrypoint with gosu, UID/GID support
docker/keys.asc             — bundled GPG signing key (binaryFate)
VERSION                     — current Monero CLI version
KEYS                        — GPG fingerprints for binary verification
```

## Build

```bash
docker buildx build \
  --build-arg VERSION=$(cat VERSION) \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/kub0-ai/monero:$(cat VERSION) \
  --push docker/
```

Image: `ghcr.io/kub0-ai/monero` (public, multi-arch amd64+arm64).

## Deployment

Kubernetes manifests are in `jkubo/ansible` repo under `manifests/blockchain/`.
Two StatefulSets: `monero-archival` (300Gi, blockchain-replicated) and `monero-wallet` (60Gi, blockchain-local).
Both run with a Tor sidecar.

RPC: HTTP Digest auth on port 18081. Credentials in vault (`monero_rpc_user`, `monero_rpc_password`).

## Version bumps

- `VERSION` file is the single source of truth
- `watch-release.yml` checks upstream daily, opens PR on new release
- `backfill.yml` builds a specific historical version (manual dispatch)
- GPG verification runs at build time against bundled `keys.asc`
