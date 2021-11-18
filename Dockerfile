ARG ENVOY_TAG

FROM debian:bullseye AS jaeger
RUN apt-get update -y
RUN apt-get install -y curl
RUN curl -L https://github.com/jaegertracing/jaeger-client-cpp/releases/download/v0.4.2/libjaegertracing_plugin.linux_amd64.so > /libjaegertracing_plugin.so

FROM envoyproxy/envoy:$ENVOY_TAG
COPY --from=jaeger /libjaegertracing_plugin.so /usr/local/lib/libjaegertracing_plugin.so
