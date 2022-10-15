#!/bin/bash
rm -r function
mkdir function
cp lambda_function.py function

pip install \
    --platform manylinux2014_x86_64 \
    --target=function \
    --implementation cp \
    --python 3.9 \
    --only-binary=:all: --upgrade \
    Pillow
cd function

zip -r ../pixelator-dp.zip .
cd ..
rm -r function
