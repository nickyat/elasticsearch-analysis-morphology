FROM elasticsearch:7.16.3
COPY ./target/elasticsearch-analysis-morphology-7.16.3.zip /tmp/elasticsearch-analysis-morphology-7.16.3.zip
RUN bin/elasticsearch-plugin install file:/tmp/elasticsearch-analysis-morphology-7.16.3.zip
