FROM debian:bookworm-slim

ARG UID=101
ARG GID=101
ARG VERSION=0.18.4.5
# binaryFate — primary Monero release signer
# Key: 81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92
ARG KEYS="81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92"

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

RUN set -ex \
  && case "${TARGETPLATFORM}" in \
       linux/amd64) ARCH=linux-x64 ;; \
       linux/arm64) ARCH=linux-armv8 ;; \
       *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
     esac \
  && TARBALL="monero-${ARCH}-v${MONERO_VERSION}.tar.bz2" \
  && curl -SLO "https://downloads.getmonero.org/cli/${TARBALL}" \
  && curl -SLO "https://www.getmonero.org/downloads/hashes.txt" \
  \
  # Import GPG signing keys (binaryFate + any extras provided)
  && for key in ${KEYS}; do \
       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
       gpg --batch --keyserver keys.openpgp.org    --recv-keys "$key" || \
       gpg --batch --keyserver pgp.mit.edu         --recv-keys "$key" ; \
     done \
  \
  # hashes.txt is a PGP-clearsigned file — verify inline signature
  && VERIFY=$(gpg --verify hashes.txt 2>&1 || true) \
  && if ! echo "${VERIFY}" | grep -qE "GOODSIG|EXPKEYSIG"; then \
       echo "ERROR: GPG verification of hashes.txt FAILED:"; \
       echo "${VERIFY}"; \
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
