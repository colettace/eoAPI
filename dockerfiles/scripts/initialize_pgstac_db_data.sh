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

  if [[ -d "$catalog_name" ]]; then
    echo "The directory \"$catalog_name\" already exists."
  else
    echo "Creating directory \"$catalog_name\"."
    mkdir "$catalog_name"
  fi

  echo "downloading STAC catalog JSON file from URL: $stac_catalog_url"
  stac_json_filepath="$catalog_name/temp_catalog.json"
  modified_stac_json_filepath="$catalog_name/temp_catalog_modified.json"
  curl -C - -o "$stac_json_filepath" $stac_catalog_url

  # rename Catalog in catalog file
  old_catalog_name=$(jq ".id" "$stac_json_filepath")

  # FIXME: ADD "last Synced on this tatetime todescription"
  #
  # FIXME: dummyproof this script to check if the regular expression
  # delimiter I use herer '/' is itself in either string
  sed "s/$old_catalog_name/\"$catalog_name\"/" < "$stac_json_filepath" > "$modified_stac_json_filepath"
  #pypgstac load collections "modified_stac_json_filepath" --dsn postgresql://$POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST:5439/$POSTGRES_DBNAME --method insert_ignore debug=True

  echo "downloading STAC item_collection JSON file from URL: $stac_item_collection_url"
  stac_json_filepath="$catalog_name/temp_item_collection.json"
  modified_stac_json_filepath="$catalog_name/temp_item_collection_modified.json"
  curl -C - -o "$stac_json_filepath" $stac_item_collection_url

  # Rename Catalog in ItemCollection file
  #sed 's/$old_catalog_name/"$catalog_name"/' < "$stac_json_filepath" > "$modified_stac_json_filepath"
  jq ".features | map(. + {\"collection\": \"$catalog_name\"})" \
    "$stac_json_filepath" > "$modified_stac_json_filepath"

  #pypgstac load items "$modified_stac_json_filepath" --dsn postgresql://$POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST:5439/$POSTGRES_DBNAME
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
