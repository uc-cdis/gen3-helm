echo "mkdir -p /data-portal/custom/sponsors"
mkdir -p /data-portal/custom/sponsors || true

echo "cp -r /overrides/gitops-sponsors /data-portal/custom/sponsors/gitops-sponsors"
cp -r /overrides/gitops-sponsors /data-portal/custom/sponsors/gitops-sponsors || true

echo "cp /overrides/gitops-logo.png /data-portal/custom/logo/gitops-logo.png"
cp /overrides/gitops-logo.png /data-portal/custom/logo/gitops-logo.png || true

echo "cp /overrides/gitops.json /data-portal/data/config/gitops.json"
cp /overrides/gitops.json /data-portal/data/config/gitops.json || true

echo "cp /overrides/gitops-logo.png /data-portal/custom/logo/gitops-logo.png"
cp /overrides/gitops-logo.png /data-portal/custom/logo/gitops-logo.png || true

echo "cp /overrides/gitops-favicon.ico /data-portal/custom/favicon/gitops-favicon.ico"
cp /overrides/gitops-favicon.ico /data-portal/custom/favicon/gitops-favicon.ico || true

echo "cp /overrides/gitops.css /data-portal/custom/css/gitops.css"
cp /overrides/gitops.css /data-portal/custom/css/gitops.css || true
