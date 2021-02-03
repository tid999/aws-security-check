# aws-security-check
This is a program for AWS service security baseline audit.
It just only audit/check, DO NOT make any chage

-------
Download & Execute:
1. Download:
    - wget https://github.com/tid999/aws-security-check/archive/master.zip
    - unzip master.zip
    - cd aws-security-check-master
    - chmod +x ./check.sh rules/*.sh
2. Setup environment：
    - AWS CLI latest version 1 or 2
    - setup aws configure
    - sudo yum install -y jq
3. Execute script:
	  - Audit all regions resource: ./check.sh
    - Audit a specific region resource: ./check.sh us-east-1

------
Check Rules:
- World-readable S3 buckets (O)
- World-writable S3 buckets (O)
- SQS Queues with policies that allow public access (O)
- SNS Topics with policies that allow public access (O)
- KMS keys with policies that allow public access (O)
- Glacier vaults with policies that allow public access (O)
- Lambda function is world accessible (O)
- Elasticsearch Service domain with publicly open policy (O)
- Usage of paravirtualized EC2 instance types (O)
- IAM role allows assumption by external account
- Route 53 alias points to non-existent resource (O)
- CloudFront distribution points to non-existent origin
- Accounts found with public EBS snapshot(s) (O)
- Accounts found with public RDS snapshot(s) (O)
- Accounts found with public RDS cluster snapshots(s) (O)
- Instances running public AMIs that are not owned by Amazon
- Hadoop YARN exposed to the Internet
- Databases (Redshift, RDS, Oracle, or mysql on EC2 instance) open to the Internet
- Memcached server accessible from Internet
- Rsync server exposed
- Telnet server exposed
- RDP server exposed to the Internet
- SSH on EC2 instance open to Internet
- MongoDB open to our scanner
- redis open to our scanner
- Elasticsearch (EC2) open to our scanner
- External endpoint with Heartbleed on 443 or 8443
- Unauthed Jenkins server open to our scanner
- Outdated Jenkins server exposed to Internet
- FTP server open to our scanner
- VNC open to our scanner
- Open web proxy server
- External endpoint uses deprecated SSL cipher suites or protocols
- VNC server accessible from Internet
- Recursive DNS server accessible from Internet
- Log4J Socket Hub server on internal fabric
- Hadoop HDFS REST API exposed to the Internet
- Redis open to the world
- Jupyter Notebook exposed to the Internet
- CouchDB on EC2 is exposed to the Internet
- SMB server exposed to public Internet

------
Some tips:
- For global service check rule, please name the script file beginning with '_'. For example, _s3_bucket_public_access.sh
