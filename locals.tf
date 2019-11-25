locals {
  mysql_flavor = "mysql"
  postgres_flavor = "postgres"
  db_environment_variables = [{
    name = "MYSQL_RANDOM_ROOT_PASSWORD"
    value = "yes"
    flavor = local.mysql_flavor
  },
  {
    name = "PGDATA"
    value = "/var/lib/postgresql/data/pgdata"
    flavor = local.postgres_flavor
  }]
  db_ports = [{
    port = 3306
    name = "mysql"
    flavor = local.mysql_flavor
  },{
    port = 5432
    name = "postgresql"
    flavor = local.postgres_flavor
  }]
  db_mounts = [{
    mount_path = "/var/lib/mysql"
    name = "notary-data"
    flavor = local.mysql_flavor
  },
  {
    mount_path = "/var/lib/postgresql/data/pgdata"
    name = "notary-data"
    flavor = local.postgres_flavor
  }]
  db_container_args = [{
    args = [
      "mysqld",
      "--innodb_file_per_table",
    ]
    flavor = local.mysql_flavor
  },
  {
    args = []
    flavor = local.postgres_flavor
  }]
}