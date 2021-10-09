FROM nginx

COPY *.conf /etc/nginx/conf.d/

RUN mkdir -p /etc/nginx/ssl/ \
 && cd /etc/nginx/ssl/ \
 && openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -subj '/CN=*.hntmonitor.com' -nodes \
 && random=$(openssl rand -base64 18) \
 && sed -i "s%CLIENT_ID%${random}%" /etc/nginx/conf.d/api.conf \
 && echo  "APKY_KEY: ${random}"
