#!/bin/sh

echo -e "\n=== authorizer\n"
(cd authorizer && yarn install && yarn run build)

echo -e "\n=== event_sender\n"
(cd event_sender && yarn install && yarn run build)

echo -e "\n=== event_expander\n"
(cd event_expander && yarn install && yarn run build)

echo -e "\n=== subscription_cleanup\n"
(cd subscription_cleanup && yarn install && yarn run build)
