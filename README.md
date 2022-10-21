# Starburst OCP Demo

Deploy [Starburst Enterprise (SEP)](https://www.starburst.io/platform/starburst-enterprise/) to Openshift. A fork of https://github.com/keklundrh/chatbot-env-setup

## Prerequisites:
- Strimzi Operator (tested on 0.23.0) OR Red Hat Openshift Streams for Apache Kafka
- Starburst Enterprise Helm Operator (tested on 354.0.0-ubi provided by Starburst Data)
- Starburst Hive
- Postgres

### *Namespace and Operator Install*

    ansible-playbook /ansible-install/starburst-prequisites-ansible.yaml

Creates "starburst" namespace and applies Strimzi and Starburst Enterprise subscriptions. Otherwise, install from Openshift Console OperatorHub.

### *Trino CLI Installation*

1. download from https://docs.starburst.io/latest/installation/download.html#clients

2. Assuming _/usr/local/bin_ is on _$PATH_ environment variable:

    cd /usr/local/bin

    cp -p /home/<username>/Download/trino-cli-*-executable.jar .

    mv trino-cli-*-executable.jar trino

    chmod +x trino

3. Validate with _trino --version_ command

### *Install Go (for Postgres Operator Install - skip if you already have Go)*

1. Download from

    https://go.dev/doc/install

2. Add gopath to env:

    export GOPATH=$HOME/go

3. Validate with _go --version_

### *Install Postgres Operator in Starburst Namespace*

1. Clone Operator from Repository:

    git clone git@github.com:dev4devs-com/postgresql-operator.git $GOPATH/src/github.com/dev4devs-com/postgresql-operator

2. Update Role Binding for "Starburst Namespace":
Change the "Namespace" values in the Makefile and deploy/role_binding.yaml to point to your starburst namespace ("starburst" if using the defaults from this setup).

3. Install Operator on Openshift:

    cd $GOPATH/src/github.com/dev4devs-com/postgresql-operator

    make install

## Starburst license
A license, provided by Starburst, yields additional features in the SEP environment. Once receiving your license file from Starburst, you need to create a secret containing the license file and reference the secret in your custom yaml file.

The following [documentation](https://docs.starburst.io/356-e/k8s/sep-config-examples.html?highlight=license#adding-the-license-file) describes the process.

### Red Hat Marketplace Registration for Starburst License
For Starburst licenses purchased through the Red Hat Marketplace, follow the setup instructions to register your cluster with the marketplace (recommended installation procedure with secret generation is on https://marketplace.redhat.com/en-us/workspace/clusters/add/register):

Generate Pull Secret on https://marketplace.redhat.com/en-us/workspace/clusters/add/register. After that, register your cluster:

    oc create namespace openshift-redhat-marketplace

    oc apply -f "https://marketplace.redhat.com/provisioning/v1/rhm-operator/rhm-operator-subscription?approvalStrategy=Automatic"

    oc create secret generic redhat-marketplace-pull-secret -n openshift-redhat-marketplace --from-literal=PULL_SECRET=<pull_secret_key>

    curl -sL https://marketplace.redhat.com/provisioning/v1/scripts/update-global-pull-secret | bash -s <pull_secret_key>

After this, push the Starburst Operator to your cluster from Red Hat Marketplace:

1. Go to Workspace > My Software > Product > Install Operator
2. Under "Operators" click Install Operator
3. Select options (for this setup choose all namespaces)
4. Click Install and monitor progress. The operator should update on your Openshift Console as well.

## Deployment
1. Before getting started, edit the `.env` or create a `.env.local` file to customize your environment: add your cluster details to the environment file.
2. Use `make deploy` to deploy `customer-domain`, `finance-domain`, `kafka` (strimzi), `starburst-enterprise`, and `starburst-hive`.

*Note*: Update starburst-enterprise/deploy.sh to use the starburst-trial.yaml if you do not have a license key

You can deploy items individually using `make deploy-customer`, for example.
3. Once Starburst is up expose a route and validate:

    oc expose svc/starburst
    oc get route | grep starburst
    trino --server <route_url> --catalog tpch

## Trino Querying:

Once connected to the Starburst Server with the Trino CLI (step 3 above), you can run Trino Queries. Full Documentation is available at https://trino.io/docs/current/sql.html

Example Queries for this demo:

_Show Catalogs:_

    trino> SHOW CATALOGS;
        Catalog     
    -----------------
    customer-domain
    datalake        
    finance-domain  
    system          
    tpch            
    (5 rows)

    Query 20221020_174419_00001_fabka, FINISHED, 2 nodes
    Splits: 12 total, 12 done (100.00%)
    36.18 [0 rows, 0B] [0 rows/s, 0B/s]

_Show Schemas:_

    trino> SHOW SCHEMAS FROM tpch;
       Schema       
    --------------------
    information_schema
    sf1                
    sf100              
    sf1000             
    sf10000            
    sf100000           
    sf300              
    sf3000             
    sf30000            
    tiny               
    (10 rows)

    Query 20221020_175325_00006_fabka, FINISHED, 3 nodes
    Splits: 12 total, 12 done (100.00%)
    0.20 [10 rows, 119B] [50 rows/s, 595B/s]

_Show Tables:_

    trino> SHOW TABLES FROM tpch.sf1;
    Table   
    ----------
    customer
    lineitem
    nation   
    orders   
    part     
    partsupp
    region   
    supplier
    (8 rows)

    Query 20221020_175624_00007_fabka, FINISHED, 3 nodes
    Splits: 12 total, 12 done (100.00%)
    0.24 [8 rows, 158B] [33 rows/s, 664B/s]

_Select Queries:_

    trino> SELECT * FROM tpch.sf1.customer LIMIT 3;
    custkey |        name        |                 address                  | nationkey |      phone      | acctbal | mktsegment |                                 
    ---------+--------------------+------------------------------------------+-----------+-----------------+---------+------------+---------------------------------
    37501 | Customer#000037501 | Ftb6T5ImHuJ                              |         2 | 12-397-688-6719 | -324.85 | HOUSEHOLD  | pending ideas use carefully. exp
    37502 | Customer#000037502 | ppCVXCFV,4JJ97IibbcMB5,aPByjYL07vmOLO 3m |        18 | 28-515-931-4624 |  5179.2 | BUILDING   | express deposits. pending, regul
    37503 | Customer#000037503 | Cg60cN3LGIUpLpXn0vRffQl8                 |        13 | 23-977-571-7365 | 1862.32 | BUILDING   | ular deposits. furiously ironic
    (3 rows)


## Issues

### StorageClass Standard Not Found

For Postgres PVC Storageclass errors, apply the "standard" storageclass object under:
_/ansible-install/objects/storageclass-standard.yaml_

### Memory Limits for Starburst Coordinator

For this error:

        pods "coordinator-6d54b88565-9zcmv" is forbidden: [maximum memory usage
        per Container is 6Gi, but limit is 16Gi, maximum cpu usage per Pod is 4,
        but limit is 4500m, maximum memory usage per Pod is 12Gi, but limit is
        17716740096]

Delete the LimitRanges on the namespace
