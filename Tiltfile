yaml = helm(
  'helm/gen3',
  name='local-lab',
  namespace='lab',
  # The values file to substitute into the chart.
  values=['./examples/local_dev_values.yaml'],
  # Values to set from the command-line
  set=['ingress.enabled=false']
  )
watch_file('helm/gen3')
watch_file('./examples/local_dev_values.yaml')
k8s_yaml(yaml)
