# Jenkins Pipeline Import Tool

This directory contains tools for importing Jenkins pipeline jobs from this repository into a Jenkins server.

## Prerequisites

### 1. Download Jenkins CLI

Before running the import script, you need to download the Jenkins CLI jar file:

```bash
wget http://YOUR_JENKINS_URL/jnlpJars/jenkins-cli.jar -O pipelines/alpha/jenkins-cli.jar
```

Replace `YOUR_JENKINS_URL` with your actual Jenkins server URL (e.g., `http://localhost:8080` or `https://jenkins.example.com`).

### 2. Create Credentials File

Create a credentials file containing your Jenkins username and API token in the format:

```
username:api_token
```

Example: `~/.jenkins-api-token`

To generate an API token:
1. Log into Jenkins
2. Click your username (top right)
3. Click "Configure"
4. Under "API Token", click "Add new Token"
5. Copy the generated token

## Usage

Run the import script from the repository root:

```bash
bash ./pipelines/alpha/import.sh <credentials_file> [jenkins_url] [folder_name]
```

### Parameters

- `credentials_file` (required): Path to file containing `username:api_token`
- `jenkins_url` (optional): Jenkins server URL (default: `http://localhost:8080/`)
- `folder_name` (optional): Jenkins folder to create jobs in (default: `pipelines`)

### Examples

Basic usage with defaults:
```bash
bash ./pipelines/alpha/import.sh ~/.jenkins-api-token
```

With custom Jenkins URL:
```bash
bash ./pipelines/alpha/import.sh ~/.jenkins-api-token http://jenkins.example.com:8080/
```

With custom folder:
```bash
bash ./pipelines/alpha/import.sh ~/.jenkins-api-token http://localhost:8080/ pipelines/alpha00
```

## Updating the Import Script

### Adding New Pipeline Jobs

1. Edit `import.sh` and add the new Jenkinsfile path to the `FILES` array:

```bash
declare -a FILES=(
    "./pipelines/alpha/Jenkinsfile.aux_all_down"
    "./pipelines/alpha/Jenkinsfile.aux_db_down"
    "./pipelines/alpha/Jenkinsfile.your_new_job"  # Add here
    # ...
)
```

2. Uncomment existing entries or add new ones as needed

### Modifying Job Template

The `scm-job.xml` file defines the Jenkins job configuration template. The script replaces `REPLACE_SCRIPT_PATH` with the actual Jenkinsfile path when creating jobs.

To modify the job template:
1. Edit `scm-job.xml`
2. Keep the `REPLACE_SCRIPT_PATH` placeholder intact
3. Adjust other Jenkins job settings as needed

## Troubleshooting

**Error: Unable to access jarfile jenkins-cli.jar**
- Make sure you've downloaded the Jenkins CLI jar file to `pipelines/alpha/jenkins-cli.jar`

**Error: can't read scm-job.xml**
- Ensure you're running the script from the repository root directory

**Authentication errors**
- Verify your credentials file format is correct: `username:api_token` (single line, no spaces)
- Ensure your API token is valid and hasn't expired
- Check that your user has permissions to create jobs in Jenkins
