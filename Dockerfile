FROM nginx:1.19.3-alpine
ENV TZ=Asia/Shanghai
# RUN echo 'nameserver 223.5.5.5'
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache ca-certificates curl unzip # --virtual .build-deps

# v2ray
# RUN rm -rf /tmp/v2ray
WORKDIR /tmp/v2ray
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray && \
    install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray && \
    install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl && \
    rm -rf /tmp/v2ray && \
    install -d /usr/local/etc/v2ray

WORKDIR /tmp/alist
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/alist/alist.tar.gz \
    https://github.com/Xhofe/alist/releases/latest/download/alist-linux-musl-amd64.tar.gz && \
    tar -xf /tmp/alist/alist.tar.gz -C /tmp/alist && \
    install -m 755 /tmp/alist/alist-linux-musl-amd64 /usr/local/bin/alist && \
    rm -rf /tmp/alist && \
    install -d /usr/local/etc/alist


# 放弃zpan使用alist，无法在alpine中使用

# nginx
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY configure.sh /configure.sh
COPY v2ray_config /
RUN chmod +x /configure.sh

WORKDIR /

ENTRYPOINT ["sh", "/configure.sh"]

