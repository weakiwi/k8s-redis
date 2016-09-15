FROM redis:3.2.3

COPY bin/run.sh /usr/local/bin/run.sh
COPY config/ /redis/config
RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT [ "bash", "-c" ]

EXPOSE 26379 6379
CMD ["/usr/local/bin/run.sh"]