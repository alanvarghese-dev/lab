# PROJECT 1: Dockerized WordPress - Progress Log

## Day 1: Container Setup
**Date:** $(date)
**Time:** $(date +"%H:%M")

### Step 1: Checked Docker Version
```bash
docker --version
Output: Docker version 29.1.2, build 890dcca877

Step 2: Created Project Structure

mkdir -p dockerized-wordpress
cd dockerized-wordpress
mkdir -p nginx mysql wordpress

Step 3: Created docker-compose.yml

File: docker-compose.yml
Content: See attached file

Step 4: Ran Docker Compose

docker-compose up -d

Output:

WARN[0000] ... the attribute `version` is obsolete, it will be ignored
[+] up 2/2
 ✔ Container wordpress_db  Running
 ✔ Container wordpress_app Running

Step 5: Containers Status

docker-compose ps

Step 6: Test WordPress Access

Command: curl -I http://localhost:8080

Browser opened at: http://localhost:8080, test was success!

