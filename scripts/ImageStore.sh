#!/bin/bash
GITLAB_REGISTRY=gitlab.scsuk.net:5005
docker login "$GITLAB_REGISTRY"
echo '##################################################################'
echo "Pulling external images and storing them locally at $GITLAB_REGISTRY"
echo '------------------------------------'

GITLAB_REGISTRY_PROJECT="$GITLAB_REGISTRY"/scsuk/ext_registry
grep -v ^# ./ImageStore.conf | while read DETAIL ; do
   SUPPLIER=$(echo "$DETAIL" | cut -d '#' -f 1)
   EXTERNAL_IMAGE=$(echo "$DETAIL" | cut -d '#' -f 2)
   EXTERNAL_TAG=$(echo "$DETAIL" | cut -d '#' -f 3)
   INTERNAL_TAG=$(echo "$DETAIL" | cut -d '#' -f 4)
   INTERNAL_TAG=${INTERNAL_TAG:-$EXTERNAL_TAG} # if blank will be same as external tag
   IMAGE_NAME=$(echo "$EXTERNAL_IMAGE" | awk -F/ '{print $NF}')
   echo "PULLING: $EXTERNAL_IMAGE:$EXTERNAL_TAG"
   set -x
   docker pull "$EXTERNAL_IMAGE:$EXTERNAL_TAG"
   set +x
   IMAGE_ID=$(docker image ls "$EXTERNAL_IMAGE:$EXTERNAL_TAG" -q)
   echo "ADD TAG: $GITLAB_REGISTRY_PROJECT/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   set -x
   docker tag $IMAGE_ID "$GITLAB_REGISTRY_PROJECT/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   set +x
   echo "PUSH TO: $GITLAB_REGISTRY_PROJECT/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   set -x
   docker push "$GITLAB_REGISTRY_PROJECT/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   set +x
   echo "Clear down images - tidy up"
   set -x
   docker image remove "$EXTERNAL_IMAGE:$EXTERNAL_TAG"
   docker image remove "$GITLAB_REGISTRY_PROJECT/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   set +x
   echo '------------------------------------'
done 

echo "See: https://gitlab.scsuk.net/scsuk/scs_registry/container_registry"
echo '##################################################################'
