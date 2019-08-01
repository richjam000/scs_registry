docker volume create scs_registry_data

docker run -d --name=scs_registry --restart=always \
-p 5000:5000 \
--volume scs_registry_data:/var/lib/registry \
localhost:5000/docker.io/registry:2
