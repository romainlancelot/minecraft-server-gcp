<h1>Minecraft Server on Google Cloud (GCP) with Terraform</h1>

This repository contains Terraform configurations to deploy a fully functional Minecraft server on Google Cloud Platform (GCP).

The infrastructure is designed to be cost-effective and flexible:

- **Persistent Storage:** Your world data is stored on a separate Persistent Disk. You can destroy the server VM to save costs when not playing, without losing your world.
- **Dockerized:** Uses the popular [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) Docker image.
- **Configurable:** Easily change Minecraft version, RAM, server type (Vanilla, Spigot, Paper, etc.) via Terraform variables.

<h2>Table of Contents</h2>

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup Guide](#setup-guide)
  - [1. Enable GCP APIs](#1-enable-gcp-apis)
  - [2. Authentication](#2-authentication)
  - [3. Configure Backend](#3-configure-backend)
  - [4. Configure Variables](#4-configure-variables)
  - [5. Deploy the Persistent Storage](#5-deploy-the-persistent-storage)
  - [6. Deploy the Server](#6-deploy-the-server)
  - [7. Connect](#7-connect)
- [Managing the Server](#managing-the-server)
  - [Save Money (Stop the Server)](#save-money-stop-the-server)
  - [Restart / Update](#restart--update)
  - [Delete Everything (Cleanup)](#delete-everything-cleanup)
- [Backup and Restore](#backup-and-restore)
  - [Backup](#backup)
  - [Restore](#restore)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Author](#author)

## Architecture

The project is split into two Terraform states:

1. **`01_persistent`**: Creates the Persistent Disk (PD) and a static IP (optional, depending on config). This state is meant to be kept alive.
2. **`02_server`**: Creates the Compute Engine VM, firewall rules, and attaches the existing disk. This state can be destroyed and recreated at will.

## Prerequisites

- A Google Cloud Platform (GCP) Project.
- [Terraform](https://www.terraform.io/downloads.html) installed.
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) installed.

## Setup Guide

### 1. Enable GCP APIs

Before running Terraform on a fresh GCP project, ensure the required APIs (`compute.googleapis.com`, `storage.googleapis.com`, `iam.googleapis.com`, etc.) are enabled:

- **Quick script (Recommended):**
  ```bash
  cd scripts
  ./enable_apis.sh
  ```
- **Or with Terraform `00_apis`:**
  ```bash
  cd terraform/00_apis
  terraform init
  terraform apply
  ```

### 2. Authentication

Authenticate Terraform with your GCP account:

```bash
gcloud auth application-default login
```

### 3. Configure Backend

Before running Terraform, you must configure where the state file is stored.

1. Open `terraform/00_apis/provider.tf`, `terraform/01_persistent/provider.tf`, and `terraform/02_server/provider.tf`.
2. Change the `bucket` value to a **unique name** (e.g., `yourname-minecraft-tfstate`). Bucket names must be globally unique across all of Google Cloud.

### 4. Configure Variables

1. Copy the example variable files and create symbolic links:

   ```bash
   mv terraform/terraform.tfvars.example terraform/terraform.tfvars
   ln -s ../terraform.tfvars terraform/00_apis/terraform.tfvars
   ln -s ../terraform.tfvars terraform/01_persistent/terraform.tfvars
   ln -s ../terraform.tfvars terraform/02_server/terraform.tfvars
   ```

2. Edit `terraform.tfvars` in the root `terraform` directory with your specific values (Project ID, Region, etc.).

**Key Variables:**

| Variable                 | Description                                      | Default                                       |
| :----------------------- | :----------------------------------------------- | :-------------------------------------------- |
| `project_id`             | **Required.** Your GCP Project ID.               | -                                             |
| `region` / `zone`        | GCP Region and Zone.                             | `europe-west9` / `europe-west9-b`             |
| `machine_type`           | VM size (e.g., `e2-medium`, `e2-standard-2`).    | `e2-medium`                                   |
| `minecraft_disk_size`    | Size of the Persistent Disk (in GB).             | `20`                                          |
| `minecraft_image`        | Docker image to use for the server.              | `itzg/minecraft-server:java25`                |
| `minecraft_version`      | Minecraft version (e.g., `1.20.4`, `LATEST`).    | `LATEST`                                      |
| `minecraft_type`         | Server type (`VANILLA`, `PAPER`, `FORGE`...).    | `VANILLA`                                     |
| `minecraft_memory`       | RAM allocated to Java (e.g., `2G`, `4G`).        | `2G`                                          |
| `minecraft_difficulty`   | Game difficulty (`peaceful`, `easy`, etc.).      | `normal`                                      |
| `minecraft_motd`         | Message of the Day.                              | `Minecraft Server on GCP`                     |
| `minecraft_icon`         | URL to server icon.                              | `https://www.gstatic.com/cgc/super_cloud.png` |
| `minecraft_ops`          | List of OP players (comma-separated).            | `""`                                          |
| `modrinth_projects`      | List of Modrinth projects (slugs/IDs) to install | `""`                                          |
| `voice_chat_port`        | UDP port for Simple Voice Chat plugin            | `24454`                                       |
| `minecraft_max_players`  | Maximum number of players allowed.               | `10`                                          |
| `minecraft_enable_rcon`  | Enable RCON for remote server management.        | `true`                                        |
| `enforce_secure_profile` | Require Mojang-signed public key for chat.       | `false`                                       |
| `use_spot_instance`      | Use Spot VM (cheaper but can be stopped by GCP)  | `false`                                       |
| `enable_static_ip`       | Enable static IP address creation and usage      | `true`                                        |
| `enable_scheduler`       | Enable automatic start/stop scheduler            | `false`                                       |
| `scheduler_start_time`   | Cron schedule for starting the server            | `0 8 * * *` (8 AM)                            |
| `scheduler_stop_time`    | Cron schedule for stopping the server            | `0 23 * * *` (11 PM)                          |
| `scheduler_timezone`     | Timezone for the scheduler                       | `Europe/Paris`                                |

### 5. Deploy the Persistent Storage

First, create the disk that will hold your data.

```bash
cd terraform/01_persistent
terraform init
terraform apply
```

> Review the plan and type `yes` to confirm.

### 6. Deploy the Server

Once the disk is created, deploy the server VM.

```bash
cd ../02_server
terraform init
terraform apply
```

> Review the plan and type `yes` to confirm.

### 7. Connect

After the deployment of `02_server` is complete, Terraform will output the public IP address of your server.

Copy this IP into your Minecraft client to connect.

## Managing the Server

### Save Money (Stop the Server)

To stop paying for the Compute Engine VM when you are not playing:

```bash
cd terraform/02_server
terraform destroy
```

**Note:** This **only** destroys the VM. Your data (world, inventory, etc.) is safe on the Persistent Disk created in step 3.

### Restart / Update

To restart the server (e.g., to update the Minecraft version after changing `minecraft_version` variable):

1. Run `terraform destroy` in `02_server`.
2. Run `terraform apply` in `02_server`.

### Delete Everything (Cleanup)

If you want to delete everything permanently (including your world data):

1. Destroy the server:

   ```bash
   cd terraform/02_server
   terraform destroy
   ```

2. Destroy the disk:

   ```bash
   cd ../01_persistent
   terraform destroy
   ```

## Backup and Restore

### Backup

You can back up your Minecraft world data by running the provided backup script. This script creates a compressed archive of your world data and saves it locally.

```sh
cd scripts
./backup_world.sh
```

### Restore

To restore a previously backed up world onto an existing or newly deployed server:

```sh
cd scripts
./restore_world.sh [path_to_backup.tar.gz]
```

If no backup path is provided, the script will automatically list existing backups and prompt you to choose one.

> To use the scripts, ensure you have `gcloud` installed and authenticated, and that your `gcloud` project and zone match your deployment.

## Troubleshooting

- **Permissions Error:** If you see an error about `iam.serviceAccountUser`, ensure your current user or the service account running Terraform has the `Service Account User` role.
- **Disk not found:** Ensure you have successfully applied `01_persistent` before trying to apply `02_server`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Romain Lancelot - [GitHub](github.com/romain-lancelot)
