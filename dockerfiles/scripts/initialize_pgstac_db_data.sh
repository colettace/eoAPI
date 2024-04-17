#!/bin/bash

set -x
# This script is adapted from this repo on github:
# https://github.com/vincentsarago/MAXAR_opendata_to_pgstac

echo "BEGIN INGEST OF STAC ITEMS FOR DEMO"

format_STAC_for_pypgstac_ingest() {

  local catalog_name=$1
  local stac_catalog_url=$2
  local stac_item_collection_url=$3

  echo ""
  echo "Catalog name: $catalog_name"
  echo "downloading STAC catalog JSON file from URL: $stac_catalog_url"

  curl -o temp_catalog.json $stac_catalog_url
  pypgstac load collections temp_catalog.json --dsn postgresql://$POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST:5439/$POSTGRES_DBNAME --method insert_ignore debug=True

  echo "downloading STAC item_collection JSON file from URL: $stac_item_collection_url"
  curl -o temp_item_collection.json $stac_item_collection_url

  jq '.features' temp_item_collection.json > temp_item_collection_FORMATTED.json
  jq 'map(. + {"collection": "$catalog_name"})' temp_item_collection.json > temp_item_collection_FORMATTED.json
  pypgstac load items temp_item_collection_FORMATTED.json --dsn postgresql://$POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST:5439/$POSTGRES_DBNAME
}

name="EXTERNAL NODE: NOAA Coastal LIDAR STAC Catalog"
url1="https://noaa-nos-coastal-lidar-pds.s3.amazonaws.com/entwine/stac/catalog.json"
url2="https://noaa-nos-coastal-lidar-pds.s3.amazonaws.com/entwine/stac/noaa_item_collection.json"
format_STAC_for_pypgstac_ingest "$name" "$url1" "$url2"


# Don't load NOAA DEMS for now

#name="EXTERNAL NODE: NOAA NCEI CUDEM Ninth Arcsecond Topobathy"
#url1="https://noaa-nos-coastal-lidar-pds.s3.amazonaws.com/dem/NCEI_ninth_Topobathy_2014_8483/stac/catalog.json"
#url2="https://noaa-nos-coastal-lidar-pds.s3.amazonaws.com/dem/NCEI_ninth_Topobathy_2014_8483/stac/noaa_dem_collection_m8483.json"
#format_STAC_for_pypgstac_ingest "$name" "$url1" "$url2"
