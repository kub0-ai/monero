FROM debian:bookworm-slim

ARG UID=101
ARG GID=101
# VERSION must be passed explicitly (CI reads the repo VERSION file).
# No silent stale default — bare `docker build` without --build-arg fails.
ARG VERSION
# Trust root: docker/keys.asc only (bundled binaryFate pubkey).
# Repo-root KEYS is a fingerprint documentation pin for CI policy — it is NOT
# imported here and there is no KEYS build-arg. Do not pass KEYS= to docker build.
# Key: 81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92
# Source: https://github.com/monero-project/monero/blob/master/utils/gpg_keys/binaryfate.asc

LABEL org.opencontainers.image.source="https://github.com/kub0-ai/monero"
LABEL org.opencontainers.image.description="Monero (monerod) v${VERSION}"
LABEL org.opencontainers.image.licenses="MIT"

RUN groupadd --gid ${GID} monero \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} monero \
  && apt-get update -y \
  && apt-get install -y curl gnupg gosu ca-certificates bzip2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TARGETPLATFORM
ENV MONERO_VERSION=${VERSION}
ENV MONERO_DATA=/home/monero/.monero

# Fail fast if VERSION was not supplied (empty ARG default)
RUN test -n "${MONERO_VERSION}" || (echo "ERROR: VERSION build-arg is required (e.g. --build-arg VERSION=\$(cat VERSION))" && exit 1)

# Import bundled GPG key (no keyserver dependency; keys.asc is sole trust root)
COPY keys.asc /tmp/keys.asc
RUN gpg --batch --import /tmp/keys.asc && rm /tmp/keys.asc

RUN set -ex \
  && case "${TARGETPLATFORM}" in \
       linux/amd64) ARCH=linux-x64 ;; \
       linux/arm64) ARCH=linux-armv8 ;; \
       *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
     esac \
  && TARBALL="monero-${ARCH}-v${MONERO_VERSION}.tar.bz2" \
  && curl -SLO "https://downloads.getmonero.org/cli/${TARBALL}" \
  && curl -SL "https://raw.githubusercontent.com/monero-project/monero-site/master/downloads/hashes.txt" -o hashes.txt \
  \
  # hashes.txt is a PGP-clearsigned file — require GOODSIG only (expired-key status is not success)
  && VERIFY=$(gpg --verify --status-fd=1 hashes.txt 2>/dev/null || true) \
  && if ! echo "${VERIFY}" | grep -qE "GOODSIG"; then \
       echo "ERROR: GPG verification of hashes.txt FAILED (GOODSIG required; expired-key status not accepted):"; \
       gpg --verify hashes.txt 2>&1 || true; \
       exit 1; \
     fi \
  \
  # Verify SHA256 of the tarball against hashes.txt
  && grep "${TARBALL}" hashes.txt | sha256sum -c - \
  \
  # Extract binaries
  && tar -xjf "${TARBALL}" \
  && EXTRACTED=$(find . -maxdepth 1 -type d -name "monero-*" | head -1) \
  && install -m 0755 -o root -g root \
       "${EXTRACTED}/monerod" \
       "${EXTRACTED}/monero-wallet-cli" \
       "${EXTRACTED}/monero-wallet-rpc" \
       /usr/local/bin/ \
  && rm -rf "${TARBALL}" "${EXTRACTED}" hashes.txt ~/.gnupg

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/monero/.monero"]

# P2P / RPC / ZMQ / wallet-rpc restricted
EXPOSE 18080 18081 18082 18089

ENTRYPOINT ["/entrypoint.sh"]
RUN monerod --version | grep -E "Monero 'Fluorine Fermi'.*v${MONERO_VERSION}"
CMD ["monerod"]
