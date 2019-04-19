#!/bin/sh
# Copyright 2017 The Forseti Security Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

forseti config endpoint <cluster ip>:50051

MODEL_NAME=$(/bin/date -u +%Y%m%dT%H%M%S)
echo "Running Forseti inventory."
forseti inventory create --import_as ${MODEL_NAME}
echo "Finished running Forseti inventory."

GET_MODEL_STATUS="forseti model get ${MODEL_NAME} | python -c \"import sys, json; print json.load(sys.stdin)['status']\""
MODEL_STATUS=`eval $GET_MODEL_STATUS`

if [ "$MODEL_STATUS" == "BROKEN" ]
    then
        echo "Model is broken, please contact discuss@forsetisecurity.org for support."
        exit
fi

# Run model command
echo "Using model ${MODEL_NAME} to run scanner"
forseti model use ${MODEL_NAME}
# Sometimes there's a lag between when the model
# successfully saves to the database.
sleep 5s

echo "Forseti config: $(forseti config show)"

# Run scanner command
echo "Running Forseti scanner."
scanner_command=`forseti scanner run`
scanner_index_id=`echo ${scanner_command} | grep -o -P '(?<=(ID: )).*(?=is created)'`
echo "Finished running Forseti scanner."

# Run notifier command
echo "Running Forseti notifier."
forseti notifier run --scanner_index_id ${scanner_index_id}
echo "Finished running Forseti notifier."

# Clean up the model tables
echo "Cleaning up model tables"
forseti model delete ${MODEL_NAME}
