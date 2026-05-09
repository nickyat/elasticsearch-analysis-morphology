# elasticsearch-analysis-morphology
Плагин для Elasticsearch 9.4.0, реализующий анализатор для русского и английского языка. Используются словари проекта http://aot.ru
Оригинальный плагин взят отсюда https://github.com/imotov/elasticsearch-analysis-morphology который в свою очередь использует
russian_morphology и english_morphology от проекта Russian Morphology for Apache Lucene https://github.com/AKuznetsov/russianmorphology
Плагин добавляет два analyzer и два token filter: "russian_morphology" и "english_morphology".

# Elasticsearch

При создании индекса указываем настройки с указанием анализатора и создаем на основе настроек маппинг. 
Пример
```
PUT /products
{
    "settings": {
        "index": {
            "analysis": {
                "analyzer": {
                    "product_name_analyzer": {
                        "type": "custom",
                        "tokenizer": "standard",
                        "filter": [
                            "lowercase",
                            "search_synonym",
                            "russian_morphology",
                            "english_morphology",
                            "ru_stopwords"
                        ]
                    }
                },
                "filter": {
                    "search_synonym": {
                        "ignore_case": "true",
                        "type": "synonym",
                        "synonyms": [
                            "bosch,бош"
                        ]
                    },
                    "ru_stopwords": {
                        "type": "stop",
                        "stopwords": "а,без,более,бы,был,была,были,было,быть,в,вам,вас,весь,во,вот,все,всего,всех,вы,где,да,даже,для,до,его,ее,если,есть,еще,же,за,здесь,и,из,или,им,их,к,как,ко,когда,кто,ли,либо,мне,может,мы,на,надо,наш,не,него,нее,нет,ни,них,но,ну,о,об,однако,он,она,они,оно,от,очень,по,под,при,с,со,так,также,такой,там,те,тем,то,того,тоже,той,только,том,ты,у,уже,хотя,чего,чей,чем,что,чтобы,чье,чья,эта,эти,это,я,a,an,and,are,as,at,be,but,by,for,if,in,into,is,it,no,not,of,on,or,such,that,the,their,then,there,these,they,this,to,was,will,with"
                    }
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "name": {
                "type": "text",
                "analyzer": "product_name_analyzer"
            },
            "code": {
                "type": "keyword"
            },
            "description": {
                "type": "text",
                "analyzer": "product_name_analyzer"
            },
            "brand": {
                "type": "keyword"
            }
        }
    }
}
```
# Dockerfile
Образ Elasticsearch 9.4.0 с шагом установки плагина analysis-morphology.

Перед сборкой образа нужно собрать ZIP плагина:

```bash
mvn clean package -Dmaven.test.skip=true
docker build -t analysis-morphology:9.4.0 .
```

# Maven 
Сборка:

```bash
mvn clean package -Dmaven.test.skip=true
```

Готовый архив:

```text
target/releases/elasticsearch-analysis-morphology-9.4.0.zip
```

Установка в существующий кластер:

```bash
bin/elasticsearch-plugin install file:/path/to/elasticsearch-analysis-morphology-9.4.0.zip
```

# Smoke test

После сборки Docker-образа можно проверить установку плагина и работу `_analyze`:

```bash
./scripts/smoke-test.sh
```

Скрипт запускает временный контейнер `analysis-morphology-smoke` на `127.0.0.1:19200`, проверяет наличие плагина в `_nodes/plugins` и выполняет анализ текста через `russian_morphology`.

В Elasticsearch 9.x при установке classic plugin может появляться предупреждение:

```text
WARNING: plugin has a policy file with no additional entitlements. Double check this is intentional.
```

Архив плагина не содержит `plugin-security.policy` или `entitlement-policy.yaml`; предупреждение не блокирует установку.
