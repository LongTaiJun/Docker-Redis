FROM longtaijun/alpine

ENV REFRESHED_AT 2016-08-22

MAINTAINER from www.svipc.com by tyson (longtaijun@msn.cn)

ENV VERSION=3.2.4
ENV DOWN_URL=http://download.redis.io/releases/redis-${VERSION}.tar.gz \
	SHA256=2ad042c5a6c508223adeb9c91c6b1ae091394b4026f73997281e28914c9369f1 \
	TEMP_DIR=/tmp/redis

RUN set -x && \
	FILE_NAME=${DOWN_URL##*/} && \
	mkdir -p ${TEMP_DIR} /data && cd ${TEMP_DIR} && \
	apk --update --no-cache upgrade && \
# grab su-exec for easy step-down from root
	apk add --no-cache 'su-exec>=0.2' && \
	apk add --no-cache --virtual .build-deps gcc linux-headers make musl-dev tar && \
	addgroup -S redis && adduser -S -h /data/redis -s /sbin/nologin -G redis redis && \
	curl -Lk ${DOWN_URL} |tar xz -C ${TEMP_DIR} --strip-components=1 && \
	#{ while :;do \
	#	curl -Lk ${DOWN_URL} -o ${TEMP_DIR}/${FILE_NAME} && { \
	#		[ "$(sha256sum ${TEMP_DIR}/${FILE_NAME}|awk '{print $1}')" == "${SHA256}" ] && break; \
	#	}; \
	#done; } && \
	#cd ${FILE_NAME%.tar*} && \
	make -C ${TEMP_DIR} && \
	make -C ${TEMP_DIR} install && \
	apk del .build-deps tar gcc make && \
	rm -rf /var/cache/apk/* ${TEMP_DIR}

COPY entrypoint.sh /entrypoint.sh
COPY redis.conf /etc/redis.conf
RUN chmod +x /entrypoint.sh

VOLUME ["/data"]
WORKDIR /data

EXPOSE 6379/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["redis-server"]
