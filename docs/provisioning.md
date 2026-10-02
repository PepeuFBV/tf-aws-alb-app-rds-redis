# Provisioning and Deployment Runbook

This runbook provisions the AWS network and EC2 infrastructure with Terraform, deploys PostgreSQL and Redis as Docker Compose services on private EC2 instances, and deploys the web application to two public EC2 instances behind an Application Load Balancer.

The repository name includes “RDS” and “Redis”, but this configuration does **not** create Amazon RDS or ElastiCache resources. PostgreSQL and Redis run as containers on EC2.

Run commands from the repository root inside the devcontainer unless a step says otherwise. The resource creation steps can incur AWS charges. Review the complete Terraform plan before applying it.

## 1. Prepare the devcontainer and AWS credentials

Rebuild or reopen the devcontainer. Confirm the required tools:

```bash
terraform version
aws --version
docker --version
docker compose version
```

For standard AWS access keys, configure the default profile:

```bash
aws configure
```

Enter the Access Key ID and Secret Access Key when prompted. Set:

```text
Default region name: us-east-1
Default output format: json
```

For AWS Learner Lab or other temporary credentials, use the repository helper instead. It prompts for the Access Key ID, Secret Access Key, and Session Token, hides the secret values, writes the default profile, sets `us-east-1`, and validates the session with STS:

```bash
./scripts/aws-login.sh
```

To paste the complete AWS credentials block, use:

```bash
./scripts/aws-login.sh --paste
```

Paste the `[default]` block and press Ctrl-D. The helper also accepts a block piped on standard input. Do not put credentials in shell commands or commit AWS config files. They persist in the devcontainer's `.aws` volume. Re-run the helper when temporary credentials expire.

Verify the active identity before running Terraform:

```bash
aws sts get-caller-identity
```

Stop if this fails. The result should contain `UserId`, `Account`, and `Arn`. Confirm the account and role are the intended AWS environment.

## 2. Create or confirm the project SSH key

Terraform registers the public key as an EC2 key pair. The deployment script uses the matching private key to connect to the Jump Host and instances.

Create the key only if it does not already exist; do not overwrite a key currently used by EC2. If `~/.ssh/id_ed25519` or its `.pub` file already exists, inspect and reuse it instead of running `ssh-keygen` again.

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 \
  -f ~/.ssh/id_ed25519 \
  -C "tf-aws-alb-app-rds-redis"
