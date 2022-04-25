FROM docker.elastic.co/elasticsearch/elasticsearch:8.1.3
COPY /target/releases/elasticsearch-analysis-morphology-8.1.3.zip /tmp/elasticsearch-analysis-morphology-8.1.3.zip
RUN bin/elasticsearch-plugin install file:/tmp/elasticsearch-analysis-morphology-8.1.3.zip
