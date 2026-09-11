# monero

Parameterized Monero (monerod) Docker image. Multi-arch: `linux/amd64`, `linux/arm64`.

## Docker

Single parameterized Dockerfile supporting any Monero CLI version. GPG-verified binary downloads using bundled signing keys.

```bash
# Build locally
docker buildx build \
  --build-arg VERSION=$(cat VERSION) \
  --platform linux/amd64 \
  -t monero:$(cat VERSION) \
  docker/
```

Image: `ghcr.io/kub0-ai/monero`

### Ports

| Port  | Service              |
|-------|----------------------|
| 18080 | P2P                  |
| 18081 | RPC                  |
| 18082 | ZMQ                  |
| 18089 | Restricted wallet RPC|

### Environment

- `MONERO_DATA` — data directory (default `/home/monero/.monero`)
- `UID` / `GID` — run as custom user/group IDs

## Version Management

- `VERSION` — current Monero CLI version (single source of truth)
- `KEYS` — GPG signing key fingerprints for binary verification
- `watch-release.yml` — daily cron checks upstream for new releases, opens PR
- `backfill.yml` — manual dispatch to build a specific historical version

## License

MIT
