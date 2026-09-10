#Helm Installing
for helm installing -> 
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    chmod 700 get_helm.sh && ./get_helm.sh
for checking Helm version --> helm version
Chart.yaml (always capital C only starting if not Helm will not recognise )
--> Chart metadata — name, version, apiVersion, description, appVersion 
execute helm charts --> helm install nginx . ###helm install <helmchartname> . ( helm working directory )
to list deployed -----> helm list 
update helm ----------> helm upgrade venkat . <venkat is chart name here>