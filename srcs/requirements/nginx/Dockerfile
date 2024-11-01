FROM debian:bullseye

EXPOSE 80
EXPOSE 443

RUN apt update && apt install -y --no-install-recommends --no-install-suggests \
    nginx \
    openssl && \
    rm -rf /var/lib/apt/lists/*

ARG CERT_FOLDER CERTIFICATE KEY COUNTRY STATE LOCALITY ORGANIZATION UNIT COMMON_NAME

RUN mkdir -p ${CERT_FOLDER} && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -out ${CERTIFICATE} \
    -keyout ${KEY} \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=${COMMON_NAME}"

COPY conf/nginx.conf /etc/nginx/
COPY conf/server.conf /etc/nginx/conf.d/
COPY static-site/ /var/www/static-site/

RUN mkdir -p /var/www/
RUN chown -R www-data:www-data /var/www/

CMD ["nginx", "-g", "daemon off;"]

