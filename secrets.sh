clickhouse.agrimin.sarvam.ai
flagsmith.agrimin.sarvam.ai
grafana.agrimin.sarvam.ai
argocd.agrimin.sarvam.ai
agents.agrimin.sarvam.ai
apps.agrimin.sarvam.ai 

az network dns record-set a add-record \
  --resource-group dns-zone-rg \
  --zone-name sarvam.ai \
  --record-set-name clickhouse.agrimin \
  --ipv4-address 34.180.49.65
  