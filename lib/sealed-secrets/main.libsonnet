local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

{
  version:: '2.6.1',
  _config:: {
    namespace: 'kube-system',
    values: {
      namespace: 'kube-system',
      },
    },

  crds: std.native('parseYaml')(importstr './charts/2.6.1/crds/sealedsecret-crd.yaml'),
  'sealed-secrets': helm.template($._config.namespace, './charts/' + $.version, $._config),
}
