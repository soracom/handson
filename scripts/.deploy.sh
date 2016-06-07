#!/bin/bash
for x in *
do
  aws s3 cp $x s3://soracom-files/ --content-type text/plain --profile web
done
