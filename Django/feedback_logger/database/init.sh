#!/bin/bash
rm -rf /var/lib/postgresql/data/pg_hba.conf.bak > /dev/null 2>&1
cp /var/lib/postgresql/data/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf.bak
echo 'host    all    all    0.0.0.0/0    md5' >> /var/lib/postgresql/data/pg_hba.conf