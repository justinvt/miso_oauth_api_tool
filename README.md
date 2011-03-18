Setup
========================

Set up the following environment variables on your computer


    export MISO_CONSUMER_KEY="your miso consumer key"

    export MISO_CONSUMER_SECRET="your miso consumer secret"

    export MISO_SITE="url of the miso api you want to test - could be http://localhost:3000 or http://tl.gomiso.com or whatever else"

    export MISO_CALLBACK_URL="http://localhost:4567/oauth/callback"


cd into this repo and run


    ruby app.rb


then navigate to

    http://localhost:4567

in your browser.  Give yourself oauth access, and then you will be taken to the api testing tool.

Fill out the form however you'd like, then click "Submit" in the top right of the browser.

The text field at the top will be populated with the response from the api.

