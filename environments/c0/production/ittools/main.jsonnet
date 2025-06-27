local config = import '../config.libsonnet';

{
  it_tools: (import 'ittools/main.libsonnet') {
    _config+:: {
      environment: config.environment,
      ingressHostname: 'ittools.akira.fr',
    },
  },
}
