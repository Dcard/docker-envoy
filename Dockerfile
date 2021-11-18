ARG ENVOY_TAG

FROM debian:bullseye AS jaeger
RUN apt-get update -y
RUN apt-get install -y curl
RUN curl -L https://github.com/envoyproxy/misc/releases/download/jaegertracing-plugin/jaegertracing-plugin-centos.tar.gz | tar zxf - -C /usr/local/lib

FROM envoyproxy/envoy:$ENVOY_TAG
COPY --from=jaeger /usr/local/lib/libjaegertracing.so.0.4.2 /usr/local/lib/libjaegertracing_plugin.so
