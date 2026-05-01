# Helm charts for deploying Supabase

This repo contains charts and a helm repo for deploying Supabase

Add the repo

```bash
helm repo add supaplus https://supafull.github.io/helm-charts
```

Now copy the `values.example.yaml` (and modify if needed) file locally and

```bash
helm upgrade --install --namespace supatest --create-namespace supatest supaplus/supabase -f values.example.yaml
```
