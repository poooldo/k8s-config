// https://github.com/fluxcd/flux2/blob/main/manifests/monitoring/monitoring-config/podmonitor.yaml

local kp = import 'github.com/jsonnet-libs/kube-prometheus-libsonnet/0.14/main.libsonnet';
local podMonitor = kp.monitoring.v1.podMonitor;

local fluxcd = import 'fluxcd.libsonnet';
local provider = fluxcd.notification.v1beta2.provider;

{
  _config:: {
    name: 'flux-system',
    namespace: 'flux-system',
  },

  podMonitor:
    podMonitor.new($._config.name) +
    podMonitor.metadata.withNamespace($._config.namespace) +
    podMonitor.metadata.withLabels({
      'app.kubernetes.io/part-of': 'flux',
      'app.kubernetes.io/component': 'monitoring',
    }) +
    podMonitor.spec.namespaceSelector.withMatchNames([$._config.namespace]) +
    podMonitor.spec.selector.withMatchExpressions([
      {
        key: 'app',
        operator: 'In',
        values: [
          'helm-controller',
          'source-controller',
          'kustomize-controller',
          'notification-controller',
          'image-automation-controller',
          'image-reflector-controller',
        ],
      },
    ]) +
    podMonitor.spec.withPodMetricsEndpoints([
      podMonitor.spec.podMetricsEndpoints.withPort('http-prom') +
      podMonitor.spec.podMetricsEndpoints.withRelabelings([
        // https://github.com/prometheus-operator/prometheus-operator/issues/4816
        podMonitor.spec.podMetricsEndpoints.relabelings.withSourceLabels(['__meta_kubernetes_pod_phase']) +
        podMonitor.spec.podMetricsEndpoints.relabelings.withAction('keep') +
        podMonitor.spec.podMetricsEndpoints.relabelings.withRegex('Running'),
      ]),
    ]),
}
