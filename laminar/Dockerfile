# Laminar gateway: the one public URL of the template.
# Caddy 2.11.9 (official image), pinned by digest.
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0

ENV PORT=8080
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/laminar-gateway
RUN chmod +x /usr/local/bin/laminar-gateway

CMD ["/usr/local/bin/laminar-gateway"]
