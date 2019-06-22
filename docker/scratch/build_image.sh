# Example docker build command
docker build -t localhost:5000/scsuk.net/scratch:1.0 -f docker/Dockerfile https://gitlab.scsuk.net/rich/scratch.git#master
docker push localhost:5000/scsuk.net/scratch:1.0
