FROM grafana/grafana:latest

COPY datasource.yml /etc/grafana/provisioning/datasources/datasource.yml
COPY dashboards.yml /etc/grafana/provisioning/dashboards/dashboards.yml
COPY dashboards/ /var/lib/grafana/dashboards/

EXPOSE 3000

