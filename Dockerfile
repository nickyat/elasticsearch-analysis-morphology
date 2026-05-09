FROM docker.elastic.co/elasticsearch/elasticsearch:9.4.0
COPY /target/releases/elasticsearch-analysis-morphology-9.4.0.zip /tmp/elasticsearch-analysis-morphology-9.4.0.zip
RUN bin/elasticsearch-plugin install file:/tmp/elasticsearch-analysis-morphology-9.4.0.zip
