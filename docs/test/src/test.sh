#! /bin/bash

## This is a ceph test script

## test SIMD

sudo rados bench -p isa 600 write --no-cleanup
sudo rados benxh -p isa 600 seq
sudo rados bench -p isa 600 rand
sudo rados -p isa cleanup

## test without SIMD 

sudo rados bench -p jerasure 600 write --no-cleanup
sudo rados benxh -p jerasure 600 seq
sudo rados bench -p jerasure 600 rand
sudo rados -p jerasure cleanup 
