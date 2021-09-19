FROM nginx

COPY json/ /usr/share/nginx/html/
COPY docker/nginx/test_site.conf /etc/nginx/conf.d/

RUN cp /usr/share/nginx/html/hotspot/info /usr/share/nginx/html/hotspot/index.html \
 && chown -R nginx.nginx /usr/share/nginx/html
