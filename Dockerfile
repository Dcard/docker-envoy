ARG ENVOY_TAG

FROM envoyproxy/envoy:$ENVOY_TAG AS base

FROM base AS jaeger
RUN apt-get update -y
RUN apt-get install -y curl build-essential cmake

ENV VERSION=0.8.0
RUN curl -L https://github.com/jaegertracing/jaeger-client-cpp/archive/refs/tags/v${VERSION}.tar.gz | tar zxf - -C /tmp
WORKDIR /tmp/jaeger-client-cpp-${VERSION}/build
RUN cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DJAEGERTRACING_PLUGIN=ON \
  -DBUILD_TESTING=OFF \
  -DHUNTER_BUILD_SHARED_LIBS=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  ..
RUN make -j$(nproc)
RUN cp libjaegertracing_plugin.so /usr/local/lib/libjaegertracing_plugin.so

FROM base
COPY --from=jaeger /usr/local/lib/libjaegertracing_plugin.so /usr/local/lib/libjaegertracing_plugin.so