```

For this lab, an empty passphrase avoids interactive prompts from the deployment script. Confirm the key files and inspect the **public** key:

```bash
ls -la ~/.ssh
cat ~/.ssh/id_ed25519.pub
```

The files should include `id_ed25519` and `id_ed25519.pub`. Never put the private `id_ed25519` file in Terraform variables, source control, or deployment output.

The GitHub SSH agent forwarded into the devcontainer is for Git access. Terraform/`deploy-service.sh` use the project key at `~/.ssh/id_ed25519` for EC2 access.

## 3. Set the administrator CIDR

Get the public IPv4 address from the network you will use for SSH administration:

```bash
curl -fsS https://checkip.amazonaws.com
```

Append `/32` to the returned address. For example, `200.100.50.25` becomes `200.100.50.25/32`, allowing SSH to the Jump Host only from that address. Recheck this value if your public IP or VPN changes.

## 4. Create the local Terraform variables file

Create `terraform/terraform.tfvars` locally. The `terraform/.gitignore` rules ignore `*.tfvars` while retaining `*.tfvars.example`.

```hcl
ssh_public_key = "ssh-ed25519 AAAA... tf-aws-alb-app-rds-redis"
admin_cidr     = "200.100.50.25/32"
```

Replace the key with the complete output of `cat ~/.ssh/id_ed25519.pub` and replace the CIDR with your current address. Do not use the private key here.

Restrict file permissions and confirm it is ignored:

```bash
chmod 600 terraform/terraform.tfvars
git status --short terraform/terraform.tfvars
git check-ignore -v terraform/terraform.tfvars
```

The status command should print nothing; `git check-ignore` should identify the `terraform/.gitignore` rule.

## 5. Initialize, validate, and plan

From the repository root:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

`init`, formatting, and validation do not create AWS infrastructure. `plan` resolves AWS-backed data sources, including the available Availability Zones and the latest matching Ubuntu 24.04 AMI, and reads AWS state. It does not create the planned resources.

Review that the plan uses the intended AWS account and `us-east-1`, the current `admin_cidr`, and the expected Ubuntu AMI. For a new deployment, expect creations without changes or destruction. The configuration currently defines:

- 2 VPCs and 5 subnets
- 2 Internet Gateways, 1 NAT Gateway, and 1 Elastic IP
- 1 VPC peering connection
- Route tables, routes, and subnet associations for both VPCs and the peering connection
- 5 EC2 instances: 2 application instances, PostgreSQL, Redis, and the Jump Host
- 1 EC2 key pair
- 1 Application Load Balancer, 1 target group, 1 HTTP listener, and 2 target attachments
- 5 Security Groups and separately managed ingress/egress rules

Terraform models routes, associations, and Security Group rules as individual resources, so the action count is higher than the headline infrastructure counts.

## 6. Apply only after reviewing a successful plan

Once the plan completes successfully and its resource changes, account, region, network ranges, instance types, and administrator CIDR have been reviewed:

```bash
terraform -chdir=terraform apply
```

Review the plan shown by `apply` and type `yes` only when it matches the reviewed plan. Do not use `-auto-approve` for this first deployment.

The infrastructure includes a NAT Gateway, an Application Load Balancer, and five EC2 instances; these can incur ongoing charges. The EC2 user-data script installs Docker and Docker Compose and creates `/opt/app`, `/opt/postgres`, or `/opt/redis`. Wait for instance initialization before deploying services.

When apply completes, inspect the outputs:

```bash
terraform -chdir=terraform output
```

Important outputs used below are `jump_host_public_ip`, `postgres_private_ip`, `redis_private_ip`, `application_instance_a_private_ip`, `application_instance_b_private_ip`, and `application_load_balancer_dns`.

## 7. Configure service environments

Create local environment files from the examples:

```bash
cp services/postgres/.env.example services/postgres/.env
cp services/redis/.env.example services/redis/.env
cp services/app/.env.example services/app/.env
chmod 600 services/postgres/.env services/redis/.env services/app/.env
```

Edit the files locally. Do not commit them. The `services/.gitignore` excludes service `.env` files.

Set these values consistently:

- `services/postgres/.env`: choose a strong `POSTGRES_PASSWORD`; the default database and user are `mural` and `mural_user`.
- `services/redis/.env`: choose a strong `REDIS_PASSWORD`.
- `services/app/.env`: set `DB_HOST` to `terraform -chdir=terraform output -raw postgres_private_ip`, `REDIS_HOST` to `terraform -chdir=terraform output -raw redis_private_ip`, and use the same database name, user, and passwords as the service files. The default ports are PostgreSQL `5432` and Redis `6379`.

The deploy script transfers each service directory, including its `.env`, to the matching EC2 host. Treat the remote files as secrets and do not include `.env` contents in logs or support requests.

## 8. Deploy PostgreSQL, Redis, and the application

Confirm the project private key exists at `~/.ssh/id_ed25519` and matches the public key in `terraform/terraform.tfvars`. The script defaults to SSH user `ubuntu`, reads Terraform outputs, and connects to private hosts through the Jump Host.

Deploy all services in dependency order:

```bash
./scripts/deploy-service.sh all
```

The script deploys PostgreSQL first, Redis second, then the application to each of its two instances. It validates required environment values, copies the service files over SSH, checks `docker compose config`, then runs `docker compose up -d --build` remotely.

You can deploy one layer at a time if needed:

```bash
./scripts/deploy-service.sh postgres
./scripts/deploy-service.sh redis
./scripts/deploy-service.sh app
```

## 9. Verify the deployment

Request the application health endpoint through the load balancer:

```bash
curl --fail --show-error \
  "http://$(terraform -chdir=terraform output -raw application_load_balancer_dns)/health"
```

The target group health check also uses `/health` and expects HTTP `200`. The current ALB listener is HTTP on port `80`; TLS/HTTPS is not configured by this Terraform code.

If the check fails, inspect the EC2 user-data result and Docker Compose status on the relevant host through the Jump Host. Check service `.env` values and confirm PostgreSQL/Redis are deployed before the app. Do not expose passwords while collecting diagnostics.

## 10. Open the application in a web browser

After the health check succeeds, get the public Application Load Balancer address:

```bash
terraform -chdir=terraform output -raw application_load_balancer_dns
```

Open `http://<application-load-balancer-dns>` in a browser, replacing the placeholder with that command's output. The listener currently accepts HTTP on port `80`; HTTPS is not configured. You can also print the complete URL with:

```bash
printf 'http://%s\n' "$(terraform -chdir=terraform output -raw application_load_balancer_dns)"
```

The application root route reads messages from PostgreSQL and renders `services/app/templates/index.html`, which is included in the repository. The `/health` endpoint returns JSON with PostgreSQL and Redis status fields, but its HTTP status is `200` even when either dependency is offline; check those fields as well as the ALB target health.

## 11. Tear down when the lab is finished

Back up any data you need first. PostgreSQL and Redis data are stored in Docker named volumes on their EC2 hosts; destroying the EC2 infrastructure deletes those hosts and their local data.

When you intend to remove the entire deployment:

```bash
terraform -chdir=terraform destroy
```

Review the destroy plan and confirm only the intended project resources will be removed. Do not delete AWS resources manually while expecting Terraform state to remain accurate.
