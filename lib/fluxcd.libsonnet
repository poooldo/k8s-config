(import 'github.com/jsonnet-libs/fluxcd-libsonnet/2.6.1/main.libsonnet') {
  helmRepository:: $.source.v1.helmRepository,
  helmRelease:: $.helm.v2.helmRelease,
  kustomization:: $.kustomize.v1.kustomization,
  alert:: $.notification.v1beta3.alert,
}
