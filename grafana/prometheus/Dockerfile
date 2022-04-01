FROM prom/prometheus:latest

FROM alpine:latest
RUN apk add gettext

COPY --from=0 /bin/prometheus /bin/prometheus

RUN mkdir -p /prometheus /etc/prometheus && \
chown -R nobody:nogroup etc/prometheus /prometheus
# Run envsubst before Prometheus.
RUN echo $'#!/bin/sh\n\
touch /etc/prometheus/prometheus.yml && \
envsubst < /etc/prometheus/prometheus.env.yml > /etc/prometheus/prometheus.yml && \
exec /bin/prometheus "$@"' \
> /etc/prometheus/entrypoint.sh
RUN chmod +x /etc/prometheus/entrypoint.sh
ENTRYPOINT ["/etc/prometheus/entrypoint.sh"]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", \
"--storage.tsdb.path=/prometheus" ]
USER nobody
EXPOSE 9090
VOLUME [ "/prometheus" ]
WORKDIR /prometheus

#ADD /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.env.yml
