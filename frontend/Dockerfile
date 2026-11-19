# Laminar dashboard (Next.js), official image v0.3.4, pinned by digest.
FROM ghcr.io/lmnr-ai/frontend:v0.3.4@sha256:512e9638f9fc9145957cf3463f47cda5f26066253b29dc73adfb050a1212e4fa

# Fixed settings. Everything Railway can derive is a template variable instead.
ENV PORT=5667 \
    HOSTNAME=:: \
    ENVIRONMENT=FULL \
    CLICKHOUSE_POSTGRES_USER=laminar_ch_ro \
    CLICKHOUSE_POSTGRES_PORT=5432

COPY --chown=nextjs:nodejs wait.mjs start.sh /app/railway/
CMD ["sh", "/app/railway/start.sh"]
