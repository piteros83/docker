docker node ls -q | xargs docker node inspect -f '{{ .ID }} [{{  printf "%25s" .Description.Hostname }}]: {{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}' 
