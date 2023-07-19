#!/bin/bash

#must be run from the project root directory
cp ./spec/fixtures/sms/sample_message.txt ./sftp/sms/FulSomeFile.txt
rm -f ./sftp/sms/processed/*.txt
