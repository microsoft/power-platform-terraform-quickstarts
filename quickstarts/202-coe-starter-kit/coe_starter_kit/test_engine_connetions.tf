data "local_file" "test_engine_connections_file" {
  count = fileexists("${path.module}/../PowerApps-TestEngine/bin/Debug/PowerAppsTestEngine/connections.json") ? 1 : 0
  filename = "${path.module}/../PowerApps-TestEngine/bin/Debug/PowerAppsTestEngine/connections.json"
}

locals {
  test_engine_connections_output_json = var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "test_engine" && length(data.local_file.test_engine_connections_file) > 0 ? jsondecode(data.local_file.test_engine_connections_file[0].content) : jsondecode("[]")
  test_engine_connections_map = { for conn in local.test_engine_connections_output_json : conn.Name => conn.Id }
  test_engine_connections_items = join("", [
    for conn in local.all_connections : format(
      "    {\n      \"LogicalName\": \"%s\",\n      \"ConnectionId\": \"%s\",\n      \"ConnectorId\": \"/providers/Microsoft.PowerApps/apis/%s\"\n    },\n",
      conn.logicalName,
      lookup(local.test_engine_connections_map, conn.name, ""),
      conn.name
    )
  ])
  test_engine_connections_trimmed = substr(local.test_engine_connections_items, 0, length(local.test_engine_connections_items) - length(",\n"))
  test_engine_connections_output  = <<EOF
[
${local.test_engine_connections_trimmed}
]
EOF
}