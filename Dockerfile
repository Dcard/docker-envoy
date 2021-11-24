ARG ENVOY_TAG

FROM ubuntu:bionic AS jaeger

RUN apt update -y
RUN apt install -y build-essential curl libc++-dev libc++abi-dev clang-9

# Force libc++ to be a static link by putting a linker script to do that.
# https://github.com/tetratelabs-attic/getenvoy-package/blob/a5345f6/linux-glibc/build_container/getenvoy_linux_glibc_rbe.sh#L29-L30
RUN echo 'INPUT(-l:libc++.a -l:libc++abi.a -lm -lpthread)' > /usr/lib/x86_64-linux-gnu/libc++.so

# Install CMake
ENV CMAKE_VERSION=3.22.0
RUN curl -L https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz | tar zxf - -C /usr/local
RUN ln -s /usr/local/cmake-${CMAKE_VERSION}-linux-x86_64/bin/cmake /usr/local/bin/cmake

# Link clang to clang-9
RUN ln -s /usr/bin/clang-9 /usr/bin/clang
RUN printf '#!/bin/bash\n\
/usr/bin/clang++-9 -stdlib=libc++ "$@"\n\
' > /usr/bin/clang++
RUN chmod +x /usr/bin/clang++

# Build jaeger-client-cpp
ENV JAEGER_VERSION=0.8.0
RUN curl -L https://github.com/jaegertracing/jaeger-client-cpp/archive/refs/tags/v${JAEGER_VERSION}.tar.gz | tar zxf - -C /tmp
WORKDIR /tmp/jaeger-client-cpp-${JAEGER_VERSION}
COPY jaeger.patch ./
RUN patch -p1 < jaeger.patch
RUN mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DHUNTER_CONFIGURATION_TYPES=Release \
    -DJAEGERTRACING_PLUGIN=ON \
    -DBUILD_TESTING=OFF \
    -DJAEGERTRACING_BUILD_EXAMPLES=OFF \
    -DHUNTER_BUILD_SHARED_LIBS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    .. && \
  make -j$(nproc) && \
  cp libjaegertracing_plugin.so /libjaegertracing_plugin.so

FROM envoyproxy/envoy:$ENVOY_TAG
COPY --from=jaeger /libjaegertracing_plugin.so /usr/local/lib/libjaegertracing_plugin.so
