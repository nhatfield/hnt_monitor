# Grafana Setup

## Login
Now that you have the full stack running, it's time to setup grafana. The first thing we need to do is login to the UI and update the default password. 

![login](images/grafana-login.png)

## Data Source
Next, lets add the prometheus data source to grafana for metric query. Click the configuration cog wheel in the left nav window. 

![config](images/grafana-config.png)

Then select `data sources` and `add data source`.

![datasource](images/grafana-datasource.png)

Select the `Prometheus` data source on the next page and add the URL to point to your prometheus host. 

![prometheus](images/datasource-prometheus.png)

![url](images/datasource-url.png)

Test and save the data source configuration and click the `back` button

![save](images/datasource-save.png)

![verify](images/datasource-verify.png)

Thats it, you're ready to query metrics in grafana from prometheus!
