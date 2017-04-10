#!/bin/sh

source ./config.sh

function create_dir(){   
    if [[ ! -d $BACKUP_DIR/sites-$type/$a ]]; then
            mkdir $BACKUP_DIR/sites-$type/$a
            mkdir $BACKUP_DIR/sites-$type/$a/$(date +%Y)
    fi

    if [[ ! -d $BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m) ]]; then
                 mkdir $BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)
                 mkdir $BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)/current

    fi
    
    
}

function tar_sites_shared() {
    type="shared"
    create_dir $a $type
    BF=$BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)/current/${a}_shared_$(date +%Y%m%d%h%mn%s).tar.gz        
    tar -c --absolute-names $d/shared/ | gzip > $BF
    echo "========================================="
    echo "SUCCESS: $a /shared sucessfully backed up."
    echo "========================================="
    
    CLEAN_UP=$BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)/current;
    cleanup $CLEAN_UP

}

function tar_sites_mysql() {
    type="mysql"
    create_dir $a $type
    BF=$BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)/current/${a}_sql_$(date +%Y%m%d).bak.gz
    BF=$BACKUP_DIR/sites-$type/$a/$(date +%Y)/$(date +%m)/current/${a}_sql_$(date +%Y%m%d).bak.gz
    mysqldump -u $MYSQL_USER -p$MYSQL_PASS $a | gzip > $BF
    if [[ -f $BF ]]; then
        echo "========================================="
        echo "SUCCESS: $a DB sucessfully backed up."
        echo "========================================="
    else
        echo "========================================="
        echo "ERROR: $a DB cannot be backed up."
        echo "========================================="
    fi
}

function cleanup(){



NEW_DESTINATION=${CLEAN_UP/current/""}

find $CLEAN_UP -mmin +1 -type f -exec echo {} \;  -exec mv {} "$NEW_DESTINATION"  \;

for file in $NEW_DESTINATION* ; do
DAY=$(date -r $file +'%d')

if [[$DAY/7 != '0']]; then
rm $file;
fi
done
}

for d in $SOURCE_DIR* ; do

    a=${d/$SOURCE_DIR/""}
    if [[ -d $d/shared ]]; then
        tar_sites_shared $a
       # tar_sites_mysql $a
    else 
        echo "========================================="
        echo "ERROR: $a cannot be backed up. No /shared dir."
        echo "========================================="
    fi


done