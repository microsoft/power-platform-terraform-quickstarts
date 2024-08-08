resource "null_resource" "run_test_engine" {
  count = var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "test_engine" ? 1 : 0

  triggers = {
    //TODO: do we need to run this always when we test a different release?
    //Anyways count and type of connections is hardcoded independent of release
    always_run = local.coe_start_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command     = "dir" //TODO: replace with actual test engine command saving the output to a file ./coe_starter_kit/test_engine_connections.json
    when        = create
    interpreter = ["pwsh", "-Command"]
  }

  provisioner "local-exec" {
    command     = "dir" //TODO remove file 
    when        = destroy
    interpreter = ["pwsh", "-Command"]
  }
}

data "local_file" "test_engine_connections_file" {
  count = var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "test_engine" ? 1 : 0
  filename = "${path.module}/test_engine_connections.json"

  //this may not wait for test engine to finish and create file, need to be tested
  depends_on = [ null_resource.run_test_engine ]
}

locals {
  test_engine_connections_output_json = var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "test_engine"? jsondecode(data.local_file.test_engine_connections_file[0].content) : jsondecode("[]")
  test_engine_connections_items = join("", [
    for conn in local.all_connections : format(
      "    {\n      \"LogicalName\": \"%s\",\n      \"ConnectionId\": \"%s\",\n      \"ConnectorId\": \"/providers/Microsoft.PowerApps/apis/%s\"\n    },\n",
      conn.logicalName,
      (var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "test_engine" ?
      flatten([for test_engine_conn in local.test_engine_connections_output_json : test_engine_conn if conn.name == test_engine_conn.Name])[0].Id : ""),
      conn.name
    )
  ])
  test_engine_connections_trimmed = substr(local.test_engine_connections_items, 0, length(local.test_engine_connections_items) - length(",\n"))
  test_engine_connections_output  = <<EOF
"ConnectionReferences": [
${local.test_engine_connections_trimmed}
]
 EOF
}
