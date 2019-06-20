#!/bin/bash
INTERNAL_REGISTRY=localhost:5000
grep -v ^# ./ImageStore.conf | while read DETAIL ; do
   SUPPLIER=$(echo "$DETAIL" | cut -d '#' -f 1)
   EXTERNAL_IMAGE=$(echo "$DETAIL" | cut -d '#' -f 2)
   EXTERNAL_TAG=$(echo "$DETAIL" | cut -d '#' -f 3)
   INTERNAL_TAG=$(echo "$DETAIL" | cut -d '#' -f 4)
   INTERNAL_TAG=${INTERNAL_TAG:-$EXTERNAL_TAG} # if blank will be same as external tag
   IMAGE_NAME=$(echo "$EXTERNAL_IMAGE" | cut -d '/' -f 2 )
   docker pull "$EXTERNAL_IMAGE:$EXTERNAL_TAG"
   IMAGE_ID=$(docker image ls "$EXTERNAL_IMAGE:$EXTERNAL_TAG" -q)
   docker tag $IMAGE_ID "$INTERNAL_REGISTRY/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   docker push "$INTERNAL_REGISTRY/$SUPPLIER/$IMAGE_NAME:$INTERNAL_TAG"
   curl -s "http://$INTERNAL_REGISTRY/v2/$SUPPLIER/$IMAGE_NAME/tags/list" | python -m json.tool
done 

echo '------------------------------------'
echo "List INTERNAL_REGISTRY $INTERNAL_REGISTRY"
curl -s http://"$INTERNAL_REGISTRY"/v2/_catalog | python -m json.tool
