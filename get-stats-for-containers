# Get ids:
docker container ls | grep[name] | awk '{print $1}' | tr '\n' ' '

# Get stats
docker stats --all --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"  [container_ids] | xargs echo > node_usage_[name]
