This is a reworking of the Apache Metrics Sensu plugin available
here: https://github.com/sensu/sensu-community-plugins/blob/master/plugins/apache/apache-metrics.rb

It calls a restful interface and sends any metrics returned (in JSON) to graphite via sensu.

It assumes all values returned are integers.
