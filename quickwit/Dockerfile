# Quickwit: full-text search over spans. Official image v0.9.1 (the version
# upstream's compose uses), pinned by digest.
FROM quickwit/quickwit:v0.9.1@sha256:3e0f079eb57dd5563f36a457e9a7a2963ff882316d6c77e3180ac3c59767a68f

# Listen on IPv6 and IPv4 (Railway's private network is IPv6). A fixed node id
# keeps the ingest write-ahead log and splits owned by the same node after a
# redeploy changes the container's hostname. REST 7280, gRPC ingest 7281.
ENV QW_LISTEN_ADDRESS=:: \
    QW_NODE_ID=laminar-quickwit \
    QW_DATA_DIR=/quickwit/qwdata \
    QW_DISABLE_TELEMETRY=1 \
    PORT=7280

CMD ["run"]
