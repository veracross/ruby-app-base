#!/bin/bash

# Install required packages
apt-get update && apt-get install -y gpg wget tar jq libasound2 xvfb unzip  \
    xz-utils libxi6 libgconf-2-4 jq libjq1 libonig5 libxkbcommon0 libxss1 libglib2.0-0 libnss3 libfontconfig1  \
    libatk-bridge2.0-0 libatspi2.0-0 libgtk-3-0 libpango-1.0-0 libgdk-pixbuf2.0-0 libxcomposite1 libxcursor1  \
    libxdamage1 libxtst6 libappindicator3-1 libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libxfixes3 libdbus-1-3  \
    libexpat1 libgcc1 libnspr4 libgbm1 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxext6 \
    libxrandr2 libxrender1 gconf-service ca-certificates fonts-liberation libappindicator1 lsb-release xdg-utils  \
    libu2f-udev

if [ "$CHROME_VERSION" = "latest" ]; then
    # Install Chrome from latest official package
    apt-get update
    curl -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
    apt-get install -f

    # Install ChromeDriver
    CHROMEDRIVER_URL=$( curl https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json | jq '.channels.Stable.downloads.chromedriver | map(select(.platform=="linux64") | .url)' | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sed -e 's|["'\'']||g' )
    curl -o chromedriver-linux64.zip $CHROMEDRIVER_URL
    unzip chromedriver-linux64.zip
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver
    chmod +x /usr/bin/chromedriver

  else

    # Get the Chrome and ChromeDriver 114 download URLs
      echo "fetching chrome and chrome driver download urls for version $CHROME_VERSION..."
      CHROME_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1135561%2Fchrome-linux.zip?generation=1682460989187924&alt=media"
      CHROMEDRIVER_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1135561%2Fchromedriver_linux64.zip?generation=1682460993294765&alt=media"

      # Download Chrome
      echo "downloading chrome..."
      curl --silent --show-error --location --fail --retry 3 --output /tmp/chrome-linux64.zip "$CHROME_URL"
      echo "chrome downloaded."
      echo "extracting chrome..."
      unzip /tmp/chrome-linux64.zip -d /tmp
      mv /tmp/chrome-linux /tmp/chrome
      ln -s /tmp/chrome/chrome /usr/local/bin/google-chrome
      chmod +x /tmp/chrome
      rm /tmp/chrome-linux64.zip

      # Download ChromeDriver
      echo "downloading chrome driver..."
      curl --silent --show-error --location --fail --retry 3 --output /tmp/chromedriver.zip "$CHROMEDRIVER_URL"
      echo "chrome driver downloaded."
      echo "extracting chrome driver..."
      unzip /tmp/chromedriver.zip -d /tmp
      mv /tmp/chromedriver_linux64 /tmp/chromedriver
      ln -s /tmp/chromedriver/chromedriver /usr/local/bin/chromedriver
      chmod +x /tmp/chromedriver
      rm /tmp/chromedriver.zip
fi




