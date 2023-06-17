#!/bin/bash

pandoc -f json blend-assen.json --lua-filter convert-to-dict.lua > metadata.json
