# Clearing data indexes

## Splunk
1. ssh into splunk
1. `/opt/splunk/bin/splunk stop`
1. `/opt/splunk/bin/splunk clean eventdata -index <index>`

## SecurityOnion
1. ssh into SecurityOnion
1. `sudo so-elasticsearch-indices-list`
1. `sudo so-elasticsearch-query <index> -XDELETE`

## Arkime
1. ssh into arkime
1. `/opt/arkime/db/db.pl http://ESHOST:9200 wipe`

## References
* [How do I reset Arkime? ](https://arkime.com/faq#how-do-i-reset-arkime)
* [Managing Indexers and Clusters of Indexers](https://docs.splunk.com/Documentation/Splunk/9.0.4/Indexer/RemovedatafromSplunk)
* [so-elasticsearch-query](https://docs.securityonion.net/en/2.3/so-elasticsearch-query.html)
* []()
* []()
* []()
* []()
* []()
