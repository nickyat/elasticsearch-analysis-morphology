FROM docker.elastic.co/elasticsearch/elasticsearch:8.4.1
COPY /target/releases/elasticsearch-analysis-morphology-8.4.1.zip /tmp/elasticsearch-analysis-morphology-8.4.1.zip
RUN bin/elasticsearch-plugin install file:/tmp/elasticsearch-analysis-morphology-8.4.1.zip
