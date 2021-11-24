# docker-envoy

This Docker image is based on the official [envoyproxy/envoy](https://hub.docker.com/r/envoyproxy/envoy/) Docker image. Compiled with a patched version of [jaeger-client-cpp](https://github.com/jaegertracing/jaeger-client-cpp) plugin.

## Usage

```sh
docker pull dcard/envoy:v1.20
```

## Building Docker Images

```sh
docker build --build-arg ENVOY_TAG=v1.20.0 .
```

## Patch File

The `jaeger.patch` file is generated based on [jaeger-client-cpp#183](https://github.com/jaegertracing/jaeger-client-cpp/issues/183#issuecomment-663440832). All changes are stored in [tommy351/jaeger-client-cpp](https://github.com/tommy351/jaeger-client-cpp/tree/envoy-plugin). You can create and apply the patch as below.

```sh
git clone https://github.com/tommy351/jaeger-client-cpp.git
cd jaeger-client-cpp
git diff -w v0.8.0 envoy-plugin > ./jaeger.patch
patch -p1 < ./jaeger.patch
```
