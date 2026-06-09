#!/bin/bash

funnelVer=$(yq '.dependencies[] | select(.name == "funnel") .version' helm/funnel/Chart.yaml)
chartPath=helm/funnel/charts/funnel-$funnelVer.tgz
if [ ! -f "$chartPath" ]; then
    echo "$chartPath does not exist. Please run 'cd helm/funnel && helm dependency update'. Existing files:"
    ls helm/funnel/charts
    exit 1
fi
