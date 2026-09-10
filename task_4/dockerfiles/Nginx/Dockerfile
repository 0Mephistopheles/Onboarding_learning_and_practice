FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends nginx && rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/sites-enabled/default

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY html/ /var/www/html/

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]