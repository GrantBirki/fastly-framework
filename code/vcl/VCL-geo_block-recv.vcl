if (table.lookup(geo_block_list, client.geo.country_code)) {
    error 601 "forbidden";
}